require "./renderable"

# A class to transform Shrimp syntax to apropiate terminal syntax to be rendered
class Crab::Ansi_Parser

    property color_mode : String

    # Create an ANSI_Parser object
    # It is prefered not to create another ANSI_Parser
    def initialize(@color_mode : String)
        @color_mode = color_mode
    end

    # A method to transform rgb values to ansi color codes
    # it has 4 parameters, r, g and b are the rgb values, is_bg is a boolean that tells if the color is a background color, if not passed it defaults to false
    # it returns a string with the ansi color code
    # The ANSI code depends on the color mode
    def rgb_to_ansi(r : Int32, g : Int32, b : Int32, is_bg : Bool = false) : String
        if r > 255 || g > 255 || b > 255
            raise "A red,blue or green value is bigger than 255"
        end
        case @color_mode
        when "full"
            return is_bg ? "\e[48;2;#{r};#{g};#{b}m" : "\e[38;2;#{r};#{g};#{b}m"
        when "256"
            ansi_code = 16 + (36 * (r // 51)) + (6 * (g // 51)) + (b // 51)
            return is_bg ? "\e[48;5;#{ansi_code}m" : "\e[38;5;#{ansi_code}m"
        when "8"
            r = (r > 128) ? 1 : 0
            g = (g > 128) ? 1 : 0
            b = (b > 128) ? 1 : 0
            return is_bg ? "\e[#{40+r+(b*4)+(g*2)}m" : "\e[#{30+r+(b*4)+(g*2)}m"
        else
            return ""
        end
    end

    # A method to transform a word to ansi color codes
    # it has 2 parameters, word is the word to transform, is_bg is a boolean that tells if the color is a background color, if not passed it defaults to false
    def word_to_ansi(word : String, is_bg : Bool = false) : String
        case word
        when "black"
            return rgb_to_ansi(0, 0, 0, is_bg)
        when "red"
            return rgb_to_ansi(255, 0, 0, is_bg)
        when "green"
            return rgb_to_ansi(0, 255, 0, is_bg)
        when "yellow"
            return rgb_to_ansi(255, 255, 0, is_bg)
        when "blue"
            return rgb_to_ansi(0, 0, 255, is_bg)
        when "magenta"
            return rgb_to_ansi(255, 0, 255, is_bg)
        when "cyan"
            return rgb_to_ansi(0, 255, 255, is_bg)
        when "white"
            return rgb_to_ansi(255, 255, 255, is_bg)
        when "orange"
            return rgb_to_ansi(255, 140, 0, is_bg)
        when "pink"
            return rgb_to_ansi(255, 192, 203, is_bg)
        when "purple"
            return rgb_to_ansi(128, 0, 128, is_bg)
        when "brown"
            return rgb_to_ansi(100, 42, 42, is_bg)
        when "gray"
            return rgb_to_ansi(128, 128, 128, is_bg)
        when "light_gray"
            return rgb_to_ansi(192, 192, 192, is_bg)
        when "grey"
            return rgb_to_ansi(128, 128, 128, is_bg)
        when "light_grey"
            return rgb_to_ansi(192, 192, 192, is_bg)
        when "light_red"
            return rgb_to_ansi(255, 150, 150, is_bg)
        when "light_green"
            return rgb_to_ansi(150, 250, 150, is_bg)
        when "light_yellow"
            return rgb_to_ansi(255, 255, 150, is_bg)
        when "light_blue"
            return rgb_to_ansi(150, 150, 255, is_bg)
        when "light_magenta"
            return rgb_to_ansi(255, 150, 255, is_bg)
        when "light_cyan"
            return rgb_to_ansi(150, 255, 255, is_bg)
        when "light_orange"
            return rgb_to_ansi(255, 140, 80, is_bg)
        when "light_pink"
            return rgb_to_ansi(255, 200, 220, is_bg)
        when "light_purple"
            return rgb_to_ansi(200, 120, 200, is_bg)
        when "light_brown"
            return rgb_to_ansi(130, 60, 60, is_bg)
        when "default"
            return is_bg ? "\e[49m" : "\e[39m"
        else
            return ""
        end
    end


    # The main function of the class, it takes a string and changes the 'crab' syntax to ansi color codes
    # it has one parameter, text is the string to transform
    # it returns the transformed string with ansi color codes when needed
    def parse(text : String|Crab::Renderable, return_to_default : Bool = true) : String
        if text.is_a?(Crab::Renderable)
            text = text.render
        else
            text = text.to_s
        end
        ansi_text = ""
        color_word = ""
        is_bg = false
        take_on_count = true
        if text.includes?("#[")
            splittedt = text.split("#[")
            ansi_text += splittedt[0]
            splittedt[1,splittedt.size].each do |sentence|
                is_bg = false
                if sentence.includes?("]")
                    color_word = sentence.split("]")[0]
                    if sentence.split("]").size > 1
                        sentence = sentence.split("]")[1..-1].join("]")
                    else
                        sentence = sentence.split("]")[1]
                    end
                    if "0123456789".includes?(color_word.strip()[0])
                        splitted = color_word.split(",")
                        if splitted.size == 3
                            ansi_text += rgb_to_ansi(splitted[0].to_i, splitted[1].to_i, splitted[2].to_i, is_bg)
                            ansi_text += sentence
                        elsif splitted.size == 4
                            if splitted[3].strip() == "bg"
                                is_bg = true
                            end
                            ansi_text += rgb_to_ansi(splitted[0].to_i, splitted[1].to_i, splitted[2].to_i, is_bg)
                            ansi_text += sentence
                        else
                            raise "Crab invalid color format"
                        end
                    else
                        if color_word.includes?(",")
                            splitted = color_word.split(",")
                            if splitted.size == 2
                                if splitted[1].strip() == "bg"
                                    is_bg = true
                                end
                                ansi_text += word_to_ansi(splitted[0].strip(), is_bg)
                                ansi_text += sentence
                            else
                                raise "Crab invalid color format"
                            end
                        else
                            ansi_text += word_to_ansi(color_word.strip(), is_bg)
                            ansi_text += sentence
                        end
                    end
                else
                    raise "Crab color format was never closed"
                end
            end
        else
            ansi_text = text
        end
        return return_to_default ? ansi_text + "\e[0m" : ansi_text
    end

    
end
