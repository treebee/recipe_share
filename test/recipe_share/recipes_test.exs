defmodule RecipeShare.RecipesTest do
  use RecipeShare.DataCase

  alias RecipeShare.Recipes

  describe "recipes" do
    alias RecipeShare.Recipes.Recipe

    @valid_attrs %{ingredients: %{}, name: "some name", picture_urls: [], published: true, tags: []}
    @update_attrs %{ingredients: %{}, name: "some updated name", picture_urls: [], published: false, tags: []}
    @invalid_attrs %{ingredients: nil, name: nil, picture_urls: nil, published: nil, tags: nil}

    def recipe_fixture(attrs \\ %{}) do
      {:ok, recipe} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Recipes.create_recipe()

      recipe
    end

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Recipes.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Recipes.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      assert {:ok, %Recipe{} = recipe} = Recipes.create_recipe(@valid_attrs)
      assert recipe.ingredients == %{}
      assert recipe.name == "some name"
      assert recipe.picture_urls == []
      assert recipe.published == true
      assert recipe.tags == []
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recipes.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{} = recipe} = Recipes.update_recipe(recipe, @update_attrs)
      assert recipe.ingredients == %{}
      assert recipe.name == "some updated name"
      assert recipe.picture_urls == []
      assert recipe.published == false
      assert recipe.tags == []
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.update_recipe(recipe, @invalid_attrs)
      assert recipe == Recipes.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Recipes.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Recipes.change_recipe(recipe)
    end
  end
end
