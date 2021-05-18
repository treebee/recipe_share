defmodule RecipeShare.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RecipeShare.Repo

  alias RecipeShare.Accounts.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles() do
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
      |> Postgrestex.from("recipes")
      |> Postgrestex.insert(attrs)
      |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    {:ok, profile}
  end

  def get_role!(access_token, user_id) do
    case Supabase.init(access_token: access_token)
         |> Postgrestex.from("user_roles")
         |> update_in([:params], fn params -> [{:select, "roles(name)"} | params] end)
         |> Postgrestex.eq("user_id", user_id)
         |> Postgrestex.call()
         |> Supabase.json(keys: :atoms) do
      %{body: [%{roles: %{name: role}}]} -> role
      %{body: []} -> nil
    end
  end

  def create_user_role(access_token, user_id, role \\ "user") do
    role = get_role!(access_token, role)

    %{status: 201, body: [user_role]} =
      Supabase.init(access_token: access_token)
      |> Postgrestex.from("user_roles")
      |> Postgrestex.insert(%{"user_id" => user_id, "role_id" => role.id})
      |> Postgrestex.update_headers(%{"Prefer" => "return=representation"})
      |> Postgrestex.call()
      |> Supabase.json(keys: :atoms)

    user_role
  end
end
