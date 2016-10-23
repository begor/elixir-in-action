defmodule ToDo do
  def new, do: HashDict.new

  def add_entry(list, date, title) do
    HashDict.update(
      list,
      date,
      [title],
      fn(titles) -> [title | titles] end
    )
  end

  def entries(list, date) do
    HashDict.get(list, date, []) 
  end
end
