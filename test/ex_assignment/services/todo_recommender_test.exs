defmodule ExAssignment.Services.TodoRecommenderTest do
  use ExAssignment.DataCase

  alias ExAssignment.Services.TodoRecommender, as: Recommender

  describe "recommend" do
    import ExAssignment.TodosFixtures

    @closed_attrs %{done: true}
    @open_attrs %{done: false}
    @zero_priority_attrs %{priority: 0, done: false}

    test "returns nil when supplied with an empty list of todos" do
      todos = []
      assert Recommender.recommend(todos) == nil
    end

    test "returns nil when supplied with a list without any open todos" do
      todos = [todo_fixture(@closed_attrs), todo_fixture(@closed_attrs)]
      assert Recommender.recommend(todos) == nil
    end

    test "returns the single open todo when supplied with a list having only one open todo" do
      open_todo = @open_attrs
        |> todo_fixture()
        |> assign_inverted_priority()

      closed_todos = [todo_fixture(@closed_attrs), todo_fixture(@closed_attrs)]

      recommended_todo = closed_todos
        |> Enum.concat([open_todo])
        |> Recommender.recommend()

      assert recommended_todo == open_todo
    end

    test "does not return closed todos" do
      open_todos = Enum.map([todo_fixture(@open_attrs), todo_fixture(@open_attrs)], fn todo -> assign_inverted_priority(todo) end)
      closed_todos = [todo_fixture(@closed_attrs), todo_fixture(@closed_attrs)]

      recommended_todo = closed_todos
        |> Enum.concat(open_todos)
        |> Recommender.recommend()

      assert Enum.member?(open_todos, recommended_todo)
      refute Enum.member?(closed_todos, recommended_todo)
    end

    test "does not error with zero priority" do
      todo = @zero_priority_attrs
        |> todo_fixture()
        |> assign_inverted_priority()

      assert Recommender.recommend([todo]) == todo
    end

    test "tasks with lower priorities are more likely to be picked" do
      todos = for n <- 1..10 do
        todo_fixture(%{priority: n * 10, done: false})
      end

      frequencies = Stream.repeatedly(fn -> Recommender.recommend(todos) end)
                    |> Enum.take(100)
                    |> Enum.frequencies()
                    |> Enum.to_list()

      first_todo = frequencies |> List.first
      last_todo = frequencies |> List.last

      assert elem(first_todo,0).id < elem(last_todo,0).id
      assert elem(first_todo,1) > elem(last_todo,1)
    end
  end

  defp assign_inverted_priority(todo) do
    %{todo | inverse_priority: Recommender.compute_inverse_priority(todo.priority)}
  end
end
