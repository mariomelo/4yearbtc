defmodule BitcoinTest do
  use ExUnit.Case
  doctest Bitcoin

  test "subtract four years" do
    assert Bitcoin.get_previous_date("2015-10-10") == "2011-10-10"
    assert Bitcoin.get_previous_date("2018-12-31") == "2014-12-31"
    assert Bitcoin.get_previous_date("2020-02-01") == "2016-02-01"
  end
end
