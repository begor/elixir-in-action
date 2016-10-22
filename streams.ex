defmodule StreamsPractice do
  def large_lines!(path) do
    path
    |> File.stream!
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 80))
  end

  def lines_length!(path) do
    path
    |> File.stream!
    |> Stream.map(&String.length/1)
    |> Enum.to_list
  end

  def longest_line_length!(path) do
    path
    |> lines_length!
    |> Enum.max
  end

  def longest_line!(path) do
    path
    |> File.stream!
    |> Enum.reduce("", &line_bigger/2)
  end

  defp line_bigger(x, y) do
    case String.length(x) > String.length(y) do
      true -> x
      false -> y
    end
  end

end
