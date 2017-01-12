defmodule Fps.Halter do
  use Silverb
  use ExActor.GenServer, export: :fps_halter
  require Logger
  @ttl :timer.hours(3)
  definit  do
    {:ok, nil, @ttl}
  end
  defcast reset, do: {:noreply, nil, @ttl}
  definfo :timeout do
    _ = Logger.error("got timeout ... halt vm")
    _ = :timer.sleep(5000)
    _ = :erlang.halt
    {:noreply, nil, @ttl}
  end
end
