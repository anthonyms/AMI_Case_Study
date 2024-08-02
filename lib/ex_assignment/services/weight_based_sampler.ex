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


  Returns an item from the list selected based on the weights. Returns nil if provided with invalid input.
  The sampler is not responsible for inverting the weights. Callers should ensure that the weights are already inverted.
  """
  def sample(items) when map_size(items) == 0 do
    nil
  end

  def sample(items) do
    items
    |> normalize_probabilities()
    |> pick_random_by_weight()
    |> elem(0)
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

  defp pick_random_by_weight(items) do
    Enum.max_by(items, fn {_key, weight} -> :rand.uniform() ** (1 / weight) end)
  end
end
