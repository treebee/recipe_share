defmodule RecipeShareWeb.Helpers do
  def picture_url(nil), do: ""
  def picture_url(""), do: ""
  def picture_url(path), do: Path.join(Supabase.storage_url(), path)
end
