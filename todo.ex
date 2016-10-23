defmodule ToDo do
  def new, do: MultiDict.new

  def add_entry(list, date, title) do
    MultiDict.add(list, date, title)
  end

  def entries(list, date) do
    MultiDict.get(list, date)
  end
end
