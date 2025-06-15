require "./ansi_parser"

# A class to handle the progress of a task
class Crab::Progress

    getter length

    # A class to handle the progress of a task
    # It is used to display the progress of a task
    def initialize()
        @length = 0
        @bars = [] of Crab::Bar
    end

    # A method to print a message above the progress bars
    # It is prefred to only use this method to print messages while the progress bars are displayed
    # Please only use one line at a time.
    def puts(text : String|Crab::Renderable, return_to_default : Bool = true)
        STDOUT.print "\e[F" * @length
        STDOUT.print "\e[0J"
        STDOUT.flush
        STDOUT.puts Parser.parse(text, return_to_default) + "\n" * (@length + 1)
        self.update_bars
    end

    # A method to add a bar to the progress
    # It takes a Crab::Bar object as parameter
    def add_bar(bar : Crab::Bar)
        @length += 1
        @bars << bar
        STDOUT.puts Parser.parse(bar.render, true)
        STDOUT.flush
    end

    # A method to update the rendering of the progress bars
    def update()
        STDOUT.print "\e[F" * @length
        STDOUT.print "\e[0J"
        STDOUT.flush
        @bars.each do |bar|
            STDOUT.puts Parser.parse(bar.render, true)
            STDOUT.flush
        end
    end
        

end