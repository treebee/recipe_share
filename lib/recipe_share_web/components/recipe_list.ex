defmodule RecipeShareWeb.Components.RecipeList do
  use RecipeShareWeb, :surface_component

  prop recipes, :list, default: []
  prop publish, :event, default: %{}
  prop delete, :event

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4">
      <div :for={{ recipe <- @recipes }} class="flex justify-between p-2 my-4 rounded-md text-gray-800 bg-indigo-100 bg-opacity-50 my-2 border-indigo-200">
        <span class="font-bold">
          {{ recipe["name"] }}
        </span>
        <div>
          <button
            :if={{ not is_nil(Map.get(@publish, :name)) and not recipe["published"] }} :on-click={{ @publish }} phx-value-id={{ recipe["id"] }}
            class="py-1 px-2 bg-blue-200"
          >
            publish
          </button>
          <button class="rounded-full p-2 mx-2">{{ Heroicons.Outline.pencil(class: "w-4 h-4")}} </button>
          <button
            class="rounded-full p-2"
           :on-click={{ @delete }}
           phx-value-id={{ recipe["id"] }}
           data-confirm="Are you sure you want to delete this recipe ({{ recipe["name"] }})?"
           >{{ Heroicons.Outline.trash(class: "w-4 h-4")}}</button>
        </div>
      </div>
    </div>
    """
  end
end
