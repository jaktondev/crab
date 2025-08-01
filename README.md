# Crab
![Crab Logo](./Logo.png "Crab Logo")

CrabCLI (or just Crab) is a Crystal-lang framework/shard to make more beautifull Command Line Apps 

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crab:
       github: jaktondev/crab
   ```

2. Run `shards install`

## Usage

### Basic Usage

Crab uses what I like to call "Crab codes", similar to Crystal's string interpolation, it's a way to add colors and styles to your text in the terminal.
These work like this: `#[color]text`, where `color` is the color you want to use and `text` is the text you want to print, the `color` parameter can be any of the following:
- A color name: black, red, green, yellow, blue, magenta, cyan, white, orange, pink, purple, brown, gray, grey, and their light variants (e.g. light_red, light_green, etc.)
- A color name for background, (ex: `#[red, bg]`)
- An r,g,b color code: `#[255, 0, 0]` (for red)
- An r,g,b color code for background: `#[255, 0, 0, bg]`
- (NEW 0.5.0) An hexadecimal color code: `#[#FF0000]` (for red)
- (NEW 0.5.0) An hexadecimal color code for background: `#[#FF0000, bg]`

So for example if you want a red text and a blue background you can do it like this: `#[red,bg]#[blue]text`, or if you want a light green text with a purple background you can do it like this: `#[light_green,bg][purple]text`.

The basic way of printing in color is using the `Crab.puts` method:

```crystal
require "crab"
Crab.puts "#[red]CRAB!" # => CRAB! (in red)
```
You can also use the `Crab.print` method to print without a newline at the end

Crab also provides a `Crab.get_cols` method to get the number of columns in the terminal, and a `Crab.get_rows` method to get the number of rows in the terminal, if you need them, it works on systems that have the `stty` command available, otherwise it will return 80 and 24 respectively.

By default Crab is activated to 256 color mode but you can change it to 8 color mode or true color mode by using the `Crab.change_color_mode` method, which takes a string as parameter, the string can be "8", "256" or "full", any other value will put it on black and white mode.

```crystal
require "crab" # Color mode is 256 by default
Crab.change_color_mode("8") # Changes the color mode to 8 colors
Crab.puts "#[red]This is red in 8 color mode" # => This is red in 8 color mode (in red)
Crab.change_color_mode("256") # Changes the color mode to 256 colors
Crab.puts "#[red]This is red in 256 color mode" # => This is red in 256 color mode (in red)
Crab.change_color_mode("full") # Changes the color mode to true color
Crab.puts "#[red]This is red in true color mode" # => This is red in true color mode (in red)
Crab.change_color_mode("bw") # Change the color mode to black and white
Crab.puts "#[red]This is red in black and white mode" # => This is red in black and white mode (in black and white, no color)
```

### Panels

The Crab shard also provides a way to create multiple 'Renderables' that can be printed in a single line, one of them is the `Panel` class, which allows you to create a panel with a title and a body.

A panel has multiple parameters, which can be set when creating the panel or modified later, these parameters are:
- width: The width of the panel, is possible use Crab.get_cols for this
- length: The length of the panel, it is the number of lines it will have
- text: The text to be display inside the panel default is ""
- title: The title of the panel, it will be displayed on top of the panel, default is ""
- crab_codes: A string with the crab codes to apply to the text inside the panel, default is "", example "#[red]#[blue, bg]"
- box_crab_codes: A string with the crab codes to apply to the box of the panel, default is "", example "#[red]#[blue, bg]"
- hpos: A string to set the horizontal position of the text, it can be right, left or center, defaults to center.
- vpos: A string to set the vertical position of the text, it can be top, bottom or center, defaults to center.
- style: A string to set the style of the panel, it can be default, double, ascii, defaults to default.

You can create a panel like this:

```crystal
require "crab"
paneltest = Crab::Panel.new(width: Crab.get_cols, length: 10, text: "Hello World", title: "My Panel", crab_codes: "#[red]", box_crab_codes: "#[blue]", hpos: "center", vpos: "center", style: "default")
Crab.puts paneltest # => Renders a panel with the text "Hello World" in red and the box in blue
```

### Rules

You can also create rules, Lines that can be used to separate sections of your terminal output, these rules can have a text in the middle, and can be styled with Crab codes.

- width: The width of the rule, is possible use Crab.get_cols for this
- text: The text to be display with the rule, it can have multiple positions
- crab_codes: A string with the crab codes to apply to the full Rule, default is "", example "#[red]"
- text_pos: A string to set the text position, it can be right, left or center, defaults to center.

```crystal
require "crab"
ruletest = Crab::Rule.new(width: Crab.get_cols, text: "Hello World", crab_codes: "#[red]", text_pos: "center")
Crab.puts ruletest # => Renders a rule with the text "Hello World" in red
```

