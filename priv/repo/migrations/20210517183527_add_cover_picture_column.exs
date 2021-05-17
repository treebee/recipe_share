defmodule RecipeShare.Repo.Migrations.AddCoverPictureColumn do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :cover_picture, :text
    end
  end
end
