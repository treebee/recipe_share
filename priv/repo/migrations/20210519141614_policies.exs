defmodule RecipeShare.Repo.Migrations.Policies do
  use Ecto.Migration

  def change do
    execute("""
    ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
    """)

    execute("""
    CREATE policy "Everyone can see own or published recipes"
    ON recipes
    AS permissive
    FOR SELECT
    USING (
      published OR (user_id = auth.uid())
    );
    """)

    execute("""
    CREATE policy "Delete recipes of other users"
    ON recipes
    AS permissive
    FOR DELETE
    USING (
      (
        (user_id = auth.uid())
        OR
        (
          'delete:recipes:others'::text IN
          (
            SELECT permissions.name FROM permissions WHERE
            (
              permissions.id IN
              (
                SELECT role_permissions.permission_id FROM
                (
                  role_permissions JOIN
                  (
                    SELECT roles.id FROM
                    (
                      roles JOIN user_roles ON
                      (
                        roles.id = user_roles.role_id
                      )
                    ) WHERE (user_roles.user_id = auth.uid())
                  ) l ON
                  (
                    role_permissions.role_id = l.id
                  )
                )
              )
            )
          )
        )
      )
    )
    """)

    execute("""
    CREATE policy "Edit recipes of other users"
    ON recipes
    AS permissive
    FOR UPDATE
    USING (
      (
        (user_id = auth.uid())
        OR
        (
          'edit:recipes:others'::text IN
          (
            SELECT permissions.name FROM permissions WHERE
            (
              permissions.id IN
              (
                SELECT role_permissions.permission_id FROM
                (
                  role_permissions JOIN
                  (
                    SELECT roles.id FROM
                    (
                      roles JOIN user_roles ON
                      (
                        roles.id = user_roles.role_id
                      )
                    ) WHERE (user_roles.user_id = auth.uid())
                  ) l ON
                  (
                    role_permissions.role_id = l.id
                  )
                )
              )
            )
          )
        )
      )
    )
    """)

    execute("ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;")

    execute("""
    CREATE policy "Assign user roles"
    ON user_roles
    AS permissive
    FOR UPDATE
    USING (
      (
        (
          'edit:user'::text IN
          (
            SELECT permissions.name FROM permissions WHERE
            (
              permissions.id IN
              (
                SELECT role_permissions.permission_id FROM
                (
                  role_permissions JOIN
                  (
                    SELECT roles.id FROM
                    (
                      roles JOIN user_roles ON
                      (
                        roles.id = user_roles.role_id
                      )
                    ) WHERE (user_roles.user_id = auth.uid())
                  ) l ON
                  (
                    role_permissions.role_id = l.id
                  )
                )
              )
            )
          )
        )
      )
    )
    """)
  end
end
