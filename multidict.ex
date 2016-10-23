defmodule MultiDict do
  def new, do: HashDict.new

  def add(dict, k, v) do
    HashDict.update(
      dict,
      k,
      [v],
      &[v | &1]
    )
  end

  def get(dict, k) do
    HashDict.get(dict, k, []) 
  end

end
