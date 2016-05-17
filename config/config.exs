# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :fps, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:fps, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :wwwest_lite,
	server_port: 9944,
	server_timeout: 120000, # timeout for all requests
	memo_ttl: 10000, # timeout for memorize json encode and decode
	callback_module: Fps, # here are handlers for requests
	post_data_type: :json # | :xml | :any # it's data type of post q for decoding
