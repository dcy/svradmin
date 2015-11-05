defmodule Svradmin.VersionTest do
  use Svradmin.ModelCase

  alias Svradmin.Version

  @valid_attrs %{end: "2010-04-17 14:00:00", name: "some content", start: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Version.changeset(%Version{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Version.changeset(%Version{}, @invalid_attrs)
    refute changeset.valid?
  end
end
