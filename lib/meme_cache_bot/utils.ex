defmodule MemeCacheBot.Utils do
  def date_now(), do: NaiveDateTime.utc_now() |> NaiveDateTime.to_string()

  def get_meme_from_message(%{photo: [%{file_id: meme_id} | _]}), do: {:ok, meme_id, "photo"}
  def get_meme_from_message(%{sticker: %{file_id: meme_id}}), do: {:ok, meme_id, "sticker"}
end
