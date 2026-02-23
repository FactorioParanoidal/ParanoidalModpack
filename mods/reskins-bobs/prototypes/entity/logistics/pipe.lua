-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done
if not mods["boblogistics"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

---
---Reskins the given pipe `prototype` using the provided `params`.
---
---### Parameters
---@param prototype data.PipePrototype # The prototype to reskin.
---@param params PipeReskinParams # The parameters to use for reskinning a pipe prototype.
local function do_pipe(prototype, params)
	-- Handle the main entity.
	prototype.pictures = reskins.lib.sprites.pipes.get_pipe(params.material_type)

	-- Re-align the fluid window.
	prototype.horizontal_window_bounding_box = { { -0.25, -0.28125 }, { 0.25, 0.15625 } }
	prototype.vertical_window_bounding_box = { { -0.28125, -0.5 }, { 0.03125, 0.125 } }

	-- Handle the corpse and death effects.
	reskins.lib.create_explosion(prototype.name, { type = prototype.type, base_entity_name = "pipe" })
	reskins.lib.create_particle(prototype.name, prototype.type, reskins.lib.particle_index["medium"], 1, params.tint)
	reskins.lib.create_particle(prototype.name, prototype.type, reskins.lib.particle_index["small"], 2, params.tint)

	reskins.lib.create_remnant(prototype.name, { type = prototype.type, base_entity_name = "pipe" })

	local pipe_remnant = data.raw["corpse"][prototype.name .. "-remnants"]
	pipe_remnant.animation = reskins.lib.sprites.pipes.get_pipe_remnants(params.material_type)

	-- Handle the icon.
	local deferrable_pipe_icon = reskins.lib.icons.pipes.get_icon(prototype, params.material_type, params.tier)
	reskins.lib.icons.assign_deferrable_icon(deferrable_pipe_icon)
end

---
---Reskins the given pipe-to-ground `prototype` using the provided `params`.
---
---### Parameters
---@param prototype data.PipeToGroundPrototype # The prototype to reskin.
---@param params PipeReskinParams # The parameters to use for reskinning a pipe prototype.
local function do_pipe_to_ground(prototype, params)
	-- Handle the main entity.
	prototype.pictures = reskins.lib.sprites.pipes.get_pipe_to_ground(params.material_type)
	prototype.fluid_box.pipe_covers = reskins.lib.sprites.pipes.get_pipe_covers(params.material_type)

	-- Handle the corpse and death effects.
	reskins.lib.create_explosion(prototype.name, { type = prototype.type, base_entity_name = "pipe-to-ground" })
	reskins.lib.create_particle(prototype.name, prototype.type, reskins.lib.particle_index["medium"], 1, params.tint)
	reskins.lib.create_particle(prototype.name, prototype.type, reskins.lib.particle_index["small"], 2, params.tint)

	reskins.lib.create_remnant(prototype.name, { type = prototype.type, base_entity_name = "pipe-to-ground" })

	local pipe_to_ground_remnant = data.raw["corpse"][prototype.name .. "-remnants"]
	pipe_to_ground_remnant.animation = reskins.lib.sprites.pipes.get_pipe_to_ground_remnants(params.material_type)

	-- Handle the icon.
	local deferrable_pipe_to_ground_icon = reskins.lib.icons.pipes.get_icon(prototype, params.material_type, params.tier)
	reskins.lib.icons.assign_deferrable_icon(deferrable_pipe_to_ground_icon)
end

---@class PipeReskinParams
---@field material_type PipeMaterialType # The supported material types for reskinning.
---@field tier integer # The tier of the added labels. An integer value from 0 to 6.
---@field tint data.Color # The tint to use for death particles.

---@type { [PipeNamePrefix]: PipeReskinParams }
local pipe_material_map = {
	["bob-copper"] = { material_type = "copper", tier = 1, tint = util.color("#d45539") },
	["bob-stone"] = { material_type = "stone", tier = 1, tint = util.color("#cfcfcf") },
	["bob-bronze"] = { material_type = "bronze", tier = 2, tint = util.color("#b09954") },
	["bob-steel"] = { material_type = "steel", tier = 2, tint = util.color("#877c76") },
	["bob-plastic"] = { material_type = "plastic", tier = 3, tint = util.color("#0078ff") },
	["bob-brass"] = { material_type = "brass", tier = 3, tint = util.color("#f9c854") },
	["bob-titanium"] = { material_type = "titanium", tier = 4, tint = util.color("#adadb2") },
	["bob-ceramic"] = { material_type = "ceramic", tier = 4, tint = util.color("#8f7967") },
	["bob-tungsten"] = { material_type = "tungsten", tier = 4, tint = util.color("#3b3b3b") },
	["bob-nitinol"] = { material_type = "nitinol", tier = 5, tint = util.color("#706f6b") },
	["bob-copper-tungsten"] = { material_type = "copper-tungsten", tier = 5, tint = util.color("#99593d") },
}

-- One-off fixes of the standard pipes.
if reskins.lib.tiers.is_pipe_tier_labeling_enabled then
	reskins.lib.tiers.add_tier_labels_to_prototype_by_name(1, "pipe", "pipe")
	reskins.lib.tiers.add_tier_labels_to_prototype_by_name(1, "pipe-to-ground", "pipe-to-ground")
end

-- Reskin pipes, create and assign extra details
for name_prefix, params in pairs(pipe_material_map) do
	local pipe_entity = data.raw["pipe"][name_prefix .. "-pipe"]
	local pipe_to_ground_entity = data.raw["pipe-to-ground"][name_prefix .. "-pipe-to-ground"]

	if pipe_entity and pipe_to_ground_entity then
		do_pipe(pipe_entity, params)
		do_pipe_to_ground(pipe_to_ground_entity, params)
	end
end
