defmodule Svradmin.Router do
  use Svradmin.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Svradmin.Auth, repo: Svradmin.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Svradmin do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/login", SessionController, :new
    resources "/users", UserController
    post "/reload_confs", PageController, :reload_confs
  end

  # Other scopes may use custom stacks.
  # scope "/api", Svradmin do
  #   pipe_through :api
  # end
end
