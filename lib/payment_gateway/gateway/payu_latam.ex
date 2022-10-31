defmodule PaymentGateway.Gateway.PayuLatam do
  @transaction_command "SUBMIT_TRANSACTION"
  @notify_url "http://www.payu.com/notify"
  @test_api_url "https://sandbox.api.payulatam.com/payments-api/4.0/service.cgi"
  @prod_api_url "https://api.payulatam.com/payments-api/4.0/service.cgi"
  @request_headers [
    {"Host", "sandbox.api.payulatam.com"},
    {"Content-Type", "application/json; charset=utf-8"},
    {"Accept", "application/json"},
    {"Content-Length", "length"}
  ]
  @request_options [hackney: [pool: :payu_latam]]

  # attributes that will be determined by client

  # 3-D secure attributes
  @embedded false
  @eci "01"
  @cavv "AOvG5rV058/iAAWhssPUAAADFA=="
  @xid "Nmp3VFdWMlEwZ05pWGN3SGo4TDA="
  @directory_server_transaction_id "00000-70000b-5cc9-0000-000000000cb"

  @credit_cards [
    "AMEX", "ARGENCARD", "CABAL", "CENCOSUD", "CODENSA", "DINERS", "ELO", 
    "HIPERCARD", "MASTERCARD", "MASTERCARD_DEBIT", "NARANJA", "SHOPPING", 
    "TRANSBANK_DEBIT", "VISA", "VISA_DEBIT"
  ]
  @non_credit_card_payment_methods [
    "BANK_REFERENCED", "BOLETO_BANCARIO", "COBRO_EXPRESS", "EFECTY", "ITAU", 
    "MULTICAJA", "PAGOFACIL", "PAGOEFECTIVO", "PIX", "PSE", "RAPIPAGO", 
    "OTHERS_CASH", "OTHERS_CASH_MX", "OXXO", "SEVEN_ELEVEN", "SPEI"
  ]

  import PaymentGateway.SignatureEncoder
  import PaymentGateway.RequestBuilderHelpers
  import PaymentGateway.RequestBuilderHelpers.PayuLatam
  alias __MODULE__.Tokens

  def add_merchant_info(%{language: language} = cart) do
    map = %{
      language: language,
      command: @transaction_command,
      merchant: %{
        apiKey: merchant_api_key(),
        apiLogin: merchant_api_login()
      }
    }

    {:payu_latam, cart, map}
  end
  def add_merchant_info(_cart) do
    {:error, "cart is missing merchant data"}
  end

  def add_order({%{
    language: language,
    order: %{
      total_transaction_price: total_price,
      tax_price: tax_price,
      order_price: order_price,
      currency: currency,
      payment_country: payment_country
    }
  } = cart, map}) do
    order = %{
      order: %{
        accountId: payu_latam_test_account_id(payment_country),
        referenceCode: reference_code(cart),
        description: order_description(),
        language: language,
        signature: payu_latam_order_signature(cart),
        notifyUrl: @notify_url,
        additionalValues: %{
          "TX_VALUE" => %{
            value: total_price,
            currency: currency
          },
          "TX_TAX" => %{
            value: tax_price,
            currency: currency
          },
          "TX_TAX_RETURN_BASE" => %{
            value: order_price,
            currency: currency
          }
        }
      }
    }

    map = Map.put(map, :transaction, order)

    {:payu_latam, cart, map}
  end
  def add_order(_request_data) do
    {:error, "cart is missing order data"}
  end

  def add_buyer({%{
    user: %{
      id: id,
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: user_phone_number,
      documentation_number: documentation_number
    },
    shipping_address: %{
      first_line: first_line,
      second_line: second_line,
      city: city,
      state: state,
      country: country,
      postal_code: postal_code,
      phone_number: shipping_adress_phone_number
    }
  } = cart, map}) do
    buyer = %{
      merchantBuyerId: id,
      fullName: "#{first_name} #{last_name}",
      emailAddress: email,
      contactPhone: user_phone_number,
      dniNumber: documentation_number,
      shippingAddress: %{
        street1: first_line,
        street2: second_line,
        city: city,
        state: state,
        country: country,
        postalCode: postal_code,
        phone: shipping_adress_phone_number
      }
    }

    transaction = Map.fetch!(map, :transaction)

    order_buyer =
      transaction
      |> Map.fetch!(:order)
      |> Map.put(:buyer, buyer)

    transaction = Map.put(transaction, :order, order_buyer)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_buyer(_request_data) do
    {:error, "cart is missing transaction buyer data"}
  end

  def add_shipping_address({%{
    shipping_address: %{
      first_line: first_line,
      second_line: second_line,
      city: city,
      state: state,
      country: country,
      postal_code: postal_code,
      phone_number: phone_number
    }
  } = cart, map}) do
    shipping_address = %{
      street1: first_line,
      street2: second_line,
      city: city,
      state: state,
      country: country,
      postalCode: postal_code,
      phone: phone_number
    }

    transaction = Map.fetch!(map, :transaction)

    order =
      transaction
      |> Map.fetch!(:order)
      |> Map.put(:shippingAddress, shipping_address)

    transaction = Map.put(transaction, :order, order)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_shipping_address(_request_data) do
    {:error, "cart is missing transaction shipping address data"}
  end

  def add_customer({%{
    user: %{
      id: _id
    },
    customer: %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: purchaser_phone_number,
      documentation_number: documentation_number
    },
    billing_address: %{
      first_line: first_line,
      second_line: second_line,
      city: city,
      state: state,
      country: country,
      postal_code: postal_code,
      phone_number: billing_adress_phone_number
    }
  } = cart, map}) do
    payer = %{
      # merchantPayerId: id,
      fullName: "#{first_name} #{last_name}",
      emailAddress: email,
      contactPhone: purchaser_phone_number,
      dniNumber: documentation_number,
      billingAddress: %{
        street1: first_line,
        street2: second_line,
        city: city,
        state: state,
        country: country,
        postalCode: postal_code,
        phone: billing_adress_phone_number
      }
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:payer, payer)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_customer(_request_data) do
    {:error, "cart is missing customer data"}
  end

  def add_payment_method({%{
    order: %{
      payment_method: payment_method
    }
  } = cart, map}) when payment_method in @non_credit_card_payment_methods do

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:paymentMethod, payment_method)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_payment_method({%{
    order: %{
      payment_method: payment_method
    },
    customer: %{
      first_name: first_name,
      last_name: last_name
    },
    payment_method: %{
      cc_number: number,
      cc_security_code: security_code,
      cc_expiration_date: expiration_date
    }
  } = cart, map}) when payment_method in @credit_cards do
    credit_card = %{
      number: number,
      securityCode: security_code,
      expirationDate: expiration_date,
      name: "#{first_name} #{last_name}"
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:creditCard, credit_card)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_payment_method(_request_data) do
    {:error, "cart is missing credit card data"}
  end

  def add_extra_parameters({%{
    order: %{
      payment_method: payment_method,
      payment_country: payment_country
    },
    cookie: cookie,
    browser_user_agent: browser_user_agent
  } = cart, map}) do

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:paymentMethod, payment_method)
      |> Map.put(:paymentCountry, payment_country)
      |> Map.put(:deviceSessionId, device_session_id_signature(cookie))
      |> Map.put(:ipAddress, ip_address())
      |> Map.put(:cookie, cookie)
      |> Map.put(:userAgent, browser_user_agent)
      |> Map.put(:type, set_transaction_type())
      |> add_three_domain_secure_attributes

    map = Map.put(map, :transaction, transaction)

    # switches to {cart, map} return for OrderRequestBuilder.add_test/2
    {cart, map}
  end
  def add_extra_parameters(_request_data) do
    {:error, "cart is missing extra parameters data"}
  end

  defp add_three_domain_secure_attributes(map) do
    three_domain_secure = %{
      embedded: @embedded,
      eci: @eci,
      cavv: @cavv,
      xid: @xid,
      directoryServerTransactionId: @directory_server_transaction_id
    }

    Map.put(map, :threeDomainSecure, three_domain_secure)
  end

  def api_url(env \\ Mix.env()) when is_atom(env) do
    if Enum.member?([:dev, :test], env) do
      @test_api_url
    else
      @prod_api_url
    end
  end

  def request_headers(), do: HTTPoison.process_request_headers(@request_headers)

  def request_options(), do: @request_options

  defp set_transaction_type, do: "AUTHORIZATION_AND_CAPTURE"

  def tokenize_credit_card(cart), do: Tokens.tokenize_credit_card(cart)

  def delete_credit_card_token(cart), do: Tokens.delete_credit_card_token(cart)

  def query_tokens(cart), do: Tokens.query_tokens(cart)

  def add_token({%{
    payment_method: %{
      cc_token_id: token_id,
      cc_security_code: security_code
    }
  } = cart, map}) do
    credit_card = %{
      securityCode: security_code
    }

    transaction =
      map
      |> Map.fetch!(:transaction)
      |> Map.put(:creditCardTokenId, token_id)
      |> Map.put(:creditCard, credit_card)

    map = Map.put(map, :transaction, transaction)

    {:payu_latam, cart, map}
  end
  def add_token(_request_data) do
    {:error, "cart missing credit card token data"}
  end
end
