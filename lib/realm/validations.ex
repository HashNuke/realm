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

      def errors(record) do
        record.__errors__
      end

      defoverridable [validate: 1]
    end
  end


  def validates_inclusion(record, field, options, condition) do
    if apply(condition, [record]) do
      record = validates_inclusion(record, field, options)
    end
    record
  end


  def validates_inclusion(record, field, options) do
    error_message = options[:message] || "does not contain valid value}"
    unless :lists.member(apply(record, :"#{field}", []), options[:in]) do
      record = add_error(record, field, error_message)
    end
    record
  end


  def validates_exclusion(record, field, options, condition) do
    if apply(condition, [record]) do
      record = validates_exclusion(record, field, options)
    end
    record
  end


  def validates_exclusion(record, field, options) do
    error_message = options[:message] || "contains an invalid value"
    if :lists.member(apply(record, :"#{field}", []), options[:from]) do
      record = add_error(record, field, error_message)
    end
    record
  end


  def validates_length(record, field, options, condition) do
    if apply(condition, [record]) do
      record = validates_length(record, field, options)
    end
    record
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


  def validates_format(record, field, options, condition) do
    if apply(condition, [record]) do
      record = validates_format(record, field, options)
    end
    record
  end


  def validates_format(record, field, options) do
    error_message = options[:message] || "does not match format"
    field_value = apply(record, :"#{field}", [])
    unless Regex.match?(options[:format], "#{field_value}") do
      record = add_error(record, field, error_message)
    end
    record
  end


  def validates_presence(record, field, options, condition) do
    if apply(condition, [record]) do
      record = validates_presence(record, field, options)
    end
    record
  end


  def validates_presence(record, field, condition) when is_function(condition) do
    validates_presence(record, field, [], condition)
  end

  def validates_presence(record, field, options) do
    error_message = options[:message] || "is not present"
    unless apply(record, :"#{field}", []) do
      record = add_error(record, field, error_message)
    end
    record
  end


  def add_error(record, field, error) do
    record.__errors__( [{field, error} | record.__errors__] )
  end


  def clear_errors(record) do
    record.__errors__([])
  end

end
