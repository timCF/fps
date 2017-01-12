defmodule Fps.Mixfile do
  use Mix.Project

  def project do
    [app: :fps,
     version: "0.0.1",
     #elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [
						:logger,
						:silverb,
						:wwwest_lite,
						:tinca,
						:exutils,
						:jazz,
						:maybe,
						:exactor
					],
     mod: {Fps, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
	defp deps do
		[
			{:silverb, github: "timCF/silverb"},
			{:wwwest_lite, github: "timCF/wwwest_lite", tag: "e56d8441ec4c3d0905c8a919d4570523ef94ba47"},
			{:tinca, github: "timCF/tinca"},
			{:exutils, github: "timCF/exutils"},
			{:jazz, github: "meh/jazz"},
			{:maybe, github: "timCF/maybe"},
			{:exactor, github: "sasa1977/exactor", tag: "0467f8100bc735405d597dbf94996195eb31e0b6", override: true}
		]
	end
end
