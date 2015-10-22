defmodule Svradmin.PageController do
  use Svradmin.Web, :controller

  def index(conn, _params) do
    svrs = [%{:id=>1, :node=>"sanguo_1@192.168.0.5", :path=>"~/sanguo/trunk/server/", :name=>"fuck", :ip=>"192.168.0.5", :port=>1000, :log_port=>7000, :is_show=>true}]
    render conn, "index.html", svrs: svrs
  end
end
