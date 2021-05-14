defmodule RecipeShareWeb.PageLiveTest do
  use RecipeShareWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Hi there!"
    assert render(page_live) =~ "Hi there!"
  end
end
