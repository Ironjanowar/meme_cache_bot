defmodule MemeCacheBot.MessageFormatter do
  require Logger

  alias ExGram.Model.{
    InlineQueryResultCachedSticker,
    InlineQueryResultCachedPhoto,
    InlineQueryResultCachedGif,
    InlineQueryResultCachedVideo
  }

  defp type_struct("gif"), do: {:ok, InlineQueryResultCachedGif, :gif_file_id, %{}}
  defp type_struct("photo"), do: {:ok, InlineQueryResultCachedPhoto, :photo_file_id, %{}}
  defp type_struct("sticker"), do: {:ok, InlineQueryResultCachedSticker, :sticker_file_id, %{}}

  defp type_struct("video"),
    do: {:ok, InlineQueryResultCachedVideo, :video_file_id, %{title: "Meme"}}

  defp type_struct(invalid_type), do: {:error, :invalid_type, invalid_type}

  def get_inline_result(meme) do
    with {:ok, struct_module, file_param, extras} <- type_struct(meme.meme_type) do
      params =
        %{type: meme.meme_type, id: meme.id}
        |> Map.put(file_param, meme.meme_id)
        |> Map.merge(extras)

      struct(struct_module, params)
    else
      err ->
        Logger.error("""
        Invalid meme type #{inspect(meme.meme_type)}:
          Error: #{inspect(err)}
          Meme: #{inspect(meme)}
        """)

        :invalid_meme
    end
  end
end
