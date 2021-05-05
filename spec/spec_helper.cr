require "spec"
require "../src/prettytable"

include PrettyTable

def check_rows(rows : Array(Array(String)), expected : Array(Array(String))) : Bool
  rows.each_with_index do |row, i|
    row.each_with_index do |item, j|
      return false if item != expected[i][j]
    end
  end
  return true
end