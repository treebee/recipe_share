defmodule RecipeShareWeb.UserManagementPage do
  use RecipeShareWeb, :surface_live_component

  alias Surface.Components.Form
  alias Surface.Components.Form.{Label, Select, Field}
  alias RecipeShare.Accounts
  alias RecipeShareWeb.Components.Modal

  data users, :list, default: []
  data user_role, :string, default: "user"
  data show_modal, :boolean, default: false
  data role_change, :string, default: "3"
  prop access_token, :string, required: true
  prop user, :map, required: true

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [users: []]}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      assign(socket,
        users: Accounts.list_users(access_token: assigns.access_token),
        user_role: Accounts.get_role!(assigns.access_token, assigns.user["id"]).id
      )

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
            <th class="text-center py-4">Role</th>
            <th class="text-right rounded-tr-md"></th>
          </tr>
        </thead>
        <tbody id="users">
          <tr :for={{ user <- @users }} id="user-{{ user.id }}" class="border border-grey-100">
            <td class="py-2"><img class="rounded-full mx-4 my-2" width=40 height=40 src={{ user.avatar_url }} /></td>
            <td class="py-2">{{ user.username }}</td>
            <td class="text-center py-2"><span class="inline-flex items-center bg-blue-300 text-blue-700 font-semibold text-md rounded-lg px-2">{{ user.role }}</span></td>
            <th class="text-right">
              <button type="button"
                :if={{ @user_role == 1 }}
                class="rounded-full p-2 mx-2"
                :on-click="edit"
                phx-value-id={{ user.id }}
              >
                {{ Heroicons.Outline.pencil(class: "w-4 h-4")}}
              </button>
            </th>
          </tr>
        </tbody>
      </table>
      <Modal id="user-modal" title="Manage Roles" show={{ @show_modal }}>
        <Form for={{ :user_role }} change="validate" submit="save">
          <div class="flex justify-between items-center">
          <Field name={{ "role" }} class="font-semibold text-md mb-2 mr-2">
            <Label>Role</Label>
            <Select
              class="border border-indigo-200"
              form={{ :user_role }} field="role" selected={{ @role_change }} options={{ "Admin": "1", "Moderator": "2", "User": "3" }} />
          </Field>
          <button type="submit" class="px-4 py-2 bg-blue-600 text-white uppercase font-semibold rounded-md">save</button>
          </div>
        </Form>
      </Modal>
    </div>
    """
  end

  @impl true
  def handle_event("validate", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("save", %{"user_role" => %{"role" => role_id}}, socket) do
    Accounts.update_user_role(socket.assigns.access_token, socket.assigns.user_change.id, role_id)

    user_change = Map.put(socket.assigns.user_change, :role_id, role_id)
    {:noreply, update(socket, :users, fn users -> [user_change | users] end)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    Modal.open("user-modal")
    user_change = Accounts.get_user!(socket.assigns.access_token, id)

    {:noreply,
     assign(socket, show_modal: true, role_change: user_change.role_id, user_change: user_change)}
  end
end
