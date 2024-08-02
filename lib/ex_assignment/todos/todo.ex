defmodule ExAssignment.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field(:done, :boolean, default: false)
    field(:priority, :integer)
    field(:inverse_priority, :integer, virtual: true)
    field(:title, :string)

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :priority, :done])
    |> validate_required([:title, :priority, :done])
  end
end
