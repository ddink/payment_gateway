defmodule PaymentGateway.RequestBuilderHelpers do

  @payu_latam_country_codes ["CO", "BR", "PA", "CL", "PE", "AR", "MX"]
  @payu_latam_test_account_ids %{
    "AR" => "512322",
    "BR" => "512327",
    "CL" => "512325",
    "CO" => "512321",
    "MX" => "512324",
    "PA" => "512326",
    "PE" => "512323"
  }

  def ip_address() do
    {:ok, ifs} = :inet.getif()
    ips = Enum.map(ifs, fn {ip, _broadaddr, _mask} -> ip end)

    {n1, n2, h1, h2} = ips |> List.first

    "#{n1}.#{n2}.#{h1}.#{h2}"
  end

  def payu_latam_test_account_id(code) when code in @payu_latam_country_codes do
    Map.get(@payu_latam_test_account_ids, code)
  end
  def payu_latam_test_account_id(_code), do: nil
end
