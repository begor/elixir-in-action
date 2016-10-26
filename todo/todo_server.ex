defimpl String.Chars, for: TodoList do
  def to_string(_), do: "#TodoList"
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end
  defp into_callback(todo_list, :done), do: todo_list
  #:halt indicates that the operation has been canceled, and the return value is ignored.
  defp into_callback(todo_list, :halt), do: :ok
end

defmodule TodoServer do
  def start do
    spawn(fn() -> loop(TodoList.new) end)
  end

  def add_entry(todo_server, entry) do
    send(todo_server, {:add_entry, entry})
  end

  def update_entry(todo_server, entry, updater) do
    send(todo_server, {:update_entry, entry, updater})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, date})

    receive do
      {:entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_list = receive do
      message -> handle_message(todo_list, message)
    end

    loop(new_list)
  end

  defp handle_message(todo_list, {:add_entry, entry}) do
    TodoList.add_entry(todo_list, entry)
  end
  defp handle_message(todo_list, {:entries, date}) do
    TodoList.entries(todo_list, date)
  end
  defp handle_message(todo_list, {:update_entry, entry, updater}) do
    TodoList.update_entry(todo_list, entry, updater)
  end
end

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
    |> read
    |> parse
    |> TodoList.new
  end

  defp read(file), do: File.stream!(file)

  defp parse(file_stream) do 
    file_stream
    |> Stream.map(&parse_line/1)
    |> Enum.to_list
  end

  defp parse_line(line) do
    line
    |> split_line
    |> prepare_map
  end

  defp split_line(line) do
    [date, task] = String.split(line, ",")
    {String.split(date, "/"), task}
  end

  defp prepare_map({[y, m, d], task}) do
    %{date: {String.to_integer(y), String.to_integer(m), String.to_integer(d)}, title: task}
  end
end
