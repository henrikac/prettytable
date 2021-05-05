require "./spec_helper"

describe Table do
  describe "#headers" do
    it "should return empty array for a new table" do
      table = PrettyTable::Table.new

      expected = Array(String).new
      actual = table.headers
      
      actual.should eq expected
    end

    it "should return an array that contains the table headers" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      expected = ["id", "name", "age"]
      actual = table.headers

      actual.size.should eq expected.size
      actual.each_with_index do |header, i|
        header.should eq expected[i]
      end
    end
  end

  describe "#set_headers" do
    it "should add headers to table" do
      table = PrettyTable::Table.new
      table.set_headers(["id", "name", "age"])

      expected = ["id", "name", "age"]
      actual = table.headers

      actual.size.should eq expected.size
      actual.each_with_index do |header, i|
        header.should eq expected[i]
      end
    end

    it "should raise an ArgumentError if headers already exist" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      expect_raises(ArgumentError) do
        table.set_headers(["city", "zip_code"])
      end
    end
  end

  describe "#add_row" do
    it "should add a row to the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table.add_row(["1", "Alice", "24"])
      table.add_row(["2", "Bob", "24"])

      expected = [["1", "Alice", "24"], ["2", "Bob", "24"]]
      actual = table.rows

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
    end

    it "should raise an ArgumentError row is not the same size as the headers" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      expect_raises(ArgumentError) do
        table.add_row(["Alice", "24"])
      end
    end
  end

  describe "#<<" do
    it "should add a row to the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table << ["1", "Alice", "24"]
      table << ["2", "Bob", "24"]

      expected = [["1", "Alice", "24"], ["2", "Bob", "24"]]
      actual = table.rows

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
    end

    it "should add rows to the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table << [["1", "Alice", "24"], ["2", "Bob", "24"]]

      expected = [["1", "Alice", "24"], ["2", "Bob", "24"]]
      actual = table.rows

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
    end

    it "should raise an ArgumentError row is not the same size as the headers" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      expect_raises(ArgumentError) do
        table << ["Alice", "24"]
      end
    end
  end

  describe "#add_rows" do
    it "should add rows to the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table.add_rows([["1", "Alice", "24"], ["2", "Bob", "24"]])

      expected = [["1", "Alice", "24"], ["2", "Bob", "24"]]
      actual = table.rows

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
    end
  end

  describe "#delete_row" do
    it "should remove a row from the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "George", "72"],
        ["2", "Wanda", "1"],
        ["3", "Clark Kent", "31"]
      ]

      deleted_row = table.delete_row(1)

      expected = [
        ["1", "George", "72"],
        ["3", "Clark Kent", "31"]
      ]
      actual = table.rows

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
      deleted_row.should eq ["2", "Wanda", "1"]
    end

    it "should raise an IndexError if invalid index" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "George", "72"],
        ["2", "Wanda", "1"],
        ["3", "Clark Kent", "31"]
      ]

      expect_raises(IndexError) do
        table.delete_row(3)
      end
    end
  end

  describe "#clear" do
    it "should remove all rows from table" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "George", "72"],
        ["2", "Wanda", "1"],
        ["3", "Clark Kent", "31"]
      ]

      table.clear

      table.rows.size.should eq 0
    end
  end

  describe "#empty?" do
    it "should return true if table has no rows" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table.empty?.should be_true
    end

    it "should return false if there are rows in table" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "George", "72"],
        ["2", "Wanda", "1"],
        ["3", "Clark Kent", "31"]
      ]

      table.empty?.should be_false
    end
  end

  describe "#to_s" do
    it "should print table" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "George", "72"],
        ["2", "Wanda", "1"],
        ["3", "Clark Kent", "31"]
      ]

      expected = "
