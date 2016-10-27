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

defmodule KeyValue do
  def start, do: ServerProcess.run(KeyValue)
  
  def init, do: HashDict.new

  def handle_call({:put, key, value}, state) do
    {:ok, HashDict.put(state, key, value)}
  end
  def handle_call({:get, key}, state) do
    {:ok, HashDict.get(state, key)}
  end
end 