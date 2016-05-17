defmodule Fps do
	use Application
	use Silverb, [
		{"@dir2exec", Exutils.priv_dir(:fps)<>"/fproxy"},
		{"@memottl", :timer.minutes(10)}
	]
	require WwwestLite
	require Exutils

	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false

		children = [
		# Define workers and child supervisors to be supervised
		# worker(Fps.Worker, [arg1, arg2, arg3]),
		]

		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Fps.Supervisor]
		Supervisor.start_link(children, opts)
	end


	WwwestLite.callback_module do
		def handle_wwwest_lite(%{cmd: "countrylist"}), do: (list_countries |> Jazz.encode!)
		def handle_wwwest_lite(%{cmd: "proxylist", country: country}) do
			case list_countries do
				error = %{error: _} -> error
				countries = [_|_] ->
					country = Maybe.maybe_to_string(country) |> String.strip |> String.upcase |> Exutils.try_catch
					case Enum.member?(countries, country) do
						true -> list_proxies(country)
						false -> %{error: "country #{inspect country} is not supported"}
					end
			end
			|> Jazz.encode!
		end
		def handle_wwwest_lite(%{cmd: "proxylist"}), do: (list_proxies |> Jazz.encode!)
	end

	def list_proxies(country \\ nil), do: Tinca.smart_memo(&phantom_cmd/2, ["#{@dir2exec}/run.sh", (case country do ; nil -> [] ; bin when is_binary(bin) -> [bin] ; end)], &is_list/1, @memottl + :random.uniform(@memottl))
	def list_countries, do: Tinca.smart_memo(&phantom_cmd/2, ["phantomjs",["#{@dir2exec}/spys_counties.js"]], &is_list/1, @memottl + :random.uniform(@memottl))

	defp phantom_cmd(script, args) when is_binary(script) and is_list(args) do
		case System.cmd(script, args, [stderr_to_stdout: true, cd: @dir2exec]) do
			{text,0} when is_binary(text) ->
				case Jazz.decode(text) do
					{:ok, lst = [_|_]} -> lst
					error -> %{error: "phantom decode #{inspect [script, args]} error #{inspect error}"}
				end
			error ->
				%{error: "phantom get #{inspect [script, args]} error #{inspect error}"}
		end
	end

end
