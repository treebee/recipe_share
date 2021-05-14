defmodule RecipeShareWeb.PageLive do
  use RecipeShareWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def render(assigns) do
    ~L"""
    Hi there!
    """
  end
end
