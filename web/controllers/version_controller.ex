defmodule Svradmin.VersionController do
  use Svradmin.Web, :controller

  alias Svradmin.Version
  alias Svradmin.Issue
  alias Svradmin.User
  alias Svradmin.Router.Helpers

  plug :scrub_params, "version" when action in [:create, :update]

  def index(conn, _params) do
    versions = Repo.all(from v in Version, order_by: [desc: v.inserted_at])
    render(conn, "index.html", versions: versions)
  end

  def new(conn, _params) do
    changeset = Version.changeset(%Version{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"version" => version_params}) do
    changeset = Version.changeset(%Version{}, version_params)

    case Repo.insert(changeset) do
      {:ok, _version} ->
        conn
        |> put_flash(:info, "Version created successfully.")
        |> redirect(to: version_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    version = Repo.get!(Version, id)
    render(conn, "show.html", version: version, apps: ["version_detail"])
  end

  def edit(conn, %{"id" => id}) do
    version = Repo.get!(Version, id)
    changeset = Version.changeset(version)
    render(conn, "edit.html", version: version, changeset: changeset)
  end

  def update(conn, %{"id" => id, "version" => version_params}) do
    version = Repo.get!(Version, id)
    changeset = Version.changeset(version, version_params)

    case Repo.update(changeset) do
      {:ok, version} ->
        conn
        |> put_flash(:info, "Version updated successfully.")
        |> redirect(to: version_path(conn, :show, version))
      {:error, changeset} ->
        render(conn, "edit.html", version: version, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    version = Repo.get!(Version, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(version)

    conn
    |> put_flash(:info, "Version deleted successfully.")
    |> redirect(to: version_path(conn, :index))
  end

  #def version_issues(conn, %{"id" => id}) do
  #  issues = Repo.all(from i in Issue, where: i.version_id == ^id)
  #  {_, start, _} = :os.timestamp
  #  formated_issues = for issue <- issues, do: format_issue(issue)
  #  {_, endtime, _} = :os.timestamp
  #  IO.inspect({"****cost secs", endtime - start})
  #  json conn, %{:issues => formated_issues} 
  #end
  def version_issues(conn, %{"id" => id}) do
    issues = Repo.all(from i in Issue, where: i.version_id == ^id)
    parent = self
    for issue <- issues, do: spawn fn -> format_issue(parent, issue) end
    all_issues = recv([], length(issues))
    #all_issues = for issue <- issues, do: format_issue(self, issue)
    json conn, %{:issues => all_issues} 
  end

  defp recv(issues, amount) do
    case length(issues) >= amount do
      true ->
        Util.mapskeysort(:id, issues)
      false ->
        receive do
          {:issue, issue} ->
            new_issues = [issue | issues]
            recv(new_issues, amount)
        end
    end
  end
          
        

  def get_versions(conn, _params) do
    json conn, %{:versions => get_versions}
  end

  def newest_version(conn, _params) do
    versions = get_versions()
    case versions do
      [] ->
        conn
        |> put_flash(:error, "还没有版本, 新建一个吧")
        |> redirect(to: Helpers.version_path(conn, :new))
        |> halt()
        #redirect conn, to: "/versions/new"
      _ ->
        [version | _] = versions
        version_id = version.id
        redirect conn, to: "/versions/" <> Integer.to_string(version_id)
    end
  end





  defp get_versions() do
    versions = Repo.all(from v in Version, order_by: [desc: v.inserted_at])
    for version <- versions, do: %{id: version.id, name: version.name}
  end

  defp get_designer_state_name(state_id) do
    designer_states = Util.get_conf(:designer_states)
    state = Util.mapskeyfind(state_id, :value, designer_states)
    state.name
  end

  #defp format_issue(issue) do
  #  %Issue{id: id, title: title, content: content, designer_id: designer_id, is_done_design: is_done_design,
  #    frontend_id: frontend_id, backend_id: backend_id, remark: remark} = issue
  #  designer = Repo.get!(User, designer_id)
  #  designer_name = designer.cn_name
  #  designer_state_name = get_designer_state_name(is_done_design)
  #  frontend_redmine = format_redmine_state(frontend_id)
  #  backend_redmine = format_redmine_state(backend_id)
  #  %{id: id, title: title, content: content, designer_name: designer_name,
  #    designer_state_name: designer_state_name, frontend_state: format_redmine_state(frontend_id),
  #    backend_state: format_redmine_state(backend_id), remark: remark}
  #end
  defp format_issue(parent, issue) do
    %Issue{id: id, title: title, content: content, designer_id: designer_id, is_done_design: is_done_design, designer_infos: str_designer_infos,
      frontend_ids: ori_frontend_ids, backend_ids: ori_backend_ids, remark: remark} = issue
    ori_designer_infos = case str_designer_infos do
      "" -> []
      _ -> Poison.decode!(str_designer_infos)
    end
    frontend_ids = String.split(ori_frontend_ids, ",")
    backend_ids = String.split(ori_backend_ids, ",")
    designer = Repo.get!(User, designer_id)
    designer_name = designer.cn_name
    designer_state_name = get_designer_state_name(is_done_design)
    designer_infos = format_designer_infos(ori_designer_infos)
    frontend_states = for frontend_id <- frontend_ids, do: format_redmine_state(frontend_id)
    backend_states = for backend_id <- backend_ids, do: format_redmine_state(backend_id)
    formated_issue = %{id: id, title: title, content: content, designer_name: designer_name,
      designer_state_name: designer_state_name, designer_infos: designer_infos, frontend_states: frontend_states,
      backend_states: backend_states, remark: remark}
    send parent, {:issue, formated_issue}
  end

  defp format_designer_infos(designer_infos) do
    IO.inspect({"***designer_infos", designer_infos})
    fun = fn designer_info ->
      %{"designer_id" => designer_id, "is_done_design" => is_done_design} = designer_info
      designer = Repo.get!(User, designer_id)
      designer_name = designer.cn_name
      designer_state_name = get_designer_state_name(is_done_design)
      %{designer_id: designer_id, designer_name: designer_name, designer_state_name: designer_state_name}
    end
    Enum.map(designer_infos, fun)
  end


  defp format_redmine_state(redmine_id) do
    case redmine_id == nil or redmine_id == 0 or redmine_id == "0" or redmine_id == "" do
      true ->
        empty_redmine_state()
      false ->
        svr_conf = Application.get_env(:svradmin, :svr_conf)
        redmine_host = Keyword.get(svr_conf, :redmine_host, [])
        url = redmine_host <> "issues/" <> redmine_id <> ".json?include=attachments,journals"
        %HTTPotion.Response{body: body} = HTTPotion.get url
        case body do
          " " ->
            empty_redmine_state()
          _ ->
            datas = Poison.decode!(body)
            %{"issue" => issue_datas} = datas
            assign_to_id = issue_datas["assigned_to"]["id"]
            assign_to_name = issue_datas["assigned_to"]["name"]
            estimated_days = Map.get(issue_datas, "estimated_hours", "")
            %{"journals" => journals} = issue_datas
            journal_users = for j <- journals, do: %{id: j["user"]["id"], name: j["user"]["name"]}
            users = [%{id: assign_to_id, name: assign_to_name} | journal_users]
            develper_name = find_developer(users)
            status_name = issue_datas["status"]["name"]
            status_id = issue_datas["status"]["id"]
            url = redmine_host <> "/issues/" <> redmine_id
            %{url: url, developer_name: develper_name, status_id: status_id, status_name: status_name,
              estimated_days: estimated_days}
        end
    end
  end

  defp empty_redmine_state() do
    %{:url=>"", :developer_name=>"", :status_id=>"", :status_name=>"", :estimated_days=>""}
  end

  defp find_developer([]) do
    ""
  end
  defp find_developer([user | users]) do
    %{:id => user_id, :name => user_name} = user
    svr_conf = Application.get_env(:svradmin, :svr_conf)
    redmine_host = Keyword.get(svr_conf, :redmine_host, [])
    developer_role_id = Keyword.get(svr_conf, :developer_role_id, [])
    url = redmine_host <> "users/" <> Integer.to_string(user_id) <> ".json?include=memberships"
    %HTTPotion.Response{body: body} = HTTPotion.get url
    case body do
      "" ->
        ""
      _ ->
        datas = Poison.decode!(body)
        memberships = datas["user"]["memberships"]
        case is_developer_membership(memberships, developer_role_id) do
          true -> user_name
          false -> find_developer(users)
        end
    end
  end

  defp is_developer_membership([], _developer_role_id) do
    false
  end
  defp is_developer_membership([membership | memberships], developer_role_id) do
    roles = membership["roles"]
    case is_role(roles, developer_role_id) do
      true -> true
      false -> is_developer_membership(memberships, developer_role_id)
    end
  end

  defp is_role([], _role_id) do
    false
  end
  defp is_role([role | roles], role_id) do
    case role["id"] == role_id do
      true -> true
      false -> is_role(roles, role_id)
    end
  end



end
