defmodule TheBank.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.BankProcs}
    ]

    opts = [strategy: :one_for_one, name: TheBank.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
