defmodule Svradmin.Router do
  use Svradmin.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Svradmin.Auth, repo: Svradmin.Repo
    plug Svradmin.Jsplug, resp: Svradmin.Repo
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
    post "/change_password", SessionController, :change_password 
    get "/get_users", UserController, :get_users

    post "/reload_confs", PageController, :reload_confs
    post "/reload_svr", PageController, :reload_svr
    post "/reset_svr", PageController, :reset_svr
    resources "/historys", HistoryController

    resources "/versions", VersionController
    get "/version_issues/:id", VersionController, :version_issues
    resources "/issues", IssueController
    get "/get_versions", VersionController, :get_versions
    get "/get_issue/:id", IssueController, :get_issue
    get "/newest_version", VersionController, :newest_version
  end

  # Other scopes may use custom stacks.
  # scope "/api", Svradmin do
  #   pipe_through :api
  # end
end
