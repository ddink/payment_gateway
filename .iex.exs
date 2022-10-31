alias PaymentGateway.OrderRequestBuilder
alias PaymentGateway.Gateway.PayuLatam

cart = %{
  id: "321",
  cookie: "pt1t38347bs6jc9ruv2ecpv7o2",
  browser_user_agent: "Mozilla/5.0 (Windows NT 5.1; rv:18.0) Gecko/20100101 Firefox/18.0",
  language: "es",
  order: %{
    total_transaction_price: 65_000,
    tax_price: 10_378,
    order_price: 54_622,
    currency: "COP",
    payment_installments: 1,
    payment_method: "VISA",
    payment_country: "CO",
    skus: %{
      "1234567890" => "2",
      "0987654321" => "1"
    },
    cart_id: "321"
  },
  # user_id: "123",
  user: %{
    id: 1,
    first_name: "Juan",
    last_name: "Doe",
    email: "jd1978@gmail.com",
    phone_number: "555-123-4567",
    documentation_number: "1234A4567B809K",
    default_credit_card_token_id: "46b7f03e-1b3b-4ce8-ad90-fe1a482f76c3"
  },
  shipping_address: %{
    first_line: "Cr 23 No. 53-50",
    second_line: "5555487",
    city: "Bogotá",
    state: "Bogotá D.C.",
    country: "CO",
    postal_code: "000000",
    phone_number: "555-987-6543"
  },
  customer: %{
    first_name: "Santiago",
    last_name: "Ruiz",
    email: "sr1960@gmail.com",
    phone_number: "555-426-9980",
    documentation_number: "987E654V321Z"
  },
  billing_address: %{
    first_line: "Cr 23 No. 53-50",
    second_line: "125544",
    city: "Bogotá",
    state: "Bogotá D.C.",
    country: "CO",
    postal_code: "000000",
    phone_number: "555-756-3126"
  },
  payment_method: %{
    cc_number: "4111111111111111",
    cc_security_code: "321",
    cc_expiration_date: "2030/12",
    cc_name: "Santiago Ruiz",
    cc_token_id: "46b7f03e-1b3b-4ce8-ad90-fe1a482f76c3",
    name: "VISA"
  }
}

headers = PayuLatam.request_headers()

# Draft of in-memory cart struct
#   can we validate it via Ecto.Changeset?
# defmodule PaymentGateway.Cart do
#   @enforce_keys [
#     :order,
#     :user,
#     :shipping_address,
#     :purchaser,
#     :billing_address,
#     :credit_card
#   ]

#   defstruct [
#     :cookie,
#     :browser_user_agent,
#     :language,
#     order: %{
#       total_transaction_price: 0,
#       tax_price: 0,
#       order_price: 0,
#       currency: "",
#       payment_installments: 1,
#       payment_method: "",
#       payment_country: "",
#       skus: %{}
#     },
#     user: %{
#       id: 0,
#       first_name: "",
#       last_name: "",
#       email: "",
#       phone_number: "",
#       documentation_number: ""
#     },
#     shipping_address: %{
#       first_line: "",
#       second_line: "",
#       city: "",
#       state: "",
#       country: "",
#       postal_code: "",
#       phone_number: ""
#     },
#     purchaser: %{
#       first_name: "",
#       last_name: "",
#       email: "",
#       phone_number: "",
#       documentation_number: ""
#     },
#     billing_address: %{
#       first_line: "",
#       second_line: "",
#       city: "",
#       state: "",
#       country: "",
#       postal_code: "",
#       phone_number: ""
#     },
#     credit_card: %{
#       number: "",
#       security_code: "",
#       expiration_date: "",
#       name: ""
#     }
#   ]
# end
