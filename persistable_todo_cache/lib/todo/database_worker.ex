defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
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
    spawn(fn ->
      file_name(db_folder, key)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, caller, db_folder) do

    spawn(fn -> 
      data = case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end
      GenServer.reply(caller, data)
    end)

    {:noreply, db_folder}
  end 

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end