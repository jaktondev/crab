# crab

CrabCLI (or just Crab) is a Crystal-lang framework/shard to make better Command Line Apps 

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crab:
       github: jaktondev/crab
   ```

2. Run `shards install`

## Usage

```crystal
require "crab"

width = Crab.get_cols

Crab.puts "Hello, #[light_blue, bg]#[green]World!"

panely = Crab::Panel.new(width: 35, text: "This is a panel", title: "Test Pan", crab_codes: "#[orange]", box_crab_codes: "#[cyan]", vpos: "center", style: "ascii", hpos: "left")

Crab.puts panely

ruly = Crab::Rule.new(width: width, text: "Rule Tested", crab_codes: "#[red]#[light_grey,bg]", text_pos: "right")
```

Right now there is a way of printing/puts strings with "crab codes" some pieces of strings with similar syntax to Crystal's string interpolation. As seen on the example above

## Development

The shard is still on progress with lots of others things planned, I'll try to update it as soon as possible.

## Contributing

If possible contact me first, if not you are free to create branches and pull requests.

## Contributors

- [jaktondev](https://github.com/jaktondev) - creator and maintainer
