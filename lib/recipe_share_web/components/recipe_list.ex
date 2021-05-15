defmodule RecipeShareWeb.Components.RecipeList do
  use RecipeShareWeb, :surface_component

  prop recipes, :list, default: []
  prop publish, :event, default: %{}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4">
      <div :for={{ recipe <- @recipes }} class="flex justify-between p-2 rounded-md text-gray-800 bg-indigo-100 bg-opacity-50 my-2 border-indigo-200">
        <span class="font-bold">
          {{ recipe["name"] }}
        </span>
        <button :if={{ not is_nil(Map.get(@publish, :name)) and not recipe["published"] }} :on-click={{ @publish }} phx-value-id={{ recipe["id"] }}>publish</button>
      </div>
    </div>
    """
  end
end
