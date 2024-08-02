defmodule ExAssignment.Services.TodoRecommender do
  @moduledoc """
  Module implementing the todo recommender service.
    This service recommends a random task based on the task's priority. Tasks with lower priority have a high probability of being picked.

  The recommender makes use of a WeightBasedSampler service to randomly chose a
  task based on a task's priority.

  Task recommendation works as follows.
    1. Reject done todos
    2. Compute the reciprocals of the priorities of open todos. This is to ensure that lower priorities
       have a higher probability.
    3. Pass the todos with their inverted priorities to a weight based sampler service.

  E.g. The following tasks have the following inverted_priorities:
    todos = %{ "Prepare lunch" => 20, "Water flowers" => 50, "Shop groceries" => 60, "Buy new flower pots" => 130 }
    todos_with_inverted_priorities = %{ "Prepare lunch" => 0.05, "Water flowers" => 0.02, "Shop groceries" => 0.0167, "Buy new flower pots" => 0.0077 }
  """

  # Since 0 is a valid priority, we add a small delta to avoid division by zero.
  @zero 0.0001

  @doc """
  Returns the next todo recommended by the system.

  The result is a single recommended tasks if the argument list contains at least one open todo or nil.
  """
  def recommend(todos) do
    case todos do
      [] -> nil
      todos -> todos
        |> Enum.reject(fn todo -> todo.done end)
        |> Enum.map(fn todo -> %{todo | inverse_priority: compute_inverse_priority(todo.priority)} end)
        |> Enum.take_random(1)
        |> List.first()
    end
  end

  # Possibilities of handling 0 priority
  # 1. Reject the task?
  # 2. Replace with a number close to 0? ✓
  # 3. Raise an error
  defp compute_inverse_priority(priority) do
    case priority do
      0 -> @zero
      _ -> 1.0 / priority
    end
  end
end
