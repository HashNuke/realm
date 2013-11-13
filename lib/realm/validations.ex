defmodule Realm.Validations do
  defmacro __using__([]) do
    quote do

      unless is_list @record_fields[:__errors__] do
        raise "In order to use Realm, you need to define an :__errors__ field with an empty list as default value"
      end

      import Realm.Validations

      def valid?(record) do
        validate(record).__errors__
          |> length == 0
      end

      def validate(record) do
        record
      end

      defoverridable [validate: 1]
    end
  end


  def validates_inclusion(record, field, options, condition) do
    if apply(condition, [record]) do
      validates_inclusion(record, field, options)
    else
      record
    end
  end


  def validates_inclusion(record, field, options) do
    error_message = "does not contain #{Enum.join options[:in], ", "}"
    unless :lists.member(apply(record, :"#{field}", []), options[:in]) do
      record = add_error(record, field, error_message)
    end
    record
  end


  def validates_length(record, field, options, condition) do
    if apply(condition, [record]) do
      validates_length(record, field, options)
    else
      record
    end
  end


  def validates_length(record, field, options) do
    if options[:message] do
      min_message = max_message = options[:message]
    else
      min_message = "must be more than #{options[:min]} character long"
      max_message = "must be less than #{options[:max]} character long"
    end

    field_value = apply(record, :"#{field}", [])

    cond do
      is_binary(field_value) ->
        field_size = size field_value

        if options[:min] && field_size < options[:min] do
          record = add_error(record, field, min_message)
        end
        if options[:max] && field_size > options[:max] do
          record = add_error(record, field, max_message)
        end
        record

      is_list(field_value) ->
        field_size = length field_value

        if options[:min] && field_size < options[:min] do
          record = add_error(record, field, min_message)
        end
        if options[:max] && field_size > options[:max] do
          record = add_error(record, field, max_message)
        end
        record

      field_value == :nil ->
        add_error(record, field, min_message)

      true ->
        add_error(record, field, "unsupported data")
    end
  end


  def add_error(record, field, error) do
    record.__errors__( [{field, error} | record.__errors__] )
  end


  def clear_errors(record) do
    record.__errors__([])
  end


  def errors(record) do
    record.__errors__
  end
end
