defmodule CachexTransactionInvalidation do
  @moduledoc """
  Documentation for `CachexTransactionInvalidation`.
  """

  require Logger

  use Agent

  @timeout 3_000

  @spec start_link(any()) :: {:error, any()} | {:ok, pid()}
  def start_link(_opts) do
    Logger.warn("Starting #{__MODULE__}")

    Agent.start_link(
      fn ->
        0
      end,
      name: __MODULE__
    )
  end

  @spec increment() :: :ok
  def increment() do
    Logger.info("Maybe incrementing the counter @ #{expat(0)}")

    Agent.update(__MODULE__, fn count ->
      {:ok, y} =
        Cachex.transaction(:my_cache, ["key"], fn w ->
          cachex_tx(w, count)
        end)

      y
    end)
  end

  @spec increment_prime() :: :ok
  def increment_prime() do
    Logger.info("Maybe incrementing' the counter @ #{expat(0)}")

    Agent.update(__MODULE__, fn count ->
      {:ok, y} =
        Cachex.transaction(:my_cache, ["key"], fn w ->
          cachex_tx(w, count, false)
        end)

      y
    end)
    |> tap(fn _ ->
      {tau1, ttl} = Cachex.get(:my_cache, "key") |> elem(1)
      Logger.warn("Updating TTL to #{ttl} (#{tau1}) outside the transaction")
      Cachex.expire_at(:my_cache, "key", tau1)
    end)
  end

  @spec get() :: non_neg_integer()
  def get() do
    Agent.get(__MODULE__, & &1)
  end

  @spec cachex_tx(Cachex.t(), non_neg_integer()) :: non_neg_integer()
  @spec cachex_tx(Cachex.t(), non_neg_integer(), boolean()) :: non_neg_integer()
  def cachex_tx(w, count, update_expiration \\ true) do
    case Cachex.get(w, "key") do
      {:ok, nil} ->
        Logger.warn("No cache entry found in #{inspect(w)}, creating one.")
        Cachex.put(w, "key", {expat(@timeout), @timeout}, ttl: @timeout)
        count + 1

      {:ok, {tau, ttl}} ->
        Logger.warn("Spam detected")
        Logger.debug("Was: #{tau} (#{ttl})")
        ttl = exponential_timeout(ttl)
        tau1 = tau + ttl
        Logger.debug("Will be: #{tau1} (#{ttl})")
        Cachex.update(w, "key", {tau1, ttl} |> IO.inspect())

        if update_expiration do
          Logger.warn("Increasing TTL to #{ttl} (#{tau1}) inside the transaction")
          Cachex.expire_at(w, "key", tau1)
        end

        count
    end
  end

  @spec expat(pos_integer()) :: pos_integer()
  def expat(ttl) do
    1_000 * DateTime.to_unix(DateTime.utc_now()) + ttl
  end

  @spec exponential_timeout(pos_integer()) :: pos_integer()
  def exponential_timeout(timeout) do
    :math.pow(timeout, 1.01) |> round()
  end
end
