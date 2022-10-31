defmodule PaymentGateway.Application do
  use Application

  def start(_type, _args) do
    children = [
      PaymentGateway
    ]

    opts = [strategy: :one_for_one, name: Test.Supervisor]
    Supervisor.start_link(children, opts)
  end
end