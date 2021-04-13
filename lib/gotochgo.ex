defmodule Gotochgo do
  @moduledoc """
  Gotochgo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Gotochgo.FakeRepo, as: Repo
  alias Gotochgo.{Comment, Company}

  @max_movement_percent_tenths 1
  @increase_price_change_percent 60

  @spec list_companies :: list({ticker :: String.t(), name :: String.t()})
  def list_companies do
    Repo.all(:companies)
  end

  @spec list_comments :: list(comments :: Comment.t())
  def list_comments do
    Repo.all(:comments)
  end

  @spec insert_comment(text :: String.t()) :: :ok
  def insert_comment(text) do
    Repo.insert(%Comment{text: text})
  end

  @spec update_price(Company.t()) :: Company.t()
  def update_price(%Company{price: price} = company) do
    price_change = price * (:rand.uniform(@max_movement_percent_tenths * 100) / 100_000)

    new_price =
      case :rand.uniform(100) do
        chance when chance in 0..@increase_price_change_percent ->
          price + price_change

        _ ->
          price - price_change
      end

    Map.put(company, :price, new_price)
  end

  @spec update_all_prices([Company.t()]) :: [Company.t()]
  def update_all_prices(companies) do
    companies
    |> Enum.map(&update_price/1)
  end

  @spec subscribe(subscriber :: pid()) :: :ok
  def subscribe(pid) do
    Repo.subscribe(pid)
  end

  @spec unsubscribe(subsriber :: pid()) :: :ok
  def unsubscribe(pid) do
    Repo.unsubscribe(pid)
  end
end
