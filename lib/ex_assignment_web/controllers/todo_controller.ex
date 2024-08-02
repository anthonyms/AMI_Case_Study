defmodule ExAssignmentWeb.TodoController do
  use ExAssignmentWeb, :controller

  alias ExAssignment.Todos
  alias ExAssignment.Todos.Todo

  def index(conn, _params) do
    open_todos = Todos.list_todos(:open)
    done_todos = Todos.list_todos(:done)
    {:ok, conn, recommended_todo} = get_recommended_todo(conn)

    render(conn, :index,
      open_todos: open_todos,
      done_todos: done_todos,
      recommended_todo: recommended_todo
    )
  end

  def new(conn, _params) do
    changeset = Todos.change_todo(%Todo{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"todo" => todo_params}) do
    case Todos.create_todo(todo_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Todo created successfully.")
        |> redirect(to: ~p"/todos")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    render(conn, :show, todo: todo)
  end

  def edit(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    changeset = Todos.change_todo(todo)
    render(conn, :edit, todo: todo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Todos.get_todo!(id)

    case Todos.update_todo(todo, todo_params) do
      {:ok, todo} ->
        conn
        |> put_flash(:info, "Todo updated successfully.")
        |> redirect(to: ~p"/todos/#{todo}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, todo: todo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)
    {:ok, _todo} = Todos.delete_todo(todo)
    {:ok, conn} = refresh_recommended(conn, id)

    conn
    |> put_flash(:info, "Todo deleted successfully.")
    |> redirect(to: ~p"/todos")
  end

  def check(conn, %{"id" => id}) do
    :ok = Todos.check(id)
    {:ok, conn} = refresh_recommended(conn, id)

    conn
    |> redirect(to: ~p"/todos")
  end

  def uncheck(conn, %{"id" => id}) do
    :ok = Todos.uncheck(id)

    conn
    |> redirect(to: ~p"/todos")
  end

  @doc """
  Get the recommended todo from the session or fetch a new one and save it in the session.
    If there is no recommended todo return nil.
  """
  def get_recommended_todo(conn) do
    case get_session(conn, :recommended) do
      nil ->
        case Todos.get_recommended() do
          nil -> {:ok, conn, nil}
          recommended ->
            conn = put_session(conn, :recommended, Integer.to_string(recommended.id))
            {:ok, conn, recommended}
        end

      recommended_id ->
        recommended = Todos.get_todo!(recommended_id)
        {:ok, conn, recommended}
    end
  end

  @doc """
  Remove the recommended todo from the session if it matches the given id.
  """
  defp refresh_recommended(conn, id) do
    case get_session(conn, :recommended) do
      nil -> {:ok, conn}
      ^id ->  {:ok, delete_session(conn, :recommended)}
      _ -> {:ok, conn}
    end
  end
end
