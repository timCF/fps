defmodule Fps do
	use Application
	use Silverb, [
		{"@memottl", :timer.minutes(30)}
	]
	require WwwestLite
	require Exutils
	use Tinca, [:backups]

	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		Tinca.declare_namespaces
		children = [
		# Define workers and child supervisors to be supervised
			worker(Fps.Worker, [])
		]

		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Fps.Supervisor]
		Supervisor.start_link(children, opts)
	end


	WwwestLite.callback_module do
		def handle_wwwest_lite(%{cmd: "countrylist"}) do
			case Tinca.get(:list_countries, :backups) do
				nil -> %{error: "404 , countrylist is not available yet"}
				data = [_|_] -> data
			end
			|> Jazz.encode!
		end
		def handle_wwwest_lite(%{cmd: "proxylist", country: country}) do
			case Tinca.get(:list_countries, :backups) do
				nil -> %{error: "404 , countrylist is not available yet , can not get proxylist"}
				countries = [_|_] ->
					country = Maybe.maybe_to_string(country) |> String.strip |> String.upcase |> Exutils.try_catch
					case Enum.member?(countries, country) do
						true ->
							case Tinca.get({:list_proxies, country}, :backups) do
								nil -> %{error: "404 , proxylist for country #{country} is not available yet"}
								data = [_|_] -> data
							end
						false ->
							%{error: "country #{inspect country} is not supported"}
					end
			end
			|> Jazz.encode!
		end
		def handle_wwwest_lite(%{cmd: "proxylist"}) do
			case Tinca.get({:list_proxies, nil}, :backups) do
				nil -> %{error: "404 , proxylist is not available yet"}
				data = [_|_] -> data
			end
			|> Jazz.encode!
		end
	end

	defp dir2exec, do: Exutils.priv_dir(:fps)<>"/fproxy"

	def list_proxies(country \\ nil) do
		countryarg = (case country do ; nil -> [] ; bin when is_binary(bin) -> [bin] ; end)
		case Tinca.get({:list_proxies, nil}, :backups) do
			nil -> Tinca.smart_memo(&phantom_cmd/2, ["#{dir2exec}/run.sh", countryarg], &is_list/1, @memottl + :random.uniform(@memottl))
			proxylst = [_|_] ->
				case Tinca.smart_memo(&list_proxies_proc/2, [proxylst, countryarg], &is_list/1, @memottl + :random.uniform(@memottl)) do
					lst = [_|_] -> lst
					%{error: _} -> Tinca.smart_memo(&phantom_cmd/2, ["#{dir2exec}/run.sh", countryarg], &is_list/1, @memottl + :random.uniform(@memottl))
				end
		end
		|> process_backup({:list_proxies, country})
	end
	def list_countries do
		Tinca.smart_memo(&list_countries_proc/0, [], &is_list/1, @memottl + :random.uniform(@memottl))
		|> process_backup(:list_countries)
	end

	defp list_countries_proc do
		case list_proxies do
			lst = [_|_] -> phantom_cmd("phantomjs", ["--web-security=no","--proxy=#{Enum.random(lst)}","#{dir2exec}/spys_counties.js"])
			error = %{error: _} -> error
		end
	end
	defp list_proxies_proc(proxylst = [_|_], countryarg), do: phantom_cmd("phantomjs", ["--web-security=no","--proxy=#{Enum.random(proxylst)}","#{dir2exec}/spys.js"|countryarg])

	defp phantom_cmd(script, args) when is_binary(script) and is_list(args) do
		case System.cmd(script, args, [stderr_to_stdout: true, cd: dir2exec]) do
			{text,0} when is_binary(text) ->
				case String.strip(text) |> Jazz.decode do
					{:ok, lst = [_|_]} -> lst
					error -> %{error: "phantom decode #{inspect [script, args]} error #{inspect error} on text #{inspect text}"}
				end
			error ->
				%{error: "phantom get #{inspect [script, args]} error #{inspect error}"}
		end
	end

	defp process_backup(data = [_|_], etskey), do: Tinca.put(data, etskey, :backups)
	defp process_backup(error = %{error: _}, etskey) do
		case Tinca.get(etskey, :backups) do
			nil -> error
			data = [_|_] -> data
		end
	end

end
