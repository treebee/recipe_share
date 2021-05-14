defmodule RecipeShare.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :text, null: false
      add :picture_urls, {:array, :text}
      add :ingredients, :map
      add :published, :boolean, default: false, null: false
      add :tags, {:array, :text}
      add :user_id, :uuid, null: false

      timestamps()
    end

    create index(:recipes, [:user_id])

    create table(:roles) do
      add :name, :text, unique: true, null: false
      add :description, :text
    end

    create table(:user_roles, primary_key: false) do
      add :user_id, :uuid, null: false, primary_key: true
      add :role_id, references(:roles, on_delete: :nothing), null: false, primary_key: true
    end

    create table(:permissions) do
      add :name, :text, unique: true, null: false
      add :description, :text
    end

    create table(:role_permissions, primary_key: false) do
      add :role_id, references(:roles, on_delete: :nothing), null: false, primary_key: true
      add :permission_id, references(:permissions, on_delete: :nothing), null: false, primary_key: true
    end

    flush()

    execute("""
    INSERT INTO roles (id, name, description) VALUES
    (1, 'admin', 'Full access to all resources. Can extend permissions of other users.'),
    (2, 'moderator', 'Can delete or edit recipes of other users.'),
    (3, 'user', 'Can create and edit/delete own recipes.');
    """)

    execute("""
    INSERT INTO permissions (id, name, description) VALUES
    (1, 'create:recipe', 'Can create recipes'),
    (2, 'delete:recipe', 'Can delete own recipes'),
    (3, 'edit:recipe', 'Can edit own recipes'),
    (4, 'edit:recipe:others', 'Can edit all recipes.'),
    (5, 'delete:recipe:others', 'Can delete all recipes.'),
    (6, 'edit:user', 'Can edit other users.'),
    (7, 'delete:user', 'Can delete users.');
    """)

    execute("""
    INSERT INTO role_permissions (role_id, permission_id) VALUES
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7),
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 5),
    (3, 1), (3, 2);
    """)
  end
end
