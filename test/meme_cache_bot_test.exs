defmodule MemeCacheBotTest do
  use ExUnit.Case
  doctest MemeCacheBot

  test "greets the world" do
    assert MemeCacheBot.hello() == :world
  end
end
