defmodule RecipeShareWeb.SessionController do
  use RecipeShareWeb, :controller

  def set_session(conn, %{"access_token" => access_token, "refresh_token" => refresh_token}) do
    {:ok, user} = Supabase.auth() |> GoTrue.get_user(access_token)

    conn
    |> put_session(:access_token, access_token)
    |> put_session(:refresh_token, refresh_token)
    |> put_session(:user_id, user["id"])
    |> json("ok")
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/")
  end
end
