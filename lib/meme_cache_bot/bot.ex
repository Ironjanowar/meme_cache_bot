defmodule MemeCacheBot.Bot do
  @bot :meme_cache_bot

  require Logger

  use ExGram.Bot,
    name: @bot

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(MemeCacheBot.Middlewares.RegisterUser)

  alias MemeCacheBot.MessageFormatter
  alias MemeCacheBot.Steps
  alias MemeCacheBot.MemeManager
  alias MemeCacheBot.Model.Meme
  alias MemeCacheBot.Utils

  def bot(), do: @bot

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
         {:ok, step} <- Steps.extract_step(user_id),
         {:ok, _} <-
           MemeManager.manage_meme(user_id, meme_id, meme_unique_id, meme_type, step) do
      Logger.debug("""
      Meme detected ->
        Type: #{inspect(meme_type)}
        User: #{inspect(user_id)}
        Meme ID: #{inspect(meme_id)}
        Meme Unique ID: #{inspect(meme_unique_id)}
        Action done: #{inspect(step)}
      """)

      answer(context, "Meme #{Atom.to_string(step)}d!")
    else
      {:error, :already_cached} ->
        answer(context, "That meme was already cached!")

      {:error, :no_step} ->
        answer(context, "What do you mean? Do you want to /cache or /delete a meme?")

      {:error, :could_not_cache} ->
        answer(context, "Sorry I could not save your meme :(")

      {:error, :could_not_delete} ->
        answer(context, "Sorry I could not delete your meme :(")

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
    with {:ok, memes} <- Meme.get_memes_by_user(user_id),
         articles =
           Enum.map(memes, &MessageFormatter.get_inline_result/1)
           |> Enum.filter(&(&1 !== :invalid_meme)) do
      answer_inline_query(context, articles)
    else
      err -> Logger.error("Error while getting memes #{err}")
    end
  end

  def handle(_, _), do: :ignore
  def handle(_), do: :ignore
end
