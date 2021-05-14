defmodule RecipeShare.Recipes.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    embeds_many :ingredients, RecipeShare.Recipes.Ingredient
    field :name, :string
    field :picture_urls, {:array, :string}
    field :published, :boolean, default: false
    field :tags, {:array, :string}
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :picture_urls, :published, :tags])
    |> cast_embed(:ingredients, with: &RecipeShare.Recipes.Ingredient.changeset/2)
    |> validate_required([:name, :picture_urls, :ingredients, :published, :tags])
  end
end
