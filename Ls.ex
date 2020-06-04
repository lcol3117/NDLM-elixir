defmodule Ls do
  def mx(l) do 
    mx(l,0) 
  end
  def mx([head|tail],n) do 
    if head>n do
      mx(tail,head) 
    else
      mx(tail,n) 
    end
  end
  def mx([],n) do
    n 
  end

  def mn(l) do
    mn(l,:infinity)
  end
  def mn([head|tail],n) do
    if head<n do
      mn(tail,head) 
    else
      mn(tail,n) 
    end
  end
  def mn([],n) do
    n 
  end

  def el([head|_tail],0) do
    head 
  end
  def el([_head|tail],n) do
    el(tail,MiscMath.prev(n)) 
  end

  def ln(l) do
    ln(l,0)
  end
  def ln([_head|tail],n) do
    ln(tail,MiscMath.succ(n)) 
  end
  def ln([],n) do
    n 
  end

  def inv(l) do
    inv(l,[]) 
  end
  def inv([head|tail],o) do
    inv(tail,o++[not head]) 
  end
  def inv([],o) do
    o 
  end

  def iof(l,e) do
    Enum.find_index(l, fn(x) -> x === e end)
  end

  def booleanOr(l) do
    booleanOr(l,false)
  end
  def booleanOr([lh|lt],false) do
    booleanOr(lt,lh)
  end
  def booleanOr(_l,true) do
    true
  end
  def boolean([],false) do
    false
  end
end
