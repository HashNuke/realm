# Realm (work in progress)

Realm is a very simple database-independent model layer with validation functions.

Incase you want to save data, you have to implement your own `save` function in the module in which you use Realm.

TODO saving models.

### Example

```elixir
defmodule User do
  use HyperModel

  def valid?(record) do
    record
    |> validates_length(:username, [min: 1])
    |> validates_inclusion(:role, [in: ["admin", "member"]])
  end
end
```


## Validation (TODO)

In the module in which you use Real, you must implement your own `valid?` function. Take a look at the example above on how to use these helpers.

Realm provides the following validation helper functions

* validates_length
* validates_presence
* validates_inclusion
* validates_format
* validates_value
