require "colorize"
require "./renderable"

# A class to transform Shrimp syntax to appropriate terminal syntax to be rendered
class Crab::Ansi_Parser
  property color_mode : String

  # Pre-defined mappings for Crab's extended color palette
  private COLORS = {
    "black" => {0, 0, 0}, "red" => {255, 0, 0}, "green" => {0, 255, 0},
    "yellow" => {255, 255, 0}, "blue" => {0, 0, 255}, "magenta" => {255, 0, 255},
    "cyan" => {0, 255, 255}, "white" => {255, 255, 255}, "orange" => {255, 140, 0},
    "pink" => {255, 192, 203}, "purple" => {128, 0, 128}, "brown" => {100, 42, 42},
    "gray" => {128, 128, 128}, "light_gray" => {192, 192, 192},
    "grey" => {128, 128, 128}, "light_grey" => {192, 192, 192},
    "light_red" => {255, 150, 150}, "light_green" => {150, 250, 150},
    "light_yellow" => {255, 255, 150}, "light_blue" => {150, 150, 255},
    "light_magenta" => {255, 150, 255}, "light_cyan" => {150, 255, 255},
    "light_orange" => {255, 140, 80}, "light_pink" => {255, 200, 220},
    "light_purple" => {200, 120, 200}, "light_brown" => {130, 60, 60}
  }

  def initialize(@color_mode : String)
  end

  # Convert RGB to Colorize::Color while respecting the Crab color_mode (downgrading if needed)
  private def rgb_to_color(r, g, b) : Colorize::Color
    case @color_mode
    when "full"
      Colorize::ColorRGB.new(r.to_u8, g.to_u8, b.to_u8)
    when "256"
      ansi_code = 16 + (36 * (r // 51)) + (6 * (g // 51)) + (b // 51)
      Colorize::Color256.new(ansi_code.to_u8)
    when "8"
      # Using standard mapping for classical 8 colors
      idx = (r > 128 ? 1 : 0) + (b > 128 ? 4 : 0) + (g > 128 ? 2 : 0)
      Colorize::ColorANSI.new(idx.to_i16)
    else
      Colorize::ColorANSI::Default
    end
  end

  # A method to transform a word to a Colorize color object
  private def word_to_color(word : String) : Colorize::Color
    if word.starts_with?("#") && word.size == 7
      r = word[1, 2].to_i(16){125}
      g = word[3, 2].to_i(16){125}
      b = word[5, 2].to_i(16){125}
      return rgb_to_color(r, g, b)
    elsif (rgb = COLORS[word.strip])
      return rgb_to_color(rgb[0], rgb[1], rgb[2])
    else
      return Colorize::ColorANSI::Default
    end
  end

  # The main function of the class, it takes a string and changes the 'crab' syntax to ansi color codes
  def parse(text : String|Crab::Renderable, return_to_default : Bool = true) : String
    content = text.is_a?(Crab::Renderable) ? text.render : text.to_s
    return content unless content.includes?("#[")

    String.build do |io|
      # Split by opening tag to find segments
      parts = content.split("#[")
      io << parts[0]
      
      # Track current state for additive colors
      current_fore = Colorize::ColorANSI::Default.as(Colorize::Color)
      current_back = Colorize::ColorANSI::Default.as(Colorize::Color)

      parts[1..].each do |segment|
        tag_end = segment.index(']')
        raise "Crab color format was never closed" unless tag_end
        
        tag_raw = segment[0...tag_end]
        sentence = segment[tag_end+1..]
        
        # Determine if it's a background or foreground color
        is_bg = tag_raw.includes?("bg")
        # Extract color value (handles "color, bg" or "r,g,b, bg")
        tag_clean = tag_raw.strip.sub(/,?\s*bg$/, "").strip
        
        if tag_clean == "default"
          current_fore = Colorize::ColorANSI::Default.as(Colorize::Color)
          current_back = Colorize::ColorANSI::Default.as(Colorize::Color)
        else
          # Support both named/hex colors and numeric RGB (r,g,b)
          new_color = if tag_clean.includes?(',')
            parts_rgb = tag_clean.split(',').map(&.strip)
            if parts_rgb.size == 3
              rgb_to_color(parts_rgb[0].to_i, parts_rgb[1].to_i, parts_rgb[2].to_i)
            else
              Colorize::ColorANSI::Default.as(Colorize::Color)
            end
          else
            word_to_color(tag_clean)
          end

          if is_bg
            current_back = new_color
          else
            current_fore = new_color
          end
        end

        # Use 1.19 Colorize.with for efficient rendering
        Colorize.with.fore(current_fore).back(current_back).surround(io) do
          io << sentence
        end
      end
      
      # Clear any residual color state if requested
      if return_to_default
        Colorize.reset(io)
      end
    end
  end
end
