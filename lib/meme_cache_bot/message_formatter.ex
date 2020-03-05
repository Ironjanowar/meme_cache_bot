defmodule MemeCacheBot.MessageFormatter do
  require Logger

  alias ExGram.Model.InlineQueryResultCachedSticker
  alias ExGram.Model.InlineQueryResultCachedPhoto
  alias ExGram.Model.InlineQueryResultCachedGif

  def get_inline_result(meme) do
    case meme.meme_type do
      "gif" ->
        %InlineQueryResultCachedGif{
          type: meme.meme_type,
          id: meme.id,
          gif_file_id: meme.meme_id
        }

      "photo" ->
        %InlineQueryResultCachedPhoto{
          type: meme.meme_type,
          id: meme.id,
          photo_file_id: meme.meme_id
        }

      "sticker" ->
        %InlineQueryResultCachedSticker{
          type: meme.meme_type,
          id: meme.id,
          sticker_file_id: meme.meme_id
        }

      _ ->
        Logger.debug("Invalid meme type #{inspect(meme.meme_type)}: #{inspect(meme)}")
        :invalid_meme
    end
  end
end
