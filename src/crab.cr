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

# Windows extra method
{% if flag?(:win32) %}
  # Bindings for Windows Console API
  lib LibWin32
    alias DWORD = UInt32
    alias HANDLE = Void*

    # -11 cast to an unsigned 32-bit integer (DWORD)
    STD_OUTPUT_HANDLE = 0xFFFFFFF5_u32

    struct COORD
      x : Int16
      y : Int16
    end

    struct SMALL_RECT
      left : Int16
      top : Int16
      right : Int16
      bottom : Int16
    end

    struct CONSOLE_SCREEN_BUFFER_INFO
      dwSize : COORD
      dwCursorPosition : COORD
      wAttributes : UInt16
      srWindow : SMALL_RECT
      dwMaximumWindowSize : COORD
    end

    # By assigning a lowercase name to the C function, we avoid
    # clashing with Crystal's built-in global GetStdHandle definition.
    fun get_std_handle = GetStdHandle(nStdHandle : DWORD) : HANDLE
    fun get_console_screen_buffer_info = GetConsoleScreenBufferInfo(hConsoleOutput : HANDLE, lpConsoleScreenBufferInfo : CONSOLE_SCREEN_BUFFER_INFO*) : Int32
  end
{% end %}

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
      Colorize.enabled = false
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

private def self.terminal_size
    {% if flag?(:win32) %}
      # --- Windows Implementation ---
      handle = LibWin32.get_std_handle(LibWin32::STD_OUTPUT_HANDLE)
      info = LibWin32::CONSOLE_SCREEN_BUFFER_INFO.new

      if LibWin32.get_console_screen_buffer_info(handle, pointerof(info)) != 0
        cols = (info.srWindow.right - info.srWindow.left + 1).to_i
        rows = (info.srWindow.bottom - info.srWindow.top + 1).to_i
        {rows: rows, cols: cols}
      else
        nil
      end

    {% else %}
      # --- POSIX Implementation (Linux, macOS, BSD) ---
      win_size = LibC::Winsize.new
      if LibC.ioctl(STDOUT.fd, LibC::TIOCGWINSZ, pointerof(win_size)) == 0
        {rows: win_size.ws_row.to_i, cols: win_size.ws_col.to_i}
      elsif LibC.ioctl(STDIN.fd, LibC::TIOCGWINSZ, pointerof(win_size)) == 0
        {rows: win_size.ws_row.to_i, cols: win_size.ws_col.to_i}
      else
        nil
      end
    {% end %}
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
