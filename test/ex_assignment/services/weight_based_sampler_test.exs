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

      frequencies =
        fn -> Sampler.sample(items) end
        |> Stream.repeatedly()
        |> Enum.take(1000)
        |> Enum.frequencies()

      assert frequencies.shop > frequencies.work * 50
      # assert_in_delta(frequencies.shop, frequencies.work * 100, 500)
    end

    test "single item map is always picked" do
      items = %{walk: 100}
      runs = 100

      frequencies = Stream.repeatedly(fn -> Sampler.sample(items) end)
      |> Enum.take(runs)
      |> Enum.frequencies()

      assert frequencies == %{walk: runs}
    end
  end
end
