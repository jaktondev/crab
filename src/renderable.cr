# A Renderable object is an object that can be rendered to a string, is the base
# class for all the objects that can be rendered for Crab.puts
abstract class Crab::Renderable
    abstract def render() : String
end
