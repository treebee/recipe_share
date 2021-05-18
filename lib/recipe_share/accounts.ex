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
  def list_profiles do
    Repo.all(Profile)
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

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end
end
