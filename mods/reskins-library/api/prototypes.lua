-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.prototypes" then
	return require("__reskins-library__.api.prototypes")
end

--- Provides methods for working with prototypes.
---
---### Examples
---```lua
---local _prototypes = require("__reskins-library__.api.prototypes")
---```
---@class Reskins.Lib.Prototypes
local _prototypes = {}

---
---Gets the name of the first item found in `data.raw.items` from among the given list of names.
---
---### Parameters
---@param ... string # An ordered list of item names to check.
---### Returns
---@return string|nil # The name of the first item found.
function _prototypes.get_name_of_first_item_that_exists(...)
	for _, name in pairs({ ... }) do
		if data.raw.item[name] then
			return name
		end
	end
end

-- Filtering tables for rescale_entity
local included_fields = {
	["shift"] = true,
	["scale"] = true,
	["collision_box"] = true,
	["selection_box"] = true,
	["north_position"] = true,
	["south_position"] = true,
	["east_position"] = true,
	["west_position"] = true,
	["position"] = true,
	["window_bounding_box"] = true,
	["circuit_wire_connection_points"] = true,
}

local excluded_fields = {
	["fluid_boxes"] = true,
	["fluid_box"] = true,
	["energy_source"] = true,
	["input_fluid_box"] = true,
}

---Resizes the given `prototype` by the given `scalar`.
---
---Recursively iterates through the given `prototype` and applies the given `scalar` to all the numeric values
---in the fields listed in `included_fields`.
---
---### Remarks
---`scalar` is recommended to be the ratio of the new tile and the original tile size.
---For example, if rescaling a 5 x 5 tile entity to a 3 x 3 tile entity, `scalar` should be `3 / 5`.
---
---### Examples
---```lua
----- Rescale the "big-electric-pole" by a factor of 2.
----- The resulting entity will have a 4 x 4 tile footprint, and sprite to match.
---prototype_tools.rescale_prototype(data.raw["electric-pole"]["big-electric-pole"], 2)
---
----- Rescale the "oil-refinery" by a factor of 3 / 5.
----- The resulting entity will have a 3 x 3 tile footprint, and sprite to match.
---prototype_tools.rescale_prototype(data.raw["assembling-machine"]["oil-refinery"], 3 / 5)
---```
---
---### Parameters
---@param entity_prototype any # The entity prototype to rescale.
---@param scalar double # The scale factor to resize the prototype by.
function _prototypes.rescale_prototype(entity_prototype, scalar)
	---
	---Recursively scales all numeric values in the given `table`, regardless of depth.
	---
	---### Returns
	---@return table # The rescaled table.
	---
	---### Parameters
	---@param table table # The table to rescale.
	local function rescale_table_recursively(table)
		for key, value in pairs(table) do
			if type(value) == "table" then
				table[key] = rescale_table_recursively(value)
			elseif type(value) == "number" then
				table[key] = value * scalar
			else
				-- Do nothing.
			end
		end

		return table
	end

	for key, value in pairs(entity_prototype) do
		-- Because Factorio assumes the value of the scale field if left undefined,
		-- we need to ensure it's defined. Use canon-typical violence.
		if entity_prototype.filename or entity_prototype.stripes or entity_prototype.filenames then
			entity_prototype.scale = entity_prototype.scale or 0.5
		end

		if included_fields[key] then
			if type(value) == "table" then
				entity_prototype[key] = rescale_table_recursively(util.copy(value))
			elseif type(value) == "number" then
				entity_prototype[key] = value * scalar
			else
				-- Do nothing.
			end
		elseif excluded_fields[key] then
			-- Do nothing.
		elseif type(value) == "table" then
			_prototypes.rescale_prototype(value, scalar)

			-- Scale is not a supported property of stripes, but will be added in child tables.
			-- FIXME: This is a hacky solution to a problem of unused prototypes, and it would be better
			-- to provide some context to the recursive calls so that scale is not added in the first place.
			if key == "stripes" then
				for _, stripe in pairs(value) do
					stripe.scale = nil
				end
			end
		end
	end
end

---Resizes a copy of the `CorpsePrototype` associated with the given `prototype` by the given
---`scalar`, and assigns the rescaled copy to `prototype`. The name of the rescaled copy is
---prefixed with "rescaled-".
---
---### Remarks
---`scalar` is recommended to be the ratio of the new tile and the original tile size.
---For example, if rescaling a 5 x 5 tile entity to a 3 x 3 tile entity, `scalar` should be `3 / 5`.
---
---### Examples
---```lua
----- Rescale the remnants of the "big-electric-pole" by a factor of 2.
----- The resulting entity will have a 4 x 4 tile footprint, and sprite to match.
---prototype_tools.rescale_remnants_of_prototype(data.raw["electric-pole"]["big-electric-pole"], 2)
---```
---
---### Parameters
---@param prototype data.EntityWithHealthPrototype # The entity with the remnants to rescale.
---@param scalar double # The scale factor to resize the prototype by.
---
---### See Also
---@see Reskins.Lib.Prototypes.rescale_prototype
function _prototypes.rescale_remnants_of_prototype(prototype, scalar)
	-- Check the entity exists
	if not prototype then
		return
	end

	-- Fetch remnant
	local remnant_name = prototype.corpse

	-- Create, rescale, and assign rescaled remnant
	if remnant_name then
		local remnant = data.raw.corpse[remnant_name]

		if remnant then
			local rescaled_remnant = util.copy(remnant)
			rescaled_remnant.name = "rescaled-" .. rescaled_remnant.name

			_prototypes.rescale_prototype(rescaled_remnant, scalar)
			data:extend({ rescaled_remnant })

			prototype.corpse = rescaled_remnant.name
		end
	end
end

---@alias ParticleType
---| "tiny-stone"
---| "small"
---| "small-stone"
---| "medium"
---| "medium-long"
---| "medium-stone"
---| "big"
---| "big-stone"
---| "big-tint"

local particle_types = {
	["tiny-stone"] = "stone-particle-tiny",
	["small"] = "metal-particle-small",
	["small-stone"] = "stone-particle-small",
	["medium"] = "metal-particle-medium",
	["medium-long"] = "long-metal-particle-medium",
	["medium-stone"] = "stone-particle-medium",
	["big"] = "metal-particle-big",
	["big-stone"] = "stone-particle-big",
	["big-tint"] = "metal-particle-big-tint",
}

-- This is doing a few things.
-- 1. Copies an existing particle prototype..
-- 2. Tints the particle prototype.
-- 3. Adds the new prototype to the data table.
-- 4. Replaces the particle on the explosion prototype with the new particle, based on a given key.
function _prototypes.create_particle_by_duplication(name, source_entity_name, source_particle_name, tint)
	---@type data.ParticlePrototype
	local particle = util.copy(data.raw["optimized-particle"][source_entity_name .. "-" .. source_particle_name])

	particle.name = "ar-" .. name .. "-" .. source_particle_name .. "-tinted"
	particle.pictures.sheet.tint = tint

	data:extend({ particle })

	return particle
end

function _prototypes.create_explosion() end

function _prototypes.create_remnant() end

return _prototypes
