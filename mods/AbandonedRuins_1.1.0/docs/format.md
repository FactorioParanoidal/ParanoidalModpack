# Ruin data format

A .lua file for a ruin returns one huge dictionary (Lua table). This Lua table contains the following optional key/value pairs:
* entities - Array of [Entities](#Entity) - The entities that are part of this ruin.
* tiles - Array of [Tiles](#Tile) - The tiles that are part of this ruin.
* variables - Array of [Variables](#Variable) - The variables that may be used for this ruin.

### Examples

```lua
return
{
  entities =
  {
    {"stone-wall", {x = -1.5, y = -2.5}},
    {"tree-05", {x = 1.46, y = -1.65},
  },
  tiles =
  {
    {"water", {x = -1, y = -1}},
    {"water", {x = -1, y = 0}},
    {"water", {x = 0, y = -1}},
    {"water", {x = 0, y = 0}},
  }
}
```
```lua
return
{
  entities =
  {
    {"gun-turret", {x = 1, y = 0}, {force = "enemy", items = {["firearm-magazine"] = 1}, }},
  }
}
```

```lua
return
{
  tiles =
  {
    {"concrete", {x = -1, y = -1}},
    {"concrete", {x = -1, y = 0}},
    {"concrete", {x = 0, y = -1}},
    {"concrete", {x = 0, y = 0}},
  }
}
```

## Entity

An array:
* [Entity expression](#Entity-expression) - Mandatory. - The first member specifies the entity name.
* [Position](#Position) - Mandatory. - The second member specifies the position of the entity, relative to the center of the ruin.
* [Entity_options](#Entity_options) - Optional. - The third member specifies extra options for the entity creation, for example the entity force.

### Examples

`{"stone-wall", {x = -1.5, y = -2.5}}`<br>
`{{type = "random-of-entity-type", entity_type = "tree"}, {x = -12.5, y = -12.5}`<br>
`{"transport-belt", {x = 0, y = 0}, {dmg = {dmg = 30}, dir = "east"}}`<br>
`{"assembling-machine-1", {x = 4, y = 0}, {dmg = {dmg = {type = "random", min = 50, max = 190}}, recipe = "copper-cable"}}`<br>
`{"gun-turret", {x = 1, y = 6}, {force = "enemy"}}`<br>
`{"wooden-chest", {x = 1.5, y = 1.5}, {items = {["piercing-rounds-magazine"] = {type = "random", min = 5, max = 50}}}}`

## Entity_options

A table with the following optional key/value pairs:
* force - string - Optional. - Name of the force of the entity. Defaults to "neutral", use "enemy" for base defenses.
* dir - [Direction](#Direction) - Optional. - Direction of the entity. Defaults to "north".
* items - [Items](#Items) - Optional. - Items inserted into the entity after spawning. Defaults to no items.
* dmg - [Damage](#Damage) - Optional. - Damage the entity takes after spawning. Defaults to 0 physical damage from the neutral force.
* recipe - string - Optional. - Name of the recipe of this assembling machine. Defaults to no recipe.
* dead - float in range [0, 1] - Optional. - Chance that the entity spawns as dead.

### Examples

`{dmg = {dmg = 30}, dir = "east"}`<br>
`{dmg = {dmg = {type = "random", min = 50, max = 190}}, recipe = "copper-cable"}`<br>
`{force = "enemy"}`<br>
`{items = {["iron-plate"] = 14}}`<br>
`{items = {["piercing-rounds-magazine"] = {type = "random", min = 5, max = 50}}}`

## Tile

An array:
* string - Mandatory. - The first member specifies the tile name.
* [Position](#Position) - Mandatory. - The second member specifies the position of the tile, relative to the center of the ruin.

### Examples

`{"concrete", {x = -1, y = -1}}`<br>
`{"water", {x = -1, y = -1}}`

## Variable

Variable values are evaluated only once per ruin and can then be referenced in number and entity expression. In contrast, "raw" number and entity expressions are evaluated every time they are encountered.

A table with the following key/value pairs:
* name - string - Mandatory. - Name of the variable, used to reference the variable later.
* type - string - Mandatory. - "number-expression" or "entity-expression", decides the type of "value".
* value - [Entity expression](#Entity-expression) or [Number expression](#Number-expression) - Mandatory. - The value to be assigned to this variable. The type of this must be given by "type".

Note:
* If you define two variables with the same name, the second definition will overwrite the first definition.
* Number and entity expression types that reference variables are not available to be assigned to a variable here.

### Examples

`{name = "random-inserter", type = "entity-expression", value = {type = "random-of-entity-type", entity_type = "inserter"}}`<br>
`{name = "small-amount", type = "number-expression", value = {type = "random", min = 1, max = 12}}`

These examples contain the entire ruin so that the usecase of variable is clear. You may also see their use in the ruins [orchard](ruins\largeRuins\orchard.lua) and [walledOrchard](ruins\largeRuins\walledOrchard.lua).

```lua
-- The will be the same amount of both magazines in the chest, but that amount is random for every ruin.
return
{
  variables =
  {
    {name = "amount", type = "number-expression", value = {type = "random", min = 20, max = 62}}
  },
  entities =
  {
    {"wooden-chest", {x = 1.5, y = 1.5}, {items = {["firearm-magazine"] = {type = "variable", name = "amount"}, ["piercing-rounds-magazine"] = {type = "variable", name = "amount"}}}}
  }
}
```
```lua
-- The chosen splitter will be random per ruin, but it will be the same splitters in the same ruin.
-- So e.g. a ruin can be made of fast-splitters. The different splitter types won't mix in the same ruin.
return
{
  variables =
  {
    {name = "random-splitter", type = "entity-expression", value = {type = "random-of-entity-type", entity_type = "splitter"}}
  },
  entities =
  {
    {{type = "variable", name = "random-splitter"}, {x = 1, y = -0.5}},
    {{type = "variable", name = "random-splitter"}, {x = 0, y = 0.5}},
    {{type = "variable", name = "random-splitter"}, {x = 1, y = 1.5}},
    {{type = "variable", name = "random-splitter"}, {x = 2, y = 0.5}},
  }
}
```

## Entity-expression

An entity name (string) or a table with the "type" key which as a string value. The rest of the table key/value pairs depend on the used type.
Available types are "random-of-entity-type", "variable" and "random-variable", their behaviours are listed below.

**type = "random-of-entity-type"**<br>
Random entity of the given entity_type. Expected key/value pairs:
* entity_type - string - Mandatory. - Entity type of the random entity.

**type = "variable"**<br>
A reference to a [Variable](#Variable) that was previously defined for this ruin. Expected key/value pairs:
* name - string - Mandatory. - Name of the variable.

**type = "random-variable"**<br>
Random [Variable](#Variable) from the given list. Expected key/value pairs:
* variables - array of strings - Mandatory. - Variable names. A random variable name is chosen from these.

### Examples

`"stone-wall"`<br>
`"fast-inserter"`<br>
`{type = "random-of-entity-type", entity_type = "tree"}`<br>
`{type = "random-of-entity-type", entity_type = "splitter"}`<br>
`{type = "variable", name = "random-inserter"}`<br>
`{type = "random-variable", variables = {"random-tree-1", "random-tree-2"}}`

## Number-expression

A number or a table with the "type" key which as a string value. The rest of the table key/value pairs depend on the used type.
Available types are "random", "variable" and "random-variable", their behaviours are listed below.

**type = "random"**<br>
Random integer from math.random(). Expected key/value pairs:
* min - number - Mandatory. - Inclusive lower bound on the random number.
* max - number - Mandatory. - Inclusive upper bound on the random number.

**type = "variable"**<br>
A reference to a [Variable](#Variable) that was previously defined for this ruin. Expected key/value pairs:
* name - string - Mandatory. - Name of the variable.

**type = "random-variable"**<br>
Random [Variable](#Variable) from the given list. Expected key/value pairs:
* variables - array of strings - Mandatory. - Variable names. A random variable name is chosen from these.

### Examples

`20`<br>
`0.92`<br>
`{type = "random", min = 100, max = 300} -- gives ints`<br>
`{type = "variable", name = "foo"}`<br>
`{type = "random-variable", variables = {"foo", "bar"}}`

## Position

All positions inside ruins are relative to the center of the ruin. Positions are be specified as a dictionary with x, y as keys with float values.

### Examples

`{x = 1.5, y = -2.42}`<br>
`{x = -2, y = 0}`

## Direction

A string. Possible values are:
* "north"
* "northeast"
* "east"
* "southeast"
* "south"
* "southwest"
* "west"
* "northwest"

### Examples

`"north"`<br>
`"west"`

## Damage

A table with the following key/value pairs:

* dmg - [Number expression](#Number-expression) - Mandatory. - The amount of damage to be done.
* type - string - Optional. - Damage type. Defaults to "physical".
* force - [ForceSpecification](https://lua-api.factorio.com/latest/Concepts.html#ForceSpecification) - Optional. - The force that will be doing the damage. Defaults to "neutral".

### Examples

`{dmg = 30}`<br>
`{dmg = 30, force = "player"}`<br>
`{dmg = 30, type = "laser"}`<br>
`{dmg = 30, type = "impact", force = "enemy"}`<br>
`{dmg = {type = "random", min = 50, max = 190}}`<br>
`{dmg = {type = "random", min = 50, max = 190}, type = "impact", force = "enemy"}`

## Items

A dictionary of items names (strings) to [number expressions](#Number-expression).
Numbers of items must be unsigned intergers.

### Examples

`{coal = 7}`<br>
`{stone = {type = "random", min = 0, max = 12}}`<br>
`{["iron-plate"] = 14, ["coal"] = 98, ["firearm-magazine"] = {type = "random", min = 100, max = 500}}`<br>
`{["wood"] = {type = "random", min = 5, max = 50}, ["raw-fish"] = 20, ["copper-plate"] = {type = "random", min = 100, max = 300}}`
