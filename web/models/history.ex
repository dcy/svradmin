defmodule Svradmin.History do
  use Svradmin.Web, :model

  schema "historys" do
    field :who, :string
    field :what, :integer
    field :svr_id, :integer

    timestamps
  end

  @required_fields ~w(who what svr_id)
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
