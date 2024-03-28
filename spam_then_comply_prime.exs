#!/usr/bin/env elixir

require Logger

# Set up Logger to print nanoseconds and all log levels:
Logger.configure(level: :debug, format: "$time $metadata[$level] $message\n")

alias CachexTransactionInvalidation, as: CTI

Logger.info "We will spam twice and then comply with the 3 second rule."
Logger.info "This trigger two spam detection events, as after the second `increment`, the duration of cache validity is 3_250 ms."
Logger.info "Final result of the counter should be 2, not 3."

Logger.debug("1. #{CTI.get()}")
CTI.increment_prime()
Logger.debug("2. #{CTI.get()}")
CTI.increment_prime()
Logger.debug("3. #{CTI.get()}")

# Sleep for 3.01 seconds and then increment again
Process.sleep(3_010) |> inspect() |> Logger.debug()
CTI.increment_prime()
y = CTI.get()
Logger.debug("4. #{y}")
IO.puts(y)
