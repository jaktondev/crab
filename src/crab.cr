require "./ansi_parser"
require "./renderable"
require "./rule"
require "./panel"

#Shrimp: A CLI framework/helper shard
#Made by JuipoMinutes
module Crab
  VERSION = "0.1"

  Parser = Ansi_Parser.new("256")

  # A function to change the global default color mode
  # The options are "full", to use true-color rgb values
  # "255" to use only the 256 ANSI colors
  # "8" To use only the classical 8 colors
  # Any other string will make the output just on black or white
  # The default is "256"
  def self.change_color_mode(color_mode : String)
    Parser.color_mode = color_mode
  end
    
  # The default way to output a Crab::Renderable or strings
  # return_to_default makes sure the text returns to the terminal's default color, if false it will retain the last colors used
  def self.puts(text : String|Crab::Renderable, return_to_default : Bool = true)
    STDOUT.puts Parser.parse(text, return_to_default)
  end

  # The way to get the terminals columns, it uses stty size
  # If it can not be found it will default to 80
  def self.get_cols() : Int32
    output_stty = String.build do |str|
      Process.run("stty size",
        shell: true,
        output: str,
        input: STDIN)
    end
    if output_stty.strip == ""
      80
    else
      output_stty.split(" ")[1].to_i
    end
  end

  # The way to get the terminals rows, it uses the stty size
  # If it can not be found it will default to 24
  def self.get_rows() : Int32
    output_stty = String.build do |str|
      Process.run("stty size",
        shell: true,
        output: str,
        input: STDIN)
    end
    if output_stty.strip == ""
      24
    else
      output_stty.split(" ")[0].to_i
    end
  end

end
