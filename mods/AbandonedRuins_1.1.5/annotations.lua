-- These are used by sumneko.lua, https://github.com/sumneko/lua-language-server/wiki/EmmyLua-Annotations

---One ruin set with ruins for all three sizes
---@class RuinSet
---@field small Ruin[]
---@field medium Ruin[]
---@field large Ruin[]

---Represents the spawning data of one ruin
---@class Ruin
---@field entities? RuinEntity[] The entities that are part of this ruin.
---@field tiles? RuinTile[] The tiles that are part of this ruin.
---@field variables? Variable[] The variables that may be used for this ruin.

---@class RuinEntity
---@field [1] EntityExpression|string The first member specifies the entity name.
---@field [2] MapPosition The second member specifies the position of the entity, relative to the center of the ruin.
---@field [3] EntityOptions The third member specifies extra options for the entity creation, for example the entity force.

---@class RuinTile
---@field [1] string The first member specifies the tile name.
---@field [2] MapPosition The second member specifies the position of the tile, relative to the center of the ruin.

---@class Variable
---@field name string Name of the variable, used to reference the variable later.
---@field type '"entity-expression"' | '"number-expression"' Decides the type of "value".
---@field value EntityExpression|string | NumberExpression|number

---@class EntityExpression
---@field type '"random-of-entity-type"' | '"variable"' | '"random-variable"' | '"random-from-list"'
---Required by "random-of-entity-type".  
---Entity type of the random entity.
---@field entity_type string
---Required by "random".  
---Name of the variable.
---@field name string
---Required by "random-variable".  
---Variable names. A random variable name is chosen from these.
---@field variables string[]
---Required by "random-from-list"  
---Array of numbers or array of strings. A random item is chosen from the array.
---@field list string[] | number[]

---@class NumberExpression
---@field type '"random"' | '"variable"' | '"random-variable"' | '"random-from-list"'
---Required by "random".  
---Inclusive lower bound on the random number.
---@field min number
---Required by "random".  
---Inclusive upper bound on the random number.
---@field max number
---Required by "random".  
---Name of the variable.
---@field name string
---Required by "random-variable".  
---Variable names. A random variable name is chosen from these.
---@field variables string[]
---Required by "random-from-list"  
---Array of numbers or array of strings. A random item is chosen from the array.
---@field list string[] | number[]

---@class EntityOptions
---@field force? string Name of the force of the entity. Defaults to "neutral", use "enemy" for base defenses.
---@field dir? Direction Direction of the entity. Defaults to "north".
---@field items? Items Items inserted into the entity after spawning. Defaults to no items.
---@field fluids? Fluids Fluids inserted into the entity after spawning. Defaults to no fluids.
---@field dmg? Damage Damage the entity takes after spawning. Defaults to 0 physical damage from the neutral force.
---@field recipe? string Name of the recipe of this assembling machine. Defaults to no recipe.
---@field dead? number Number in range [0, 1]. Chance that the entity spawns as dead.

---@alias Direction '"north"' | '"northeast"' | '"east"' | '"southeast"' | '"south"' | '"southwest"' | '"west"' | '"northwest"'

---A dictionary of items names to number expressions. Numbers of items must be unsigned integers.
---@alias Items table<string, NumberExpression|uint>

---A dictionary of fluid names to number expressions. Note that most entities, e.g. storage tanks or pipes, accept only one fluid.
---@alias Fluids table<string, NumberExpression|number>

---@class Damage
---@field dmg NumberExpression|number
---@field type? string Damage type. Defaults to "physical".
---@field force? ForceIdentification The force that will be doing the damage. Defaults to "neutral".

---A dictionary of variable names to values.
---@alias VariableValues table<string, number|string>

---@class RuinQueueItem
---@field size number
---@field center MapPosition
---@field surface LuaSurface
