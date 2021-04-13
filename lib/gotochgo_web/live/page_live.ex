defmodule GotochgoWeb.PageLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket), do: Gotochgo.subscribe(self())

    companies = Gotochgo.list_companies()
    comments = Gotochgo.list_comments()

    {:ok, assign(socket, companies: companies, comments: comments),
     temporary_assigns: [comments: []]}
  end

  def render(assigns) do
    GotochgoWeb.PageView.render("index.html", assigns)
  end

  def handle_info({:new_prices, companies}, socket) do
    {:noreply, assign(socket, :companies, companies)}
  end

  def handle_info({:new_comment, comment}, socket) do
    {:noreply, assign(socket, comments: [comment])}
  end

  def handle_event("submit_comment", %{"comments" => %{"text" => text}}, socket) do
    Gotochgo.insert_comment(text)
    {:noreply, socket}
  end

  def terminate({:shutdown, :closed}, socket) do
    Gotochgo.unsubscribe(self())
  end
end
