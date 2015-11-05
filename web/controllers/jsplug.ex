defmodule Svradmin.Jsplug do
  import Plug.Conn
  #import Comeonin.Bcrypt, only: [checkpw: 2]
  import Phoenix.Controller
  alias Svradmin.Router.Helpers

  def init(default), do: default
  def call(conn, default), do: assign(conn, :apps, [])


end

