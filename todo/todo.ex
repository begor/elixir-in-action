defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(%TodoList{auto_id: id, entries: entries} = list, entry) do
    entry = Map.put(entry, :id, id)
    new_entries = HashDict.put(entries, id, entry)
    %TodoList{list | entries: new_entries, auto_id: id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def update_entry(%TodoList{entries: entries} = list, entry, updater) do
    case entries[entry.id] do
      nil -> list
      old_entry ->
        new_entry = updater.(old_entry)
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %TodoList{list | entries: new_entries}
    end
  end
end

defmodule TodoList.CsvImporter do
  def import(file) do
    file
    |> File.stream!
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn([date, task]) -> {String.split(date, "/"), task} end)
    |> Stream.map(fn({[y, m, d], task}) -> %{date: {String.to_integer(y), String.to_integer(m), String.to_integer(d)}, title: task} end)
    |> Enum.to_list
    |> TodoList.new
    |> IO.inspect
  end
end
