defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder) # Makes sure the folder exists
    {:ok, db_folder}
  end

# Huge downside of a cast is that the caller can’t know whether the request was successfully handled. 
# In fact, the caller can’t even be sure that the request reached the target process. 
# This is a property of casts. 
# Casts promote overall availability by allowing client processes to move on immediately after a request is issued. 
# But this comes at the cost of consistency, because you can’t be confident about whether a request has succeeded.

  def handle_cast({:store, key, data}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(db_folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, db_folder}
  end 

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end