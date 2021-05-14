defmodule RecipeShareWeb.PageLive do
  use RecipeShareWeb, :surface_view

  alias RecipeShareWeb.Components.Navbar

  @impl true
  def render(assigns) do
    ~H"""

    <header>
      <Navbar />
    </header>
    """
  end
end
