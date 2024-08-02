defmodule ExAssignment.Services.WeightBasedSampler do
  @moduledoc """
  A sampler that takes into consideration the weights of items when randomly selecting an item.
  Since the sampling is based on relative weights, we consider a weight of zero as invalid input.

  The sampling algorithm is based on the following articles.
  https://elixirforum.com/t/weight-based-random-sampling/23345/6
  https://gist.github.com/O-I/3e0654509dd8057b539a
  https://hexdocs.pm/weighted_random/WeightedRandom.html

  We chose an elixir implementation of the Ruby version.
  """

  @doc """
  Accepts a map of items with their corresponding weights
    %{walk: 0.5, shop: 0.5, work: 0.1, gym: 0.2}

  Returns an item from the list selected based on the weights.
  Returns nil if provided with invalid input. The following input is considered invalid
    1. -ve weight
    2. 0 weight
    3. non-numeric weight
    4. empty map

    The sampler is not responsible for inverting the weights. Callers should ensure that the weights are already inverted.
  """
  def sample(items) do
    with {:ok, items} <- validate_input(items),
         item <- _sample(items) do
      item
    else
      {:error, _reason} -> nil
    end
  end

  @doc """
    Normalizes the relative weights to probabilities. The sum of the normalized weights always equals 1
    %{walk: 0.3846}, {shop: 0.3846}, {work: 0.0769}, {gym: 0.1538}
  """

  # This function is made public so it can be tested
  def normalize_probabilities(items) do
    sum_of_weights = Enum.reduce(items, 0, fn {_key, value}, acc -> acc + value end)
    Enum.reduce(items, %{}, fn {key, value}, acc -> Map.put(acc, key, value / sum_of_weights) end)
  end

  defp validate_input(items) do
    cond do
      !is_map(items) -> {:error, :non_map_input}
      Enum.empty?(items) -> {:error, :empty_input}
      Enum.any?(items, fn {_key, value} -> value == 0 end) -> {:error, :zero_weight}
      Enum.any?(items, fn {_key, value} -> value < 0 end) -> {:error, :negative_weight}
      Enum.any?(items, fn {_key, value} -> !is_number(value) end) -> {:error, :non_numeric_weight}
      true -> {:ok, items}
    end
  end

  defp _sample(items) do
    items
    |> normalize_probabilities()
    |> pick_random_by_weight()
    |> elem(0)
  end

  defp pick_random_by_weight(items) do
    Enum.max_by(items, fn {_key, weight} -> :rand.uniform() ** (1 / weight) end)
  end
end
