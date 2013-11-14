defmodule Realm do

  defmacro __using__([]) do
    quote do
      use Realm.Validations
      # use Realm.AttributeTracker

      def attributes(record) do
        Enum.filter @record_fields, fn({field, value})->
          Regex.match?(%r/\A__[a-zA-Z0-9]+__\z/, "#{field}") == false
        end
      end

    end
  end

end
