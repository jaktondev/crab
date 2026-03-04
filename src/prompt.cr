require "./ansi_parser"
require "./crab"

# A class to better handle the user input
# It is used to create a prompt with a text
class Crab::Prompt
  
    property text : String
    property answer : String
    property is_password : Bool
    property options : Array(String)
    property empty_allow : Bool

    # Create a new Prompt object
    # It's parameters are:
    # text: The text to be display with the prompt, it can have crab codes
    # is_password: A boolean to set if the prompt is a password, default is false
    # options: An array of strings with the options to be display, default is [], example ["yes", "no"]
    # empty_allow: A boolean to set if the prompt can be empty, default is false
    def initialize(@text : String, @is_password : Bool = false, @options : Array(String) = [] of String, @empty_allow : Bool = false)
        @answer = ""
    end

    # A methos to make sure the prompt is valid
    # It checks if the answer is valid, if not it asks again
    # It returns the answer if it is valid
    def check_answer
        if @answer == "" && !@empty_allow
            Crab.puts "#[red]Please enter a valid answer"
            return ask
        else
            if @options.size > 0
                if !@options.includes?(@answer)
                    Crab.puts "#[red]Please enter a valid answer"
                    return ask
                else
                    return @answer.to_s
                end
            else
                return @answer.to_s
            end
        end
    end
        
    # A method to ask the user for an answer
    # It prints the text and the options if they are set
    # It returns the answer if it is valid
    # It uses the check_answer method to check if the answer is valid
    def ask
        if @is_password && STDIN.tty?
            Crab.print "#[purple]" + @text + "#[default]: "
            if @options.size > 0
                Crab.print " (#[cyan]#{@options.join("#[default]|#[cyan]")}#[default]): "
            end
            @answer = STDIN.noecho &.gets.to_s.chomp
            Crab.puts ""
        else
            Crab.print "#[purple]" + @text + "#[default]: "
            if @options.size > 0
                Crab.print " (#[cyan]#{@options.join("#[default]|#[cyan]")}#[default]): "
            end
            @answer = gets.to_s.chomp
        end
        return check_answer
    end

end

# A class to better handle the user input
# It is used to create a prompt with a text
# This class is a subclass of Crab::Prompt that returns a float
class Crab::Promptn
  
    property text : String
    property answer : String
    property is_password : Bool
    property options : Array(String)

    # Create a new Prompt object
    # It's parameters are:
    # text: The text to be display with the prompt, it can have crab codes
    # is_password: A boolean to set if the prompt is a password, default is false
    # options: An array of strings with the options to be display, default is [], example ["yes", "no"]
    def initialize(@text : String, @is_password : Bool = false, @options : Array(String) = [] of String)
        @answer = ""
    end

    # A methos to make sure the prompt is valid
    # It checks if the answer is valid, if not it asks again
    # It returns the answer if it is valid
    def check_answer
        if @answer == ""
            Crab.puts "#[red]Please enter a valid answer"
            return ask
        else
            if @options.size > 0
                if !@options.includes?(@answer)
                    Crab.puts "#[red]Please enter a valid answer"
                    return ask
                else
                    begin
                        fanswer = @answer.to_f64
                    rescue
                        Crab.puts "#[red]Please enter a numeric answer"
                        return ask
                    end
                    return @answer.to_f64
                end
            else
                begin
                    fanswer = @answer.to_f64
                rescue
                    Crab.puts "#[red]Please enter a numeric answer"
                    return ask
                end
                return @answer.to_f64
            end
        end
    end
        
    # A method to ask the user for an answer
    # It prints the text and the options if they are set
    # It returns the answer if it is valid
    # It uses the check_answer method to check if the answer is valid
    def ask
        if @is_password && STDIN.tty?
            Crab.print "#[purple]" + @text + "#[default]: "
            if @options.size > 0
                Crab.print " (#[cyan]#{@options.join("#[default]|#[cyan]")}#[default]): "
            end
            @answer = STDIN.noecho &.gets.to_s.chomp
            Crab.puts ""
        else
            Crab.print "#[purple]" + @text + "#[default]: "
            if @options.size > 0
                Crab.print " (#[cyan]#{@options.join("#[default]|#[cyan]")}#[default]): "
            end
            @answer = gets.to_s.chomp
        end
        return check_answer
    end

end