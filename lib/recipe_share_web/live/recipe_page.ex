defmodule RecipeShareWeb.RecipePage do
  use RecipeShareWeb, :surface_live_component

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, TextInput, Submit, Label, Inputs, Checkbox, TextArea}
  alias RecipeShare.Recipes.{Recipe, Ingredient}
  alias RecipeShare.Recipes
  alias RecipeShareWeb.Components.Modal
  alias RecipeShareWeb.Components.RecipeList

  data action, :atom, default: :new
  data recipes, :list, default: []
  data show_modal, :boolean, default: false

  data recipe, :map, default: %Recipe{}
  data changeset, :map, default: Recipe.changeset(%Recipe{}, %{})

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
      <div :if={{ length(@recipes) > 0 }}>
        <h2 class="font-semibold text-xl text-center">Your Recipes</h2>
        <RecipeList id="recipes-list" recipes={{ @recipes }} publish="publish-recipe" />
      </div>
      <h2 :if={{ length(@recipes) == 0 }} class="font-semibold text-xl text-center">
        You haven't shared any recipes yet.
      </h2>
      <Modal id="recipe-modal" title={{ modal_title(@action) }} show={{ @show_modal }} >
        <Form for={{ @changeset }} change="validate" submit="save">
          <Field name={{ :name }} class="font-semibold text-md mb-2">
            <Label>Name</Label>
            <div class="mt-4">
              <TextInput class="text-xs p-2 bg-transparent border border-gray-400 rounded-md w-full" />
            </div>
          </Field>
          <Field name={{ :description }} class="font-semibold text-md mb-2">
            <Label>Instructions</Label>
            <div class="mt-4">
              <TextArea
                rows="6"
                class="text-xs p-2 bg-transparent border border-gray-400 rounded-md w-full" />
            </div>
          </Field>
          <Label class="font-semibold text-md mb-4">Ingredients</Label>
          <Inputs for={{ :ingredients }} :let={{ form: f, index: idx }} opts={{append: [%{}]}}>
            <div class="flex w-full my-4 items-center">
              <Field name={{ :quantity }} class="flex-grow">
                  <TextInput form={{ f }} field={{ :quantity }} opts={{ placeholder: "quantity", phx_input: "blur"}}
                  class="font-semibold text-md border border-gray-400 rounded-md p-2"/>
              </Field>
              <Field name={{ :name }} class="flex-grow">
                  <TextInput form={{ f }} field={{ :name }} opts={{ placeholder: "name"}}
                  class=" font-semibold text-md border border-gray-400 rounded-md p-2 mx-2"/>
              </Field>
              <button type="button" :if={{ num_ingredients(@changeset) > 1}} :on-click="remove-ingredient" phx-value-id={{ idx }}>
                {{ Heroicons.Solid.trash(class: "w-4 h-4") }}
              </button>
            </div>
          </Inputs>
          <div>
            <a href="#" :on-click="add_ingredient" class="text-blue-400 hover:text-blue-500 text-sm">Add a ingredient</a>
          </div>
          <Field name={{ :published }}>
            <Label>Publish</Label>
            <Checkbox />
          </Field>
          <Submit
           class="my-2 bg-blue-600 uppercase font-semibold p-2 rounded-md disabled:opacity-30"
           opts={{ disabled: not @changeset.valid? }}
          >Save</Submit>
        </Form>
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

    recipes |> IO.inspect()
  end

  @impl true
  def handle_event("publish-recipe", %{"id" => id}, socket) do
    Supabase.init(access_token: socket.assigns.access_token)
    |> Postgrestex.from("recipes")
    |> Postgrestex.update(%{"published" => true})
    |> Postgrestex.eq("id", id)
    |> Postgrestex.call()

    recipes = socket.assigns.recipes |> Enum.map(&set_published(&1, String.to_integer(id)))
    {:noreply, assign(socket, :recipes, recipes)}
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    IO.inspect(recipe_params)

    changeset =
      socket.assigns.recipe
      |> Recipes.change_recipe(recipe_params)
      |> Map.put(:action, :validate)

    IO.inspect({changeset.data, changeset.changes})
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    now = DateTime.utc_now()

    recipe_params =
      recipe_params
      |> Map.put("inserted_at", now)
      |> Map.put("updated_at", now)
      |> Map.put("user_id", socket.assigns.user["id"])
      |> Map.put(
        "ingredients",
        Map.values(Map.get(recipe_params, "ingredients", %{}))
      )

    ch = Recipes.change_recipe(get_recipe("new"), recipe_params)

    cond do
      ch.valid? ->
        Supabase.init(access_token: socket.assigns.access_token)
        |> Postgrestex.from("recipes")
        |> Postgrestex.insert(recipe_params)
        |> Postgrestex.call()
        |> Supabase.json()

        {:noreply,
         put_flash(socket, :info, "Recipe created successfully") |> push_redirect(to: "/recipes")}

      true ->
        {:noreply, assign(socket, :changeset, ch)}
    end
  end

  @impl true
  def handle_event("remove-ingredient", %{"id" => idx}, socket) do
    ingredients =
      Map.get(socket.assigns.changeset.changes, :ingredients, [])
      |> List.delete_at(String.to_integer(idx))

    changeset = socket.assigns.changeset |> Ecto.Changeset.put_embed(:ingredients, ingredients)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("add_ingredient", _values, socket) do
    existing_ingredients =
      Map.get(socket.assigns.changeset.changes, :ingredients, socket.assigns.recipe.ingredients)

    ingredients =
      existing_ingredients
      |> Enum.concat([
        Ingredient.changeset(%{}, %{})
      ])

    changeset = socket.assigns.changeset |> Ecto.Changeset.put_embed(:ingredients, ingredients)
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("open", %{"action" => action}, socket) do
    Modal.open("recipe-modal")

    recipe = get_recipe(action)
    changeset = Recipe.changeset(recipe, %{})

    {:noreply,
     assign(socket,
       recipe: recipe,
       changeset: changeset,
       show_modal: true,
       action: String.to_atom(action)
     )}
  end

  def get_recipe("new"), do: %Recipe{ingredients: []}

  defp modal_title(:new), do: "Create a new Recipe"
  defp modal_title(:edit), do: "Edit Recipe"

  defp num_ingredients(changeset) do
    length(changeset.data.ingredients) + length(Map.get(changeset.changes, :ingredients, []))
  end

  defp set_published(%{"id" => id} = recipe, id), do: Map.put(recipe, "published", true)
  defp set_published(recipe, _), do: recipe
end
