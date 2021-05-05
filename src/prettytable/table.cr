require "csv"
require "json"

class PrettyTable::Table
  # Returns the table headers.
  getter headers = [] of String
  # Returns the rows in the table.
  getter rows = Array(Array(String)).new

  # Creates a new `Table` with no *headers*.
  def initialize
  end

  # Create a new `Table` with the specified *headers*.
  def initialize(@headers : Array(String))
  end

  # Sets the table headers.
  #
  # An `ArgumentError` is raised if headers has already been set.
  def set_headers(headers : Array(String))
    if !@headers.empty?
      raise ArgumentError.new("headers has already been set")
    end

    @headers = headers
  end

  # Adds a row to the table.
  #
  # An `ArgumentError` is raised if the *row* does not
  # have the same size as the *headers*.
  def add_row(row : Array(String))
    if @headers.empty?
      raise ArgumentError.new("please add headers before trying to add rows")
    end

    if row.size != @headers.size
      raise ArgumentError.new("expected a row of size #{headers.size}")
    end

    @rows << row
  end

  # :ditto:
  def <<(row : Array(String))
    self.add_row(row)
  end

  # Adds multiple rows to the table.
  def add_rows(rows : Array(Array(String)))
    rows.each do |row|
      self.add_row(row)
    end
  end

  # :ditto:
  def <<(rows : Array(Array(String)))
    self.add_rows(rows)
  end

  # Removes a row from the table, returning that row.
  def delete_row(idx : Int32) : Array(String)
    if @rows.empty? || idx < 0 || idx > @rows.size
      raise IndexError.new
    end
    return @rows.delete_at(idx)
  end

  # Removes all rows from `self`.
  def clear
    @rows.clear
  end

  # Returns `true` if `self` is empty, `false` otherwise.
  def empty? : Bool
    return @rows.empty?
  end

  # Writes the table to *io*.
  def to_s(io : IO) : Nil
    return if @headers.empty?

    column_sizes = calculate_column_sizes

    output = build_header(column_sizes)
    output += build_rows(column_sizes)

    io.puts output
  end

  # Saves the table to a .csv file.
  def to_csv(filename : String)
    data = CSV.build do |csv|
      csv.row @headers
      @rows.each { |row| csv.row row }
    end

    File.write(filename, data)
  end

  # Returns a table created based on data from a .csv file.
  def self.from_csv(csv_file : String) : PrettyTable::Table
    file_data = File.read csv_file
    csv = CSV.new(file_data, headers: true)

    table = PrettyTable::Table.new(csv.headers)

    csv.each { |c| table << c.row.to_a }

    return table
  end

  # Returns the table as a hash.
  def to_h : Hash(String, Array(String))
    return Hash.zip(@headers, @rows.transpose)
  end

  # Serializes the table into JSON.
  def to_json : String
    if @rows.empty?
      return @rows.to_json
    end

    arr = Array(Hash(String, String)).new(@rows.size)

    @rows.each { |r| arr << Hash.zip(@headers, r) }

    return arr.to_json
  end

  # Returns the row at index *idx*.
  def [](idx : Int32) : Array(String)
    if @rows.empty? || idx < 0 || idx > (@rows.size - 1)
      raise IndexError.new
    end

    return @rows[idx]
  end

  # Returns all rows within the given range.
  #
  # NOTE: See https://crystal-lang.org/api/1.0.0/Array.html#[](range:Range)-instance-method
  # for more information.
  def [](range : Range) : Array(Array(String))
    return @rows[range]
  end

  # Returns table column *[key]*.
  def [](key : String) : Array(String)
    h = self.to_h

    if !h.has_key?(key)
      raise KeyError.new("unknown column name: #{key}")
    end

    return h[key]
  end

  # Updates the row at the given index.
  def []=(idx : Int32, value : Array(String))
    if value.size != @headers.size
      raise ArgumentError.new("expected a row of size #{@headers.size}")
    end

    @rows[idx] = value
  end

  # Returns a new `Table` that is a copy of `self`, removing
  # any items that appear in *other*.
  def -(other : PrettyTable::Table) : PrettyTable::Table
    diff = PrettyTable::Table.new(@headers)
    diff << @rows - other.rows
    return diff
  end

  # Returns a new `Table` with the given *columns*.
  #
  # Example:
  # ```
  # table = PrettyTable::Table.new(["id", "name", "age"])
  # ```
  # will create a table with the following columns
  # ```
  # +----+------+-----+
  # | id | name | age |
  # +----+------+-----+
  # ```
  # You can select just the *name* and *age* column like this
  # ```
  # table.select(["name", "age"])
  # ```
  # this will return a new `Table` with columns
  # ```
  # +------+-----+
  # | name | age |
  # +------+-----+
  # ```
  # However, `table.select(["age", "name"])` will create a table
  # with columns
  # ```
  # +-----+------+
  # | age | name |
  # +-----+------+
  # ```
  #
  # NOTE: If no columns are specified (empty array or an array of empty strings)
  # then `self` is returned.
  def select(columns : Array(String)) : PrettyTable::Table
    return self if columns.select { |i| !i.empty? }.empty?

    hashed_table = self.to_h

    columns.each do |column|
      if !hashed_table.has_key?(column)
        raise KeyError.new("unknown column name: #{column}")
      end
    end

    new_table = PrettyTable::Table.new(columns)

    @rows.each_with_index do |_, i|
      row = Array(String).new
      columns.each do |column|
        row << hashed_table[column][i]
      end
      new_table.add_row(row)
    end

    return new_table
  end

  # Sorts a table based on the given *column* and returns a new `Table`.
  def sort(column : String, asc_order = true) : PrettyTable::Table
    idx = -1
    @headers.each_with_index do |header, i|
      if header == column
        idx = i
      end
    end

    if idx == -1
      raise KeyError.new("unknown column name: #{column}")
    end

    sorted_table = PrettyTable::Table.new(@headers)

    if asc_order
      sorted_rows = @rows.sort { |a, b| a[idx] <=> b[idx] }
    else
      sorted_rows = @rows.sort { |a, b| b[idx] <=> a[idx] }
    end

    sorted_table << sorted_rows

    return sorted_table
  end

  # Returns a new `Table` with rows sorted based on the comparator in the given block.
  def sort(&block : Array(String), Array(String) -> Int32) : PrettyTable::Table
    sorted_table = PrettyTable::Table.new(@headers)
    sorted_table << @rows.sort! &block
    return sorted_table
  end

  # Appends a new column to `self`.
  def add_column(column_name : String, column_data : Array(String))
    if column_name.empty?
      raise ArgumentError.new("column name is undefined")
    end

    if !@headers.select { |h| h == column_name }.empty?
      raise ArgumentError.new("table already has a #{column_name} column")
    end

    if column_data.size != @rows.size
      raise ArgumentError.new("expected a column of size #{@rows.size}")
    end

    @headers << column_name
    @rows.each_with_index { |r, i| r << column_data[i] }
  end

  # Removes a column from `self` and returns the data from the removed column.
  def remove_column(column_name : String) : Array(String)
    if column_name.empty?
      raise ArgumentError.new("column name is undefined")
    end

    tmp = self.to_h
    removed_data = tmp[column_name]

    @headers = @headers - [column_name]

    removed_data.each_with_index do |item, i|
      @rows[i] = @rows[i] - [item]
    end

    return removed_data
  end

  private def table_line(column_sizes : Array(Int32)) : String
    return "" if @headers.empty?

    line = "+"
    column_sizes.each do |size|
      line += "-" * size
      line += "+"
    end

    line += "\n"

    return line
  end

  private def build_header(column_sizes : Array(Int32)) : String
    return "" if @headers.empty?

    paddings = calculate_extra_padding(column_sizes, @headers)

    header = "\n"
    header += table_line(column_sizes)

    @headers.each_with_index do |h, i|
      header += "| " + h
      header += " " * paddings[i].to_i
    end

    header += "|\n"
    header += table_line(column_sizes)

    return header
  end

  private def build_rows(column_sizes : Array(Int32)) : String
    return "" if @rows.empty?

    output = ""
    @rows.each_with_index do |row, i|
      paddings = calculate_extra_padding(column_sizes, row)

      row.each_with_index do |item, j|
        if is_numerical?(item)
          output += "|" + " " * paddings[j].to_i
          output += item + " "
        else
          output += "| " + item
          output += " " * paddings[j].to_i
        end
      end

      output += "|\n"
    end

    output += table_line(column_sizes)

    return output
  end

  # Calculate how much extra padding is needed for each item in a row
  # to make the rows align nicely.
  private def calculate_extra_padding(column_sizes : Array(Int32), items : Array(String)) : Array(Int32)
    paddings = items.map_with_index do |item, i|
      width = item.size + 2
      padding = 1

      if width < column_sizes[i]
        padding += column_sizes[i] - width
      end

      next padding
    end

    return paddings
  end

  # Returns if *item* can be converted into either f32, f64, i32 or i64.
  private def is_numerical?(item : String) : Bool
    if item.to_f32? || item.to_f64? || item.to_i32? || item.to_i64?
      return true
    end

    return false
  end

  # Calculates the width of each column.
  private def calculate_column_sizes : Array(Int32)
    column_sizes = @headers.map(&.size).map { |i| i += 2 }

    # calculates the longest item in each column
    if !@rows.empty?
      @rows.each_with_index do |row, i|
        row.each_with_index do |item, j|
          if (item.size + 2) > column_sizes[j]
            column_sizes[j] = item.size + 2
          end
        end
      end
    end

    return column_sizes
  end
end