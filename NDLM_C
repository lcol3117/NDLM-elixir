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
