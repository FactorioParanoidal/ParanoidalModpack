# Adding miniloaders for other mods

This is the documentation on how the template system works. It is not perfect and there will be corner cases where the code needs to be changed; if you struggle adding your mod, [file an issue](https://github.com/hgschmie/factorio-miniloader-redux/issues) or a [draft PR](https://github.com/hgschmie/factorio-miniloader-redux/compare) and I will help as time permits.

## How the miniloader works

There was a long explanation here on how to compute throughput and speed. Doing this makes the inserters run much too fast. So this turned into straight up trial-and-error with measurement...

Going faster than 240 items/s required some reconfiguration of the pickup and dropoff points.

| Belt Tier            | Speed (items/sec) | Rotation Speed | Inserter Count | Hand Size | Speed (in/out/both)|
|----------------------|-------------------|----------------|----------------|-----------|--------------------|
| Chute                | 3.75              | 0.01875        | 2              | 1         | 3/4/4              |
| Standard             | 15                | 0.075          | 2              | 1         | 15/15/15           |
| Fast                 | 30                | 0.125          | 2              | 1         | 30/30/30           |
| Express              | 45                | 0.125          | 2              | 2         | 48/48/45           |
| Turbo                | 60                | 0.25           | 2              | 1         | 60/60/60           |
| Stack                | 60                | 0.25           | 2              | 1 *)      | 60/60/60           |
| Bob Basic            | 7.5               | 0.046875       | 2              | 1         | 8/9/7.5            |
| Bob Turbo            | 60                | 0.25           | 2              | 1         | 60/60/60           |
| Bob Ultimate         | 75                | 0.1875         | 2              | 3         | 75/75/75           |
| Krastorio Advanced   | 60                | 0.25           | 2              | 1         | 60/60/60           |
| Krastorio Superior   | 90                | 0.25           | 2              | 4         | 90/90/90           |
| Matt Ultra Fast      | 90                | 0.25           | 2              | 4         | 96/96/90           |
| Matt Extreme Fast    | 180               | 0.5            | 4              | 3         | 180/180/180        |
| Matt Ultra Express   | 270               | 0.5            | 6              | 3         | 270/270/270  +)    |
| Matt Extreme Express | 360               | 0.5            | 8              | 3         | 360/300/330  +)    |
| Matt Ultimate        | 450               | 0.5            | 8              | 8         | 425/425/425  +)    |
| Adv. Furnaces PRO-1  | 75                | 0.1875         | 2              | 3         | 75/75/75           |
| Adv. Furnaces PRO-2  | 105               | 0.25           | 2              | 6         | 102/104/105        |
| SE Space Belt        | 45                | 0.125          | 2              | 2         | 48/48/45           |
| SE Deep Space Belt   | 90                | 0.25           | 2              | 4         | 90/90/90           |

Speed measured:

in:  Output from a fast belt (faster than the miniloader), onto a chest<br/>
out: Output to a fast best (faster than the miniloader), from a chest<br/>
both: Input/Output from/to a belt of the same tier, chest at both ends

*) Stacking loaders are a special case; they are locked into 4x (max stack size) stack<br/>
+) Using high speed mode. This shifts the pickup points for some loaders to allow going past 240 items/sec.

For non-stacking belts, the theoretical maximum throughput is 480 items/sec (max belt speed). The maximum that seems to be possible with inserters (which need time to swing around and can drop only one item per tick on a belt) seems to be the 425 items/sec measured for the Matt Ultimate loader.

## Adding new miniloaders

All changes should be made in the `prototypes/templates.lua` file. The examples below omit the existing elements in the tables for illustration purposes. Do *not* remove any of the other entries, all changes should only add things.

Identify the mod you want to support. Add a line to the `supported_mods` table near the top of the file. E.g. to support Bob's logistics, the module is called `boblogistics`. Add a simple moniker:

```lua
local supported_mods = {
    -- here is more stuff in that table
    ['boblogistics'] = 'bob', -- support Bob's Logistics mod
}
```

At the end of the `template.loaders` table, add a note for the mod you support. If a mod adds new belt tiers, they are usually called `<something>-transport-belt`. For Bob, the new tiers are called `bob-basic`, `bob-turbo` and `bob-ultimate` (see [the bob belt prototypes](https://github.com/modded-factorio/bobsmods/blob/main/boblogistics/prototypes/entity/belt.lua) for details). For each tier, add an empty entry:

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    -- here is more stuff in that table

    -- =================================================
    -- == Bob's Logistics
    -- =================================================

    ['bob-basic'] = {},
    ['bob-turbo'] = {},
    ['bob-ultimate'] = {},
}
```

Now identify under which condition these loaders should be visible. As this is an extra mod, there is a check needed to ensure that the mod is loaded. Bob also has a configuration switch. Add a condition check to each of the mods that returns `true` if the loader should be enabled. This can be an inline function or a `check_<xxx>` function:

```lua
local function check_bob()
    return game_mode.bob and (settings.startup['bobmods-logistics-beltoverhaul'].value == true)
end

---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
    },
}
```

Each of the belt tiers needs the same check.

There is a bit of boilerplate that every loader needs:

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            return {
                subgroup = 'belt',
                stack_size = 50,
            }
        end,
    },
}
```

