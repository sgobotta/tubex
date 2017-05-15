defmodule Tubex.Quota do
  @moduledoc """
  The Quota module provides access to estimate resource usage of the YouTube
  API. It also provides a way of tracking actual usage of the API so you can
  store it in some short term, but not transient, data storage.

  Quota limits must be defined for each resource type.
  """

  defprotocol Limits do
    @doc """
    Returns the cost for a particular action on a resource, with some parts.
    """
    @spec cost_for(map, atom, list(atom)) :: {:ok, Integer.t} | {:error, term}
    def cost_for(resource, call, parts)
  end

  @spec new(Keyword.t) :: {:ok, pid} | {:error, term}
  def new(config) do
    dir = Keyword.get(config, :directory)
    ref = :bitcask.open(to_char_list(dir), [:read_write, {:expiry_secs, 10}])
    Agent.start_link(fn -> %{dir: dir, ref: ref} end, name: __MODULE__)
  end

  def total_used(pid) do
    ref = handle(pid)
    :bitcask.list_keys(ref)
    |> Enum.reduce(0, fn(key, acc) ->
      {:ok, s} = :bitcask.get(ref, key)
      String.to_integer(s) + acc
    end)
  end

  def update(pid, used) do
    :bitcask.put(handle(pid), Integer.to_string(DateTime.to_unix(DateTime.utc_now(), :milliseconds)), "#{used}")
  end

  defdelegate cost_for(resource, call, parts), to: Tubex.Quota.Limits

  defp handle(pid), do: Agent.get(pid, &Map.get(&1, :ref))
end