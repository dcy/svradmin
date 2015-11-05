defmodule Svradmin.VersionControllerTest do
  use Svradmin.ConnCase

  alias Svradmin.Version
  @valid_attrs %{end: "2010-04-17 14:00:00", name: "some content", start: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, version_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing versions"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, version_path(conn, :new)
    assert html_response(conn, 200) =~ "New version"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, version_path(conn, :create), version: @valid_attrs
    assert redirected_to(conn) == version_path(conn, :index)
    assert Repo.get_by(Version, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, version_path(conn, :create), version: @invalid_attrs
    assert html_response(conn, 200) =~ "New version"
  end

  test "shows chosen resource", %{conn: conn} do
    version = Repo.insert! %Version{}
    conn = get conn, version_path(conn, :show, version)
    assert html_response(conn, 200) =~ "Show version"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, version_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    version = Repo.insert! %Version{}
    conn = get conn, version_path(conn, :edit, version)
    assert html_response(conn, 200) =~ "Edit version"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    version = Repo.insert! %Version{}
    conn = put conn, version_path(conn, :update, version), version: @valid_attrs
    assert redirected_to(conn) == version_path(conn, :show, version)
    assert Repo.get_by(Version, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    version = Repo.insert! %Version{}
    conn = put conn, version_path(conn, :update, version), version: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit version"
  end

  test "deletes chosen resource", %{conn: conn} do
    version = Repo.insert! %Version{}
    conn = delete conn, version_path(conn, :delete, version)
    assert redirected_to(conn) == version_path(conn, :index)
    refute Repo.get(Version, version.id)
  end
end
