require "./renderable"

# A class to handle the progress of a task (Only used in progress.cr)
class Crab::Bar < Crab::Renderable

    property width : Int32
    property text : String
    property total : Int32
    property current : Int32
    property color : String
    
    # Create a new progress bar
    # The parameters are:
    # - width: The width of the bar (default: 50)
    # - text: The text to display before the bar (default: "") (max 15 characters)
    # - total: The total number of units in the bar (default: 100)
    # - current: The current number of units in the bar (default: 0)
    # - color: The color of the bar (default: "default") (can be any color supported by Crab::Ansi_Parser, including r,g,b formats)
    def initialize(@width : Int32 = 50, @text : String = "", @total : Int32 = 100, @current : Int32 = 0, @color : String = "default")
        @chars_per_unit = @width / @total
        if @text.size > 15
            @text = @text[0,13] + ".."
        end
        if @text.size < 15
            @text = @text + " " * (15 - @text.size)
        end
    end

    # Render the Bar to a String to be Parsed by an Crab::Ansi_Parser, if possible do not call directly
    # Prefer to use the Crab::Progress class to handle progress bars
    def render : String
        to_return = ""
        if @current > @total
            @current = @total
        end
        to_return += @text + " "
        to_return += "[#[#{@color}]"
        filled_chars = (@chars_per_unit * @current).round().to_i
        to_return += "█" * filled_chars
        to_return += " " * (@width - filled_chars)
        to_return += "#[default]]"
        to_return += "#{@current}/#{@total}"
        return to_return
    end
end