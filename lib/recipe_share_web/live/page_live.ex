defmodule RecipeShareWeb.PageLive do
  use RecipeShareWeb, :surface_view

  data access_token, :string, default: nil

  @impl true
  def mount(_params, %{"access_token" => access_token}, socket) do
    send(self(), {:ensure_profile, access_token})
    socket = assign(socket, access_token: access_token)
    {:ok, assign_new(socket, :user, fn -> fetch_user(access_token) end)}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="recipe-main" :hook="SupabaseAuth">

    </div>
    """
  end

  @impl true
  def handle_info({:ensure_profile, access_token}, socket) do
    user = fetch_user(access_token) |> IO.inspect()

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
