defmodule MemeCacheBot.Bot do
  @bot :meme_cache_bot

  require Logger

  use ExGram.Bot,
    name: @bot

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(MemeCacheBot.Middlewares.RegisterUser)

  alias ExGram.Model.InlineQueryResultCachedSticker
  alias ExGram.Model.InlineQueryResultCachedPhoto

  def bot(), do: @bot

  def handle({:command, "start", _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, "cache", _msg}, context) do
    answer(context, "Which meme do you want to cache?")
  end

  def handle({:message, %{photo: photos}}, context) do
    Logger.debug("MEEEH #{inspect(photos)}")
    answer(context, "Photo received")
  end

  def handle({:message, %{sticker: sticker}}, context) do
    Logger.debug("MEEEH #{inspect(sticker)}")
    answer(context, "Sticker received")
  end

  def handle({:message, m}, context) do
    Logger.debug("MEEEH #{inspect(m)}")
    answer(context, "Meh")
  end

  def handle({:inline_query, %{query: _text}}, context) do
    articles = [
      %InlineQueryResultCachedSticker{
        type: "sticker",
        id: "1",
        sticker_file_id: "CAACAgQAAxkBAAIYK15QOqKWcVlEy58rOb2NAZPPqHtLAAK2AAMNpCQAAfLcVSn4p-yvGAQ"
      },
      %InlineQueryResultCachedPhoto{
        type: "photo",
        id: "2",
        photo_file_id:
          "AgACAgQAAxkBAAIYKV5QOmm48Gg9_4bLPSqqcD7X6I7qAAJZsTEbLWSAUpti2Y6sVsTmR1ioGwAEAQADAgADbQAD8z4IAAEYBA"
      }
    ]

    answer_inline_query(context, articles)
  end
end
