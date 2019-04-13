defmodule AccountAggregate do
  use GenServer

  alias TheBank.Account

  def start_link(name) do
    GenServer.start_link(__MODULE__, %Account{}, name: name)
  end

  def find(type, account_number) do
    account_id = "#{type}-#{account_number}"
    name = {:via, Registry, {Registry.BankProcs, account_id}}

    AccountAggregate.start_link(name) # {:ok, pid} | {:error {:already_started, pid}}
    name
  end

  def dispatch(command) do
    proc = find(:account, command.account_number)

    case AccountAggregate.execute(proc, command) do
      new_events ->
        EventStore.store_events(new_events)
        AccountAggregate.apply(proc, new_events)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def init(state) do
    {:ok, state}
  end

  def execute(pid, command) do
    GenServer.call(pid, {:execute, command})
  end

  def apply(pid, event) do
    GenServer.call(pid, {:apply, event})
  end

  def handle_call({:execute, command}, _from, account) do
    new_events =
      case Account.execute(account, command) do
        es when is_list(es) ->
          es

        nil ->
          []

        event ->
          [event]

        {:error, reason} ->
          {:error, reason}
      end

    {:reply, new_events, account}
  end

  def handle_call({:apply, events}, _from, account) do
    new_account =
      Enum.reduce(events, account, fn e, acc ->
        Account.apply(acc, e)
      end)

    {:reply, :ok, new_account}
  end
end
