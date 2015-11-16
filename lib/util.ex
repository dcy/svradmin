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

  def mapskeysort(key, map_list) do
    fun = fn(f_item, b_item) -> Map.get(f_item, key) <= Map.get(b_item, key) end
    :lists.sort(fun, map_list)
  end


  def get_conf(key) do
    svr_conf = Application.get_env(:svradmin, :svr_conf)
    Keyword.get(svr_conf, key, [])
  end

  def remove_ecto_struct_keys(map) do
    Map.drop(map, [:__meta__, :inserted_at, :updated_at])
  end

  def remove_maps_nil(map) do
    lists = Enum.map(map, fn {k, v} ->
      new_v = case v do
        nil -> ""
        _ -> v
      end
      {k, new_v} end)
    Enum.into(lists, %{})
  end




end
