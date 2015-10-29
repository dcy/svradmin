defmodule Svradmin.SessionController do
  use Svradmin.Web, :controller
  alias Svradmin.User

  def new(conn, _) do
    if conn.assigns[:current_user] do
      conn |> redirect(to: page_path(conn, :index))
    else
      render conn, "new.html"
    end
  end

  def create(conn, %{"session" => %{"name" => user, "password" =>
                                     pass}}) do
    case Svradmin.Auth.login_by_username_and_pass(conn, user, pass, repo:
                                               Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Svradmin.Auth.logout()
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: page_path(conn, :index))
  end

  def change_password(conn, %{"ori_password"=>ori_password, "new_password"=>new_password}) do
    current_user = conn.assigns[:current_user]
    IO.inspect(current_user)
    if current_user do
      %User{password: password, id: id} = current_user
      IO.inspect({"password", password})
      IO.inspect({"ori_password", ori_password})
      result = 
      case password == ori_password do
        false ->
          "oriPasswordWrong"
        true ->
          user = Repo.get!(User, id)
          changeset = User.changeset(user, %{"password"=>new_password})
          case Repo.update(changeset) do
            {:ok, user} ->
              "success"
            {:error, changeset} ->
              "fail"
          end
      end
      json conn, %{:result => result}
    else
      json conn, %{:result => "fail"}
    end
  end

end
