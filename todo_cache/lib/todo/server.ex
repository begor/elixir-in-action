defmodule Todo.Server do
  use GenServer


  def start, do: GenServer.start(Todo.Server, nil)

  def init(_), do: {:ok, Todo.List.new}

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, entry, updater) do
    GenServer.cast(pid, {:update_entry, entry, updater})
  end

  def delete_entry(pid, entry) do
    GenServer.cast(pid, {:delete_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end
  def handle_cast({:update_entry, entry, updater}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, entry, updater)}
  end
  def handle_cast({:delete_entry, entry}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end
