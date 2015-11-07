defmodule Util do

  def mapskeydelete(_, _, []) do
    []
  end
  def mapskeydelete(what, key, [h|t]) do
    case Map.get(h, key) == what do
      true -> t
      false -> [h | mapskeydelete(what, key, t)]
    end
  end

  def mapskeyreplace(_, _, [], _) do
    []
  end
  def mapskeyreplace(what, key, [h|t], new) do
    case Map.get(h, key) == what do
      true -> [new|t]
      false -> [h|mapskeyreplace(what, key, t, new)]
    end
  end

  def mapskeyfind(_, _, []) do
    false
  end
  def mapskeyfind(what, key, [h|t]) do
    case Map.get(h, key) == what do
      true -> h
      false -> mapskeyfind(what, key, t)
    end
  end

  def get_conf(key) do
    svr_conf = Application.get_env(:svradmin, :svr_conf)
    Keyword.get(svr_conf, key, [])
  end

  def remove_ecto_struct_keys(map) do
    Map.drop(map, [:__meta__, :inserted_at, :updated_at])
  end




end
