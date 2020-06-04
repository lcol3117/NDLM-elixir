defmodule Parallel do
  def pmap(collection, fun) do
    collection
    |> Enum.map(fn (elem) ->
      Task.async fn -> fun.(elem) end end)
    |> Enum.map(fn (task) ->
      Task.await task
    end)
  end

  def pfilter(collection, fun) do
    vals = pmap(collection, fun)
    build_new(collection, vals)
  end

  def build_new(collection, vals) do
    build_new(collection, vals, [])
  end
  def build_new([ch|ct], [vh|vt], res) do
    if vh do
      build_new(ct,vt,res++[ch])
    else
      build_new(ct,vt,res)
    end
  end
  def build_new([],[],res) do
    res
  end
end
