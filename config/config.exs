# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :svradmin, Svradmin.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "hFu08L87XY+WxUbSMjUBz/dZI7FXELCXMP3xi+fKPBqVEhEykA3RHfHBcv2CD45d",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Svradmin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false


# Configure Something
config :svradmin, :svr_conf,
  redmine_host: "http://123.59.70.27:8888/",
  designer_states: [%{:name=>"未完成", :value=>0}, %{:name=>"已完成", :value=>1},
    %{:name=>"不需要", :value=>-1}],
  developer_role_id: 4,
  svrs: [
    %{:id=>1, :node=>:"sanguo_1@192.168.0.5", :path=>"/home/dcy/sanguo/trunk/server/", :name=>"trunk服务器", :ip=>"192.168.0.5", :port=>1000, :log_port=>7001, :is_show=>true},
    %{:id=>2, :node=>:"sanguo_2@192.168.0.6", :path=>"/home/dcy/sanguo/trunk/server1/", :name=>"分支服务器", :ip=>"192.168.0.6", :port=>1000, :log_port=>7001, :is_show=>true}
  ]
  
