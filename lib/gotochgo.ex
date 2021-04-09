defmodule Gotochgo do
  @moduledoc """
  Gotochgo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Gotochgo.FakeRepo, as: Repo

  @spec list_companies :: list({ticker :: String.t(), name :: String.t()})
  def list_companies do
    Repo.all(:companies)
  end
end