+----+------------+-----+
| id | name       | age |
+----+------------+-----+
|  1 | George     |  72 |
|  2 | Wanda      |   1 |
|  3 | Clark Kent |  31 |
+----+------------+-----+
"
      actual = table.to_s

      actual.should eq expected
    end
  end

  describe "#to_csv" do
    after_each do
      filename = "./spec/data/table_data.csv"
      File.delete(filename) if File.exists?(filename)
    end

    it "should save table data to a .csv file" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "George", "72"],
        ["2", "Wanda", "1"],
        ["3", "Clark Kent", "31"]
      ]

      table.to_csv("./spec/data/table_data.csv")
      File.exists?("./spec/data/table_data.csv").should be_true

      table_from_csv = PrettyTable::Table.from_csv("./spec/data/table_data.csv")

      table_from_csv.headers.size.should eq table.headers.size
      table_from_csv.headers.each_with_index do |header, i|
        header.should eq table.headers[i]
      end

      table_from_csv.rows.size.should eq table.rows.size
      check_rows(table_from_csv.rows, table.rows).should be_true
    end
  end

  describe ".from_csv" do
    it "should read a csv file and return a table" do
      table = PrettyTable::Table.from_csv("./spec/data/test.csv")

      table.should_not be_nil
    end

    it "should return a table with headers set correctly" do
      table = PrettyTable::Table.from_csv("./spec/data/test.csv")

      expected_headers = ["id", "name", "age"]
      actual_headers = table.headers

      actual_headers.size.should eq expected_headers.size
      actual_headers.each_with_index do |item, i|
        item.should eq expected_headers[i]
      end
    end

    it "should return a table with rows correctly" do
      table = PrettyTable::Table.from_csv("./spec/data/test.csv")

      expected_rows = [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]
      actual_rows = table.rows

      actual_rows.size.should eq expected_rows.size
      check_rows(actual_rows, expected_rows).should be_true
    end

    it "should output table created from csv correctly" do
      table = PrettyTable::Table.from_csv("./spec/data/test.csv")

      expected = "
+----+-----------------+-----+
| id | name            | age |
+----+-----------------+-----+
|  1 | John Doe        |  31 |
|  2 | Kelly Strong    |  20 |
|  3 | James Hightower |  58 |
+----+-----------------+-----+
"
      actual = table.to_s

      actual.should eq expected
    end
  end

  describe "#to_h" do
    it "should convert a table into a hash" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expected = {
        "id" => ["1", "2", "3"],
        "name" => ["John Doe", "Kelly Strong", "James Hightower"],
        "age" => ["31", "20", "58"]
      }
      actual = table.to_h

      typeof(actual).should eq Hash(String, Array(String))
      actual.should eq expected
    end
  end

  describe "#to_json" do
    it "should return an empty json array if no rows in table" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table.to_json.should eq "[]"
    end

    it "should return table as json" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expected = "[{\"id\":\"1\",\"name\":\"John Doe\",\"age\":\"31\"},"
      expected += "{\"id\":\"2\",\"name\":\"Kelly Strong\",\"age\":\"20\"},"
      expected += "{\"id\":\"3\",\"name\":\"James Hightower\",\"age\":\"58\"}]"
      actual = table.to_json

      actual.should eq expected
    end
  end

  describe "#[](idx)" do
    it "should return row" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expected = ["3", "James Hightower", "58"]
      actual = table[2]

      typeof(actual).should eq Array(String)
      actual.should eq expected
    end

    it "should raise an IndexError if index is invalid" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expect_raises(IndexError) do
        table[3]
      end
    end
  end

  describe "#[](range)" do
    it "should return rows within specified range" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"],
        ["5", "Lulu Sparkles", "28"]
      ]

      expected = [
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"],
      ]
      actual = table[1..3]

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
    end
  end

  describe "#[](key)" do
    it "should return a column" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expected = ["John Doe", "Kelly Strong", "James Hightower"]
      actual = table["name"]

      typeof(actual).should eq Array(String)
      actual.should eq expected
    end

    it "should raise a KeyError if table does not have column name matching the specified key" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expect_raises(KeyError) do
        table["unknown"]
      end
    end
  end

  describe "#[]=" do
    it "should update the content of the specified row" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
      ]

      table[2] = ["3", "Lulu Sparkles", "28"]

      expected = [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "Lulu Sparkles", "28"]
      ]
      actual = table.rows

      actual.size.should eq expected.size
      check_rows(actual, expected).should be_true
    end

    it "should raise an IndexError if index is invalid" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
      ]

      expect_raises(IndexError) do
        table[3] = ["3", "Lulu Sparkles", "28"]
      end
    end

    it "should raise an ArgumentError if row has different size" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
      ]

      expect_raises(ArgumentError) do
        table[2] = ["3", "Lulu Sparkles"]
      end
    end
  end

  describe "#-" do
    it "should return the difference between two tables" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"],
        ["5", "Lulu Sparkles", "28"]
      ]

      other = PrettyTable::Table.new(["id", "name", "age"])
      other << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expected = PrettyTable::Table.new(["id", "name", "age"])
      expected << [
        ["4", "Brian Muscle", "3"],
        ["5", "Lulu Sparkles", "28"]
      ]
      actual = table - other

      actual.headers.should eq expected.headers
      check_rows(actual.rows, expected.rows).should be_true
    end
  end

  describe "#select" do
    it "should return a new table with the given columns" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expected = "
