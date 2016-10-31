defmodule ServerProcess do
  def run(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  def call(pid, message) do
    send(pid, {:call, self, message})
    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, self, message})
  end

  defp loop(module, state) do
    receive do
      {:call, from, message} -> 
        {response, new_state} = module.handle_call(message, state)
        send(from, {:response, response})
        loop(module, new_state)
      {:cast, message} ->
        new_state = module.handle_cast(message, state)
        loop(module, new_state)
    end
    
  end
end


defmodule TodoServer do
  def start, do: ServerProcess.run(TodoServer)

  def init, do: TodoList.new

  def add_entry(pid, entry) do
    ServerProcess.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, entry, updater) do
    ServerProcess.cast(pid, {:update_entry, entry, updater})
  end

  def delete_entry(pid, entry) do
    ServerProcess.cast(pid, {:delete_entry, entry})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    TodoList.add_entry(todo_list, entry)
  end
  def handle_cast({:update_entry, entry, updater}, todo_list) do
    TodoList.update_entry(todo_list, entry, updater)
  end
  def handle_cast({:delete_entry, entry}, todo_list) do
    TodoList.delete_entry(todo_list, entry)
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
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

  def delete_entry(%TodoList{entries: entries} = list, entry_id) do
    %TodoList{list | entries: HashDict.delete(entries, entry_id)}
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
