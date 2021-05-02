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
end