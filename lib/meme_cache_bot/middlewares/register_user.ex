defmodule MemeCacheBot.Middlewares.RegisterUser do
  use ExGram.Middleware

  alias ExGram.Cnt
  alias MemeCacheBot.Model.User

  import ExGram.Dsl

  def call(%Cnt{update: update} = cnt, _opts) do
    {:ok, %{id: telegram_id, first_name: first_name, username: username}} = extract_user(update)

    if User.get_by_telegram_id(telegram_id) == nil do
      User.insert(%{telegram_id: telegram_id, first_name: first_name, username: username})
    end

    cnt
  end

  def call(cnt, _), do: cnt
end
