-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.nuclear) then
	return
end

-- Set input parameters
local inputs = {
	type = "reactor",
	icon_name = "nuclear-reactor",
	base_entity_name = "nuclear-reactor",
	mod = "bobs",
	group = "power",
}

local reactors = {
	["nuclear-reactor"] = { tier = 1, prog_tier = 3, material = "aluminum-invar" },
	["bob-nuclear-reactor-2"] = { tier = 2, prog_tier = 4, material = "silver-titanium" },
	["bob-nuclear-reactor-3"] = { tier = 3, prog_tier = 5, material = "gold-copper" },
}

local function skin_reactor_entity(name, tint, material)
	-- tint        - rgb table to tint the reactor, e.g. {0.5, 0.5, 0.5}
	-- material    - Heatpipe to use, accepted values: "base", "aluminum-invar", "silver-aluminum", "silver-titanium", "gold-copper"

	-- Reskin reactor entities
	local entity = data.raw["reactor"][name]

	entity.picture = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/nuclear-reactor/reactor.png",
				width = 302,
				height = 318,
				scale = 0.5,
				shift = util.by_pixel(-5, -7),
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/reactor-mask.png",
				width = 302,
				height = 318,
				scale = 0.5,
				shift = util.by_pixel(-5, -7),
				tint = tint,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/reactor-highlights.png",
				width = 302,
				height = 318,
				scale = 0.5,
				shift = util.by_pixel(-5, -7),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive"
			},
			-- Pipes
			{
				filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/heat-pipes/" .. material .. "/reactor-piping.png",
				width = 302,
				height = 318,
				scale = 0.5,
				shift = util.by_pixel(-5, -7),
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/nuclear-reactor/reactor-shadow.png",
				width = 525,
				height = 323,
				scale = 0.5,
				shift = { 1.625, 0 },
				draw_as_shadow = true,
			},
		},
	}

	-- Pipes
	entity.lower_layer_picture = {
		filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/heat-pipes/" .. material .. "/reactor-base-pipes.png",
		width = 320,
		height = 316,
		scale = 0.5,
		shift = util.by_pixel(-1, -5),
	}

	entity.connection_patches_connected = {
		sheet = {
			filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/heat-pipes/" .. material .. "/reactor-connect-patches.png",
			width = 64,
			height = 64,
			variation_count = 12,
			scale = 0.5,
		},
	}

	entity.connection_patches_disconnected = {
		sheet = {
			filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/heat-pipes/" .. material .. "/reactor-connect-patches.png",
			width = 64,
			height = 64,
			variation_count = 12,
			y = 64,
			scale = 0.5,
		},
	}
end

local function skin_reactor_remnants(name, tint, material)
	-- tint        - rgb table to tint the reactor, e.g. {0.5, 0.5, 0.5}
	-- material    - Heatpipe to use, accepted values: "base", "aluminum-invar", "silver-aluminum", "silver-titanium", "gold-copper"

	-- Reskin reactor remnants
	local remnant = data.raw["corpse"][name .. "-remnants"]

	remnant.animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/nuclear-reactor/remnants/nuclear-reactor-remnants.png",
				width = 410,
				height = 396,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/remnants/nuclear-reactor-remnants-mask.png",
				width = 410,
				height = 396,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/remnants/nuclear-reactor-remnants-highlights.png",
				width = 410,
				height = 396,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Pipes
			{
				filename = "__reskins-bobs__/graphics/entity/power/nuclear-reactor/heat-pipes/" .. material .. "/reactor-remnants.png",
				width = 410,
				height = 396,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				scale = 0.5,
			},
		},
	}
end

-- Construct default inputs
reskins.lib.set_inputs_defaults(inputs)

-- Reskin entities
for name, map in pairs(reactors) do
	-- Initialize table address
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)

	-- We need to assign fuel, pipe-tier, and reactor inputs
	inputs.pipe_tier = map.tier
	inputs.fuel = reskins.bobs.nuclear_reactor_index[name]

	-- Create explosions
	reskins.lib.create_explosion(name, inputs)

	if reskins.lib.settings.get_value("bobmods-revamp-nuclear") == true and reskins.lib.settings.get_value("reskins-bobs-do-bobrevamp-reactor-color") == true then
		inputs.reactor = reskins.bobs.nuclear_reactor_index[name]
		inputs.tint = reskins.bobs.nuclear_reactor_index[name].tint

		-- Create particles
		reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["big"], 1, inputs.tint)
		reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["medium"], 2, inputs.tint)
	else
		inputs.reactor = "reactor-" .. tier
		inputs.tint = reskins.lib.tiers.get_tint(tier)

		-- Create particles
		reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["big"], 1, inputs.tint)
		reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["medium"], 2, inputs.tint)
	end

	-- Create remnants
	reskins.lib.create_remnant(name, inputs)

	-- Reskin remnants
	skin_reactor_remnants(name, inputs.tint, map.material)

	-- Reskin entities
	skin_reactor_entity(name, inputs.tint, map.material)

	-- Reskin icons
	inputs.icon_base = "nuclear-reactor-" .. reskins.bobs.nuclear_reactor_index[name].name .. "-" .. map.material
	reskins.lib.construct_icon(name, tier, inputs)

	::continue::
end
