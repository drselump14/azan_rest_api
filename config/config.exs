import Config

config :azan_rest_api, port: 4240

import_config "#{Mix.env()}.exs"
