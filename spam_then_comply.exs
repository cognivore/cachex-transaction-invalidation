#!/usr/bin/env elixir

alias CachexTransactionInvalidation, as: CTI

IO.inspect "Hello, World!"
CTI.get() |> IO.inspect()
IO.inspect "Current applications running in BEAM:"
IO.inspect :application.loaded_applications()

CTI.increment()
CTI.get() |> IO.inspect()
CTI.increment()
CTI.get() |> IO.inspect()

# Sleep for 3.01 seconds and then increment again
Process.sleep(3010)
CTI.increment()
CTI.get() |> IO.inspect()
