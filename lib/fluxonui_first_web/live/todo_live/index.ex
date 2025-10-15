defmodule FluxonUIFirstWeb.TodoLive.Index do
  use FluxonUIFirstWeb, :live_view

  alias FluxonUIFirst.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Todos
        <:actions>
          <.button variant="solid" navigate={~p"/todos/new"}>
            <.icon name="hero-plus" /> New Todo
          </.button>
        </:actions>
      </.header>

      <.table id="todos">
        <.table_head>
          <:col>Description</:col>
          <:col>Due</:col>
          <:col>Actions</:col>
        </.table_head>
        <.table_body>
          <.table_row
            :for={{id, todo} <- @streams.todos}
            id={"##{id}"}
            phx-click={JS.navigate(~p"/todos/#{todo}")}
            class="cursor-pointer hover:bg-accent/50"
          >
            <:cell>{todo.description}</:cell>
            <:cell>{todo.due}</:cell>
            <:cell>
              <div class="sr-only">
                <.link navigate={~p"/todos/#{todo}"}>Show</.link> |
              </div>
              <.link navigate={~p"/todos/#{todo}/edit"}>Edit</.link>
              |
              <.link
                phx-click={JS.push("delete", value: %{id: todo.id}) |> hide("##{id}")}
                data-confirm="Are you sure?"
              >
                Delete
              </.link>
            </:cell>
          </.table_row>
        </.table_body>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Todos.subscribe_todos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Todos")
     |> stream(:todos, list_todos(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(socket.assigns.current_scope, id)
    {:ok, _} = Todos.delete_todo(socket.assigns.current_scope, todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  @impl true
  def handle_info({type, %FluxonUIFirst.Todos.Todo{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :todos, list_todos(socket.assigns.current_scope), reset: true)}
  end

  defp list_todos(current_scope) do
    Todos.list_todos(current_scope)
  end
end
