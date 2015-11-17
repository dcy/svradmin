defmodule Svradmin.IssueController do
  use Svradmin.Web, :controller
  import Util
  require Logger

  alias Svradmin.Issue
  import Svradmin.Auth, only: [authenticate_user: 2]

  plug :scrub_params, "issue" when action in [:create, :update]
  plug :authenticate_user

  def index(conn, _params) do
    issues = Repo.all(Issue)
    render(conn, "index.html", issues: issues)
  end

  def new(conn, %{"version_id" => version_id}) do
    changeset = Issue.changeset(%Issue{})
    render(conn, "new.html", changeset: changeset, version_id: version_id, apps: ["new_issue"])
  end

  def create(conn, %{"issue" => issue_params}) do
    designer_infos = case issue_params["designer_infos"] do
      nil -> [];
      ori_designer_infos -> Map.values(ori_designer_infos)
    end
    #issue_params = %{issue_params | "designer_infos" => Poison.encode!(designer_infos)}
    issue_params = Map.put(issue_params, "designer_infos", Poison.encode!(designer_infos))
    #new_params = case issue_params["remark"] do
    #  nil -> %{issue_params | "remark" => ""}
    #  _ -> issue_params
    #end
    new_params = remove_maps_nil(issue_params)
    #new_params = case new_params["designer_infos"] do
    #  nil -> Map.put(new_params, "designer_infos", "[]")
    #  designer_infos -> %{new_params | "designer_infos" => Poison.encode!(designer_infos)}
    #end
    
    version_id = new_params["version_id"]
    changeset = Issue.changeset(%Issue{}, new_params)

    #case Repo.insert(changeset) do
    #  {:ok, _issue} ->
    #    conn
    #    |> put_flash(:info, "Issue created successfully.")
    #    |> redirect(to: issue_path(conn, :index))
    #  {:error, changeset} ->
    #    render(conn, "new.html", changeset: changeset, version_id: version_id)
    #end
    case Repo.insert(changeset) do
      {:ok, _issue} ->
        json conn, %{:result => "success"}
      {:error, changeset} ->
        errors = :io_lib.format("~p", [changeset.errors])
        Logger.error "Create issue's error #{errors}"
        json conn, %{:result => "fail"}
    end
  end

  def show(conn, %{"id" => id}) do
    issue = Repo.get!(Issue, id)
    render(conn, "show.html", issue: issue)
  end

  #def edit(conn, %{"id" => id}) do
  #  issue = Repo.get!(Issue, id)
  #  changeset = Issue.changeset(issue)
  #  render(conn, "edit.html", issue: issue, changeset: changeset)
  #end
  def edit(conn, %{"id" => id}) do
    render(conn, "edit.html", issue_id: id, apps: ["edit_issue"])
  end

  #def update(conn, %{"id" => id, "issue" => issue_params}) do
  #  issue = Repo.get!(Issue, id)
  #  changeset = Issue.changeset(issue, issue_params)

  #  case Repo.update(changeset) do
  #    {:ok, issue} ->
  #      conn
  #      |> put_flash(:info, "Issue updated successfully.")
  #      |> redirect(to: issue_path(conn, :show, issue))
  #    {:error, changeset} ->
  #      render(conn, "edit.html", issue: issue, changeset: changeset)
  #  end
  #end
  def update(conn, %{"id" => id, "issue" => issue_params}) do
    #new_params = case issue_params["remark"] do
    #  nil -> %{issue_params | "remark" => ""}
    #  _ -> issue_params
    #end
    #new_params = case issue_params["designer_infos"] do
    #  nil -> %{new_params | "designer_infos" => "[]"}
    #  _ -> new_params
    #end
    ori_designer_infos = issue_params["designer_infos"]
    designer_infos = Map.values(ori_designer_infos)
    issue_params = %{issue_params | "designer_infos" => Poison.encode!(designer_infos)}
    new_params = Util.remove_maps_nil(issue_params)
    issue = Repo.get!(Issue, id)
    changeset = Issue.changeset(issue, new_params)

    case Repo.update(changeset) do
      {:ok, issue} ->
        json conn, %{:result => "success"}
      {:error, changeset} ->
        errors = :io_lib.format("~p", [changeset.errors])
        Logger.error "Create issue's error #{errors}"
        json conn, %{:result => "fail"}
    end
  end

  #def delete(conn, %{"id" => id}) do
  #  issue = Repo.get!(Issue, id)

  #  # Here we use delete! (with a bang) because we expect
  #  # it to always work (and if it does not, it will raise).
  #  Repo.delete!(issue)

  #  conn
  #  |> put_flash(:info, "Issue deleted successfully.")
  #  |> redirect(to: issue_path(conn, :index))
  #end
  def delete(conn, %{"id" => id}) do
    issue = Repo.get!(Issue, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(issue)

    json conn, %{:result => "success"}
  end

  def get_issue(conn, %{"id" =>id}) do
    issue = Repo.get!(Issue, id)
    issue_map = Util.remove_ecto_struct_keys(Map.from_struct(issue))
    str_designer_infos = issue_map.designer_infos
    designer_infos = Poison.decode!(str_designer_infos)
    json conn, %{issue: %{issue_map | :designer_infos => designer_infos}}
  end

  def format_designer_infos() do
    issues = Repo.all(Issue)
    for issue <- issues, do: format_designer_infos issue
  end

  def format_designer_infos(issue) do
    designer_id = issue.designer_id
    is_done_design = issue.is_done_design
    designer_infos = Poison.encode!([%{designer_id: designer_id, is_done_design: is_done_design}])
    changeset = Issue.changeset(issue, %{designer_infos: designer_infos})
    case Repo.update(changeset) do
      {:ok, issue} ->
        IO.inspect({"****format_designer_infos success", issue.id})
      {:error, changeset} ->
        IO.inspect({"******error changeset", changeset})
        errors = :io_lib.format("~p", [changeset.errors])
        Logger.error "Create issue's error #{errors}"
    end
  end

end
