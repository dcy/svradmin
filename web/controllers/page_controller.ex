defmodule Svradmin.PageController do
  use Svradmin.Web, :controller
  import Util

  def index(conn, _params) do
    render conn, "index.html", svrs: formated_svrs
  end

  def reload_confs(conn, %{"svr_id" => str_svr_id}) do
    {svr_id, _} = Integer.parse(str_svr_id)
    result = case is_svr_live(svr_id) do
      false ->
        "serverNotLive"
      true -> 
        svr = get_svr(svr_id)
        %{:node=>node, :path=>path} = svr
        System.cmd("svn", ["up"], cd: path)
    end
    json conn, %{:result=>result}
  end









  def svrs() do
    [
      %{:id=>1, :node=>:"sanguo_1@192.168.0.5", :path=>"/home/dcy/sanguo/trunk/server/", :name=>"中文fuck", :ip=>"192.168.0.5", :port=>1000, :log_port=>7001, :is_show=>true},
      %{:id=>2, :node=>:"sanguo_2@192.168.0.6", :path=>"/home/dcy/sanguo/trunk/server1/", :name=>"fuck2", :ip=>"192.168.0.5", :port=>1000, :log_port=>7001, :is_show=>true}
    ]
  end


  ########private functions########
  defp is_svr_live(svr_id) do
    svr = get_svr(svr_id)
    %{:node=>node} = svr
    is_node_live(node)
  end

  defp get_svr(svr_id) do
    svrs = svrs()
    mapskeyfind(svr_id, :id, svrs)
  end

  defp is_node_live(node) do
    Node.connect(node)
  end

  defp is_svr_live(svr_id) do
    svr = get_svr(svr_id)
    %{:node=>node} = svr
    is_node_live(node)
  end

  defp format_svr(svr) do
    %{:node=>node} = svr
    is_live = is_node_live(node)
    Map.put(svr, :is_live, is_live)
  end

  defp formated_svrs() do
    svrs = svrs()
    for svr <- svrs, do: format_svr(svr)
  end
end
