defmodule RecipeShareWeb.Components.Page do
  use Surface.Component

  alias RecipeShareWeb.IndexPage
  alias RecipeShareWeb.RecipePage
  alias RecipeShareWeb.RecipeDetail
  alias RecipeShareWeb.UserManagementPage

  prop page, :string, values: ["recipes", "index", "users", "recipe_detail"]
  prop user, :map, default: %{}
  prop access_token, :string, default: nil
  prop recipe_id, :integer, default: nil
  prop opts, :keyword, default: []

  @impl true
  def render(assigns) do
    ~H"""
    <IndexPage :if={{ @page == "index" or @user == %{} }} id="index-page" />
    <RecipePage :if={{ @page == "recipes" and @user != %{} }} user={{ @user }} access_token={{ @access_token }} uploads={{ Keyword.get(@opts, :uploads, %{}) }} id="recipes-page" />
    <UserManagementPage :if={{ @page == "users" and @user != %{} }} id="users-page" access_token={{ @access_token }} user={{ @user }} />
    <RecipeDetail :if={{ @page == "recipe_detail" and @user != %{} }} id="recipe-page" access_token={{ @access_token }} user={{ @user }} recipe_id={{ @recipe_id }} />
    """
  end
end
