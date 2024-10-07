import Config

config :azan_rest_api, port: 14240

import_config "#{Mix.env()}.exs"
