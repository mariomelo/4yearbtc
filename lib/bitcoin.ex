defmodule Bitcoin do
  @start_date "2014-07-18"
  @map_key "bpi"
  @year_gap 4
  @server_url "https://api.coindesk.com/v1/bpi/historical/close.json?start=2010-07-17&end=2020-12-27"

  @moduledoc """
  Documentation for `Bitcoin`.
  """

  def get_data do
    {:ok, data} = HTTPoison.get(@server_url)

    data.body
    |> Poison.decode!()
    |> Map.get(@map_key)
  end

  def get_previous_date(original_date) do
    [year, month, day] = String.split(original_date, "-")
    "#{String.to_integer(year) - @year_gap}-#{month}-#{day}"
  end
end
