defmodule CachexTransactionInvalidation.MixProject do
  use Mix.Project

  def project do
    [
      app: :cachex_transaction_invalidation,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CachexTransactionInvalidation.Otp.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cachex, git: "https://github.com/whitfin/cachex", branch: "main"}
    ]
  end
end
