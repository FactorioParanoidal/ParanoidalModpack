--- PlanetsLib entity removal floors
--- Places temporary tile ghosts underneath configured entities while they
--- are marked for deconstruction. This prevents construction robots from
--- destroying an entity's mining results when the entity sits on a tile whose
--- prototype has destroys_dropped_items set.
---
--- Ported from the lunar-rock removal mechanic in "Muluna, Moon of Nauvis".
--- The mechanic is configured per planet and per entity so that planets can
--- share the implementation without sharing prototypes or rules.
-- @module lib.entity-removal-floors

local util = require("util")
local lib = require("lib.lib")

local Public = {}

local DEFAULT_WAITING_MESSAGE = { "planetslib.entity-removal-floor-waiting" }

-- Entity prototype types that can use this mechanic. Plants and trees are
-- included because they are deconstructable and can drop items just like simple
-- entities. Containers are included because deconstructing one spills its
-- inventory onto the ground.
local SUPPORTED_ENTITY_TYPES = {
	"simple-entity",
	"plant",
	"tree",
	"container",
}

---Finds a supported entity prototype by name.
-- @param entity_name string
-- @return table|nil
local function find_supported_entity_prototype(entity_name)
	for _, entity_type in ipairs(SUPPORTED_ENTITY_TYPES) do
		local prototypes_of_type = data.raw[entity_type]
		local prototype = prototypes_of_type and prototypes_of_type[entity_name]
		if prototype then
			return prototype
		end
	end
	return nil
end

---Returns the supported prototype types as a readable list.
-- @return string
local function supported_entity_types_text()
	return table.concat(SUPPORTED_ENTITY_TYPES, ", ")
end

---Returns the tile prototype name from a data-stage place_as_tile result.
-- @param result string|table|nil
-- @return string|nil
local function tile_name_from_place_result(result)
	if type(result) == "string" then
		return result
	elseif type(result) == "table" then
		return result.name
	end
	return nil
end

