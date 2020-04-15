defmodule MemeCacheBot.Model.Meme do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
  alias MemeCacheBot.{Repo, Utils}

  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memes" do
    field(:meme_id, :string)
    field(:meme_unique_id, :string)
    field(:telegram_id, :integer)
    field(:meme_type, :string)
    field(:last_used, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(users, attrs) do
    users
    |> cast(attrs, [:meme_id, :meme_unique_id, :telegram_id, :meme_type, :last_used])
    |> validate_required([:meme_id, :meme_unique_id, :telegram_id, :meme_type, :last_used])
    |> unique_constraint(:meme_telegram_index)
  end

  def insert(meme_params) do
    changeset = changeset(%Meme{}, meme_params)

    if changeset.valid? do
      case get_meme_by_user_and_id(meme_params.telegram_id, meme_params.meme_unique_id) do
        {:ok, nil} ->
          Repo.insert(changeset)

        {:ok, _} ->
          {:ok, :already_cached}
      end
    else
      {:error, changeset.errors}
    end
  end

  def get_memes_by_user(telegram_id) do
    q = from(m in Meme, where: m.telegram_id == ^telegram_id, order_by: [desc: m.last_used])
    {:ok, Repo.all(q)}
  end

  def get_meme_by_user_and_id(telegram_id, meme_unique_id) do
    q =
      from(m in Meme, where: m.telegram_id == ^telegram_id and m.meme_unique_id == ^meme_unique_id)

    {:ok, Repo.one(q)}
  end

  def delete_meme(telegram_id, meme_unique_id) do
    q =
      from(m in Meme, where: m.telegram_id == ^telegram_id and m.meme_unique_id == ^meme_unique_id)

    case Repo.delete_all(q) do
      {0, _} = result ->
        Logger.debug("Could not DELETE meme\n#{inspect(result)}")
        {:error, :could_not_delete}

      result ->
        Logger.debug("DELETE result\n#{inspect(result)}")
        {:ok, :meme_deleted}
    end
  end

  def update_last_used(telegram_id, meme_unique_id) do
    from(m in Meme, where: m.telegram_id == ^telegram_id and m.meme_unique_id == ^meme_unique_id)
    |> Repo.update_all(set: [last_used: Utils.date_now()])
  end
end
