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

    quotes =
      data.body
      |> Poison.decode!()
      |> Map.get(@map_key)

    gains =
      Map.keys(quotes)
      |> Enum.map(fn key -> get_quote_diff(key, quotes) end)
      |> Enum.filter(fn item -> item != nil end)
      |> Enum.sort()

    gains
    |> Poison.encode!()
    |> Chartkick.line_chart(library: %{hAxis: %{logScale: true}, explorer: %{axis: 'horizontal'}})
    |> draw_chart()
    |> draw_capped_chart(gains)
    |> place_data("%%MINIMUM%%", get_minimum(gains))
    |> place_data("%%AVERAGE%%", get_average(gains))
    |> place_data("%%P90%%", get_p90(gains))
    |> write_html_file()
  end

  def draw_chart(data) do
    File.read!("template.html")
    |> String.replace("%%CHART1%%", data)
  end

  def draw_capped_chart(data, gains) do
    capped =
      gains
      |> Enum.map(fn [date, profit] ->
        cond do
          profit > 10 -> [date, 10]
          true -> [date, profit]
        end
      end)
      |> Poison.encode!()
      |> Chartkick.line_chart(library: %{explorer: %{axis: 'horizontal'}})

    data
    |> String.replace("%%CHART2%%", capped)
  end

  def write_html_file(content) do
    {:ok, file} = File.open("readme.html", [:write])
    IO.binwrite(file, content)
    File.close(file)
  end

  def place_data(content, placeholder, data) do
    content
    |> String.replace(placeholder, data)
  end

  def get_quote_diff(original_date, _quotes)
      when original_date < @start_date,
      do: nil

  def get_quote_diff(original_date, quotes) do
    previous_date = get_previous_date(original_date)
    gains = Map.get(quotes, original_date) / Map.get(quotes, previous_date)
    [original_date, gains]
  end

  def get_previous_date(original_date) do
    [year, month, day] = String.split(original_date, "-")
    "#{String.to_integer(year) - @year_gap}-#{month}-#{day}"
  end

  defp get_minimum(gains) do
    Enum.min_by(gains, fn [_date, gain] -> gain end)
    |> Enum.at(1)
    |> Kernel.*(100)
    |> Float.round(2)
    |> to_string()
  end

  defp get_average(gains) do
    gains
    |> Enum.map(fn [_date, profit] -> profit end)
    |> Enum.reduce(fn profit, acc -> acc + profit end)
    |> Kernel./(length(gains))
    |> Kernel.*(100)
    |> Float.round(2)
    |> to_string()
  end

  defp get_p90(gains) do
    limit = floor(length(gains) / 10)

    gains
    |> Enum.map(fn [_date, profit] -> profit end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.slice(0..limit)
    |> Enum.reverse()
    |> Enum.at(0)
    |> Kernel.*(100)
    |> Float.round(2)
    |> to_string()
  end
end
