defmodule Gotochgo.FakeRepo do
  @moduledoc """
  A GenServer that essentially fakes a database.
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def all(key) do
    GenServer.call(__MODULE__, {:all, key})
  end

  def inspect do
    GenServer.call(__MODULE__, :inspect)
  end

  # ┌──────────────────┐
  # │ Server Callbacks │
  # └──────────────────┘

  def init(_state) do
    companies = Gotochgo.SAndP500.companies()
    {:ok, %{companies: companies}}
  end

  def handle_call({:all, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call(:inspect, _, state) do
    {:reply, state, state}
  end
end
