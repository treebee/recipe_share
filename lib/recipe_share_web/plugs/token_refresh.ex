defmodule RecipeShareWeb.Plugs.TokenRefresh do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{} = conn, _default) do
    conn
    |> get_session()
    |> check_token_expiration(conn)
  end

  defp check_token_expiration(
         %{"access_token" => access_token, "refresh_token" => refresh_token},
         conn
       ) do
    {:ok, %{"exp" => exp}} = Joken.peek_claims(access_token)

    refresh_access_token(exp - System.system_time(:second), refresh_token, conn)
  end

  defp check_token_expiration(_session, conn), do: conn

  defp refresh_access_token(time_remaining, refresh_token, conn) when time_remaining < 10 do
    case Supabase.auth() |> GoTrue.refresh_access_token(refresh_token) do
      {:ok, %{"access_token" => at, "refresh_token" => rt}} ->
        conn |> put_session(:access_token, at) |> put_session(:refresh_token, rt)

      _ ->
        conn |> clear_session()
    end
  end

  defp refresh_access_token(_, _, conn), do: conn
end
