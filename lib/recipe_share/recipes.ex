defmodule RecipeShare.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false

  alias RecipeShare.Recipes.Recipe
  alias RecipeShare.Recipes.Ingredient

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes(options \\ []) do
    %{body: recipes} =
      Supabase.init(options)
      |> Postgrestex.from("recipes")
      |> Postgrestex.is_("published", "true")
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    Enum.map(recipes, &Map.merge(%Recipe{}, &1))
  end

  @doc """
  Gets a single recipe.

  """
  def get_recipe!(id, access_token) when is_integer(id),
    do: get_recipe!(Integer.to_string(id), access_token)

  def get_recipe!(id, access_token) do
    %{status: 200, body: [recipe]} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("recipes")
      |> Postgrestex.eq("id", id)
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    Map.merge(%Recipe{}, recipe)
    |> Map.update(:ingredients, [], fn ingredients ->
      if is_nil(ingredients), do: [], else: Enum.map(ingredients, &Map.merge(%Ingredient{}, &1))
    end)
  end

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
      |> Map.put("cover_picture", generate_cover_url(uploaded_files))

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

  """
  def update_recipe(recipe, attrs, uploaded_files, access_token) do
    now = DateTime.utc_now()

    if length(uploaded_files) > 0 or recipe.changes != %{} do
      params =
        attrs
        |> Map.to_list()
        |> Enum.filter(fn {key, _v} -> Map.has_key?(recipe.changes, String.to_atom(key)) end)
        |> Map.new()

      picture_urls = Enum.concat([recipe.data.picture_urls, uploaded_files])

      params =
        params
        |> Map.put("updated_at", now)
        |> Map.put("picture_urls", picture_urls)
        |> Map.put("cover_picture", generate_cover_url(picture_urls))
        |> Map.put("ingredients", process_ingredients(params))

      params =
        if Map.has_key?(recipe.changes, :ingredients),
          do: Map.put(params, "ingredients", Map.get(params, "ingredients")),
          else: params

      %{status: 200, body: [recipe]} =
        Supabase.init(access_token: access_token)
        |> Postgrestex.from("recipes")
        |> Postgrestex.update(params)
        |> Postgrestex.eq("id", Integer.to_string(recipe.data.id))
        |> Postgrestex.call()
        |> Supabase.json()

      {:ok, recipe}
    end
  end

  defp process_ingredients(%{"ingredients" => ingredients}) do
    ingredients
    |> Map.values()
    |> Enum.filter(fn ingredient -> ingredient["delete"] != "true" end)
  end

  defp process_ingredients(_), do: []

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
      |> Postgrestex.delete(%{})
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

  defp generate_cover_url([]), do: ""

  defp generate_cover_url([cover | _picture_urls]) do
    {:ok, %{"signedURL" => url}} =
      Supabase.Connection.new()
      |> Supabase.Storage.Objects.sign("recipe-pictures", cover, expires_in: 60 * 24 * 365)

    url
  end
end
