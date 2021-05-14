defmodule RecipeShareWeb.PageLive do
  use RecipeShareWeb, :surface_view

  alias RecipeShareWeb.Components.Page
  alias Surface.Components.Form
  alias Surface.Components.Form.Submit
  alias Surface.Components.LivePatch
  alias Surface.Components.LiveRedirect

  @default_pages [
    %{name: "index", module: RecipeShareWeb.IndexPage, icon: "view-grid"},
    %{name: "recipes", module: RecipeShareWeb.RecipePage, icon: "view-grid"}
  ]

  data page, :string, default: "index"
  data pages, :list, default: @default_pages
  data user, :map, default: %{}
  data access_token, :string, default: nil

  @impl true
  def mount(params, %{"access_token" => access_token}, socket) do
    send(self(), {:ensure_profile, access_token})

    socket =
      assign(socket, access_token: access_token)
      |> assign_page(params)

    {:ok, assign(socket, user: fetch_user(access_token))}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"page" => page}, _, socket) do
    {:noreply,
     assign(socket, :page, page)
     |> assign(
       :module,
       @default_pages
       |> Enum.find(fn entry -> entry.name == page end)
       |> Map.get(:module)
     )
     |> assign(:pages, @default_pages)}
  end

  @impl true
  def handle_params(_, _, socket), do: {:noreply, socket}

  defp assign_page(socket, %{"page" => page}), do: assign(socket, page: page)
  defp assign_page(socket, _), do: socket

  @impl true
  def render(assigns) do
    ~H"""
    <header class="bg-indigo-300">
      <nav role="navigation">
        <div class="container flex mx-auto items-center px-2 py-4">
          <div class="flex-1 text-2xl font-bold">
            <a href="/">Recipe Share</a>
          </div>
          <div class="flex-grow flex focus-within:ring-1 ring-indigo-500 rounded-md">
            <input
            class="p-3 rounded-l-md placeholder-gray-300 w-full focus:outline-none"
            placeholder="e.g. lasagne, pan cakes" />
            <button class="rounded-r-md px-4 py-2 bg-green-500 text-white focus:outline-none">
              {{ Heroicons.Outline.search(class: "w-4 h-4 stroke-2") }}
            </button>
          </div>
          <div class="text-right flex-1">
            <div
              x-data="{ open: false, loggedIn: {{ not is_nil(@access_token) }} }"
              x-cloak
              class="ml-3 relative">
              <div>
                <button
                  @click="open = !open"
                  @click.away="open = false"
                  class="btn-nav-icon ring-1 ring-indigo-500 text-indigo-500" id="user-menu" aria-haspopup="true"
                >
                  <span class="sr-only">Open user menu</span>
                  {{ Heroicons.Solid.user(class: "w-5 h-5") }}
                </button>
              </div>
              <div
                x-cloak
                x-show.transition="open"
                class="origin-top-right absolute right-0 z-10 mt-2 w-32 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5" role="menu" aria-orientation="vertical" aria-labelledby="user-menu">
                <LiveRedirect
                  :if={{ is_nil(@access_token) }}
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" opts={{ role: "menuitem" }}
                  to={{ Routes.auth_path(@socket, :index) }}
                >Login</LiveRedirect>
                <a href="#" x-show="!loggedIn" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">Register</a>
                <LivePatch
                  :if={{ not is_nil(@access_token) }}
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" opts={{ role: "menuitem" }}
                  to={{ Routes.page_path(@socket, :index, "recipes") }}
                >Your Recipes</LivePatch>

                <Form :if={{ not is_nil(@access_token) }} for={{ :logout }} action="/logout" method="post" opts={{ role: "menuitem"}}>
                  <Submit class="w-full text-right block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Logout</Submit>
                </Form>
              </div>
            </div>
          </div>
        </div>
      </nav>
    </header>
    <main role="main">
      <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="info">{{ live_flash(@flash, :info) }}</p>

      <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="error">{{ live_flash(@flash, :error) }}</p>

      <div>
        <Page page={{ @page }} user={{ @user }} access_token={{ @access_token }} />
      </div>
    </main>
    """
  end

  @impl true
  def handle_info({:ensure_profile, access_token}, socket) do
    user = fetch_user(access_token)

    username = Map.get(user, "user_metadata", %{}) |> Map.get("full_name")

    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("profiles")
         |> Postgrestex.eq("id", user["id"])
         |> Postgrestex.call()
         |> Supabase.json() do
      %{body: []} ->
        Supabase.init(access_token: access_token)
        |> Postgrestex.from("profiles")
        |> Postgrestex.insert(%{"username" => username, "id" => user["id"]})
        |> Postgrestex.call()

      _ ->
        nil
    end

    {:noreply, socket}
  end

  defp fetch_user(access_token) do
    {:ok, user} = Supabase.auth() |> GoTrue.get_user(access_token)
    user
  end
end
