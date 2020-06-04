defmodule MiscMath do
  def abs(x) do
    unless x>0 do
      -x
    else
      x
    end
  end

  def succ(x) do
    x + 1
  end

  def prev(x) do
    x - 1
  end

  def median(l) do
    median(Enum.sort(l),:sorted) 
  end
  def median(l,:sorted) do
    Ls.el(l,div(Ls.ln(l),2))
  end

  def l2dist(a,b) do
    Parallel.pmap((0..(Ls.ln(a) - 1)),fn(x) -> 
      getDValue(a,b,x) end)
    |> Enum.sum
    |> :math.sqrt
  end

  def getDValue(a,b,x) do
    :math.pow(Ls.el(b,x) - Ls.el(a,x),2)
  end
end
