defmodule Realm do
  defmacro __using__([]) do

    quote do
      Record.deffunctions [attributes: [], errors: [], validations: []], __ENV__

      def valid?(record) do
        true
      end

      defoverridable [valid?: 1]


      def add_error(record, field, error) do
        record.errors( ListDict.merge record.errors, [{field, error}] )
      end

      def clear_errors(record) do
        record.errors([])
      end


      def validates_inclusion(record, field, options, condition) do
        if apply(condition, [record]) do
          validates_inclusion(record, field, options)
        end
      end


      def validates_inclusion(record, field, options) do
        error_message = "does not contain #{Enum.join options[:in], ", "}"
        unless :lists.member(record.attributes[field], options[:in]) do
          add_error(record, field, error_message)
        end
      end


      def validates_length(record, field, options, condition) do
        if apply(condition, [record]) do
          validates_length(record, field, options)
        end
      end


      def validates_length(record, field, options) do
        if options[:message] do
          min_message = max_message = options[:message]
        else
          min_message = "must be more than #{options[:min]}"
          max_message = "must be less than #{options[:max]}"
        end

        cond do
          is_binary(record) ->
            result_record = record
            if options[:min] && size(result_record.attributes[field]) < options[:min] do
              result_record = add_error(result_record, field, min_message)
            end
            if options[:max] && size(result_record.attributes[field]) > options[:max] do
              result_record = add_error(result_record, field, max_message)
            end

          is_list(record) ->
            result_record = record
            if options[:min] && length(result_record.attributes[field]) < options[:min] do
              result_record = add_error(result_record, field, min_message)
            end
            if options[:max] && length(result_record.attributes[field]) > options[:max] do
              result_record = add_error(result_record, field, max_message)
            end

          true ->
            add_error(record, field, "unsupported data")
        end
      end

    end
  end
end
