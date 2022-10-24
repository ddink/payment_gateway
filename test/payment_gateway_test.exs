defmodule PaymentGatewayTest do
  use PaymentGateway.CartCase, async: true
  doctest PaymentGateway

  @tag :api_call
  describe "checkout/1" do
    test "when transaction's api call is successful returns a {:ok, response_body} tuple",
      %{ cart: cart } do
      case PaymentGateway.checkout(cart) do
        {:ok, response_body} ->
          assert is_map(response_body)
        {:error, message} ->
          assert message =~ "timed out"
      end
    end
  end

  @tag :api_call
  describe "tokenize_credit_card/1" do
    test "when transaction's api call is successful returns a {:ok, response_body} tuple",
      %{ cart: cart } do
      assert {:ok, response_body} = PaymentGateway.tokenize_credit_card(cart)
      assert is_map(response_body)
    end
  end

  @tag :api_call
  describe "delete_token/1" do
    test "when transaction's api call is successful returns a {:ok, response_body} tuple",
      %{ cart: cart } do
      cart_with_token = create_cart_with_token(cart)

      assert {:ok, response_body} = PaymentGateway.delete_token(cart_with_token)
      assert is_map(response_body)
    end
  end

  @tag :api_call
  describe "query_tokens/1" do
    test "when transaction's api call is successful returns a {:ok, response_body} tuple",
      %{ cart: cart } do
      cart_with_token = create_cart_with_token(cart)

      assert {:ok, response_body} = PaymentGateway.query_tokens(cart_with_token)
      assert is_map(response_body)
    end
  end

  @tag :api_call
  describe "pay_with_token/1" do
    test "when transaction's api call is successful returns a {:ok, response_body} tuple",
      %{ cart: cart } do
      cart_with_token = create_cart_with_token(cart)

      case PaymentGateway.pay_with_token(cart_with_token) do
        {:ok, response_body} ->
          assert is_map(response_body)
        {:error, message} ->
          assert message =~ "timed out"
      end
    end
  end

  defp create_cart_with_token(cart) do
    {:ok, response_body} = PaymentGateway.register_credit_card(cart)
    token_id = response_body["creditCardToken"]["creditCardTokenId"]

    credit_card =
      cart
      |> Map.fetch!(:credit_card)
      |> Map.put(:token_id, token_id)

    cart_with_token =
      Map.put(cart, :credit_card, credit_card)

    cart_with_token
  end
end
