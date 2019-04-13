defmodule TheBankTest do
  use ExUnit.Case
  doctest TheBank

  test "does bank things" do
    :ok = TheBank.open_account(123)
    :ok = TheBank.deposit(123, 1000)
  end
end
