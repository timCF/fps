defmodule Fps.Worker do
	use Silverb, [{"@ttl",333}]
	use ExActor.GenServer, export: true
	require Logger
	definit  do
		{:ok, nil, @ttl}
	end
	definfo :timeout do
		_ = case Fps.list_proxies do
			%{error: error} -> Logger.error(error)
			[_|_] -> :ok
		end
		case Fps.list_countries do
			%{error: error} ->
				Logger.error(error)
			lst = [_|_] ->
				Enum.shuffle(lst)
				|> Exutils.pmap_lim(1, 20, fn(country) ->
					_ = Fps.Halter.reset()
					_ = case Fps.list_proxies(country) do
						%{error: error} -> Logger.error(error)
						[_|_] -> :ok
					end
					:timer.sleep(@ttl)
				end)
		end
		{:noreply, nil, @ttl}
	end
end
