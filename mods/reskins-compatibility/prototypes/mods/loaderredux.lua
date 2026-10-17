-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["LoaderRedux"] then
	return
end
if mods["vanilla-loaders-hd"] then
	return
end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then
	return
end

-- Set input parameters
local inputs = {
	type = "loader",
	icon_name = "loader",
	base_entity_name = "splitter",
	mod = "compatibility",
	group = "loaderredux",
	particles = { ["medium"] = 1, ["big"] = 4 },
	icon_layers = 2,
	make_remnants = false,
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
	["loader"] = { tier = 1, set_type = reskins.lib.defines.belt_sprites.standard },
	["fast-loader"] = { tier = 2, set_type = reskins.lib.defines.belt_sprites.express },
	["express-loader"] = { tier = 3, set_type = reskins.lib.defines.belt_sprites.express },
	["purple-loader"] = { tier = 4, set_type = reskins.lib.defines.belt_sprites.express },
	["green-loader"] = { tier = 5, set_type = reskins.lib.defines.belt_sprites.express },
}

-- Reskin entities
for name, map in pairs(tier_map) do
	---@type data.LoaderPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = reskins.lib.tiers.get_belt_tint(map.tier)

	reskins.lib.setup_standard_entity(name, map.tier, inputs)

	-- Retint the entity mask
	entity.structure.direction_in.sheets[2].tint = inputs.tint
	entity.structure.direction_out.sheets[2].tint = inputs.tint

	-- Apply belt set
	-- entity.belt_animation_set = reskins.lib.sprites.belts.get_belt_animation_set(map.set_type, inputs.tint)

	::continue::
end
