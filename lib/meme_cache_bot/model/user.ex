defmodule MemeCacheBot.Model.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

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
    |> validate_required([:telegram_id, :first_name, :username])
  end

  def insert(user_params) do
    changeset = changeset(%User{}, user_params)

    if changeset.valid? do
      MemeCacheBot.Repo.insert(changeset)
    else
      {:error, changeset.errors}
    end
  end
end
