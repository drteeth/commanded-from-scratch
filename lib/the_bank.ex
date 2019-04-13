defmodule TheBank do
  # The Commands
  defmodule OpenAccount do
    defstruct [:account_number]
  end

  defmodule Deposit do
    defstruct [:account_number, :amount]
  end

  # The Events
  defmodule AccountOpened do
    defstruct [:account_number, :balance]
  end

  defmodule Deposited do
    defstruct [:account_number, :amount]
  end

  # The Aggregate
  defmodule Account do
    defstruct [:account_number, :balance]

    def execute(%Account{} = account, %OpenAccount{} = command) do
      if account.account_number == nil do
        %AccountOpened{
          account_number: command.account_number,
          balance: 0
        }
      else
        {:error, :account_already_opened}
      end
    end

    def execute(%Account{}, %Deposit{} = command) do
      %Deposited{
        account_number: command.account_number,
        amount: command.amount
      }
    end

    def apply(%Account{} = account, %AccountOpened{} = event) do
      %{account | account_number: event.account_number, balance: event.balance}
    end

    def apply(%Account{} = account, %Deposited{} = event) do
      %{account | balance: account.balance + event.amount}
    end
  end

  # The API
  def open_account(account_number) do
    command = %OpenAccount{account_number: account_number}
    AccountAggregate.dispatch(command)
  end

  def deposit(account_number, amount) do
    command = %Deposit{account_number: account_number, amount: amount}
    AccountAggregate.dispatch(command)
  end
end