---Finds an item that places the given tile. Used when the caller does not
---specify a default_tile_item explicitly.
-- @param tile_name string
-- @return string|nil
local function find_tile_item(tile_name)
	local matches = {}
	for item_name, item in pairs(data.raw["item"] or {}) do
		local placement = item.place_as_tile
		if placement and tile_name_from_place_result(placement.result) == tile_name then
			matches[#matches + 1] = item_name
		end
	end
	table.sort(matches)
	return matches[1]
end

---Normalises an entity list into an ordered array of unique names.
-- Accepts a single name, an array of names, or a dictionary of name -> true.
-- @param entities string|table
-- @param api_name string Function name used in error messages.
-- @return table
local function normalize_entities(entities, api_name)
	local names = {}
	local seen = {}

	local function add_name(name)
		if type(name) ~= "string" then
			error(
				api_name
					.. " - 'entities' must contain entity names. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
			)
		end
		if not seen[name] then
			seen[name] = true
			names[#names + 1] = name
		end
	end

	if type(entities) == "string" then
		add_name(entities)
	elseif type(entities) == "table" then
		for key, value in pairs(entities) do
			if type(key) == "number" then
				if value ~= nil and value ~= false then
					add_name(type(value) == "table" and value.name or value)
				end
			elseif value then
				add_name(key)
			end
		end
	end

	table.sort(names)
	if #names == 0 then
		error(
			api_name
				.. " - 'entities' must name at least one supported entity. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	return names
end

--- PlanetsLib.assign_entity_removal_floor(planet, entities, default_tile, options)
--- Configures temporary floor tiles for entities on a planet. When one of
--- the entities is marked for deconstruction while standing on a tile whose
--- prototype destroys dropped items, PlanetsLib cancels the deconstruction
--- order, places tile ghosts of `default_tile` under it, and reissues the order
--- once the floor exists. Robots built floor tiles are removed again after the
--- entity is gone and its dropped items have been picked up.
---
--- The same entity may be configured differently on different planets. Calling
--- this function again for the same planet/entity pair replaces the older rule.
--- @param planet string|table Planet name or planet prototype.
--- @param entities string|table One entity name, an array of names, or a dictionary of name -> true.
--- @param default_tile string Tile prototype used when no other suitable tile item is available.
--- @param options table|nil Optional fields:
---   `default_tile_item` (string): Item used to place the default tile. Inferred from the tile when omitted; when no such item exists, players cannot fall back to another tile.
---   `waiting_message` (LocalisedString): Message shown when a queued entity is marked for deconstruction again. Defaults to a PlanetsLib message.
function Public.assign_entity_removal_floor(planet, entities, default_tile, options)
	local api_name = "PlanetsLib.assign_entity_removal_floor(planet,entities,default_tile,options)"
	local planet_name = type(planet) == "table" and planet.name or planet
	if type(planet_name) ~= "string" then
		error(
			api_name
				.. " - 'planet' must be a planet name or prototype. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	assert(
		data.raw["planet"][planet_name],
		api_name
			.. " - Planet not found: "
			.. tostring(planet_name)
			.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
	)

	local entity_names = normalize_entities(entities, api_name)
	for _, entity_name in ipairs(entity_names) do
		assert(
			find_supported_entity_prototype(entity_name),
			api_name
				.. " - Entity not found or unsupported type: "
				.. tostring(entity_name)
				.. " (configured for planet "
				.. planet_name
				.. "). Supported prototype types: "
				.. supported_entity_types_text()
				.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end

	if type(default_tile) ~= "string" then
		error(
			api_name
				.. " - 'default_tile' must be a tile prototype name. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	local tile = data.raw["tile"][default_tile]
	assert(
		tile,
		api_name
			.. " - Tile not found: "
			.. tostring(default_tile)
			.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
	)
	assert(
		not tile.destroys_dropped_items,
		api_name
			.. " - 'default_tile' must not have destroys_dropped_items set: "
			.. default_tile
			.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
	)

	options = options or {}
	assert(
		type(options) == "table",
		api_name
			.. " - 'options' must be a table. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
	)

	local default_tile_item = options.default_tile_item
	if default_tile_item ~= nil then
		if type(default_tile_item) ~= "string" then
			error(
				api_name
					.. " - 'options.default_tile_item' must be an item prototype name. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
			)
		end
		local item = data.raw["item"][default_tile_item]
		assert(
			item,
			api_name
				.. " - Item not found: "
				.. tostring(default_tile_item)
				.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
		local placement = item.place_as_tile
		local placed_tile = placement and tile_name_from_place_result(placement.result)
		assert(
			placed_tile == default_tile,
			api_name
				.. " - 'options.default_tile_item' must place the default tile ("
				.. default_tile
				.. "), but "
				.. default_tile_item
				.. " places "
				.. tostring(placed_tile)
				.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	else
		default_tile_item = find_tile_item(default_tile)
	end

	local waiting_message = options.waiting_message or DEFAULT_WAITING_MESSAGE
	assert(
		type(waiting_message) == "string" or type(waiting_message) == "table",
		api_name
			.. " - 'options.waiting_message' must be a LocalisedString. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
	)

	local planet_rules = PlanetsLib.constants.entity_removal_floors[planet_name]
	if not planet_rules then
		planet_rules = {}
		PlanetsLib.constants.entity_removal_floors[planet_name] = planet_rules
	end

	for _, entity_name in ipairs(entity_names) do
		if planet_rules[entity_name] then
			lib.detailed_log(
				"[PlanetsLib] Replacing entity removal floor rule for "
					.. entity_name
					.. " on "
					.. planet_name
			)
		end
		planet_rules[entity_name] = {
			default_tile = default_tile,
			default_tile_item = default_tile_item,
			waiting_message = util.table.deepcopy(waiting_message),
		}
	end

	return planet_rules
end

---Alias for assign_entity_removal_floor, matching the "add a rule" wording used
---by some of the other PlanetsLib mod-data helpers.
Public.add_entity_removal_floor_rule = Public.assign_entity_removal_floor

---Returns the default waiting message key used when a rule does not provide one.
-- @return table
function Public.get_default_waiting_message()
	return { "planetslib.entity-removal-floor-waiting" }
end

return Public
