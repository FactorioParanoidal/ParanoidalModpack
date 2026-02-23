-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if reskins.lib.settings.get_value("reskins-angels-use-angels-material-colors-pipes") == false then
	return
end
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set trigger
reskins.angels.triggers.smelting.pipes_use_material_colors = true

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

---@type { [PipeNamePrefix]: PipeReskinParams }
local pipe_material_map = {
	["titanium"] = { material_type = "angels-titanium", tier = 4, tint = util.color("#995f92") },
	["ceramic"] = { material_type = "angels-ceramic", tier = 4, tint = util.color("#ffffff") },
	["tungsten"] = { material_type = "angels-tungsten", tier = 4, tint = util.color("#7e5f45") },
	["nitinol"] = { material_type = "angels-nitinol", tier = 5, tint = util.color("#7664a9") },
}

-- Reskin pipes, create and assign extra details
for name_prefix, params in pairs(pipe_material_map) do
	local pipe_entity = data.raw["pipe"]["bob-" .. name_prefix .. "-pipe"]
	local pipe_to_ground_entity = data.raw["pipe-to-ground"]["bob-" .. name_prefix .. "-pipe-to-ground"]

	if pipe_entity and pipe_to_ground_entity then
		do_pipe(pipe_entity, params)
		do_pipe_to_ground(pipe_to_ground_entity, params)
	end
end
