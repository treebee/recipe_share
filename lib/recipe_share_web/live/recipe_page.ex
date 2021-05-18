defmodule RecipeShareWeb.RecipePage do
  use RecipeShareWeb, :surface_live_component

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, TextInput, Label, Inputs, Checkbox, TextArea, HiddenInput}
  alias Surface.Components.LiveFileInput
  alias RecipeShare.Recipes.{Recipe, Ingredient}
  alias RecipeShare.Recipes
  alias RecipeShareWeb.Components.Modal
  alias RecipeShareWeb.Components.RecipeList

  data action, :atom, default: :new
  data recipes, :list, default: []
  data show_modal, :boolean, default: false
  prop uploads, :struct, required: true

  data recipe, :map, default: %Recipe{}
  data changeset, :map, default: Recipe.changeset(%Recipe{}, %{})

  prop access_token, :string, required: true
  prop user, :map, required: true

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [recipes: []]}
  end

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
          class="rounded-md p-2 bg-green-500 hover:bg-green-600 active:bg-green-700 flex items-center"
          :on-click="open"
          phx-value-action={{ :new }}
        >
          {{ Heroicons.Outline.document(class: "w-4 h-4 mr-2") }}Create Recipe
        </button>
      </div>
      <div :if={{ length(@recipes) > 0 }}>
        <h2 class="font-semibold text-xl text-center">Your Recipes</h2>
        <div class="rounded-md py-2 my-4">
          <RecipeList
            id="recipe-list"
            recipes={{ @recipes }}
            publish="publish-recipe"
            delete="delete-recipe"
            edit="open"
          />
        </div>
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

          <Inputs for={{ :ingredients }} :let={{ form: f }}>
            <div class="flex w-full my-4 items-center">
              <Field name={{ :quantity }} class="flex-grow">
                  <TextInput form={{ f }} field={{ :quantity }} opts={{ placeholder: "quantity", phx_input: "blur"}}
                  class="font-semibold text-md border border-gray-400 rounded-md p-2"/>
              </Field>
              <Field name={{ :name }} class="flex-grow">
                  <TextInput form={{ f }} field={{ :name }} opts={{ placeholder: "name"}}
                  class=" font-semibold text-md border border-gray-400 rounded-md p-2 mx-2"/>
              </Field>
              <Field :if={{ temp_ingredient?(f) }} name={{ :temp_id }}>
                <HiddenInput form={{ f }} />
              </Field>
              <button :if={{ temp_ingredient?(f) }} type="button" :on-click="remove-ingredient" phx-value-id={{ Map.get(f.data, :temp_id, Map.get(Map.get(f, :changes, %{}), :temp_id)) }}>
                {{ Heroicons.Solid.trash(class: "w-4 h-4") }}
              </button>
              <Field :if={{ not temp_ingredient?(f) }} name={{ :delete }} class="block">
                <Checkbox form={{ f }}/>
              </Field>
            </div>
          </Inputs>
          <div>
            <a href="#" :on-click="add_ingredient" class="text-blue-400 hover:text-blue-500 text-sm my-2">Add a ingredient</a>
          </div>
          <Field name={{ :published }} class="my-2">
            <Label class="font-semibold mr-2">Publish recipe</Label>
            <Checkbox />
          </Field>
          <div>
            <div class="py-2 grid grid-cols-3 gap-1">
              <div class="block" :for={{ entry <- @uploads.recipe_picture.entries }}>
                {{ live_img_preview entry, width: 80 }}
                <button type="button" :on-click="cancel-upload" phx-value-ref={{ entry.ref }} aria-label="cancel">&times;</button>
                <div
                 class="my-2 text-red-400"
                 :for={{ err <- upload_errors(@uploads.recipe_picture, entry) }}
                >
                  <p>{{ error_to_string(err) }}</p>
                </div>
              </div>
            </div>
            <LiveFileInput upload={{ @uploads.recipe_picture }} />

          </div>
          <div class="flex justify-end my-2">
            <button
            type="submit"
            class="px-4 py-2 my-2 bg-blue-600 text-white uppercase font-semibold rounded-md disabled:opacity-30"
            disabled= {{ not @changeset.valid? }}
            >Save</button>
          </div>
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

    recipes
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
  def handle_event("delete-recipe", %{"id" => id}, socket) do
    socket =
      case Recipes.delete_recipe(id, socket.assigns.access_token) do
        {:ok, recipe} ->
          update(socket, :recipes, fn recipes -> [Map.put(recipe, "deleted", true) | recipes] end)
          |> put_flash(:info, "Successfully deleted recipe")

        {:error, _error} ->
          put_flash(socket, :danger, "Something went wrong")
      end

    {:noreply, push_patch(socket, to: "/recipes")}
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset =
      socket.assigns.recipe
      |> Recipes.change_recipe(recipe_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"recipe" => recipe_params}, %{assigns: %{action: :edit}} = socket) do
    socket =
      if socket.assigns.changeset.valid? do
        uploaded_files = handle_file_uploads(socket)

        case Recipes.update_recipe(
               socket.assigns.changeset,
               recipe_params,
               uploaded_files,
               socket.assigns.access_token
             ) do
          {:ok, recipe} ->
            update(socket, :recipes, fn recipes -> [recipe | recipes] end)
            |> push_patch(to: "/recipes")

            Modal.close("recipe-modal")

            put_flash(socket, :info, "Recipe updated successfully")
            |> update(:recipes, fn recipes -> [recipe | recipes] end)
            |> push_patch(to: "/recipes")

          error ->
            socket
        end
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"recipe" => recipe_params}, %{assigns: %{action: :new}} = socket) do
    uploaded_files = handle_file_uploads(socket)

    case Recipes.create_recipe(
           recipe_params,
           uploaded_files,
           socket.assigns.access_token,
           socket.assigns.user["id"]
         ) do
      {:ok, recipe} ->
        Modal.close("recipe-modal")

        {:noreply,
         put_flash(socket, :info, "Recipe created successfully")
         |> update(:recipes, fn recipes -> [recipe | recipes] end)
         |> push_patch(to: "/recipes")}

      {:error, ch} ->
        {:noreply, assign(socket, :changeset, ch)}
    end
  end

  @impl true
  def handle_event("remove-ingredient", %{"id" => id}, socket) do
    ingredients =
      socket.assigns.changeset.changes.ingredients
      |> Enum.reject(fn %{data: ingredient} -> Map.get(ingredient, :temp_id) == id end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:ingredients, ingredients)

    {:noreply, assign(socket, changeset: changeset, ingredients: ingredients)}
  end

  @impl true
  def handle_event("add_ingredient", _values, socket) do
    existing_ingredients =
      Map.get(socket.assigns.changeset.changes, :ingredients, socket.assigns.recipe.ingredients)

    ingredients =
      existing_ingredients
      |> Enum.concat([
        Ingredient.changeset(%Ingredient{temp_id: get_temp_id()}, %{})
      ])

    changeset = socket.assigns.changeset |> Ecto.Changeset.put_embed(:ingredients, ingredients)
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("open", %{"action" => "edit", "id" => id}, socket) do
    Modal.open("recipe-modal")
    recipe = Recipes.get_recipe!(id, socket.assigns.access_token)

    changeset = Recipe.changeset(recipe, %{})

    {:noreply,
     assign(socket,
       recipe: recipe,
       changeset: changeset,
       show_modal: true,
       action: :edit
     )}
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

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :recipe_picture, ref)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  def get_recipe("new"), do: %Recipe{}

  defp modal_title(:new), do: "Create a new Recipe"
  defp modal_title(:edit), do: "Edit Recipe"

  defp set_published(%{"id" => id} = recipe, id), do: Map.put(recipe, "published", true)
  defp set_published(recipe, _), do: recipe

  defp handle_file_uploads(socket) do
    consume_uploaded_entries(socket, :recipe_picture, fn %{path: path}, entry ->
      conn = Supabase.Connection.new()

      object_path = Path.join(socket.assigns.user["id"], entry.client_name)

      {:ok, _} =
        conn
        |> Supabase.Storage.Objects.create("recipe-pictures", object_path, path,
          content_type: entry.client_type
        )

      object_path
    end)
  end

  defp get_temp_id(),
    do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  defp temp_ingredient?(f) do
    not (is_nil(Map.get(f.data, :temp_id)) and
           is_nil(Map.get(Map.get(f, :changes, %{}), :temp_id)))
  end
end
