defmodule PaymentGateway do
  import PaymentGateway.{CartParser, Gateway}
  use GenServer

  @impl true
  def init(state \\ %{}) do
    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def checkout(cart) do
    GenServer.call(__MODULE__, {:checkout, cart}, 6_000)
  end

  def tokenize_credit_card(cart) do
    GenServer.call(__MODULE__, {:tokenize_credit_card, cart}, 6_000)
  end

  def delete_token(cart) do
    GenServer.call(__MODULE__, {:delete_token, cart}, 6_000)
  end

  def query_tokens(cart) do
    GenServer.call(__MODULE__, {:query_tokens, cart}, 6_000)
  end

  def pay_with_token(cart) do
    GenServer.call(__MODULE__, {:pay_with_token, cart}, 6_000)
  end

  defp call_gateway_api({request_type, _cart} = request_data) when is_atom(request_type) do
    request_data
    |> select_gateway
    |> parse
    |> send_request
  end

  @impl true
  def handle_call({_gateway, _cart} = request_data, _from, state) do
    response = request_data |> call_gateway_api
    {:reply, response, state}
  end
end
