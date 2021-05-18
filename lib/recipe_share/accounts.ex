defmodule RecipeShare.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  def get_user!(access_token, user_id) do
    %{body: users} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("user_roles")
      |> Postgrestex.select(["roles:role_id(id,name), profile:user_id(id,username,avatar_url)"])
      |> Postgrestex.eq("user_id", user_id)
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    users
    |> Enum.map(&transform_user_response/1)
    |> List.first()
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%{}, ...]

  """
  def list_users(access_token: access_token) do
    %{body: users} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("user_roles")
      |> Postgrestex.select(["roles:role_id(id,name), profile:user_id(id,username,avatar_url)"])
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    users
    |> Enum.map(&transform_user_response/1)
  end

  defp transform_user_response(%{roles: %{id: role_id, name: role_name}, profile: user}) do
    Map.put(user, :role, role_name) |> Map.put(:role_id, role_id)
  end

  @doc """
  Gets a single profile.

  Returns `nil` if not found.
  """
  def get_profile!(access_token, user_id) do
    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("profiles")
         |> Postgrestex.eq("id", user_id)
         |> Postgrestex.call()
         |> Supabase.json() do
      %{body: [profile]} -> profile
      %{body: []} -> nil
    end
  end

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

  """
  def create_profile(attrs, access_token) do
    %{body: [profile], status: 201} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("profiles")
      |> Postgrestex.insert(attrs)
      |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    {:ok, profile}
  end

  def update_profile(access_token, user_id, attrs) do
    %{body: [profile]} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("profiles")
      |> Postgrestex.update(attrs)
      |> Postgrestex.eq("id", user_id)
      |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    {:ok, profile}
  end

  def get_role!(access_token, user_id) do
    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("user_roles")
         |> update_in([:params], fn params -> [{:select, "roles(id,name)"} | params] end)
         |> Postgrestex.eq("user_id", user_id)
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{body: [%{roles: role}]} -> role
      %{body: []} -> nil
    end
  end

  def get_role_by_name(access_token, role) do
    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("roles")
         |> Postgrestex.eq("name", role)
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{body: [role]} -> role
      %{body: []} -> nil
    end
  end

  def create_user_role(access_token, user_id, role \\ "user") do
    role = get_role_by_name(access_token, role)

    %{status: 201, body: [user_role]} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("user_roles")
      |> Postgrestex.insert(%{"user_id" => user_id, "role_id" => role.id})
      |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    user_role
  end

  def update_user_role(access_token, user_id, role_id) do
    %{status_code: 200} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("user_roles")
      |> Postgrestex.update(%{"role_id" => role_id})
      |> Postgrestex.eq("user_id", user_id)
      |> Postgrestex.call()
  end
end
