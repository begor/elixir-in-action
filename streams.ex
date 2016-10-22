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

end
