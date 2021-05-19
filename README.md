# RecipeShare

An (incomplete) application to play around with [Supabase](supabase.io),
[Surface](https://surface-ui.org/) and to get comfortable with Postgres'
[row level security](https://www.postgresql.org/docs/13/ddl-rowsecurity.html) features.

## User Roles

- user (default)
- moderator
- admin

Moderators and Admins can delete recipes of other users.
Admins can assign new roles to users.
All users can see all _published_ recipes.

Policies are created [here](./priv/repo/migrations/20210519141614_policies.exs)
