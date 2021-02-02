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
  backends: [{LoggerFileBackend, :debug}, {LoggerFileBackend, :error}]

config :logger, :debug,
  path: "log/debug.log",
  level: :debug,
  format: "$dateT$timeZ [$level] $message\n"

config :logger, :error,
  path: "log/error.log",
  level: :error,
  format: "$dateT$timeZ [$level] $message\n"
