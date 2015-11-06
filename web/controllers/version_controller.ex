defmodule Svradmin.VersionController do
  use Svradmin.Web, :controller

  alias Svradmin.Version
  alias Svradmin.Issue
  alias Svradmin.User

  plug :scrub_params, "version" when action in [:create, :update]

  def index(conn, _params) do
    versions = Repo.all(Version)
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

  def version_issues(conn, %{"id" => id}) do
    issues = Repo.all(from i in Issue, where: i.version_id == ^id)
    formated_issues = for issue <- issues, do: format_issue(issue)
    IO.inspect(formated_issues)
    json conn, %{:issues => formated_issues} 
  end

  defp get_designer_state_name(state_id) do
    designer_states = Util.get_conf(:designer_states)
    state = Util.mapskeyfind(state_id, :value, designer_states)
    state.name
  end

  defp format_issue(issue) do
    %Issue{title: title, content: content, designer_id: designer_id, is_done_design: is_done_design,
      frontend_id: frontend_id, backend_id: backend_id, remark: remark} = issue
    designer = Repo.get!(User, designer_id)
    designer_name = designer.cn_name
    designer_state_name = get_designer_state_name(is_done_design)
    frontend_redmine = format_redmine_state(frontend_id)
    backend_redmine = format_redmine_state(backend_id)
    %{title: title, content: content, designer_name: designer_name,
      designer_state_name: designer_state_name, frontend_state: format_redmine_state(frontend_id),
      backend_state: format_redmine_state(backend_id), remark: remark}
  end


  defp format_redmine_state(redmine_id) do
    svr_conf = Application.get_env(:svradmin, :svr_conf)
    redmine_host = Keyword.get(svr_conf, :redmine_host, [])
    url = redmine_host <> "issues/" <> Integer.to_string(redmine_id) <> ".json?include=attachments,journals"
    %HTTPotion.Response{body: body} = HTTPotion.get url
    IO.inspect({"***body", body})
    case body do
      " " ->
        %{:url=>"", :developer_name=>"", :status_id=>"", :status_name=>""}
      _ ->
        datas = Poison.decode!(body)
        %{"issue" => issue_datas} = datas
        assign_to_id = issue_datas["assigned_to"]["id"]
        assign_to_name = issue_datas["assigned_to"]["name"]
        %{"journals" => journals} = issue_datas
        journal_users = for j <- journals, do: %{id: j["user"]["id"], name: j["user"]["name"]}
        users = [%{id: assign_to_id, name: assign_to_name} | journal_users]
        develper_name = find_developer(users)
        status_name = issue_datas["status"]["name"]
        status_id = issue_datas["status"]["id"]
        url = redmine_host <> "/issues/" <> Integer.to_string(redmine_id)
        %{url: url, developer_name: develper_name, status_id: status_id, status_name: status_name}
    end
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
