defmodule RecipeShareWeb.RecipePage do
  use RecipeShareWeb, :surface_live_component

  alias RecipeShare.Recipes.Recipe
  alias RecipeShareWeb.Components.Modal

  data action, :atom, default: :new
  data recipes, :list, default: []
  data show_modal, :boolean, default: false
  prop access_token, :string, required: true
  prop user, :map, required: true

  @impl true
  def update(assigns, socket) do
    socket =
      assign(socket,
        recipes: fetch_recipes(assigns.user["id"], assigns.access_token)
      )

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="recipes-view" class="container mx-auto pt-10 px-2">
      <button phx-click="moep">Click me!</button>
      <div
        class="flex justify-end text-white font-semibold"
      >
        <button
          type="button"
          class="rounded-md p-2 bg-green-500 flex items-center"
          :on-click="open"
          phx-value-action={{ :new }}
        >
          {{ Heroicons.Outline.document(class: "w-4 h-4 mr-2") }}Create Recipe
        </button>
      </div>
      <h2 :if={{ length(@recipes) > 0 }} class="font-semibold text-xl text-center">Your Recipes</h2>
      <h2 :if={{ length(@recipes) == 0 }} class="font-semibold text-xl text-center">
        You haven't shared any recipes yet.
      </h2>
      <Modal id="recipe-modal" title={{ modal_title(@action) }} show={{ @show_modal }} >
        Hello modal
      </Modal>


    </div>
    """
  end

  def fetch_recipes(uid, access_token) do
    %{body: recipes} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("recipes")
      |> Postgrestex.eq("user_id", uid)
      |> Postgrestex.call()
      |> Supabase.json()

    IO.inspect(recipes)
    recipes
  end

  @impl true
  def handle_event("open", %{"action" => action}, socket) do
    Modal.open("recipe-modal")

    {:noreply,
     assign(socket, recipe: %Recipe{}, show_modal: true, action: String.to_atom(action))}
  end

  defp modal_title(:new), do: "Create a new Recipe"
  defp modal_title(:edit), do: "Edit Recipe"
end
