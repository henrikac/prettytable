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
      actual.each_with_index do |row, i|
        row.each_with_index do |item, j|
          item.should eq expected[i][j]
        end
      end
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
      actual.each_with_index do |row, i|
        row.each_with_index do |item, j|
          item.should eq expected[i][j]
        end
      end
    end

    it "should add rows to the table" do
      table = PrettyTable::Table.new(["id", "name", "age"])

      table << [["1", "Alice", "24"], ["2", "Bob", "24"]]

      expected = [["1", "Alice", "24"], ["2", "Bob", "24"]]
      actual = table.rows

      actual.size.should eq expected.size
      actual.each_with_index do |row, i|
        row.each_with_index do |item, j|
          item.should eq expected[i][j]
        end
      end
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
      actual.each_with_index do |row, i|
        row.each_with_index do |item, j|
          item.should eq expected[i][j]
        end
      end
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
      table_from_csv.rows.each_with_index do |row, i|
        row.each_with_index do |item, j|
          item.should eq table.rows[i][j]
        end
      end
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
      actual_rows.each_with_index do |row, i|
        row.each_with_index do |item, j|
          item.should eq expected_rows[i][j]
        end
      end
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
end