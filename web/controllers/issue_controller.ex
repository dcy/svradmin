defmodule Svradmin.IssueController do
  use Svradmin.Web, :controller
  import Util

  alias Svradmin.Issue
  import Svradmin.Auth, only: [require_admin: 2]

  plug :scrub_params, "issue" when action in [:create, :update]
  plug :require_admin

  def index(conn, _params) do
    issues = Repo.all(Issue)
    render(conn, "index.html", issues: issues)
  end

  def new(conn, %{"version_id" => version_id}) do
    changeset = Issue.changeset(%Issue{})
    render(conn, "new.html", changeset: changeset, version_id: version_id, apps: ["new_issue"])
  end

  def create(conn, %{"issue" => issue_params}) do
    new_params = case issue_params["remark"] do
      nil -> %{issue_params | "remark" => ""}
      _ -> issue_params
    end
    
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
        IO.inspect(changeset)
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
    new_params = case issue_params["remark"] do
      nil -> %{issue_params | "remark" => ""}
      _ -> issue_params
    end
    issue = Repo.get!(Issue, id)
    changeset = Issue.changeset(issue, new_params)

    case Repo.update(changeset) do
      {:ok, issue} ->
        json conn, %{:result => "success"}
      {:error, changeset} ->
        json conn, %{:result => "fail"}
    end
  end

  def delete(conn, %{"id" => id}) do
    issue = Repo.get!(Issue, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(issue)

    conn
    |> put_flash(:info, "Issue deleted successfully.")
    |> redirect(to: issue_path(conn, :index))
  end

  def get_issue(conn, %{"id" =>id}) do
    issue = Repo.get!(Issue, id)
    issue_map = Util.remove_ecto_struct_keys(Map.from_struct(issue))
    json conn, %{issue: issue_map}
  end

end
