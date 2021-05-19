defmodule RecipeShareWeb.RecipeDetail do
  use RecipeShareWeb, :surface_live_component

  alias RecipeShare.Accounts
  alias RecipeShare.Recipes

  prop recipe_id, :integer, required: true
  prop access_token, :string, required: true
  prop user, :map, required: true
  data recipe, :map, default: %{}
  data can_delete, :boolean, default: false

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [recipe: %{}]}
  end

  @impl true
  def update(assigns, socket) do
    recipe = Recipes.get_recipe!(assigns.recipe_id, assigns.access_token)
    role = get_role(assigns.access_token, assigns.user)
    can_delete = recipe.id == assigns.user["id"] or role.name in ["admin", "moderator"]
    {:ok, assign(socket, assigns) |> assign(recipe: recipe, can_delete: can_delete)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto my-20 max-w-xl">
      <div class="flex justify-end" :if={{ @can_delete }}>
        <button
          class="bg-red-500 rounded-md text-white py-1 px-4 right-0"
          :on-click="delete"
          phx-value-id={{ Map.get(@recipe, :id) }}
        >delete</button>
      </div>
      <h1 class="font-semibold text-2xl text-center">{{ Map.get(@recipe, :name) }}</h1>
      <div class="py-8">
        <img width="400" height="320" src={{ picture_url(Map.get(@recipe, :cover_picture)) }}
         class="rounded-md mx-auto"
        />
      </div>
      <h2 class="font-semibold text-xl text-center">Ingredients</h2>
      <div class="py-4">
        <div class="grid grid-cols-2 gap-2 mx-auto" :for={{ ingredient <- @recipe.ingredients }}>
          <span class="text-right">{{ ingredient.quantity }}</span>
          <span>{{ ingredient.name }}</span>
        </div>
      </div>
      <h2 class="font-semibold text-xl text-center">Instructions</h2>
      <div class="py-4">
        <pre>
          {{ @recipe.description }}
        </pre>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _recipe} = Recipes.delete_recipe(id, socket.assigns.access_token)

    socket =
      put_flash(socket, :info, "Successfully deleted recipe")
      |> push_patch(to: "/")

    {:noreply, socket}
  end

  defp get_role(_access_token, %{}), do: %{name: "user", id: "3"}

  defp get_role(access_token, user) do
    Accounts.get_role!(access_token, user["id"])
  end
end
