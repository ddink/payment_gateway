import Config

config :payment_gateway,
  prod_merchant_api_key: "INSERT_MERCHANT_API_KEY",
  prod_merchant_api_login: "INSERT_MERCHANT_API_LOGIN",
  prod_merchant_api_id: "INSERT_MERCHANT_API_LOGIN",
  prod_payu_latam_api_url: "https://api.payulatam.com/payments-api/4.0/service.cgi"

import_config "#{config_env()}.exs"
