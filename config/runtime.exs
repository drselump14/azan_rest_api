import Config

if config_env() == :prod do
  config :azan_rest_api, port: System.get_env("PORT") || 14240
end
