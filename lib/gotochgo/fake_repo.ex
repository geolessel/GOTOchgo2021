defmodule Gotochgo.FakeRepo do
  @moduledoc """
  A GenServer that fakes a database.
  """

  alias Gotochgo.Comment

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def all(key) do
    GenServer.call(__MODULE__, {:all, key})
  end

  def subscribe(subscriber_pid) do
    GenServer.cast(__MODULE__, {:subscribe, subscriber_pid})
  end

  def unsubscribe(subscriber_pid) do
    GenServer.cast(__MODULE__, {:unsubscribe, subscriber_pid})
  end

  def insert(%Comment{} = comment) do
    GenServer.cast(__MODULE__, {:insert_comment, comment})
  end

  def inspect do
    GenServer.call(__MODULE__, :inspect)
  end

  def restart_timer do
    GenServer.cast(__MODULE__, :restart_timer)
  end

  # ┌──────────────────┐
  # │ Server Callbacks │
  # └──────────────────┘

  def init(_state) do
    companies = Gotochgo.SAndP500.companies()
    {:ok, timer} = build_timer()

    {:ok,
     %{
       comments: [%Comment{id: 1, text: "first!"}],
       comment_counter: 1,
       companies: companies,
       subscribers: [],
       timer: timer
     }}
  end

  def handle_call({:all, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call(:inspect, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:subscribe, pid}, state) do
    state = Map.update(state, :subscribers, [], &[pid | &1])
    {:noreply, state}
  end

  def handle_cast({:unsubscribe, pid}, state) do
    state =
      Map.update(state, :subscribers, [], fn subscribers ->
        Enum.filter(subscribers, &(&1 != pid))
      end)

    {:noreply, state}
  end

  def handle_cast({:insert_comment, comment}, state) do
    comment = %{comment | id: state.comment_counter + 1}

    state =
      state
      |> Map.update(:comments, [], &[comment | &1])
      |> Map.update(:comment_counter, 0, &(&1 + 1))

    {:noreply, state}
  end

  def handle_cast(:restart_timer, state) do
    with {:ok, _} <- :timer.cancel(state.timer),
         {:ok, timer} <- build_timer() do
      {:noreply, Map.put(state, :timer, timer)}
    end
  end

  def handle_info(:tick, state) do
    companies = Gotochgo.update_all_prices(state.companies)

    state.subscribers
    |> Enum.each(fn subscriber ->
      send(subscriber, {:new_prices, companies})
    end)

    {:noreply, Map.put(state, :companies, companies)}
  end

  def update_ms, do: 2_000
  def build_timer, do: :timer.send_interval(update_ms(), :tick)
end
