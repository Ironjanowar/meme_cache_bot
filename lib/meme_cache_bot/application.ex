defmodule MemeCacheBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    token = ExGram.Config.get(:ex_gram, :token)

    children = [
      MemeCacheBot.Repo,
      ExGram,
      {MemeCacheBot.Bot, [method: :polling, token: token]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MemeCacheBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
