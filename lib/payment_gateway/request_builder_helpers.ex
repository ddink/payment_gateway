defmodule PaymentGateway.RequestBuilderHelpers do
  def ip_address() do
    {:ok, ifs} = :inet.getif()
    ips = Enum.map(ifs, fn {ip, _broadaddr, _mask} -> ip end)

    {n1, n2, h1, h2} = ips |> List.first

    "#{n1}.#{n2}.#{h1}.#{h2}"
  end
end
