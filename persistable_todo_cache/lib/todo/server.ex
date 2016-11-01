defmodule Todo.Server do
  use GenServer


  def start(name), do: GenServer.start(Todo.Server, name)

  def init(name), do: {:ok, {name, Todo.List.new}}

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

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end
  def handle_cast({:update_entry, entry, updater}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, entry, updater)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end
  def handle_cast({:delete_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end
end
