defmodule RecipeShare.Repo do
  use Ecto.Repo,
    otp_app: :recipe_share,
    adapter: Ecto.Adapters.Postgres
end
