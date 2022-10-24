defmodule PaymentGateway.Gateway.PayuLatamTest do
  use PaymentGateway.CartCase, async: true
  import PaymentGateway.Gateway.PayuLatam

  describe "add_merchant_info/1" do
    test "takes a cart and returns a {:payu_latam, _, _} tuple with an initalized map", %{ cart: cart} do
      assert {:payu_latam, _cart, map} = add_merchant_info(cart)

      assert map[:language] == "es"
      assert map[:command] == "SUBMIT_TRANSACTION"
      assert map[:merchant][:apiKey] == "4Vj8eK4rloUd272L48hsrarnUA"
      assert map[:merchant][:apiLogin] == "pRRXKOl8ikMmt9u"
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_merchant_info(%{})
      assert message == "cart is missing merchant data"
    end
  end

  describe "add_order/1" do
    test "takes {cart, map} tuple and returns tuple with updated map", %{ cart: cart } do
      assert {:payu_latam, _cart, map} = add_order({cart, %{}})

      order = map[:transaction][:order]
      additional_values = order[:additionalValues]

      refute map[:language] == "es"

      assert order[:accountId] == "512321"
      assert order[:referenceCode] =~ first_sku(cart)
      assert order[:description] == "Payment test description"
      assert order[:language] == "es"
      assert order[:signature] == payu_latam_order_signature(cart)
      assert order[:notifyUrl] == "http://www.payu.com/notify"

      assert additional_values["TX_VALUE"][:value] == 65_000
      assert additional_values["TX_VALUE"][:currency] == "COP"
      assert additional_values["TX_TAX"][:value] == 10_378
      assert additional_values["TX_TAX_RETURN_BASE"][:value] == 54_622
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_order(%{})
      assert message == "cart is missing order data"
    end
  end

  describe "add_buyer/1" do
    test "takes {cart, map} tuple and returns tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {:payu_latam, _cart, map} =  add_buyer({cart, map})

      buyer = map[:transaction][:order][:buyer]
      buyer_shipping_address = buyer[:shippingAddress]

      assert buyer[:merchantBuyerId] == 1
      assert buyer[:fullName] == "Juan Doe"
      assert buyer[:emailAddress] == "jd1978@gmail.com"
      assert buyer[:contactPhone] == "555-123-4567"
      assert buyer[:dniNumber] == "1234A4567B809K"

      assert buyer_shipping_address[:street1] == "Cr 23 No. 53-50"
      assert buyer_shipping_address[:street2] == "5555487"
      assert buyer_shipping_address[:city] == "Bogotá"
      assert buyer_shipping_address[:state] == "Bogotá D.C."
      assert buyer_shipping_address[:country] == "CO"
      assert buyer_shipping_address[:postalCode] == "000000"
      assert buyer_shipping_address[:phone] == "555-987-6543"
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_buyer(%{})
      assert message == "cart is missing transaction buyer data"
    end
  end

  describe "add_shipping_address/1" do
    test "takes {cart, map} tuple and returns tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {:payu_latam, _cart, map} = add_shipping_address({cart, map})

      assert map[:transaction][:order][:accountId] == cart.user.id

      transaction_shipping_address = map[:transaction][:order][:shippingAddress]

      assert transaction_shipping_address[:street1] == "Cr 23 No. 53-50"
      assert transaction_shipping_address[:street2] == "5555487"
      assert transaction_shipping_address[:city] == "Bogotá"
      assert transaction_shipping_address[:state] == "Bogotá D.C."
      assert transaction_shipping_address[:country] == "CO"
      assert transaction_shipping_address[:postalCode] == "000000"
      assert transaction_shipping_address[:phone] == "555-987-6543"
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_shipping_address(%{})
      assert message == "cart is missing transaction shipping address data"
    end
  end

  describe "add_payer/1" do
    test "takes {cart, map} tuple and returns tuple with updated map",
    %{
      cart: cart,
      order_added_map: map
    } do
      assert {:payu_latam, _cart, map} =  add_payer({cart, map})

      payer = map[:transaction][:payer]
      payer_billing_address = payer[:billingAddress]

      # assert payer[:merchantPayerId] == 1
      assert payer[:fullName] == "Santiago Ruiz"
      assert payer[:emailAddress] == "sr1960@gmail.com"
      assert payer[:contactPhone] == "555-426-9980"
      assert payer[:dniNumber] == "987E654V321Z"

      assert payer_billing_address[:street1] == "Cr 23 No. 53-50"
      assert payer_billing_address[:street2] == "125544"
      assert payer_billing_address[:city] == "Bogotá"
      assert payer_billing_address[:state] == "Bogotá D.C."
      assert payer_billing_address[:country] == "CO"
      assert payer_billing_address[:postalCode] == "000000"
      assert payer_billing_address[:phone] == "555-756-3126"
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_payer(%{})
      assert message == "cart is missing payer data"
    end
  end

  describe "add_credit_card/1" do
    test "takes {cart, map} tuple and returns tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {:payu_latam, _cart, map} = add_credit_card({cart, map})

      credit_card = map[:transaction][:creditCard]

      assert credit_card[:number] == "4111111111111111"
      assert credit_card[:securityCode] == "321"
      assert credit_card[:expirationDate] == "2030/12"
      assert credit_card[:name] == "Santiago Ruiz"
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_credit_card(%{})
      assert message == "cart is missing credit card data"
    end
  end

  describe "add_extra_parameters/1" do
    test "takes {cart, map} tuple and returns {cart, map} tuple with updated map",
          %{
            cart: cart,
            order_added_map: map
          } do
      assert {_cart, map} = add_extra_parameters({cart, map})

      transaction = map[:transaction]

      assert transaction[:paymentMethod] == "VISA"
      assert transaction[:paymentCountry] == "CO"
      assert transaction[:cookie] == "pt1t38347bs6jc9ruv2ecpv7o2"
      assert transaction[:userAgent] == "Mozilla/5.0 (Windows NT 5.1; rv:18.0) Gecko/20100101 Firefox/18.0"
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_extra_parameters(%{})
      assert message == "cart is missing extra parameters data"
    end
  end

  describe "tokenize_credit_card/1" do
    test "returns encoded JSON string when passed a valid cart", %{ cart: cart } do
      assert json = tokenize_credit_card(cart)
      assert is_binary(json)
    end

    test "returns {:error, message} tuple when passed an invalid cart" do
      assert {:error, _message} = tokenize_credit_card(%{})
    end
  end

  describe "delete_credit_card_token/1" do
    test "returns encoded JSON string when passed a valid cart", %{ cart: cart } do
      assert json = delete_credit_card_token(cart)
      assert is_binary(json)
    end

    test "returns {:error, message} tuple when passed an invalid cart" do
      assert {:error, _message} = delete_credit_card_token(%{})
    end
  end

  describe "query_tokens/1" do
    test "returns encoded JSON string when passed a valid cart", %{ cart: cart } do
      assert json = query_tokens(cart)
      assert is_binary(json)
    end

    test "returns {:error, message} tuple when passed an invalid cart" do
      assert {:error, _message} = query_tokens(%{})
    end
  end

  describe "add_token/1" do
    test "takes {cart, map} tuple and returns tuple with updated map",
      %{
        cart: cart,
        order_added_map: map
      } do
      assert {:payu_latam, _cart, map} = add_token({cart, map})

      assert map[:transaction][:creditCardTokenId] ==
              cart.credit_card.token_id
      assert map[:transaction][:creditCard][:securityCode] ==
              cart.credit_card.security_code
    end

    test "returns {:error, message} tuple when passed an invalid request data" do
      assert {:error, message} = add_token(%{})
      assert message == "cart missing credit card token data"
    end
  end

  defp first_sku(cart) do
    cart.order.skus
    |> Map.keys
    |> List.first
  end
end
