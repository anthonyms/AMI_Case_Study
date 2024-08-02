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
  end
end
