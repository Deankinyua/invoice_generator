defmodule InvoiceGenerator.Profile.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :binary_id

  schema "profiles" do
    field :country, :string
    field :city, :string
    field :phone, :string
    field :postal_code, :string
    field :street, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [:country, :city, :phone, :postal_code, :street])
    |> validate_required([:country, :city, :phone, :postal_code, :street])
    |> validate_the_lengths()
  end

  def validate_the_lengths(changeset) do
    changeset
    |> validate_length(:country, max: 80)
    |> validate_length(:city, max: 40)
    |> validate_length(:phone, max: 15)
    |> validate_length(:postal_code, max: 80)
  end
end
