defmodule RecipeShare.Repo.Migrations.AddMissingForeignKeys do
  use Ecto.Migration

  def change do
    alter table(:user_roles) do
      modify :user_id, references(:profiles, on_delete: :delete_all, type: :uuid)
    end
  end
end