+-----------------+-----+
| name            | age |
+-----------------+-----+
| John Doe        |  31 |
| Kelly Strong    |  20 |
| James Hightower |  58 |
+-----------------+-----+
"
      actual = table.select(["name", "age"])

      actual.headers.should eq ["name", "age"]
      actual.rows.size.should eq table.rows.size
      actual.to_s.should eq expected
    end

    it "should return original table if no columns specified" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      table.select(Array(String).new).should eq table
      table.select([""]).should eq table
      table.select(["", "", ""]).should eq table
    end

    it "should raise a KeyError if a column is requested that does not exist" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expect_raises(KeyError) do
        table.select(["height"])
      end
    end
  end

  describe "#sort" do
    it "should sort a table rows based on specified column (asc order)" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"],
        ["5", "Lulu Sparkles", "28"]
      ]

      expected = PrettyTable::Table.new(["id", "name", "age"])
      expected << [
        ["4", "Brian Muscle", "3"],
        ["3", "James Hightower", "58"],
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["5", "Lulu Sparkles", "28"]
      ]
      actual = table.sort("name")

      actual.rows.size.should eq expected.rows.size
      check_rows(actual.rows, expected.rows).should be_true
    end

    it "should sort a table rows based on specified column (desc order)" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"],
        ["5", "Lulu Sparkles", "28"]
      ]

      expected = PrettyTable::Table.new(["id", "name", "age"])
      expected << [
        ["5", "Lulu Sparkles", "28"],
        ["2", "Kelly Strong", "20"],
        ["1", "John Doe", "31"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"]
      ]
      actual = table.sort("name", false)

      actual.rows.size.should eq expected.rows.size
      check_rows(actual.rows, expected.rows).should be_true
    end

    it "should raise an KeyError if unknown column specified" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "3"],
        ["5", "Lulu Sparkles", "28"]
      ]

      expect_raises(KeyError) do
        table.sort("height")
      end
    end
  end

  describe "#sort(&block)" do
    it "should sort a table rows based on comparator" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "49"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "83"],
        ["5", "Lulu Sparkles", "28"],
      ]

      expected = PrettyTable::Table.new(["id", "name", "age"])
      expected << [
        ["5", "Lulu Sparkles", "28"],
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "49"],
        ["3", "James Hightower", "58"],
        ["4", "Brian Muscle", "83"],
      ]
      actual = table.sort { |a, b| a[2] <=> b[2] }

      actual.rows.size.should eq expected.rows.size
      check_rows(actual.rows, expected.rows).should be_true
    end
  end

  describe "#add_column" do
    it "should add a column to the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      column_data = ["183", "167", "192"]

      table.add_column("height", column_data)

      expected = PrettyTable::Table.new(["id", "name", "age", "height"])
      expected << [
        ["1", "John Doe", "31", "183"],
        ["2", "Kelly Strong", "20", "167"],
        ["3", "James Hightower", "58", "192"]
      ]
      actual = table

      actual.headers.size.should eq expected.headers.size
      check_rows(actual.rows, expected.rows).should be_true
    end

    it "should raise an ArgumentError if column_name is an empty string" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      column_data = ["183", "167", "192"]

      expect_raises(ArgumentError) do
        table.add_column("", column_data)
      end
    end

    it "should raise an ArgumentError if table already have a column == column_name" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      column_data = ["183", "167", "192"]

      expect_raises(ArgumentError) do
        table.add_column("age", column_data)
      end
    end

    it "should raise an ArgumentError if column_data.size != table.rows.size" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      column_data = ["183", "167"]

      expect_raises(ArgumentError) do
        table.add_column("height", column_data)
      end
    end
  end

  describe "#remove_column" do
    it "should remove a column from table and return removed column data" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      removed_data = table.remove_column("name")

      expected = PrettyTable::Table.new(["id", "age"])
      expected << [
        ["1", "31"],
        ["2", "20"],
        ["3", "58"]
      ]
      actual = table

      actual.headers.size.should eq expected.headers.size
      check_rows(actual.rows, expected.rows)

      removed_data.should eq ["John Doe", "Kelly Strong", "James Hightower"]
    end

    it "should raise an ArgumentError if column name is an empty string" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]

      expect_raises(ArgumentError) do
        table.remove_column("")
      end

      table.headers.size.should eq 3
    end

    it "should raise a KeyError if unknown column name" do
      table = PrettyTable::Table.new(["id", "name", "age"])
      table << [
        ["1", "John Doe", "31"],
        ["2", "Kelly Strong", "20"],
        ["3", "James Hightower", "58"]
      ]
      
      expect_raises(KeyError) do
        table.remove_column("height")
      end

      table.headers.size.should eq 3
    end
  end
end