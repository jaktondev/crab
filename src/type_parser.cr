require "./renderable"

# A class to prepare/parse the basic
# Crystal types to be used in Crab
# It is used to prepare the data to be printed
class Crab::TypeParser

    # A method to prepare the data to be printed
    # It takes a string, int, float, bool or nil
    # and returns a string with the data prepared
    # With crab codes
    # It takes 2 optional parameters, maxl and minl
    # maxl is the maximum length of the generated string
    # minl is the minimum length of the generated string
    def self.to_crab(content : String | Int | Float | Bool | Nil, maxl : Int = 99, minl : Int = 0) : String
        case content
        when String
            if content.size < minl
                content = content + " " * (minl - content.size)
            end
            if content.size > maxl
                content = content[0..maxl-4] + "..."
            end
            return content.to_s
        when Int
            content = content.to_s
            if content.size < minl
                content = content + " " * (minl - content.size)
            end
            if content.size > maxl
                content = content[0..maxl-1] + "e+" + content[content.size - maxl..-1].size.to_s
            end
            return "#[cyan]" + content.to_s  + "#[default]"
        when Float
            content = content.to_s
            if content.size < minl
                content = content + " " * (minl - content.size)
            end
            if 'e'.in?(content)
                return "#[purple]" + content.to_s + "#[default]"
            else
                if content.size > maxl
                    content = content[0..maxl-1]
                    content = content + "e+" + (content.size - maxl).to_s
                end
                return "#[purple]" + content.to_s + "#[default]"
            end
        when Bool
            case content
            when true
                return "#[green]true#[default]" + " " * (minl - 4)
            when false
                return "#[red]false#[default]" + " " * (minl - 5)
            else
                return ""
            end
        when Nil
            return "#[grey]nil#[default]" + " " * (minl - 3)
        else
            return ""
        end
    end

end