defmodule MemeCacheBot.Bot do
  @bot :meme_cache_bot

  require Logger

  use ExGram.Bot,
    name: @bot

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(MemeCacheBot.Middlewares.RegisterUser)

  alias MemeCacheBot.Model.Meme
  alias MemeCacheBot.MessageFormatter
  alias MemeCacheBot.Utils

  def bot(), do: @bot

  def handle({:command, "start", _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, "cache", _msg}, context) do
    answer(context, "Which meme do you want to cache?")
  end

  def handle({:message, %{photo: [%{file_id: meme_id} | _], from: %{id: user_id}}}, context) do
    case save_meme(user_id, meme_id, "photo") do
      :ok -> answer(context, "Photo meme saved!")
      _ -> answer(context, "Photo meme could not be saved :(")
    end
  end

  def handle({:message, %{sticker: %{file_id: meme_id}, from: %{id: user_id}}}, context) do
    case save_meme(user_id, meme_id, "sticker") do
      :ok -> answer(context, "Sticker meme saved!")
      _ -> answer(context, "Sticker meme could not be saved :(")
    end
  end

  def handle({:message, m}, context) do
    Logger.debug("MEEEH #{inspect(m)}")
    answer(context, "Meh")
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

  # Private
  defp save_meme(telegram_id, meme_id, meme_type) do
    case Meme.insert(%{
           meme_id: meme_id,
           telegram_id: telegram_id,
           meme_type: meme_type,
           last_used: Utils.date_now()
         }) do
      {:ok, meme} ->
        Logger.debug("Meme saved: #{inspect(meme)}")
        :ok

      err ->
        Logger.error("Could not save meme: #{inspect(err)}")
        :error
    end
  end
end
