# Realm

Realm is a simple database-independent model layer in Elixir with validation functions and attribute tracking.

It does not provide any saving mechanism. It is left to the user to implement whatever is convinient.


## Usage

* Define your record with a field called "errors" with a default value as an empty list
* In your record, to add validations, define a `validate` function which takes a record as the first argument and also returns the record.


Once you have done those, you can use the `valid?` function on the record. It returns `true` or `false`.


### Example

All validation functions return the record. The record is modified, with the errors added whenever necessary, so you will have to keep the modified record. To make things easier, use Elixir's pipes. Look at the example below:

```elixir
defrecord User, errors: [], first_name: nil, last_name: nil, age: 0, role: "member" do
  use Realm

  def validate(record) do
    record
      |> validates_length(:first_name, [min: 1])
      |> validates_inclusion(:role, [in: ["admin", "member"]])
  end
end
```

Note that the `validate` MUST return a record.

## Validation helpers

In your `validate` function, you can use the following helpers.

In all the helper functions, the first two arguments are

* `record` - record to be validated
* `field_name` - the field name in the record to validate

#### validates_length(record, field_name, options)

Validates length of Elixir strings (binaries) or lists (including single quoted strings).

Accepts the following options:

* `min` - minimum length of the field
* `max` - maximum length of the field
* `message` - the error message incase the validation fails

Either `min` or `max` should be passed. Passing both is also fine.
If you do not pass a `message`, a standard error message will be used.

#### validates_presence(record, field_name, options)

Validates the value of the field is non-nil.

The only option is `message`, which is the custom error message.

#### validates_inclusion(record, field_name, options)

Validates if the field contains only any of values from a specified list.

Valid options:

* `in` - list of valid values
* `message` - custom error message

#### validates_exclusion(record, field_name, options)

Validates if the field doesn't contain any of values from a specified list.

Valid options:

* `from` - list of invalid values
* `message` - custom error message

#### validates_format(record, field_name, options)

Validates if the format of the field's value matches the specified format.

Valid options:

* `format` - regexp that specifies the format
* `message` - custom error message


## Adding custom validation

Easy peasy... add your custom validations to the `validate` function. Make sure you return the record at the end.

