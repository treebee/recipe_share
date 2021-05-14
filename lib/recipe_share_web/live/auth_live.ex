defmodule RecipeShareWeb.AuthLive do
  use Surface.LiveView

  alias SupabaseSurface.Components.Auth

  data user, :map, default: nil

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gray-800 h-screen pt-20 px-5">
      <div class="container mx-auto max-w-sm">
        <Auth id="supabase-auth"
         providers={{ ["github", "google"] }}
         />
      </div>
    </div>
    """
  end
end
