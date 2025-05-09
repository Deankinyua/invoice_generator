# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :invoice_generator,
  ecto_repos: [InvoiceGenerator.Repo],
  generators: [timestamp_type: :utc_datetime]

# * Don't pay attention to this I was just playing with Application.get_env/3

config :invoice_generator, Databases.RepoOne,
  # A database configuration
  ip: "localhost",
  port: 5433

config :invoice_generator, Databases.RepoTwo,
  # Another database configuration (for the same OTP app)
  ip: "localhost",
  port: 20717

config :invoice_generator, invoice_generator_databases: [Databases.RepoOne, Databases.RepoTwo]

# *--------------------------------------------------#

# Configures the endpoint
config :invoice_generator, InvoiceGeneratorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: InvoiceGeneratorWeb.ErrorHTML, json: InvoiceGeneratorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: InvoiceGenerator.PubSub,
  live_view: [signing_salt: "18tXAzCs"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

config :invoice_generator, InvoiceGenerator.Mailer,
  adapter: Swoosh.Adapters.Brevo,
  api_key: System.get_env("BREVO_API_KEY")

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  invoice_generator: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  invoice_generator: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :types, %{
  "image/jpeg" => ["jpeg"],
  "image/png" => ["png"],
  "image/jpg" => ["jpg"]
  # "audio/x-ms-wma" => ["wma"]
}

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
