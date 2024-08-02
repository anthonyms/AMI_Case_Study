defmodule ExAssignmentWeb.TodoControllerTest do
  use ExAssignmentWeb.ConnCase

  import ExAssignment.TodosFixtures

  describe "index" do
    test "lists all todos", %{conn: conn} do
      open_todo = todo_fixture(%{done: false})
      done_todos = todo_fixture(%{done: true})

      conn = get(conn, ~p"/todos")

      assert html_response(conn, 200)
      assert conn.assigns.open_todos == [open_todo]
      assert conn.assigns.done_todos == [done_todos]
      assert conn.assigns.recommended_todo == open_todo
      assert get_session(conn, :recommended) == Integer.to_string(open_todo.id)
    end

    test "it does not error out when there are no open todos", %{conn: conn} do
      conn = get(conn, ~p"/todos")
      assert conn.status == 200
    end
  end

  # https://elixirforum.com/t/following-redirection-in-controllertests/10084/2
  describe "check" do
    test "it removes a checked recommended todo from the session", %{conn: conn} do
      todo = todo_fixture(%{done: false, priority: 1})

      conn = get(conn, ~p"/todos") # populate session with recommended todo
      assert conn.assigns.recommended_todo == todo

      conn = put(conn, ~p"/todos/#{todo.id}/check")
      assert "/todos" = redirect_path = redirected_to(conn, 302)

      conn = get(recycle(conn), redirect_path)
      assert conn.assigns.recommended_todo != todo
    end
  end

  # https://elixirforum.com/t/following-redirection-in-controllertests/10084/2
  describe "delete" do
    test "it removes a deleted recommended todo from the session", %{conn: conn} do
      todo = todo_fixture(%{done: false, priority: 1})

      conn = get(conn, ~p"/todos") # populate session with recommended todo
      assert conn.assigns.recommended_todo == todo

      conn = delete(conn, ~p"/todos/#{todo.id}")
      assert "/todos" = redirect_path = redirected_to(conn, 302)

      conn = get(recycle(conn), redirect_path)
      assert conn.assigns.recommended_todo != todo
    end
  end
end
