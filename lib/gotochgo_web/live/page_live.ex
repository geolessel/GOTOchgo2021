defmodule GotochgoWeb.PageLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket), do: Gotochgo.subscribe(self())

    companies = Gotochgo.list_companies()
    {:ok, assign(socket, :companies, companies)}
  end

  def render(assigns) do
    GotochgoWeb.PageView.render("index.html", assigns)
  end

  def handle_info({:new_prices, companies}, socket) do
    {:noreply, assign(socket, :companies, companies)}
  end
end
