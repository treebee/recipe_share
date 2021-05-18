defmodule RecipeShareWeb.UserManagementPage do
  use RecipeShareWeb, :surface_live_component

  alias RecipeShare.Accounts

  data users, :list, default: []
  prop access_token, :string, required: true

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [users: []]}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, :users, Accounts.list_users(access_token: assigns.access_token))

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto mt-20">
      <table class="border-collapse table-auto max-w-2xl w-full mx-auto whitespace-no-wrap table-striped relative rounded-md">
        <thead class="bg-blue-800 text-white py-2">
          <tr class="text-left py-4 bg-blue-600">
            <th class="py-4 rounded-tl-md"></th>
            <th class="py-4">Name</th>
            <th class="text-center py-4 rounded-tr-md">Role</th>
          </tr>
        </thead>
        <tbody id="users">
          <tr :for={{ user <- @users }} id="user-{{ user.id }}" class="border border-grey-100">
            <td class="py-2"><img class="rounded-full mx-4 my-2" width=40 height=40 src={{ user.avatar_url }} /></td>
            <td class="py-2">{{ user.username }}</td>
            <td class="text-center py-2"><span class="inline-flex items-center bg-blue-300 text-blue-700 font-semibold text-md rounded-lg px-2">{{ user.role }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
