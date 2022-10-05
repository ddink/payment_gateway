defmodule PaymentGateway.OrderRequestBuilderTest do
  use PaymentGateway.CartCase
  import PaymentGateway.OrderRequestBuilder

  test "add_merchant_info/1 takes a cart and returns a tuple an initalized map", %{ cart: cart} do
    assert {_cart, map} = add_merchant_info(cart)

    assert map[:language] == "es"
    assert map[:command] == "SUBMIT_TRANSACTION"
    assert map[:merchant][:apiKey] == "4Vj8eK4rloUd272L48hsrarnUA"
    assert map[:merchant][:apiLogin] == "pRRXKOl8ikMmt9u"
  end

  test "add_transaction_order/1 takes {cart, map} tuple
        and returns tuple with updated map", %{ cart: cart } do
    assert {_cart, map} = add_transaction_order({cart, %{}})

    order = map[:transaction][:order]
    additional_values = order[:additionalValues]

    refute map[:language] == "es"

    assert order[:accountId] == "512321"
    assert order[:referenceCode] =~ first_sku(cart)
    assert order[:description] == "Payment test description"
    assert order[:language] == "es"
    assert order[:signature] == order_signature(cart)
    assert order[:notifyUrl] == "http://www.payu.com/notify"

    assert additional_values["TX_VALUE"][:value] == 65_000
    assert additional_values["TX_VALUE"][:currency] == "COP"
    assert additional_values["TX_TAX"][:value] == 10_378
    assert additional_values["TX_TAX_RETURN_BASE"][:value] == 54_622
  end

  test "add_transaction_buyer/1 takes {cart, map} tuple
        and returns tuple with updated map", %{ cart: cart } do
    assert {_cart, map} =  add_transaction_buyer({cart, %{transaction: %{}}})

    buyer = map[:transaction][:buyer]
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

  test "add_transaction_shipping_address/1 takes {cart, map} tuple
        and returns tuple with updated map",
        %{
          cart: cart,
          order_added_map: order_added_map } do
    assert {_cart, map} = add_transaction_shipping_address({cart, order_added_map})

    assert map[:transaction][:order][:accountId] == cart.user.id

    transaction_shipping_address = map[:transaction][:shippingAddress]

    assert transaction_shipping_address[:street1] == "Cr 23 No. 53-50"
    assert transaction_shipping_address[:street2] == "5555487"
    assert transaction_shipping_address[:city] == "Bogotá"
    assert transaction_shipping_address[:state] == "Bogotá D.C."
    assert transaction_shipping_address[:country] == "CO"
    assert transaction_shipping_address[:postalCode] == "000000"
    assert transaction_shipping_address[:phone] == "555-987-6543"
  end

  test "add_payer/1 takes {cart, map} tuple and returns tuple with updated map", %{ cart: cart } do
    assert {_cart, map} =  add_payer({cart, %{}})

    payer = map[:payer]
    payer_billing_address = payer[:billingAddress]

    assert payer[:merchantBuyerId] == 1
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

  test "add_credit_card/1 takes {cart, map} tuple
        and returns tuple with updated map", %{ cart: cart } do
    assert {_cart, map} = add_credit_card({cart, %{}})

    credit_card = map[:creditCard]

    assert credit_card[:number] == "4111111111111111"
    assert credit_card[:securityCode] == "321"
    assert credit_card[:expirationDate] == "2030/12"
    assert credit_card[:name] == "Santiago Ruiz"
  end

  test "add_extra_parameters/1 takes {cart, map} tuple
        and returns tuple with updated map", %{ cart: cart } do
    assert {_cart, map} = add_extra_parameters({cart, %{}})

    assert map[:paymentMethod] == "VISA"
    assert map[:paymentCountry] == "CO"
    assert map[:cookie] == "pt1t38347bs6jc9ruv2ecpv7o2"
    assert map[:userAgent] == "Mozilla/5.0 (Windows NT 5.1; rv:18.0) Gecko/20100101 Firefox/18.0"
  end

  describe "add_test/1" do
    test "returns updated map with \"test\"=true
          when in :dev or :test environments", %{ cart: cart } do
      assert {_cart, map} = add_test({cart, %{}})

      assert map[:test] == true
    end

    test "returns updated map with \"test\"=false
          when not in :dev or :test environments", %{ cart: cart } do
      assert {_cart, map } = add_test({cart, %{}}, :prod)

      assert map[:test] == false
    end
  end

  defp first_sku(cart) do
    cart.skus
    |> Map.keys
    |> List.first
  end
end
