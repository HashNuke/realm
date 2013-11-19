# Realm

Realm is a simple model layer in Elixir with validation functions.

It is database-independent. Any interaction with databases are left to be implemented by the user (if required).


## Usage

* Define your record with a field called `__errors__` with a default value as an empty list
* In your record, to add validations, define a `validate` function which takes a record as the first argument and also returns the record.


Once you have done those, you can use the `valid?` function on the record. It returns `true` or `false`.


### Example

All validation functions return the record. The record is modified, with the errors added whenever necessary, so you will have to keep the modified record. To make things easier, use Elixir's pipes. Look at the example below:

```elixir
defrecord Student, name: nil, phone: nil, country: nil, __errors__: [] do
  use Realm
  def validate(record) do
    record
    |> validates_length(:name, [min: 1])
    |> validates_length(:country, [max: 2, message: "use a valid 2-letter country code"])
    |> validates_format(:phone, [format: %r/[0-9]+/], fn(record)-> record.country == "US" end)
  end
end

john = Student[name: "John Doe"]
john.valid?           #=> false
john.attributes       #=> [name: "John Doe", phone: nil, country: nil]
john.validate.errors  #=> [country: "use a valid 2-letter country code"]

## We have a condition for the validating phone number
## So let us update the country to US and validate again
john.country("US").validate.errors  #=> [phone: "does not match format"]
```

Note that the `validate` MUST return a record.

## record.attributes()

When you have a record of the type `User`, to get attributes do `record.attributes`.

It will return all fields and their values, except the field names that start and end with `__`. Like the `__errors__` field, which isn't returned.


## Validation helpers

In your `validate` function, you can use the following helpers.

In all the helper functions, the first two arguments are

* `record` - record to be validated
* `field_name` - the field name in the record to validate

Each validation helper can also be passed a function, that accepts a record, as a 4th argument. If such a function is passed, then the validation is performed only if the function returns true.


#### validates_length(record, field_name, options)

Validates length of Elixir strings (binaries) or lists (including single quoted strings).

Accepts the following options:

* `min` - minimum length of the field
* `max` - maximum length of the field
* `message` - the error message incase the validation fails

Either `min` or `max` should be passed. Passing both is also fine.
If you do not pass a `message`, a standard error message will be used.

```elixir
validates_length(record, :name, [min: 3, max: 30])

validates_length(record, :name, [min: 3, message: "Name is not long enough"])

validates_length(record, :phone, [min: 10], fn(record)-> record.country == "US" end)
```

#### validates_presence(record, field_name, options)

Validates the value of the field is non-nil.

The only option is `message`, which is the custom error message.

```elixir
validates_presence(record, :age)

validates_presence(record, :age, [message: "Age must be entered"])

# In this case you can skip the options arg
validates_presence(record, :age, fn(record)-> record.country == "US" end)
```

#### validates_inclusion(record, field_name, options)

Validates if the field contains only any of values from a specified list.

Valid options:

* `in` - list of valid values. This is a __required__ option
* `message` - custom error message

```elixir
validates_inclusion(record, :role, [in: ["admin", "member"]])

validates_inclusion(record, :role, [in: ["admin", "member"], message: "must have a valid role"])

validates_inclusion(record, :costume, fn(record)-> record.role == "superhero" end)
```

#### validates_exclusion(record, field_name, options)

Validates if the field doesn't contain any of values from a specified list.

Valid options:

* `from` - list of invalid values. this is a __required__ option.
* `message` - custom error message

```elixir
validates_exclusion(record, :role, [from: ["superman", "batman"]])

validates_exclusion(record, :role, [from: ["superman", "batman"], message: "You cannot be a superhero."])

validates_exclusion(record, :role, [from: ["ironman", "batman"]], fn(record)-> record.status != "billionaire" end)
```

#### validates_format(record, field_name, options)

Validates if the format of the field's value matches the specified format.

Valid options:

* `format` - regexp that specifies the format. This is a required option.
* `message` - custom error message

```elixir
validates_format(record, :serial_number, [format: %r/[a-z][0-9]{3}/])

validates_format(record, :serial_number, [format: %r/[a-z][0-9]{3}/], message: "Invalid serial number"])

validates_format(record, :serial_number, [format: %r/[a-z][0-9]{3}/]], fn(record)->
  record.expiry_year < 2011
end)
```

#### validates_uniqueness(record, field_name, options)

Validates if the uniqueness of the record, by using the condition passed. Ideally you'll be using checking the database or some source to validate if this record is unique in some way.

Valid options:

* `condition` - function to check the uniqueness. It should accept a record and should return `true` if the record's field's value is unique.
* `message` - custom error message

This is the only function without a variant, which accepts a fourth argument (like other validation helpers). If you want any other condition, just specify it in the condition option itself.

### Adding custom validation

Easy peasy... add your custom validations to the `validate` function. Make sure you return the record at the end.

When writing your own validation, to add your own errors for fields, use the following helpers

#### add_error(record, field_name, error_message)

Add error to a record, for a field, after validation

example:

```elixir
add_error(record, :username, "already been taken")
```

#### clear_errors(record)

Clear errors in a validated record

```elixir
clear_errors(record)
```

## Credits

Author: [Akash Manohar](http://twitter.com/HashNuke)

Copyright &copy; 2013 under the MIT License
