defmodule MemeCacheBot.Model.Meme do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
  alias MemeCacheBot.Repo

  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memes" do
    field(:meme_id, :string)
    field(:telegram_id, :integer)
    field(:meme_type, :string)
    field(:last_used, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(users, attrs) do
    users
    |> cast(attrs, [:meme_id, :telegram_id, :meme_type, :last_used])
    |> validate_required([:meme_id, :telegram_id, :meme_type, :last_used])
  end

  def insert(meme_params) do
    changeset = changeset(%Meme{}, meme_params)

    if changeset.valid? do
      Repo.insert(changeset)
    else
      {:error, changeset.errors}
    end
  end

  def get_memes_by_user(user_id) do
    q = from(m in Meme, where: m.telegram_id == ^user_id, order_by: m.last_used)
    {:ok, Repo.all(q)}
  end

  def delete_meme(telegram_id, meme_id) do
    q = from(m in Meme, where: m.telegram_id == ^telegram_id and m.meme_id == ^meme_id)

    case Repo.delete_all(q) do
      {0, _} = result ->
        Logger.debug("Could not DELETE meme\n#{inspect(result)}")
        {:error, :could_not_delete}

      result ->
        Logger.debug("DELETE result\n#{inspect(result)}")
        {:ok, :meme_deleted}
    end
  end
end
