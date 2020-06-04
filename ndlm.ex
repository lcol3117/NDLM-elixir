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

defmodule NDLM do
  def build_transform(data) do
    Parallel.pmap(data, fn(x) -> 
      getND(x,data) end)
  end

  defp getND(x, data) do
    Parallel.pmap(data, fn(y) -> 
      l2dNotSelf(y,x) end)
    |> Ls.mn
  end

  defp l2dNotSelf(a,b) do
    raw = MiscMath.l2dist(a,b)
    unless raw === 0 do
      raw
    else
      :infinity
    end
  end

  def linked(a,b,data,eta) do
    linked(a,b,data,build_transform(data),eta)
  end
  def linked(a,b,data,ndt,eta) do
    regionpts = Parallel.pfilter(data, fn(x) -> inRegion(a,b,eta,x) end)
    acceptpts = Parallel.pfilter(regionpts, fn(x) -> ok(a,b,ndt,data,x) end)
    Ls.ln(acceptpts) >= (Ls.ln(regionpts) / 3)
  end

  defp inRegion(a,b,eta,x) do
    m = (Ls.el(b,1) - Ls.el(a,1)) / (Ls.el(b,0) - Ls.el(a,1))
    ypred = (m * (Ls.el(x,0) - Ls.el(a,0))) + Ls.el(a,1)
    beta = MiscMath.abs(ypred - Ls.el(x,1))
    minx = Ls.mn([Ls.el(a,0),Ls.el(b,0)])
    maxx = Ls.mx([Ls.el(a,0),Ls.el(b,0)])
    if Ls.el(x,0) > minx do
      if Ls.el(x,0) < maxx do
        beta <= eta
      else
        false
      end
    else
      false
    end
  end

  defp ok(a,b,ndt,data,x) do
    ndta = Ls.el(ndt,Ls.iof(data,a))
    ndtb = Ls.el(ndt,Ls.iof(data,b))
    ndtx = Ls.el(ndt,Ls.iof(data,x))
    minouter = Ls.mn([ndta,ndtb])
    ndtx < minouter
  end

  def sameCluster(a,b,data,eta) do
    sameCluster(a,b,data,build_transform(data),eta)
  end
  def sameCluster(a,b,data,ndt,eta) do
    [a1,b1] = Parallel.pmap([a,b], fn(x) -> 
      closest(x,data) end)
    opt = [[a,b],[a1,b],[a,b1],[a1,b1]]
    Parallel.pmap(opt, fn(o) -> 
      linked(Ls.el(o,0),Ls.el(o,1),data,ndt,eta) end)
    |> Ls.booleanOr
  end

  defp closest(p,data) do
    dists = Parallel.pmap(data, fn(x) -> 
      l2dNotSelf(x,p) end)
    Ls.el(data,Ls.iof(dists,Ls.mn(dists)))
  end
end
