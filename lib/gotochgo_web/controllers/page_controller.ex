defmodule GotochgoWeb.PageController do
  use GotochgoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", companies: Gotochgo.list_companies())
  end
end
