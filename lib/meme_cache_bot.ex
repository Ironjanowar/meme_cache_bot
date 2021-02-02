defmodule MemeCacheBot do
  alias MemeCacheBot.Model.{User, Meme}
  alias MemeCacheBot.MessageFormatter

  def get_stats do
    %{
      users_count: User.get_users_count(),
      memes_count: Meme.get_memes_count(),
      meme_master: User.get_meme_master()
    }
  end

  def get_stats_message do
    stats = get_stats()

    """
    Total users: **#{stats.users_count}**
    Total memes: **#{stats.memes_count}**

    #{MessageFormatter.format_meme_master(stats.meme_master)}
    """
  end
end
