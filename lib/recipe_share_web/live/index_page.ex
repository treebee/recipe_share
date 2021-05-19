defmodule RecipeShareWeb.IndexPage do
  use RecipeShareWeb, :surface_live_component

  alias Surface.Components.LivePatch
  alias RecipeShare.Recipes

  data recipes, :list, default: []

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [recipes: []]}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, recipes: Recipes.list_recipes())
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="index">
    <div class="container mx-auto mt-20">
      <div :for={{ recipe <- @recipes }} id={{ "recipe-#{recipe.id}" }} class="mx-auto my-2 border border-indigo-200 rounded-md flex p-4 max-w-2xl">
        <div>
        <img width=200 height=180 class="mr-4 rounded-md" src={{ picture_url(recipe.cover_picture) }} />
        </div>
        <div class="">
          <LivePatch to="/recipes/{{ recipe.id }}">
          <div class="text-xl font-bold">
          {{ recipe.name }}
          </div>
          </LivePatch>
          <div class="text-sm">created at {{ recipe.inserted_at }}</div>
        </div>
      </div>
    </div>
    </div>
    """
  end
end
