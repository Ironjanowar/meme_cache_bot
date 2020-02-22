defmodule MemeCacheBot.Utils do
  def date_now(), do: NaiveDateTime.utc_now() |> NaiveDateTime.to_string()
end
