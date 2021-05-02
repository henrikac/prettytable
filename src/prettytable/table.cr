require "csv"

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
    if row.size != headers.size
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