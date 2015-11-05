defmodule Svradmin.Issue do
  use Svradmin.Web, :model

  schema "issues" do
    field :version_id, :integer
    field :title, :string
    field :content, :string
    field :designer_id, :integer
    field :is_done_design, :integer
    field :frontend_id, :integer
    field :backend_id, :integer
    field :remark, :string

    timestamps
  end

  @required_fields ~w(version_id title content designer_id is_done_design frontend_id backend_id remark)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
