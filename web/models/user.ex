defmodule Svradmin.User do
  use Svradmin.Web, :model

  schema "users" do
    field :name, :string
    field :password, :string
    field :cn_name, :string
    field :is_admin, :integer

    timestamps
  end

  @required_fields ~w(name password cn_name is_admin)
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
