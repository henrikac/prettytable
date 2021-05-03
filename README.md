# prettytable

Crystal library that makes it easy to build simple text tables.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     prettytable:
       github: henrikac/prettytable
   ```

2. Run `shards install`

## Usage

#### Basic example

```crystal
require "prettytable"

table = PrettyTable::Table.new(["id", "name", "age"])
# headers can be set as above or later with #set_headers(headers : Array(String))
table << [
  ["1", "Melody Connolly", "42"],
  ["2", "Leslie Hutchinson", "1"],
  ["3", "Codey French", "58"]
]

puts table
```
will output
```

+----+-------------------+-----+
| id | name              | age |
+----+-------------------+-----+
|  1 | Melody Connolly   |  42 |
|  2 | Leslie Hutchinson |   1 |
|  3 | Codey French      |  58 |
+----+-------------------+-----+

```

#### Ways to add rows to table

+ `PrettyTable::Table#add_row(row : Array(String))`
+ `PrettyTable::Table#add_rows(rows : Array(Array(String)))`
+ `PrettyTable::Table#<<(row : Array(String))`
+ `PrettyTable::Table#<<(rows : Array(Array(String)))`

#### To hash

```crystal
require "prettytable"

table = PrettyTable::Table.new(["id", "name", "age"])
table << [
  ["1", "Melody Connolly", "42"],
  ["2", "Leslie Hutchinson", "1"],
  ["3", "Codey French", "58"]
]

table.to_h # => {
           #      "id" => ["1", "2", "3"],
           #      "name" => ["Melody Connoly", "Leslie Hutchinson", "Codey French"],
           #      "age" => ["42", "1", "58"]
           #    }
```

#### Get row/column

```crystal
require "prettytable"

table = PrettyTable::Table.new(["id", "name", "age"])
table << [
  ["1", "Melody Connolly", "42"],
  ["2", "Leslie Hutchinson", "1"],
  ["3", "Codey French", "58"]
]

# get row
table[0] # => ["1", "Melody Connolly", "42"]

# get column
table["name"] # => ["Melody Connolly", "Leslie Hutchinson", "Codey French"]
```

#### To/From CSV

```crystal
require "prettytable"

table = PrettyTable::Table.new(["id", "name", "age"])
table << [
  ["1", "Melody Connolly", "42"],
  ["2", "Leslie Hutchinson", "1"],
  ["3", "Codey French", "58"]
]

table.to_csv("./table.csv") # => saves the table to table.csv

# Load table from .csv
loaded_table = PrettyTable::Table.from_csv("./table.csv")
loaded_table.headers # => ["id", "name", "age"]
```

## Contributing

1. Fork it (<https://github.com/henrikac/prettytable/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Henrik Christensen](https://github.com/henrikac) - creator and maintainer
