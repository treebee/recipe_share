defmodule RecipeShare.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :username, :text
      add :avatar_url, :text

      timestamps()
    end

  end
end
