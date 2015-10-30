defmodule Svradmin.PageController do
  use Svradmin.Web, :controller
  import Util
  require Logger
  alias Svradmin.History

  defmacro type_reload_confs do
    1 
  end

  defmacro type_reload_svr do
    2
  end

  defmacro type_reset_svr do
    3
  end


  def index(conn, _params) do
    render conn, "index.html", svrs: formated_svrs, historys: formated_historys 
  end

  def reload_confs(conn, %{"svr_id" => str_svr_id}) do
    {svr_id, _} = Integer.parse(str_svr_id)
    {result, remark} = case is_svr_live(svr_id) do
      :ignored ->
        {"serverNotLive", ""}
      false ->
        {"serverNotLive", ""}
      true -> 
        svr = get_svr(svr_id)
        %{:node=>node, :path=>path} = svr
        System.cmd("svn", ["up"], cd: path)
        IO.inspect({"path", path})
        case System.cmd("sh", ["make.sh"], cd: path <> "script") do
        #case System.cmd("/bin/rebar", ["compile"], cd: path) do
          {_, 0} ->
            reload(node, :data_confs)
            changeset = History.changeset(%History{}, %{"who" => conn.assigns.current_user.cn_name, "what" => type_reload_confs, "svr_id" => svr_id})
            Repo.insert(changeset)
            case validate_confs(node) do
              :ok -> {"success", ""}
              other -> {"validateFail", other} 
            end
          {fail_reason, 1} ->
            {"makeFail", fail_reason}
        end
    end
    IO.inspect({"result", result, remark})
    json conn, %{:result=>result, :remark=>remark}
  end

  def reload_svr(conn, %{"svr_id" => str_svr_id}) do
    {svr_id, _} = Integer.parse(str_svr_id)
    {result, remark} = case is_svr_live(svr_id) do
      :ignored ->
        {"serverNotLive", ""}
      false ->
        {"serverNotLive", ""}
      true -> 
        svr = get_svr(svr_id)
        %{:node=>node, :path=>path} = svr
        System.cmd("svn", ["up"], cd: path)
        case System.cmd("sh", ["make.sh"], cd: path <> "script") do
        #case System.cmd("rebar", ["compile"], cd: path <> "script") do
          {_, 0} ->
            reload(node, :all)
            changeset = History.changeset(%History{}, %{"who" => conn.assigns.current_user.cn_name, "what" => type_reload_svr, "svr_id" => svr_id})
            Repo.insert(changeset)
            case validate_confs(node) do
              :ok -> {"success", ""}
              other -> {"validateFail", other}
            end
          {fail_reason, 1} ->
            {"makeFail", fail_reason}
        end
    end
    json conn, %{:result=>result, :remark=>remark}
  end

  def reset_svr(conn, %{"svr_id" => str_svr_id}) do
    {svr_id, _} = Integer.parse(str_svr_id)
    svr = get_svr(svr_id)
    %{:path=>path, :node=>node} = svr
    case is_svr_live(svr_id) do
      false ->
        :ok
      true ->
        case Node.connect(node) do
          true -> :rpc.call(node, :xysvr, :server_stop, [])
          false -> raise "canNotConnectTheNode"
        end
    end
    #db_script_path = path <> "db_script"
    #:os.cmd(to_char_list("cd " <> db_script_path <> "; python init_db.py"))
    System.cmd("python", ["init_db.py"], cd: path <> "db_script")
    #script_path = path <> "script"
    #:os.cmd(to_char_list("cd " <> script_path <> "; python start_daemon_server.py"))
    System.cmd("python", ["start_daemon_server.py"], cd: path <> "script")
    changeset = History.changeset(%History{}, %{"who" => conn.assigns.current_user.cn_name, "what" => type_reset_svr, "svr_id" => svr_id})
    Repo.insert(changeset)
    json conn, %{:result=> "success"}
  end



  def svrs() do
    svr_conf = Application.get_env(:svradmin, :svr_conf)
    Keyword.get(svr_conf, :svrs, [])
    #[
    #  %{:id=>1, :node=>:"sanguo_1@192.168.0.5", :path=>"/home/dcy/sanguo/trunk/server/", :name=>"trunk服务器", :ip=>"192.168.0.5", :port=>1000, :log_port=>7001, :is_show=>true},
    #  %{:id=>2, :node=>:"sanguo_2@192.168.0.6", :path=>"/home/dcy/sanguo/trunk/server1/", :name=>"分支服务器", :ip=>"192.168.0.5", :port=>1000, :log_port=>7001, :is_show=>true}
    #]
  end



  ########private functions########
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

  defp formated_historys() do
    historys = Repo.all(from h in History, order_by: [desc: h.inserted_at], limit: 12)
    for history <- historys, do: formate_history(history)
  end

  defp formate_history(history) do
    %Svradmin.History{what: what, svr_id: svr_id, inserted_at: time, who: who} = history
    #what_str = case what do
    #  type_reload_confs -> "热更配置" 
    #  type_reload_svr -> "热更整服"
    #  type_reset_svr -> "清数据库"
    #end
    what_str = cond do
      type_reload_confs == what -> "热更配置"
      type_reload_svr == what -> "热更整服"
      type_reset_svr == what -> "清数据库"
    end
    svr = get_svr(svr_id)
    svr_name = svr.name
    %{:svr_name=>svr_name, :who=>who, :what=>what, :what_str=>what_str, :time=>time}
  end

  defp validate_confs(node) do
    case Node.connect(node) do
      true -> :rpc.call(node, :lib_validate, :validate_datas_for_rpc, [])
      false -> raise "canNotConnectTheNode"
    end
  end

  defp reload(node, modules) do 
    case Node.connect(node) do
      true ->
        fail_mods = :rpc.call(node, :xysvr_hu, :reload, [modules, "not_notify"])
        case fail_mods do
          [] -> Logger.debug("All Mods reload success")
          _ -> Logger.debug("These Mods reload fail: #{inspect fail_mods}")
        end
      false ->
        raise "canNotConnectTheNode"
    end
  end


end
