defmodule GotochgoWeb.PageLive do
  use Phoenix.LiveView

  def render(_assigns) do
    companies = Gotochgo.list_companies()
    GotochgoWeb.PageView.render("index.html", companies: companies)
  end
end
