defmodule CachexTransactionInvalidation.Otp.Application do
  @moduledoc """
  Start the cache from here.
  """

  require Logger

  use Application

  def start(_type, _args) do
    Logger.warn("Starting #{__MODULE__}")

    children = [
      {Cachex, name: :my_cache},
      CachexTransactionInvalidation
    ]

    opts = [strategy: :one_for_one, name: CachexTransactionInvalidation.Otp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
