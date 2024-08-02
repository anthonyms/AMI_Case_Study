defmodule ExAssignment.Services.WeightBasedSamplerTest do
  use ExUnit.Case

  alias ExAssignment.Services.WeightBasedSampler, as: Sampler

  describe "normalize_probabilities" do
    test "the sum of probabilities should be one" do
      items = %{walk: 5, shop: 5, work: 0.1, gym: 200}

      assert items
             |> Sampler.normalize_probabilities()
             |> Enum.reduce(0, fn {_key, value}, acc -> acc + value end) == 1
    end

    test "single item map has a probability of one" do
      items = %{walk: 100}

      assert Sampler.normalize_probabilities(items).walk == 1
    end

    test "returns an empty map when provided an empty map" do
      items = %{}

      assert Sampler.normalize_probabilities(items) == %{}
    end
  end

  describe "sample" do
    test "high weight items are more likely to be picked" do
      items = %{shop: 200, work: 20}

      frequencies = Stream.repeatedly(fn -> Sampler.sample(items) end)
        |> Enum.take(1000)
        |> Enum.frequencies()

      assert frequencies.shop > frequencies.work
    end

    test "it respects the relative weights" do
      items = %{shop: 200, work: 2}

      frequencies = Stream.repeatedly(fn -> Sampler.sample(items) end)
        |> Enum.take(1000)
        |> Enum.frequencies()

      assert frequencies.shop > frequencies.work * 50
      # assert_in_delta(frequencies.shop, frequencies.work * 100, 500)
    end

    test "single item map is always picked" do
      items = %{walk: 100}

      frequencies = Stream.repeatedly(fn -> Sampler.sample(items) end)
        |> Enum.take(100)
        |> Enum.frequencies()

      assert frequencies == %{walk: 100}
    end

    test "correctly handles invalid input" do
      non_map_input = [walk: 5, shop: 5, work: 0.1, gym: 200]
      empty_input = %{}
      zero_weight = %{walk: 5, shop: 5, work: 0.1, gym: 0}
      negative_weight = %{walk: 5, shop: 5, work: 0.1, gym: -200}
      non_numeric_weight = %{walk: ~c"5", shop: :abcd, work: 0.1, gym: 200}

      assert Sampler.sample(non_map_input) == nil
      assert Sampler.sample(empty_input) == nil
      assert Sampler.sample(zero_weight) == nil
      assert Sampler.sample(negative_weight) == nil
      assert Sampler.sample(non_numeric_weight) == nil
    end
  end
end
