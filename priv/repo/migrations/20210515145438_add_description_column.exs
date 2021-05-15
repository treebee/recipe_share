defmodule RecipeShare.Repo.Migrations.AddDescriptionColumn do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :description, :text
    end
  end
end
