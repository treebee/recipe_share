defmodule RecipeShareWeb.Router do
  use RecipeShareWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RecipeShareWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RecipeShareWeb.Plugs.TokenRefresh
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RecipeShareWeb do
    pipe_through :browser

    post "/logout", SessionController, :logout
    live "/login", AuthLive, :index
    live "/register", AuthLive, :index

    live "/", PageLive, :index
    live "/:page", PageLive, :index
    live "/recipes/:recipe_id", PageLive, :index
  end

  # Other scopes may use custom stacks.
  scope "/", RecipeShareWeb do
    pipe_through :api
    pipe_through :fetch_session

    post "/session", SessionController, :set_session
  end

  # Other scopes may use custom stacks.
  # scope "/api", RecipeShareWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RecipeShareWeb.Telemetry
    end
  end
end
