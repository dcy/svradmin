defmodule Svradmin.PageController do
  use Svradmin.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
