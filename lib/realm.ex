defmodule Realm do

  defmacro __using__([]) do
    quote do
      use Realm.Validations
      # use Realm.AttributeTracker

      def attributes(record) do
        fields = Enum.filter @record_fields, fn({field, default_value})->
          Regex.match?(%r/\A__[a-zA-Z0-9]+__\z/, "#{field}") == false
        end
        Enum.map fields, fn({field, default_value})-> {"#{field}", apply(record, field, [])} end
      end

    end
  end

end
