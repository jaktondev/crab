require "./renderable"

# A class to create a panel with a title and text
# It can be used to create a box with text inside
class Crab::Panel < Crab::Renderable

  property width : Int32
  property length : Int32
  property text : String
  property title : String
  property crab_codes : String
  property box_crab_codes : String
  property hpos : String
  property vpos : String
  property style : String


  # A method to align text based on the width of the panel
  # it has 2 parameters, text is the text to align, is_title is a boolean that tells if the text is a title, if not passed it defaults to false
  # it returns a string with the text aligned
  # Please do not call this method directly
  def string_setter(text : String, is_title : Bool = false) : String
    if text.size > @width - 2 && text.size <= 3
      text = text[0..@width - 5] + "..."
    else
      text = text[0..@width - 3]
    end
    to_return = ""
    if @hpos == "left" && !(is_title)
      to_return = text + " " * ((@width-2) - text.size )
    elsif @hpos == "right" && !(is_title)
      to_return = " " * ((@width - 2) - text.size) + text
    else

      side = ((@width - 2) - text.size) //2
      to_return = " " * side + text + " " * side
    end
    if to_return.size < @width - 2
      to_return += " " * ((@width - 2) - to_return.size)
    end
    return to_return
  end

  # A method to set paragraphs based on the width of the panel
  # it has 1 parameter, text is the text to set as paragraphs
  # it returns a string with the text set as paragraphs separated by newlines
  # Please do not call this method directly
  def paragraph_setter(text : String) : String
    to_return = ""
    text = text.split(" ")
    text.each do |word|
      if to_return.size + word.size + 1 > @width - 2
        to_return += "\n"
      end
      to_return += word + " "
    end
    return to_return
  end    

  # Render the Panel to a String to be Parsed by an Crab::Ansi_Parser, if possible do not call directly
  def render() : String
    if @style == "default"
      vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom = "│", "─", "┐", "┘", "┌", "└"
    elsif @style == "double"
      vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom = "║", "═", "╗", "╝", "╔", "╚"
    elsif @style == "ascii"
      vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom = "|", "-", "+", "+", "+", "+"
    else
      vertical_char, horizontal_char, right_top, right_bottom, left_top, left_bottom = "│", "─", "┐", "┘", "┌", "└"
    end
    to_return = ""
    if @title != ""
      title = string_setter(@title,true).gsub(" ", horizontal_char)
      to_return += "#{box_crab_codes}#{left_top}#{title}#{right_top}\n"
    else
      to_return += "#{box_crab_codes}#{left_top}#{horizontal_char * (@width - 2)}#{right_top}\n"
    end
    text_array = paragraph_setter(@text).split("\n")
    if text_array.size > @length - 2
      text_array = text_array[0..@length - 4]
      text_array.push("...")
    elsif @vpos == "top"
      text_array = text_array + [""] * (@length - 2 - text_array.size)
    elsif @vpos == "bottom"
      text_array = [""] * (@length - 2 - text_array.size) + text_array
    else
      side = ((@length - 2) - text_array.size) //2
      text_array = [""] * side + text_array + [""] * side
    end
    if text_array.size < @length - 2
      text_array = text_array + [""] * (@length - 2 - text_array.size)
    end
    text_array.each do |line|
      to_return += "#{box_crab_codes}#{vertical_char}#{crab_codes}#{string_setter(line)}#[default]#[default,bg]#{box_crab_codes}#{vertical_char}\n"
    end
    to_return += "#{box_crab_codes}#{left_bottom}#{horizontal_char * (@width - 2)}#{right_bottom}\n"
    return to_return
  end

  # Create a new Panel object
  # It's parameters are:
  # width: The width of the panel, is possible use Crab.get_cols for this
  # length: The length of the panel, it is the number of lines it will have
  # text: The text to be display inside the panel default is ""
  # title: The title of the panel, it will be displayed on top of the panel, default is ""
  # crab_codes: A string with the crab codes to apply to the text inside the panel, default is "", example "#[red]#[blue, bg]"
  # box_crab_codes: A string with the crab codes to apply to the box of the panel, default is "", example "#[red]#[blue, bg]"
  # hpos: A string to set the horizontal position of the text, it can be right, left or center, defaults to center.
  # vpos: A string to set the vertical position of the text, it can be top, bottom or center, defaults to center.
  # style: A string to set the style of the panel, it can be default, double, ascii, defaults to default.
  def initialize(@width : Int32 = 28, @length : Int32 = 7, @text : String = "",@title : String = "", @crab_codes : String = "", @box_crab_codes : String = "", @hpos : String = "center", @vpos : String = "center", @style : String = "default")
    if @width < 3
      @width = 3
    end
    if @length < 3
      @length = 3
    end
  end
end
