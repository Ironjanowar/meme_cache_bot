# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :meme_cache_bot, MemeCacheBot.Repo,
  database: "meme_cache_bot_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :meme_cache_bot,
  ecto_repos: [MemeCacheBot.Repo]

config :meme_cache_bot,
  admins: {:system, "ADMINS"}

config :ex_gram,
  token: {:system, "BOT_TOKEN"}

config :logger,
  level: :debug,
  truncate: :infinity,
  backends: [{LoggerJSONFileBackend, :log_name}]

config :logger, :log_name,
  path: "log/debug.log",
  level: :debug,
  metadata: [:file, :line],
  json_encoder: Jason,
  uuid: true
