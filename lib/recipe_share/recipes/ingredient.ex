defmodule RecipeShare.Recipes.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  # keep it simple here and use free form text instead of having extra unit types
  # for 'kilograms', 'litres' etc...
  #
  # quantity: "300g"
  # name: "Broccoli"
  # -> 300g Broccoli
  @primary_key false
  embedded_schema do
    field :name, :string, primary_key: true
    field :quantity, :string
    field :delete, :boolean, virtual: true, default: false
    field :temp_id, :string, virtual: true
  end

  @doc false
  def changeset(%__MODULE__{} = ingredient, attrs) do
    ingredient
    |> Map.put(:temp_id, ingredient.temp_id || attrs["temp_id"])
    |> cast(attrs, [:quantity, :name, :delete, :temp_id])
    |> validate_required([:quantity, :name])
  end

  def changeset(%{quantity: quantity, name: name, delete: delete, temp_id: temp_id}, attrs) do
    %__MODULE__{quantity: quantity, name: name, delete: delete, temp_id: temp_id}
    |> changeset(attrs)
  end

  def changeset(%{}, attrs), do: changeset(%__MODULE__{}, attrs)
end
