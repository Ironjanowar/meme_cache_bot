defmodule MemeCacheBot.Bot do
  @bot :meme_cache_bot

  require Logger

  use ExGram.Bot,
    name: @bot

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(MemeCacheBot.Middlewares.RegisterUser)

  alias MemeCacheBot.MemeManager
  alias MemeCacheBot.MessageFormatter
  alias MemeCacheBot.Model.Meme
  alias MemeCacheBot.Steps
  alias MemeCacheBot.Utils

  def bot, do: @bot

  def handle({:command, "start", _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, "cache", %{from: %{id: user_id}}}, context) do
    Steps.add_step(user_id, :cache)
    answer(context, "Which meme do you want to cache?")
  end

  def handle({:command, "delete", %{from: %{id: user_id}}}, context) do
    Steps.add_step(user_id, :delete)
    answer(context, "Which meme do you want to delete?")
  end

  def handle({:message, %{from: %{id: user_id}} = message}, context) do
    with {:ok, meme_id, meme_unique_id, meme_type} <- Utils.get_meme_from_message(message),
         {{:ok, %Meme{}}, meme_info} <-
           {Meme.get_meme_by_user_and_id(user_id, meme_unique_id),
            %{
              user_id: user_id,
              meme_id: meme_id,
              meme_unique_id: meme_unique_id,
              meme_type: meme_type
            }} do
      Steps.add_step(user_id, meme_info)
      markup = Utils.generate_buttons(user_id, :delete)

      answer(context, "You already have that meme saved, do you want to delete it?",
        reply_markup: markup
      )
    else
      {{:ok, nil}, meme_info} ->
        Steps.add_step(user_id, meme_info)
        markup = Utils.generate_buttons(user_id, :cache)

        answer(context, "Do you want to save this meme?", reply_markup: markup)

      {:error, :no_meme, message} ->
        Logger.error("""
        Unrecognized meme on message:
          Message: #{inspect(message)}
        """)

        answer(context, "Sorry I don't recognize that as a meme :(")

      error ->
        Logger.error("""
        Error while processing a message ->
          Error: #{inspect(error)}
          Message: #{inspect(message)}
        """)

        answer(context, "Sorry there was an error")
    end
  end

  def handle({:message, m}, _context) do
    Logger.debug("Could not extract a user from this message: #{inspect(m)}")
  end

  def handle({:inline_query, %{query: _text, from: %{id: user_id}}}, context) do
    case Meme.get_memes_by_user(user_id) do
      {:ok, memes} ->
        articles =
          Enum.map(memes, &MessageFormatter.get_inline_result/1)
          |> Enum.filter(&(&1 !== :invalid_meme))

        answer_inline_query(context, articles, is_personal: true)

      err ->
        Logger.error("Error while getting memes #{err}")
    end
  end

  def handle({:callback_query, %{data: data} = message}, context) do
    Logger.debug("message: #{inspect(message)}")

    with [action, user_id] <- String.split(data, ":"),
         {:ok, meme_info} <- Steps.extract_step(user_id),
         {:ok, _} <- MemeManager.manage_meme(meme_info, action) do
      edit(context, :inline, "Meme #{action}d!")
    else
      {:error, :already_cached} ->
        edit(context, :inline, "That meme was already cached!")

      {:error, :could_not_cache} ->
        edit(context, :inline, "Sorry I could not save your meme :(")

      {:error, :could_not_delete} ->
        edit(context, :inline, "Sorry I could not delete your meme :(")

      error ->
        Logger.error("""
        Error while processing a callback query ->
          Error: #{inspect(error)}
          Message: #{inspect(message)}
        """)

        edit(context, :inline, "Sorry there was an error")
    end
  end

  def handle(_, _), do: :ignore
  def handle(_), do: :ignore
end
