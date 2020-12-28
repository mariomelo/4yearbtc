defmodule BitcoinTest do
  use ExUnit.Case
  doctest Bitcoin

  test "subtract four years" do
    assert Bitcoin.get_previous_date("2015-10-10") == "2011-10-10"
    assert Bitcoin.get_previous_date("2018-12-31") == "2014-12-31"
    assert Bitcoin.get_previous_date("2020-02-01") == "2016-02-01"
  end

  test "90 Percentile funcions is doing okay" do
    data =
      1..100
      |> Enum.map(fn item -> ["date", item] end)

    big_data =
      500..700
      |> Enum.map(fn item -> ["date", item] end)

    assert Bitcoin.get_p90(data) == 10
    assert Bitcoin.get_p90(big_data) == 519
  end
end
