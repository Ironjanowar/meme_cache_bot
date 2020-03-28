defmodule MemeCacheBot.Utils do
  require Logger

  def date_now, do: NaiveDateTime.utc_now() |> NaiveDateTime.to_string()

  def get_meme_from_message(%{animation: %{file_id: meme_id, file_unique_id: meme_unique_id}}),
    do: {:ok, meme_id, meme_unique_id, "gif"}

  def get_meme_from_message(%{photo: [%{file_id: meme_id, file_unique_id: meme_unique_id} | _]}),
    do: {:ok, meme_id, meme_unique_id, "photo"}

  def get_meme_from_message(%{sticker: %{file_unique_id: meme_unique_id, file_id: meme_id}}),
    do: {:ok, meme_id, meme_unique_id, "sticker"}

  def get_meme_from_message(%{video: %{file_unique_id: meme_unique_id, file_id: meme_id}}),
    do: {:ok, meme_id, meme_unique_id, "video"}

  def get_meme_from_message(message) do
    Logger.debug("Unrecognized meme: #{inspect(message)}")
    {:error, :no_meme, message}
  end

  def generate_buttons(user_id, :cache),
    do: ExGram.Dsl.create_inline([[[text: "Yes", callback_data: "cache:#{user_id}"]]])

  def generate_buttons(user_id, :delete),
    do: ExGram.Dsl.create_inline([[[text: "Yes", callback_data: "delete:#{user_id}"]]])
end
