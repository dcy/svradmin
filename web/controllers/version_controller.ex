defmodule Svradmin.VersionController do
  use Svradmin.Web, :controller

  alias Svradmin.Version
  alias Svradmin.Issue

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
    json conn, %{:issues => issues} 
  end

  defp format_issue(issue) do
    %Issue{title: title, content: content, designer_id: designer_id, is_done_design: is_done_design,
      frontend_id: frontend_id, backend_id: backend_id} = issue
    frontend_redmine = format_redmine_state(frontend_id)
    backend_redmine = format_redmine_state(backend_id)
    
  end


  defp format_redmine_state(redmine_id) do
    svr_conf = Application.get_env(:svradmin, :svr_conf)
    redmine_host = Keyword.get(svr_conf, :redmine_host, [])
    url = redmine_host <> "issues/" <> Integer.to_string(redmine_id) <> ".json?include=attachments,journals"
    IO.inspect({"******url", url})
    %HTTPotion.Response{body: body} = HTTPotion.get url
    datas = Poison.decode!(body)
    IO.inspect({"*****datas", datas})
    %{"issue" => issue_datas} = datas
    %{"journals" => journals} = issue_datas
    IO.inspect({"*****journals", journals})
    
    
  end

end
