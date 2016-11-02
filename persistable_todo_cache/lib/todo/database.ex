defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    worker = GenServer.call(:database_server, {:get_worker, key})
    Todo.DatabaseWorker.store(worker, key, data)
  end

  def get(key) do
    worker = GenServer.call(:database_server, {:get_worker, key})
    IO.puts "Got worker"
    IO.inspect worker
    Todo.DatabaseWorker.get(worker, key)
  end

  def init(db_folder) do
    File.mkdir_p(db_folder) # Make sure the folder exists
    workers = start_workers(db_folder)
    {:ok, {db_folder, workers}}
  end

  def handle_call({:get_worker, key}, caller, {db_folder, workers}) do
    key_hash = :erlang.phash2(key, 3)
    IO.puts "Hash"
    IO.inspect key_hash
    {:reply, HashDict.get(workers, key_hash), workers}
  end
  def handle_call(m, _, s) do
    {:noreply, s}
  end

  defp start_workers(db_folder) do
    Enum.reduce(
      0..2, 
      HashDict.new,
      fn(i, acc) -> 
        {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
        HashDict.put(acc, i, pid)
      end)
  end
end