defmodule MemeCacheBot.Bot do
  @bot :meme_cache_bot

  require Logger

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(MemeCacheBot.Middlewares.RegisterUser)

  alias MemeCacheBot.MemeManager
  alias MemeCacheBot.MessageFormatter
  alias MemeCacheBot.Model.Meme
  alias MemeCacheBot.Steps
  alias MemeCacheBot.Utils

  def bot, do: @bot

  command("start", description: "Says hi!")
  command("help", description: "Sends some help")
  command("about", description: "Who made the bot")
  command("count", description: "How many memes have you saved?")

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, Utils.help_command())
  end

  def handle({:command, :about, _msg}, context) do
    answer(context, Utils.about_command(), parse_mode: "Markdown")
  end

  def handle({:command, :count, %{from: %{id: user_id}}}, context) do
    message =
      Meme.count_memes_by_user(user_id) |> elem(1) |> MessageFormatter.format_count_message()

    answer(context, message, parse_mode: "Markdown")
  end

  def handle({:message, %{from: %{id: user_id}, message_id: message_id} = message}, context) do
    with {:ok, meme_id, meme_unique_id, meme_type} <- Utils.get_meme_from_message(message),
         {{:ok, %Meme{}}, meme_info} <-
           {Meme.get_meme_by_user_and_id(user_id, meme_unique_id),
            %{
              user_id: user_id,
              meme_id: meme_id,
              meme_unique_id: meme_unique_id,
              meme_type: meme_type
            }} do
      {:ok, uuid} = Steps.add_step(meme_info)
      markup = Utils.generate_buttons(uuid, :delete)

      answer(context, "You already have that meme saved, do you want to delete it?",
        reply_markup: markup,
        reply_to_message_id: message_id
      )
    else
      {{:ok, nil}, meme_info} ->
        {:ok, uuid} = Steps.add_step(meme_info)
        markup = Utils.generate_buttons(uuid, :cache)

        answer(context, "Do you want to save this meme?",
          reply_markup: markup,
          reply_to_message_id: message_id
        )

      {:error, :no_meme, message} ->
        Logger.error("""
        Unrecognized meme on message:
          Message: #{inspect(message)}
        """)

        answer(context, "Sorry I don't recognize that as a meme :(",
          reply_to_message_id: message_id
        )

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

  def handle({:inline_query, %{query: text, from: %{id: user_id}}}, context) do
    page = Utils.get_page_from_message(text)

    case Meme.get_memes_by_user(user_id, page) do
      {:ok, memes} ->
        articles =
          Enum.map(memes, &MessageFormatter.get_inline_result/1)
          |> Enum.filter(&(&1 !== :invalid_meme))

        answer_inline_query(context, articles, is_personal: true, cache_time: 0)

      err ->
        Logger.error("Error while getting memes #{err}")
    end
  end

  def handle(
        {:callback_query, %{data: data, message: %{message_id: message_id}} = message},
        context
      ) do
    Logger.debug("message: #{inspect(message)}")

    with [action, uuid] <- String.split(data, ":"),
         {:ok, meme_info} <- Steps.get_step(uuid),
         {:ok, _} <- MemeManager.manage_meme(meme_info, action) do
      edit(context, :inline, "Meme #{action}d!", reply_to_message_id: message_id)
    else
      {:error, :already_cached} ->
        edit(context, :inline, "That meme was already cached!", reply_to_message_id: message_id)

      {:error, :could_not_cache} ->
        edit(context, :inline, "Sorry I could not save your meme :(",
          reply_to_message_id: message_id
        )

      {:error, :could_not_delete} ->
        edit(context, :inline, "Sorry I could not delete your meme :(",
          reply_to_message_id: message_id
        )

      error ->
        Logger.error("""
        Error while processing a callback query ->
          Error: #{inspect(error)}
          Message: #{inspect(message)}
        """)

        edit(context, :inline, "Sorry there was an error")
    end
  end

  def handle(
        {:update, %{chosen_inline_result: %{from: %{id: user_id}, result_id: meme_unique_id}}},
        _
      ) do
    Meme.update_last_used(user_id, meme_unique_id)
  end

  # Admins only
  def handle({:command, "stats", %{from: %{id: user_id}}}, context) do
    if Utils.is_admin(user_id) do
      stats_message = MemeCacheBot.get_stats_message()
      answer(context, stats_message, parse_mode: "Markdown")
    end
  end

  def handle(_, _), do: :ignore
  def handle(_), do: :ignore
end
