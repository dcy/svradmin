defmodule Svradmin.HistoryController do
  use Svradmin.Web, :controller

  alias Svradmin.History

  plug :scrub_params, "history" when action in [:create, :update]

  def index(conn, _params) do
    historys = Repo.all(History)
    render(conn, "index.html", historys: historys)
  end

  def new(conn, _params) do
    changeset = History.changeset(%History{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"history" => history_params}) do
    changeset = History.changeset(%History{}, history_params)

    case Repo.insert(changeset) do
      {:ok, _history} ->
        conn
        |> put_flash(:info, "History created successfully.")
        |> redirect(to: history_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    history = Repo.get!(History, id)
    render(conn, "show.html", history: history)
  end

  def edit(conn, %{"id" => id}) do
    history = Repo.get!(History, id)
    changeset = History.changeset(history)
    render(conn, "edit.html", history: history, changeset: changeset)
  end

  def update(conn, %{"id" => id, "history" => history_params}) do
    history = Repo.get!(History, id)
    changeset = History.changeset(history, history_params)

    case Repo.update(changeset) do
      {:ok, history} ->
        conn
        |> put_flash(:info, "History updated successfully.")
        |> redirect(to: history_path(conn, :show, history))
      {:error, changeset} ->
        render(conn, "edit.html", history: history, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    history = Repo.get!(History, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(history)

    conn
    |> put_flash(:info, "History deleted successfully.")
    |> redirect(to: history_path(conn, :index))
  end
end