The `dash_prefix` parameter of the data function will contain the name of the loader ready to be prepended to any other string. It is usually `tier_name` + `-`.

`subgroup` defines where the loaders show up in the crafting and logistics menus. `stack_size` is the number of loaders in a stack. These rarely need to be changed.

Find the needed tint for the loader. This very much depends on the mod that loaders are added for. I tend to load the belt graphics into Gimp and look at the colors with the pipette tool.

For bob:

- basic - #c3c3c3
- turbo - #b700ff
- ultimate - #1aeb2e

Those don't have to be perfect, "close enough" usually suffices.

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            return {
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
            }
        end,
    },
}
```

Some more values to define:

`order` defines the order in which the loaders show up in the menus. Ordering uses the usual Factorio rules. The base and space age game loaders have a `d[a]` prefix:

- `d[a]-h` is the chute loader, if enabled
- `d[a]-m` is the standard loader
- `d[a]-n` is the fast loader
- `d[a]-o` is the express loader
- `d[a]-p` is the turbo loader, if space age is enabled
- `d[a]-t` is the stack loader, if space age is enabled

Other mods can slot loaders before and after the standard loaders if needed.

If a mod defines a full set of new loaders (which are usually faster than the standard loaders), they should define their own prefix and order.

Bob defines one tier "below" the standard loader and two above:

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
            }
        end,
    },
}
```

- `speed` is usually derived from the belt speed. Use the `dash_prefix` parameter to find the transport belt in the `data.raw` table.
- `upgrade_from` is the loader tier from which this loader is an upgrade. This can be a bit tricky when adding loaders to existing tiers.

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute' -- slots in between chute and the standard tier

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
            }
        end,
    },
}
```

Ingredients returns the set of ingredients for the loader. As some mods modify loader recipes, it is possible to define multiple recipes and select them based on the mods enabled.

This is a function so the ingredients can be dynamically computed.

Rule of thumb for defining a recipe is

- two loaders of the previous tier, if a previous tier exists
- one underground belt of the current tier
- some additional ingredients representing the inserters. Simplest is two inserters of a tier that supports the current belt speed.

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute' -- slots in between chute and the standard tier

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                ingredients = function()
                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bob-steam-inserter',              amount = 2 },
                        },
                    }
                end,
            }
        end,
    },
}
```

Finally the `prerequisites` field defines the technologies that need to be defined to unlock that miniloader.

This should include the previous miniloader and the logistics tier that enables the belt needed. If the other ingredients have different prerequisites, those should be included as well.

If no `technology_trigger` and no `unit` element (see below) is defined, the `prerequisites` field *must* be defined and have at least one entry. The `unit` value of that first entry is used for the miniloader (this is the cost to research the miniloader technology).

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute' -- slots in between chute and the standard tier

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                ingredients = function()
                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bob-steam-inserter',              amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        bob = { 'logistics-0', const:name_from_prefix(previous), },
                    }
                end,
            }
        end,
    },
}
```

Three more settings are used to select graphics. All three are optional and if they don't exist, it is assumed that the belt brings the full set of graphics (belt, underground belt, explosion and remnants). This is true for the base game and space age belts but depends wildly on the different mods.

- `entity_gfx` selects the actual graphic that represents the miniloader. The default is the light colored miniloader that matches the game belts. An alternative variant, `matt`, exists that is dark colored and matches the [Matt's Logistics](https://mods.factorio.com/mod/matts-logistics) belts. If a mod brings very differently colored belts, another set of graphics (`entity/<xxx>-miniloader-structure-base.png`) must be added, otherwise the design of the loader will not match the belts.
- `corpse_gfx` selects the remnants graphics and reuses the underground belt graphics sets. Those must be named *exactly* `<xxx>-underground-belt-remnants`.
- `explosion_gfx` selects the explosion graphics and reuses the underground belt graphics sets. Those must be named *exactly* `<xxx>-underground-belt-explosion`. If unset, falls back to the `corpse_gfx` name, then to the prefix.
- `belt_gfx` selects the graphics used for the belt animation in the loader. As loader tiers are usually created for a specific new belt type, this should rarely need to be set.

For Bob, each tier brings a belt and we use the light colored entity. Only set the `loader_gfx`.

```lua
---@type table<string, miniloader.LoaderDefinition>
template.loaders = {
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute' -- slots in between chute and the standard tier

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                loader_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bob-steam-inserter',              amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        bob = { 'logistics-0', const:name_from_prefix(previous), },
                    }
                end,
            }
        end,
    },
}
```

The basic loader is very early in the game, so it should be triggered by a research trigger. As it is an upgrade to the chute which requires 100 iron gear wheels, add some more.

``` lua
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute' -- slots in between chute and the standard tier

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                loader_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bob-steam-inserter',              amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        bob = { 'logistics-0', const:name_from_prefix(previous), },
                    }
                end,
                research_trigger = {
                    type = 'craft-item', item = 'iron-gear-wheel', count = 200,
                },
            }
        end,
    },
