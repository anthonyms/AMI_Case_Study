defmodule ExAssignment.Services.TodoRecommender do
  @moduledoc """
  Module implementing the todo recommender service.
    This service recommends a random task based on the tasks priority. Tasks with lower priority have a high probability of being picked.

  The recommender makes use of a WeightBasedSampler service to randomly chose a
    task based on a tasks priority.
  """

  @doc """
  Returns the next todo that is recommended to be done by the system.

  ASSIGNMENT: ...
  """
  def recommend(todos) do
    case todos do
      [] -> nil
      todos -> todos |> Enum.take_random(1) |> List.first()
    end
  end
end
