defmodule RecipeShare.Recipes.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    embeds_many :ingredients, RecipeShare.Recipes.Ingredient, on_replace: :delete
    field :name, :string
    field :description, :string
    field :picture_urls, {:array, :string}
    field :published, :boolean, default: false
    field :tags, {:array, :string}
    field :user_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :picture_urls, :published, :tags, :description])
    |> cast_embed(:ingredients, with: &RecipeShare.Recipes.Ingredient.changeset/2)
    |> validate_required([:name, :ingredients, :published])
  end
end