```

Finally, the inserter speed needs to be configured. For the basic belt, the desired speed is 7.5 items per second. This can be accomplished with two inserters that move 3.75 items per second each. With some measuring, the actual rotation speed for an inserter is 0.046875.

Speed is defined as a table with four attributes:

- `items_per_second` - only used for the display text. For Bob Basic this is 7.5
- `rotation_speed` - defines how quick the inserters move. For Bob Basic, the right value is 0.046875
- `inserter_pairs` - number of inserter pairs used. Usually 1 but for higher speeds, more than pair might be needed
- `stack_size_bonus` - number of additional items moved with each inserter rotation. Must be a positive integer.

``` lua
    ['bob-basic'] = {
        condition = check_bob,
        data = function(dash_prefix)
            local previous = 'chute' -- slots in between chute and the standard tier

            return {
                order = 'd[a]-l', -- slower than standard, faster than chute
                subgroup = 'belt',
                stack_size = 50,
                tint = util.color('c3c3c3'),
                speed = data.raw['transport-belt'][dash_prefix .. 'transport-belt'].speed,
                upgrade_from = const:name_from_prefix(previous),
                loader_gfx = '', -- use basic graphics for explosion and remnants
                ingredients = function()
                    return select_data {
                        bob = {
                            { type = 'item', name = const:name_from_prefix(previous),  amount = 1 },
                            { type = 'item', name = dash_prefix .. 'underground-belt', amount = 1 },
                            { type = 'item', name = 'bob-steam-inserter',              amount = 2 },
                        },
                    }
                end,
                prerequisites = function()
                    return select_data {
                        bob = { 'logistics-0', const:name_from_prefix(previous), },
                    }
                end,
                research_trigger = {
                    type = 'craft-item', item = 'iron-gear-wheel', count = 200,
                },
                speed_config = {
                    items_per_second = 7.5,
                    rotation_speed = 0.046875,
                    inserter_pairs = 1,
                    stack_size_bonus = 0,
                },
            }
        end,
    },
```


Additional things that can be defined in a loader template:

- `localized_name` - controls the localized name of the mini loader. Rarely needed to change.
- `unit` - defines the [TechnologyUnit](https://lua-api.factorio.com/latest/types/TechnologyUnit.html) to research this miniloader. If undefined and no `research_trigger` is defined, the value of the first prerequisite is used.
- `energy_source` - set the energy source and consumption. This is normally auto-computed based on the loader speed. It can be set here to adjust or use a different energy source (e.g. the chute uses `void` as it does not need electric energy). It should be a function that returns two values, one [EnergySource](https://lua-api.factorio.com/latest/types/BaseEnergySource.html) and an [Energy](https://lua-api.factorio.com/latest/types/Energy.html) value.
- `bulk` - enable [bulk](https://wiki.factorio.com/Bulk_inserter) support for the internal inserters. Bulk support is tuned towards the space age stack inserter and may behave wrong/strange if enabled for other belt speeds. When `bulk` is enabled, some settings are locked:
  - `wait_for_full_hand` is `true`
  - `grab_less_to_match_belt_stack` is `true`
  - `stack_size_bonus` is 4
  - `max_belt_stack_size` is 4
  - the inserter uses 50% more power
- `nerf_mode` - Turn off some inserter features:
  - Filtering is disabled
  - No wires can be connected

## Doing really obscure things (prototype processing)

For some mods, it is necessary to do things directly to the prototype entities. This should only be done if templating alone simply won't cut it.

e.g. for Space Exploration, it is necessary to mark entities that should be in space with an additional field in the prototype itself. This can be done with a `prototype_processor`:

``` lua
---@param prototype data.EntityWithOwnerPrototype
local function allow_in_space(prototype)
    ---@diagnostic disable-next-line:inject-field
    prototype.se_allow_in_space = true
end

local loaders = {
...
    ['se-space'] = {
...
                prototype_processor = allow_in_space,
    },
...
}
```

For every entity that is related to the 'se-space' type of miniloader, the `prototype_processor` is called with the prototype itself. In this case, the function will add the `se_allow_in_space = true` attribute to the prototype which will allow using the SE specific miniloaders on a space platform.

Sometimes, the default for a an entity when a specific mod is enabled, is wrong. E.g. in the case of Space Exploration, all inserter-related entities are allowed to be used in space by default.

To avoid that, it is possible to define a per-mod specific `prototype_processor` that will be called for *all* entities defined. If multiple mod that require processors are enabled, they will all be called. These mod-specific processors will all be called *before* any loader specific processor is called.

In the case of SE, a global processor is defined in the `prototype_processors` local table:

``` lua
---@type table<string, miniloader.PrototypeProcessor>)
local prototype_processors = {
    space_exploration = function(prototype)
        ---@diagnostic disable-next-line:inject-field
        prototype.se_allow_in_space = false
    end
}
```

The key in this table is the canonical value from the `supported_mods` table.

This ensures that for every entity defined, the `se_allow_in_space` field is set to `false` when SE is enabled. But the per-loader processor then overrides that, which get the desired effect of only allowing the SE specific miniloaders to be available in space.
