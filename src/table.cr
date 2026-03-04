require "./renderable"
require "./type_parser"


# A class to create a table with a title
# It can be used to create a table with data inside
class Crab::Table < Crab::Renderable
    property title : String
    property crab_codes : String
    property box_crab_codes : String
    property header_crab_codes : String
    property style : String
    getter rows : Int32
    getter columns : Int32

    # Create a new table:
    # The arguments are:
    # - column_names: An array of strings with the names of the columns (mandatory)
    # - title: A string with the title of the table (optional)
    # - crab_codes: A string with the crab codes to be used in the table (optional)
    # - box_crab_codes: A string with the crab codes to be used in the box (optional)
    # - header_crab_codes: A string with the crab codes to be used in the header/column names (optional)
    # - style: A string with the style of the table (optional)
    # The styles are:
    # - default: The default style
    # - double: The double style
    # - ascii: The ascii style
    # if otherwise specified, the default style will be used
    def initialize(@column_names : Array(String), @title : String = "", @crab_codes : String = "", @box_crab_codes : String = "", @header_crab_codes : String = "", @style : String = "default")
        @rows = 0
        @columns = @column_names.size
        @data = [] of Array(String)
        @width = 0
        @column_names.each do |name|
            if name.size > @width
                @width = name.size
            end
        end
        if @width < 8
            @width = 8
        end
        @column_names = prepare_row(@column_names)
    end

    # A method to prepare a row of data to be only strings
    # It takes an array of strings, ints, floats, bools or nil
    # and returns an array of strings with the data prepared
    # With crab codes
    # For more information see Crab::TypeParser
    def prepare_row(row : Array(T)) forall T
        arr = [] of String
        row.each do |cell|
            arr << Crab::TypeParser.to_crab(cell,@width,@width)
        end
        return arr
    end

    # A method to easily prepare a row of data to be added to the table
    # It takes an array of strings, ints, floats, bools or nil
    # and adds it to the table by calling prepare_row and add_row
    def padd_row(row)
        row = prepare_row(row)
        add_row(row)
    end

    # A method to add a row of data to the table
    # It takes an array of strings and adds it to the table
    def add_row(row : Array(String))
        if row.size != @columns
            raise "Crab::Table: The number of columns in the row does not match the number of columns in the table"
        end
        @rows += 1
        @data << row

    end

    # A method to somewhat parse the row of data to be printed
    # It takes an array of strings, the crab codes to be used, the vertical character to be used and the width of the table
    # If possible do not call directly
    def row_parser(row : Array(String), codes : String, vertical_char : String, width : Int64) : String 
        row_output = ""
        row.each do |cell|
            row_output += @box_crab_codes + vertical_char + "#[default]#[default,bg]" + codes + cell + "#[default]#[default,bg]"
        end
        return row_output + @box_crab_codes + vertical_char + "#[default]#[default,bg]" + "\n"
    end

    # The render method of the table
    # It takes no arguments and returns a string with the table rendered
    # Will be directly called by an Crab::Ansi_Parser or Crab.puts method
    # If possible do not call directly
    def render() : String
        width = @width
        output = ""
        if @title != ""
            total_width = (((@columns * width) + (@columns - 1)))
            if @title.size > total_width
                @title = @title[0..total_width-4] + "..."
            end
            output += " " * ((total_width - @title.size) // 2) + @title + "\n"
        end
        if @style == "default"
            vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom, union_left, union_right, union_top, union_bottom, union = "│", "─", "┐", "┘", "┌", "└", "├", "┤", "┬", "┴", "┼"
        elsif @style == "double"
            vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom, union_left, union_right, union_top, union_bottom, union = "║", "═", "╗", "╝", "╔", "╚", "╠", "╣", "╦", "╩", "╬"
        elsif @style == "ascii"
            vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom, union_left, union_right, union_top, union_bottom, union = "|", "-", "+", "+", "+", "+", "+", "+", "+", "+", "+"
        else
            vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom, union_left, union_right, union_top, union_bottom, union = "│", "─", "┐", "┘", "┌", "└", "├", "┤", "┬", "┴", "┼"
        end
        output += @box_crab_codes + left_top + (horizontal_char * (width) + union_top) * (@columns -1) + horizontal_char * width + right_top + "\n"

        output += row_parser(@column_names, @header_crab_codes, vertical_char, width)
        @data.each do |row|
            output += @box_crab_codes + union_left + (horizontal_char * (width )+ union) * (@columns -1) + horizontal_char * width + union_right + "\n"
            output += row_parser(row, @crab_codes, vertical_char, width)
        end
        output += @box_crab_codes + left_bottom + (horizontal_char * (width ) + union_bottom) * (@columns -1) + horizontal_char * width + right_bottom + "\n"
        return output
    end

end
