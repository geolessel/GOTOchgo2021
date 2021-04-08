defmodule GotochgoWeb.PageController do
  use GotochgoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
