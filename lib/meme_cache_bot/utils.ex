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

  def get_meme_from_message(%{voice: %{file_unique_id: meme_unique_id, file_id: meme_id}}),
    do: {:ok, meme_id, meme_unique_id, "voice"}

  def get_meme_from_message(message) do
    Logger.debug("Unrecognized meme: #{inspect(message)}")
    {:error, :no_meme, message}
  end

  def generate_buttons(user_id, :cache),
    do: ExGram.Dsl.create_inline([[[text: "Yes", callback_data: "cache:#{user_id}"]]])

  def generate_buttons(meme_uuid, :delete),
    do: ExGram.Dsl.create_inline([[[text: "Yes", callback_data: "delete:#{meme_uuid}"]]])

  def help_command do
    """
    Send me a meme in any of these formats:
     - Sticker
     - GIF
     - Photo
     - Video

    If you don't have it, I'll ask if you want to save it!

    If you already have that meme, I'll ask if you want to delete it.
    """
  end

  def about_command do
    """
    __This bot was made by [@Ironjanowar](https://github.com/Ironjanowar) with ❤️__

    If you want to share some love and give a star ⭐️ to the repo [here it is](https://github.com/Ironjanowar/meme_cache_bot)
    """
  end

  def get_page_from_message(text) do
    case Integer.parse(text) do
      {page, _} -> page
      _ -> 0
    end
  end

  def is_admin(user_id) do
    case ExGram.Config.get(:meme_cache_bot, :admins) |> Jason.decode() do
      {:ok, admins} ->
        Logger.debug("admins: #{inspect(admins)}")
        user_id in admins

      _ ->
        Logger.error(
          "The admins env var may be not correctly configurated, the format should be an array of strings. For example: [\"admin\", \"admin2\"]"
        )

        false
    end
  end
end
