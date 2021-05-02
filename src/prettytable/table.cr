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
end