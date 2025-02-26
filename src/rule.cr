require "./renderable"

# An Object made to create Rules and possibly headers
class Crab::Rule < Crab::Renderable

  property width : Int32
  property text : String
  property crab_codes : String
  property text_pos : String

  # Create a new Rule object
  # It's parameters are:
  # width: The width of the rule, is possible use Crab.get_cols for this
  # text: The text to be display with the rule, it can have multiple positions
  # crab_codes: A string with the crab codes to apply to the full Rule, default is "", example "#[red]"
  # text_pos: A string to set the text position, it can be right, left or center, defaults to center.
  def initialize(@width : Int32 = 80, @text : String = "", @crab_codes : String = "", @text_pos : String = "center")
  end

  # Render the Rule to a String to be Parsed by an Crab::Ansi_Parser, if possible do not call directly
  def render() : String
    text_size = @text.strip.size
    total_rule = @width - text_size
    to_return = "#{crab_codes}"
    case @text_pos
    when "right"
      to_return += "_" * total_rule
      to_return += @text.strip
    when "left"
      to_return += @text.strip
      to_return += "_" * total_rule
    else
      side = total_rule//2
      to_return += ("_" * side) + @text.strip + ("_" * side)

    return to_return
    end
  end
end