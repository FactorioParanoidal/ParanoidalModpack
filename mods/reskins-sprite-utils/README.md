# Artisanal Reskins: Sprite Utils

A comprehensive set of standalone icon and sprite utilities for Factorio mod development. Originally
developed to support the Artisanal Reskins ecosystem, this library provides robust tools for
manipulating icons, sprites, and prototypes with full type safety and extensive validation.

## Features

- **Icon Manipulation**: Create, scale, transform, and extract icons from prototypes
- **Sprite Utilities**: Convert icons to sprites, create 4-way animations from sprite sheets
- **Prototype Scaling**: Rescale entity prototypes and their associated remnants
- **Type Safety**: Full LuaLS type annotations and comprehensive error handling for improved
  integration with the [Factorio Modding Tool Kit](https://github.com/justarandomgeek/vscode-factoriomod-debug)
- **Validation**: Extensive parameter validation with descriptive error messages

## Installation

Add `reskins-sprite-utils` as a dependency in your `info.json`:

```json
{
  "dependencies": ["reskins-sprite-utils"]
}
```

## Quick Start

```lua
-- Import the modules you need
local utils_icons = require("__reskins-sprite-utils__.icons")
local utils_sprites = require("__reskins-sprite-utils__.sprites")

-- Get an existing icon from a prototype without worrying how it was defined, let alone how completely.
-- Have confidence that it will be a valid icons array, every time.
local existing_icon = utils_icons.get_icon_from_named_prototype("iron-plate", "item")

-- Already have the prototype? Even simpler:
local entity = data.raw["assembling-machine"]["assembling-machine-1"]
existing_icon = utils_icons.get_icon_from_prototype(entity)

-- Create a sprite from icon data to assign it to e.g. an entity that should
-- have a different icon when on the ground versus your inventory.
local sprite = utils_sprites.create_sprite_from_icons(existing_icon, 1.0)

-- Create a new oil refinery that's only 3x3 and otherwise looks the same as
-- the existing oil refinery, only smaller, and the remnants, too!
local small_refinery = util.merge({
	{ name = "small-oil-refinery" },
	data.raw["assembling-machine"]["oil-refinery"],
})

local small_refinery_corpse = util.merge({
    { name = "small-oil-refinery-remnants" },
    data.raw.corpse[small_refinery.corpse],
})
small_refinery.corpse = small_refinery_corpse.name

utils_sprites.rescale_prototype(small_refinery, 3 / 5)
utils_sprites.rescale_remnants_of_prototype(small_refinery, 3 / 5)

data:extend({ small_refinery, small_refinery_corpse })
```

When scaling prototypes, the `scalar` parameter represents the ratio of new size to original size:
- `scalar = 2.0`: Double the size
- `scalar = 0.5`: Half the size  
- `scalar = 3/5`: Scale a 5x5 entity to 3x3

## Contributing

This library is part of the Artisanal Reskins project. Contributions, bug reports, and feature
requests are welcome on the project's repository.