### Prompts

Crab also provides a way to create prompts, which are used to get input from the user, these prompts can be styled with Crab codes and can have options to choose from.

- text: The text to be display with the prompt, it can have crab codes
- is_password: A boolean to set if the prompt is a password, default is false (it will hide the input)
- options: An array of strings with the options to be display, default is [], example ["yes", "no"]
- empty_allow: A boolean to set if the prompt can be empty, default is false, if there are options it will still ask for a valid one

To use a prompt you can do it like this:

```crystal
require "crab"
prompttest = Crab::Prompt.new(text: "What is your name?", options: ["yes", "no"])
name = prompttest.ask # => Asks the user for their name, and returns the input
```

If you need a numeric input, you can use the `Crab::Promptn` class, which is a numeric prompt that will only accept numbers, it has the same parameters, except empty_allow, as the `Crab::Prompt` class, but it will only accept numbers as input and will return a float.

```crystal
require "crab"
promptntest = Crab::Promptn.new(text: "What is your age?")
age = promptntest.ask # => Asks the user for their age, and returns the input as a float
promptntest2 = Crab::Promptn.new(text: "How many cats do you have?", options: ["0", "1", "2", "3", "4", "5"])
cats = promptntest2.ask.to_i # => Asks the user for the number of cats they have, and then converts the input to an integer
```

### Tables
Crab also provides a way to create tables, which are used to display data in a tabular format, these tables can be styled with Crab codes. When creating a table you must provide the column names.

The arguments are:

- column_names: An array of strings with the names of the columns (mandatory)
- title: A string with the title of the table (optional)
- crab_codes: A string with the crab codes to be used in the table (optional)
- box_crab_codes: A string with the crab codes to be used in the box (optional)
- header_crab_codes: A string with the crab codes to be used in the header/column names (optional)
- style: A string with the style of the table (optional)

The styles are:

- default: The default style
- double: The double style
- ascii: The ascii style

if otherwise specified, the default style will be used

To add rows to the table you can use the `add_row` method, which takes an array of strings with the values of the row, and it will add the row to the table.
if you want to add a row with other primitive types, you can use the `padd_row` method, which takes an array of any type and will convert them to strings before adding them to the table. (prepare add)

You can create a table like this:

```crystal
require "crab"
tabletest = Crab::Table.new(column_names: ["Name", "Age", "City"], title: "My Table", crab_codes: "#[red]", box_crab_codes: "#[blue]")
tabletest.add_row(["John", "25", "New York"])
tabletest.padd_row(["Jane", 30, "Los Angeles"])
Crab.puts tabletest # => Renders a table with the data in it, with the title "My Table" in red and the box in blue
```

### Progress and Bars
Crab also provides a way to create ways to show different progress bars, these progress bars can be styled with Crab codes.

First you will need to create a `Crab::Progress` object, which will be used to render the progress bars.

Then you can create a progress bar using the `Crab::Bar` class, which takes the following parameters:

- width: The width of the bar (default: 50)
- text: The text to display before the bar (default: "") (max 15 characters, will be truncated if longer)
- total: The total number of units in the bar (default: 100)
- current: The current number of units in the bar (default: 0)
- color: The color of the bar (default: "default") (can be any color supported by Crab including r,g,b formats)

You can add a bar to the progress object using the `add_bar` method, which takes a `Crab::Bar` object as parameter.

Once added you can update the bar changing the `current` value, and you can update the progress object using the `update` method, which will render the bars in the terminal.

If you want to add text during a progress you can use the `Crab::Progress.puts` method, which will print the text in the terminal, above the progress bars, works just like `Crab.puts`, but should be used while you want to print text during a progress.

```crystal
require "crab"
progress = Crab::Progress.new
bar1 = Crab::Bar.new(width: 50, text: "Downloading", total: 100, current: 0, color: "blue")
bar2 = Crab::Bar.new(width: 50, text: "Uploading", total: 100, current: 0, color: "green")
progress.add_bar(bar1)
progress.add_bar(bar2)

# CODE

bar1.current = 50
bar2.current = 25
progress.update # => Renders the progress bars with the current values
progress.puts "Halfway there!" # => Prints "Halfway there!" above the progress bars

# CODE
bar1.current = 100
bar2.current = 100
progress.update # => Renders the progress bars with the current values, now both are full
progress.puts "Done!" # => Prints "Done!" above the progress bars
Crab.puts "All done!" # => Prints "All done!" in the terminal
```


## Development

I will try to update, fix and add new features to Crab as much as I can, but I'm still a student and I have other projects to work on, so please be patient. :p

## Contributing

If possible contact me first, if not you are free to create branches and pull requests.

## Contributors

- [jaktondev](https://github.com/jaktondev) - creator and maintainer
