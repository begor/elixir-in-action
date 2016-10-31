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

defmodule KeyValue do
  def start, do: ServerProcess.run(KeyValue)
  
  def init, do: HashDict.new

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end

  def handle_cast({:put, key, value}, state) do
    HashDict.put(state, key, value)
  end
end 