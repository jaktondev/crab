require "colorize"
require "./ansi_parser"
require "./renderable"
require "./rule"
require "./panel"
require "./type_parser"
require "./table"
require "./prompt"
require "./bar"
require "./progress"

# Bindings for terminal window size (TIOCGWINSZ)
lib LibC
  {% if flag?(:linux) %}
    TIOCGWINSZ = 0x5413u32
  {% elsif flag?(:darwin) || flag?(:bsd) %}
    TIOCGWINSZ = 0x40087468u32
  {% else %}
    TIOCGWINSZ = 0u32
  {% end %}

  struct Winsize
    ws_row : UInt16
    ws_col : UInt16
    ws_xpixel : UInt16
    ws_ypixel : UInt16
  end

  fun ioctl(fd : Int, request : ULong, argp : Winsize*) : Int
end

#Crab: A CLI framework/helper shard
#Made by JaktonDev
module Crab
  VERSION = "0.3.0"

  Parser = Ansi_Parser.new("256")

  # A function to change the global default color mode
  # The options are "full", to use true-color rgb values
  # "255" to use only the 256 ANSI colors
  # "8" To use only the classical 8 colors
  # Any other string will make the output just on black or white
  # The default is "256"
  def self.change_color_mode(color_mode : String)
    Parser.color_mode = color_mode
    case color_mode
    when "full", "256", "8"
      Colorize.enabled = true
    when "none"
      Colorize.enabled = false
    else
      # 1.19 feature: respects TTY, TERM=dumb, and NO_COLOR
      Colorize.on_tty_only!
    end
  end

  # The default way to output a Crab::Renderable or strings
  # return_to_default makes sure the text returns to the terminal's default color, if false it will retain the last colors used
  def self.puts(text : String|Crab::Renderable, return_to_default : Bool = true)
    STDOUT.puts Parser.parse(text, return_to_default)
  end

  def self.print(text : String|Crab::Renderable, return_to_default : Bool = true)
    STDOUT.print Parser.parse(text, return_to_default)
    STDOUT.flush
  end

  # Internal helper to get terminal size via ioctl
  private def self.terminal_size
    win_size = LibC::Winsize.new
    # Try STDOUT first, then STDIN, then default
    if LibC.ioctl(STDOUT.fd, LibC::TIOCGWINSZ, pointerof(win_size)) == 0
      {rows: win_size.ws_row.to_i, cols: win_size.ws_col.to_i}
    elsif LibC.ioctl(STDIN.fd, LibC::TIOCGWINSZ, pointerof(win_size)) == 0
      {rows: win_size.ws_row.to_i, cols: win_size.ws_col.to_i}
    else
      nil
    end
  end

  # The way to get the terminals columns
  # If it can not be found it will default to 80
  def self.get_cols() : Int32
    self.terminal_size.try(&.[:cols]) || 80
  end

  # The way to get the terminals rows
  # If it can not be found it will default to 24
  def self.get_rows() : Int32
    self.terminal_size.try(&.[:rows]) || 24
  end

end
