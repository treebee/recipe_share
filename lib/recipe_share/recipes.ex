defmodule RecipeShare.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false
  alias RecipeShare.Repo

  alias RecipeShare.Recipes.Recipe

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    Repo.all(Recipe)
  end

  @doc """
  Gets a single recipe.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_recipe!(123)
      %Recipe{}

      iex> get_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recipe!(id), do: Repo.get!(Recipe, id)

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(%{field: value})
      {:ok, %Recipe{}}

      iex> create_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(recipe_params, uploaded_files, access_token, user_id) do
    now = DateTime.utc_now()

    recipe_params =
      recipe_params
      |> Map.put("inserted_at", now)
      |> Map.put("updated_at", now)
      |> Map.put("user_id", user_id)
      |> Map.put(
        "ingredients",
        Map.values(Map.get(recipe_params, "ingredients", []))
      )
      |> Map.put("picture_urls", uploaded_files)

    ch = change_recipe(%Recipe{}, recipe_params)

    cond do
      ch.valid? ->
        %{body: [recipe], status: 201} =
          Supabase.init(access_token: access_token)
          |> Postgrestex.from("recipes")
          |> Postgrestex.insert(recipe_params)
          |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
          |> Postgrestex.call()
          |> Supabase.json()

        {:ok, recipe}

      true ->
        {:error, ch}
    end
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Recipe{} = recipe, attrs) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a recipe and returns it.

  ## Examples

      iex> delete_recipe(recipe)
      {:ok, %Recipe{}}

      iex> delete_recipe(recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recipe(recipe_id, access_token) do
    req =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("recipes")
      |> Postgrestex.delete("")
      |> Postgrestex.eq("id", recipe_id)
      |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})

    case HTTPoison.delete(req.path, req.headers, params: req.params) |> Supabase.json() do
      %{status: 200, body: [recipe]} ->
        {:ok, recipe}

      error ->
        {:error, error}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end
end
