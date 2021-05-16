defmodule RecipeShareWeb.Components.Page do
  use Surface.Component

  alias RecipeShareWeb.IndexPage
  alias RecipeShareWeb.RecipePage

  prop page, :string, values: ["recipes", "index"]
  prop user, :map, default: %{}
  prop access_token, :string, default: nil
  prop opts, :keyword, default: []

  @impl true
  def render(assigns) do
    ~H"""
    <IndexPage :if={{ @page == "index" }} id="index-page" />
    <RecipePage :if={{ @page == "recipes" }} user={{ @user }} access_token={{ @access_token }} uploads={{ Keyword.get(@opts, :uploads, %{}) }} id="recipes-page" />
    """
  end
end
