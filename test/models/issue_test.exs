defmodule Svradmin.IssueTest do
  use Svradmin.ModelCase

  alias Svradmin.Issue

  @valid_attrs %{backend_id: 42, content: "some content", designer_id: 42, frontend_id: 42, is_done_design: 42, remark: "some content", title: "some content", version_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Issue.changeset(%Issue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Issue.changeset(%Issue{}, @invalid_attrs)
    refute changeset.valid?
  end
end
