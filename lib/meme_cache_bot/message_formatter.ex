defmodule MemeCacheBot.MessageFormatter do
  require Logger

  alias ExGram.Model.{
    InlineQueryResultCachedGif,
    InlineQueryResultCachedPhoto,
    InlineQueryResultCachedSticker,
    InlineQueryResultCachedVideo,
    InlineQueryResultCachedVoice
  }

  defp type_struct("gif"), do: {:ok, InlineQueryResultCachedGif, :gif_file_id, %{}}
  defp type_struct("photo"), do: {:ok, InlineQueryResultCachedPhoto, :photo_file_id, %{}}
  defp type_struct("sticker"), do: {:ok, InlineQueryResultCachedSticker, :sticker_file_id, %{}}

  defp type_struct("voice"),
    do: {:ok, InlineQueryResultCachedVoice, :voice_file_id, %{title: "Voice Message Meme"}}

  defp type_struct("video"),
    do: {:ok, InlineQueryResultCachedVideo, :video_file_id, %{title: "Meme"}}

  defp type_struct(invalid_type), do: {:error, :invalid_type, invalid_type}

  def get_inline_result(meme) do
    case type_struct(meme.meme_type) do
      {:ok, struct_module, file_param, extras} ->
        params =
          %{type: meme.meme_type, id: meme.meme_unique_id}
          |> Map.put(file_param, meme.meme_id)
          |> Map.merge(extras)

        struct(struct_module, params)

      err ->
        Logger.error("""
        Invalid meme type #{inspect(meme.meme_type)}:
          Error: #{inspect(err)}
          Meme: #{inspect(meme)}
        """)

        :invalid_meme
    end
  end

  def format_count_message(count) do
    """
    You have saved *#{count}* memes in total!
    """
  end
end
