defmodule MemeCacheBot.Middlewares.RegisterUser do
  use ExGram.Middleware

  alias ExGram.Cnt
  alias MemeCacheBot.Model.User

  import ExGram.Dsl

  def call(%Cnt{update: update} = cnt, _opts) do
    {:ok, %{id: telegram_id} = user} = extract_user(update)

    if User.get_by_telegram_id(telegram_id) == nil do
      Map.put(user, :telegram_id, telegram_id) |> User.insert()
    end

    cnt
  end

  def call(cnt, _), do: cnt
end
