defmodule PaymentGateway.Gateway.PayuLatam.TokensTest do
  use PaymentGateway.CartCase
  import PaymentGateway.Gateway.PayuLatam.Tokens

  describe "tokenize_credit_card/3" do
    test "success: takes user, card_info, and language arguments separately and
          returns an encoded json string containing request data", %{ cart: cart } do
      json = tokenize_credit_card(cart.user, cart.payment_method, cart.language)
      assert is_binary(json)

      request_data = Jason.decode!(json)
      assert is_map(request_data)
      assert request_data["language"] == cart.language
      assert request_data["creditCardToken"]["payerId"] == cart.user.id
    end
  end

  describe "tokenize_credit_card/1" do
    test "success: takes a cart and returns an encoded json string containing map of request data", %{ cart: cart } do
      json = tokenize_credit_card(cart)
      assert is_binary(json)

      request_data = Jason.decode!(json)
      assert is_map(request_data)
      assert request_data["language"] == cart.language
      assert request_data["creditCardToken"]["payerId"] == cart.user.id
    end

    test "error: returns {:error, message} tuple if cart is missing request data" do
      assert {:error, message} = tokenize_credit_card(%{})
      assert message == "missing request data needed to tokenize credit card"
    end
  end

  describe "delete_credit_card_token/3" do
    test "success: takes user, card_info, and language arguments separately and
          returns an encoded json string containing request data", %{ cart: cart } do
      json = delete_credit_card_token(cart.user, cart.payment_method, cart.language)
      assert is_binary(json)

      request_data = Jason.decode!(json)
      assert is_map(request_data)
      assert request_data["removeCreditCardToken"]["payerId"] == cart.user.id
      assert request_data["removeCreditCardToken"]["creditCardTokenId"] == cart.payment_method.cc_token_id
    end
  end

  describe "delete_credit_card_token/1" do
    test "success: takes a cart and returns an encoded json string containing map of request data", %{ cart: cart } do
      json = delete_credit_card_token(cart)
      assert is_binary(json)

      request_data = Jason.decode!(json)
      assert is_map(request_data)
      assert request_data["removeCreditCardToken"]["payerId"] == cart.user.id
      assert request_data["removeCreditCardToken"]["creditCardTokenId"] == cart.payment_method.cc_token_id
    end

    test "error: returns {:error, message} tuple if cart is missing request data" do
      assert {:error, message} = delete_credit_card_token(%{})
      assert message == "missing request data needed to delete credit card token"
    end
  end

  describe "query_tokens/2" do
    test "success: takes user and language arguments separately and
          returns an encoded json string containing request data", %{ cart: cart } do
      json = query_tokens(cart.user, cart.language)
      assert is_binary(json)

      request_data = Jason.decode!(json)
      assert is_map(request_data)
      assert request_data["creditCardTokenInformation"]["creditCardTokenId"] == cart.user.default_credit_card_token_id
    end
  end

  describe "query_tokens/1" do
    test "success: takes a cart with token id and returns an encoded json string containing map of request data", %{ cart: cart } do
      json = query_tokens(cart)
      assert is_binary(json)

      request_data = Jason.decode!(json)
      assert is_map(request_data)
      assert request_data["creditCardTokenInformation"]["creditCardTokenId"] == cart.payment_method.cc_token_id
    end

    test "success: takes a cart without token id and returns an encoded json string containing map of request data", %{ cart: cart } do
      inserted_at = Timex.now() |> Timex.shift(years: -1)
      cart = cart |> Map.put(:payment_method, %{}) |> Map.merge(%{ user: %{ inserted_at: inserted_at } } )
      json = query_tokens(cart)

      assert is_binary(json)

      todays_date = Timex.now() |> Timex.format!("%F", :strftime)
      todays_date_last_year = inserted_at |> Timex.format!("%F", :strftime)
      request_data = Jason.decode!(json)

      assert is_map(request_data)
      assert request_data["creditCardTokenInformation"]["startDate"] =~ todays_date_last_year
      assert request_data["creditCardTokenInformation"]["endDate"] =~ todays_date
    end

    test "error: returns {:error, message} tuple if cart is missing request data" do
      assert {:error, message} = query_tokens(%{})
      assert message == "missing request data needed to query credit card tokens"
    end
  end
end
