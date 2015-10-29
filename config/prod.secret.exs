use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :svradmin, Svradmin.Endpoint,
  secret_key_base: "uQBIpYk8y80hVTEIeU7dYOEhsCzxmAMv31qSkZwf5NlZ7VqSZdgPDAXvk42y4S8j"

# Configure your database
config :svradmin, Svradmin.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "xy123",
  database: "svradmin_prod",
  pool_size: 20
