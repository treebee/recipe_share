defmodule RecipeShareWeb.Components.Modal do
  use Surface.LiveComponent

  prop(title, :string, required: true)
  prop(show, :boolean, default: false)
  slot(default)

  data(leave_duration, :integer, default: 300)

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={{ @id }}
      :hook="Modal"
      class={{ "modal fixed z-10 inset-0 overflow-y-auto" }}
      x-data="{ open: {{ @show }} }"
      x-init="() => {
        $watch('open', isOpen => {
          console.log({{ @show }})
          if (!isOpen) {
            modalHook.modalClosing({{ @leave_duration }})
          }
        })
      }"
      @keydown.escape.window="open = false"
      x-show="open"
      x-cloak
    >
      <div class="flex justify-center items-end text-center min-h-screen bg-black bg-opacity-50 px-4 sm:block sm:p-0">
        <div
          x-show="open"
          x-cloak
          x-transition:enter="ease-out duration-<%= @enter_duration %>"
          x-transition:enter-start="opacity-0"
          x-transition:enter-end="opacity-100"
          x-transition:leave="ease-in duration-<%= @leave_duration %>"
          x-transition:leave-start="opacity-100"
          x-transition:leave-end="opacity-0"
          class="fixed inset-0 transition-opacity" aria-hidden="true">
          <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
        </div>
        <!-- This element is to trick the browser into centering the modal contents. -->
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <div
          x-cloak
          x-show="open"
          @click.away="open = false"
          class="inline-block align-bottom bg-blueGray-600 rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:align-middle md:max-w-xl sm:max-w-lg sm:w-full" role="dialog" aria-modal="true" aria-labelledby="modal-headline"
          x-transition:enter="ease-out duration-<%= @enter_duration %>"
          x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave="ease-in duration-<%= @leave_duration %>"
          x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
        >
          <div class="modal-content bg-dark-900 p-4">
            <div class="inline-block align-botto text-left overflow-hidden shadow-xl transform transition-all sm:align-middle sm:max-w-lg sm:w-full" role="dialog" aria-modal="true" aria-labelledby="modal-headline">
              <div class="flex justify-between">
                <h3 class="text-lg leading-6 font-medium text-blueGray-200 mt-1" id="modal-headline">{{ @title }}</h3>
                <button :on-click="close" class={{ "px-3 py-1 rounded-md" }}>Back</button>
              </div>
            </div>
            <div class="p-4">
              <slot />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket), do: {:noreply, assign(socket, show: false)}

  @impl true
  def handle_event("open", _, socket), do: {:noreply, assign(socket, show: true)}

  @impl true
  def handle_event("modal-closed", _, socket) do
    {:noreply, assign(socket, show: false)}
  end

  def open(modal_id), do: send_update(__MODULE__, id: modal_id, show: true)
  def close(modal_id), do: send_update(__MODULE__, id: modal_id, show: false)
end
