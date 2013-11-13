defmodule Realm do

  defmacro __using__([]) do
    quote do
      use Realm.Validations
    end
  end

end
