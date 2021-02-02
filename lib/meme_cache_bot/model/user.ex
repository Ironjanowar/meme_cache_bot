defmodule MemeCacheBot.Model.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
  alias MemeCacheBot.Model.Meme
  alias MemeCacheBot.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:telegram_id, :integer)
    field(:first_name, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(users, attrs) do
    users
    |> cast(attrs, [:telegram_id, :first_name, :username])
    |> validate_required([:telegram_id, :first_name])
  end

  def insert(user_params) do
    changeset = changeset(%User{}, user_params)

    if changeset.valid? do
      Repo.insert(changeset)
    else
      {:error, changeset.errors}
    end
  end

  def get_by_telegram_id(telegram_id) do
    q = from(u in User, where: u.telegram_id == ^telegram_id)
    Repo.one(q)
  end

  def get_users_count do
    q = from(u in User, select: count(u.id))
    Repo.one(q)
  end

  def get_meme_master do
    subq =
      from(m in Meme,
        select: %{count: count(m.id), telegram_id: m.telegram_id},
        group_by: :telegram_id,
        order_by: [desc: :count],
        limit: 1
      )

    q = from(u in User, select: %{user: u}, join: subquery(subq), limit: 1)

    case Repo.one(q) do
      %{user: user} -> user
      result -> result
    end
  end
end
