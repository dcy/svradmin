defmodule Svradmin.HistoryTest do
  use Svradmin.ModelCase

  alias Svradmin.History

  @valid_attrs %{svr_id: 42, what: 42, who: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = History.changeset(%History{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = History.changeset(%History{}, @invalid_attrs)
    refute changeset.valid?
  end
end
