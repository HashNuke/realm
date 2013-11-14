defmodule RealmTest do
  use ExUnit.Case

  defrecord Student, name: nil, age: nil, role: nil, __errors__: [] do
    use Realm
  end

  test "Get attributes" do
    student = Student[name: "John Doe"]
    IO.inspect student.attributes
    assert(Student[name: "John Doe"].attributes |> Dict.get(:name) == "John Doe")
  end

end
