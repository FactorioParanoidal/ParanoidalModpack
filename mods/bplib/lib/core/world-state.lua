--Manipulation of "world state" objects, which encode brief information
--about entities, specifically their prototype name and location.
--World states are useful for generating string hash keys as well as
--transitioning between pickled data (like undo-redo records) and live entities.

local position_lib = require("lib.core.math.pos")
local tlib = require("lib.core.table")

local pos_get = position_lib.pos_get
local filter_in_place = tlib.filter_in_place

---Brief information about an entity's prototype and location in the world.
---@class Core.WorldState
---@field public position MapPosition The position of the entity.
---@field public surface_index uint The surface index of the entity.
---@field public name string The prototype name of the entity.
---@field public key Core.WorldKey World key for this state

---Partial world state with optional fields.
---@class Core.PartialWorldState
---@field public position? MapPosition The position of the entity.
---@field public surface_index? uint The surface index of the entity.
---@field public name? string The prototype name of the entity.
---@field public key Core.WorldKey World key for this state

---String representation of a world state, suitable for use as a hash key.
---@alias Core.WorldKey string

local lib = {}

---Make a world key from raw parameters.
---@param pos MapPosition
---@param surface_index uint
---@param name string
---@return Core.WorldKey
local function make_world_key(pos, surface_index, name)
	local x, y = pos_get(pos)
	return string.format("%2.2f:%2.2f:%d:%s", x, y, surface_index, name)
end
lib.make_world_key = make_world_key

---@deprecated Use lib.make_world_key
function lib.make_key(pos, surface_index, name)
	return make_world_key(pos, surface_index, name)
end

---Get the world state of an entity.
---@param entity LuaEntity A *valid* entity.
---@return Core.WorldState
function lib.get_world_state(entity)
	local pos = entity.position
	local surface_index = entity.surface_index
	local name = entity.type == "entity-ghost" and entity.ghost_name
		or entity.name
	return {
		position = pos,
		surface_index = surface_index,
		name = name,
		key = make_world_key(pos, surface_index, name),
	}
end

---Get the world key of an entity
---@param entity LuaEntity A *valid* entity.
---@return Core.WorldKey
function lib.get_world_key(entity)
	local prototype_name = entity.type == "entity-ghost" and entity.ghost_name
		or entity.name
	return make_world_key(entity.position, entity.surface_index, prototype_name)
end

---Parse a world key string back into its components.
---@param key Core.WorldKey
---@return Core.WorldState
function lib.parse_world_key(key)
	local x, y, surface_index, name =
		string.match(key, "^([^:]+):([^:]+):([^:]+):(.+)$")
	return {
		position = {
			x = tonumber(x) --[[@as number]],
			y = tonumber(y) --[[@as number]],
		},
		surface_index = tonumber(surface_index) --[[@as uint]],
		name = name --[[@as string]],
		key = key,
	}
end

---@param surface_index uint
---@param position MapPosition
---@param name string
---@return LuaEntity[]
function lib.find_matching_raw(surface_index, position, name)
	local surface = game.get_surface(surface_index)
	if not surface then return {} end
	return filter_in_place(
		surface.find_entities_filtered({ position = position }),
		function(entity)
			return entity.name == name
				or (entity.type == "entity-ghost" and entity.ghost_name == name)
		end
	)
end

---Find all entities matching a given world state. This may return multiple
---results in the event of non-colliding identically-named stacked entities.
---@param state Core.WorldState
---@return LuaEntity[]
function lib.find_matching(state)
	return lib.find_matching_raw(state.surface_index, state.position, state.name)
end

return lib
