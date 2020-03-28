defmodule MemeCacheBot.MemeManager do
  alias MemeCacheBot.Model.Meme
  alias MemeCacheBot.Utils

  require Logger

  def cache_meme(%{
        user_id: telegram_id,
        meme_id: meme_id,
        meme_unique_id: meme_unique_id,
        meme_type: meme_type
      }) do
    case Meme.insert(%{
           meme_id: meme_id,
           meme_unique_id: meme_unique_id,
           telegram_id: telegram_id,
           meme_type: meme_type,
           last_used: Utils.date_now()
         }) do
      {:error, :already_cached} = ok ->
        ok

      {:ok, meme} ->
        Logger.debug("Meme cached: #{inspect(meme)}")
        {:ok, :meme_cached}

      err ->
        Logger.error("Could not cache meme: #{inspect(err)}")
        {:error, :could_not_cache}
    end
  end

  def delete_meme(%{
        user_id: telegram_id,
        meme_unique_id: meme_unique_id
      }) do
    case Meme.delete_meme(telegram_id, meme_unique_id) do
      {:ok, :meme_deleted} ->
        Logger.debug("Deleted meme: #{inspect(meme_unique_id)}")
        {:ok, :meme_deleted}

      _ ->
        Logger.debug(
          "Could not delete meme #{inspect(meme_unique_id)} for user #{inspect(telegram_id)}"
        )

        {:error, :could_not_delete}
    end
  end

  def manage_meme(meme_info, "cache"),
    do: cache_meme(meme_info)

  def manage_meme(meme_info, "delete"),
    do: delete_meme(meme_info)
end
