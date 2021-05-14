defmodule RecipeShare.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, []}

  schema "profiles" do
    field :avatar_url, :string
    field :username, :string
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:username, :avatar_url])
    |> validate_required([:id])
  end
end
