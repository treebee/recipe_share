defmodule RecipeShareWeb.IndexPage do
  use RecipeShareWeb, :surface_live_component

  @impl true
  def render(assigns) do
    ~H"""
    {{ Map.get(assigns, :user)}}
    """
  end
end
