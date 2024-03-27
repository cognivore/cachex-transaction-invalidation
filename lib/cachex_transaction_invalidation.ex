defmodule CachexTransactionInvalidation do
  @moduledoc """
  Documentation for `CachexTransactionInvalidation`.
  """

  require Logger

  use Agent

  @timeout 3_000

  def start_link(_opts) do
    Logger.warn("Starting #{__MODULE__}")

    Agent.start_link(
      fn ->
        Cachex.put(:my_cache, "key", @timeout, ttl: @timeout)
        0
      end,
      name: __MODULE__
    )
  end

  def increment() do
    Agent.update(__MODULE__, fn count ->
      {:ok, y} =
        Cachex.transaction(:my_cache, ["key"], fn w ->
          cachex_tx(w, count |> IO.inspect(label: :count))
        end)

      y
    end)
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  defp cachex_tx(w, count) do
    case Cachex.get(w, "key") do
      {:ok, nil} ->
        Cachex.put(w, "key", @timeout, ttl: @timeout)
        count + 1

      {:ok, ttl} ->
        ttl = :math.pow(ttl, 1.01) |> round()
        Cachex.update(w, "key", ttl)
        Cachex.expire_at(w, "key", ttl)
        Logger.warn("Spam detected, increasing TTL to #{ttl}")
        count
    end
    |> IO.inspect(label: :pe)
  end
end
