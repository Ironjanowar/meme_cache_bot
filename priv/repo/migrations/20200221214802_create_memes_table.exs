defmodule MemeCacheBot.Repo.Migrations.CreateMemesTable do
  use Ecto.Migration

  def change do
    create table(:memes, primary_key: false) do
      add(:id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()"))
      add(:meme_id, :string)
      add(:telegram_id, :integer)
      add(:meme_type, :string)
      add(:last_used, :naive_datetime)

      timestamps()
    end

    create(unique_index(:memes, [:meme_id, :telegram_id], name: :meme_telegram_index))
  end
end
