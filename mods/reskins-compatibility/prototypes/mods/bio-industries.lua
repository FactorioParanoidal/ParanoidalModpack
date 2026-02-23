-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["Bio_Industries"] then
	return
end

-- FIXME: Handle the graphics overhaul when it lands
if reskins.lib.version.is_same_or_newer(mods["Bio_Industries"], "1.2.0") then
	return
end

---@type CreateIconsFromListTable
local intermediates = {}

if reskins.bobs and reskins.bobs.triggers.greenhouse.items then
	intermediates["seedling"] = { mod = "bobs", group = "greenhouse", subgroup = "items" }
end

if reskins.bobs and reskins.bobs.triggers.electronics.items then
	intermediates["bob-resin-wood"] = { mod = "bobs", type = "recipe", group = "plates", subgroup = "recipes" }
end

if reskins.bobs and reskins.bobs.triggers.plates.items then
	intermediates["carbon"] = { mod = "bobs", group = "plates", subgroup = "items" }
end

reskins.internal.create_icons_from_list(intermediates, {
	mod = "compatibility",
	group = "bio-industries",
	make_icon_pictures = false,
	flat_icon = true,
})

---@type data.Vector
local shift_upleft = { -8, -8 }

---@type data.Vector
local shift_upright = { 8, -8 }

---@type double
local scale = 0.5

---A dictionary of recipe names and the icon sources to use to create a composite icon.
---The first entry in each icon source table is the base layer of the created icon.
---@type { [string]: IconSources }
local recipe_icon_source_map = {
	-- Seeds
	["bi-seed-1"] = {
		{ name = "bi-seed", type_name = "item" },
		{ name = "water", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
	["bi-seed-2"] = {
		{ name = "bi-seed", type_name = "item" },
		{ name = "bi-ash", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-seed-3"] = {
		{ name = "bi-seed", type_name = "item" },
		{ name = "fertilizer", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-seed-4"] = {
		{ name = "bi-seed", type_name = "item" },
		{ name = "bi-adv-fertilizer", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Seedlings
	["bi-seedling-1"] = {
		{ name = "seedling", type_name = "item" },
		{ name = "water", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
	["bi-seedling-2"] = {
		{ name = "seedling", type_name = "item" },
		{ name = "bi-ash", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-seedling-3"] = {
		{ name = "seedling", type_name = "item" },
		{ name = "fertilizer", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-seedling-4"] = {
		{ name = "seedling", type_name = "item" },
		{ name = "bi-adv-fertilizer", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Wood
	["bi-logs-1"] = {
		{ name = "wood", type_name = "item" },
		{ name = "water", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
	["bi-logs-2"] = {
		{ name = "wood", type_name = "item" },
		{ name = "bi-ash", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-logs-3"] = {
		{ name = "wood", type_name = "item" },
		{ name = "fertilizer", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-logs-4"] = {
		{ name = "wood", type_name = "item" },
		{ name = "bi-adv-fertilizer", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Miscellaneous
	["bi-battery"] = {
		{ name = "battery", type_name = "item" },
		{ name = "bi-biomass", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
	["bi-sulfur"] = {
		{ name = "sulfur", type_name = "item" },
		{ name = "bi-ash", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-acid"] = {
		{ name = "sulfuric-acid", type_name = "fluid" },
		{ name = "bi-biomass", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
	["bi-basic-gas-processing"] = {
		{ name = "petroleum-gas", type_name = "fluid" },
		{ name = "coal", type_name = "item", scale = scale, shift = shift_upleft },
		{ name = "resin", type_name = "item", scale = scale, shift = shift_upright },
	},
	["bi-solid-fuel"] = {
		{ name = "solid-fuel", type_name = "item" },
		{ name = "wood-bricks", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Wood and Pulp related recipes
	["bi-woodpulp"] = {
		{ name = "bi-woodpulp", type_name = "item" },
		{ name = "wood", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-resin-pulp"] = {
		{ name = "resin", type_name = "item" },
		{ name = "bi-woodpulp", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-wood-from-pulp"] = {
		{ name = "wood", type_name = "item" },
		{ name = "bi-woodpulp", type_name = "item", scale = scale, shift = shift_upleft },
		{ name = "resin", type_name = "item", scale = scale, shift = shift_upright },
	},

	-- Ash
	["bi-ash-1"] = {
		{ name = "bi-ash", type_name = "item" },
		{ name = "wood", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-ash-2"] = {
		{ name = "bi-ash", type_name = "item" },
		{ name = "bi-woodpulp", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Charcoal
	["bi-charcoal-1"] = {
		{ name = "wood-charcoal", type_name = "item" },
		{ name = "bi-woodpulp", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-charcoal-2"] = {
		{ name = "wood-charcoal", type_name = "item" },
		{ name = "wood", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Pellets
	["bi-coke-coal"] = {
		{ name = "angels-pellet-coke", type_name = "item" },
		{ name = "coal", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-pellet-coke"] = {
		{ name = "angels-pellet-coke", type_name = "item" },
		{ name = "solid-fuel", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-pellet-coke-2"] = {
		{ name = "angels-pellet-coke", type_name = "item" },
		{ name = "carbon", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Stone and Crushed Stone
	["bi-stone-brick"] = {
		{ name = "stone-brick", type_name = "item" },
		{ name = "bi-ash", type_name = "item", scale = scale, shift = shift_upleft },
		{ name = "stone-crushed", type_name = "item", scale = scale, shift = shift_upright },
	},
	["bi-crushed-stone-1"] = {
		{ name = "stone-crushed", type_name = "item" },
		{ name = "stone", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-crushed-stone-2"] = {
		{ name = "stone-crushed", type_name = "item" },
		{ name = "concrete", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-crushed-stone-3"] = {
		{ name = "stone-crushed", type_name = "item" },
		{ name = "hazard-concrete", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-crushed-stone-4"] = {
		{ name = "stone-crushed", type_name = "item" },
		{ name = "refined-concrete", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-crushed-stone-5"] = {
		{ name = "stone-crushed", type_name = "item" },
		{ name = "refined-hazard-concrete", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Fertilizer
	["bi-fertilizer-1"] = {
		{ name = "fertilizer", type_name = "item" },
		{ name = "sulfur", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-fertilizer-2"] = {
		{ name = "fertilizer", type_name = "item" },
		{ name = "sodium-hydroxide", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
	["bi-adv-fertilizer-1"] = {
		{ name = "bi-adv-fertilizer", type_name = "item" },
		{ name = "alien-artifact", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-adv-fertilizer-2"] = {
		{ name = "bi-adv-fertilizer", type_name = "item" },
		{ name = "bi-biomass", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Plastic
	["bi-plastic-1"] = {
		{ name = "plastic-bar", type_name = "item" },
		{ name = "wood", type_name = "item", scale = scale, shift = shift_upleft },
	},
	["bi-plastic-2"] = {
		{ name = "plastic-bar", type_name = "item" },
		{ name = "bi-cellulose", type_name = "item", scale = scale, shift = shift_upleft },
	},

	-- Cellulose
	["bi-cellulose-2"] = {
		{ name = "bi-cellulose", type_name = "item" },
		{ name = "steam", type_name = "fluid", scale = scale, shift = shift_upleft },
	},
}

-- FIXME: This will need follow-up if and/or when Bio Industries is ported to 2.0
if mods["bobelectronics"] and reskins.lib.settings.get_value("reskins-bobs-do-bobelectronics-circuit-style") ~= "off" then
	recipe_icon_source_map["wooden-board"] = {
		{ name = "wooden-board", type_name = "item" },
		{ name = "wood", type_name = "item", scale = scale, shift = shift_upleft },
	}

	recipe_icon_source_map["bi-press-wood"] = {
		{ name = "wooden-board", type_name = "item" },
		{ name = "bi-woodpulp", type_name = "item", scale = scale, shift = shift_upleft },
		{ name = "resin", type_name = "item", scale = scale, shift = shift_upright },
	}
end

for recipe_name, sources in pairs(recipe_icon_source_map) do
	local icon_data = reskins.lib.icons.create_icons_from_sources(sources)
	reskins.lib.icons.assign_icons_to_prototype_and_related_prototypes(recipe_name, "recipe", icon_data)
end

-- BOILER
if reskins.bobs and reskins.bobs.triggers.power.entities then
	-- Set input parameters
	local inputs = {
		type = "boiler",
		base_entity_name = "boiler",
		icon_name = "boiler",
		mod = "bobs",
		group = "power",
		particles = { ["big"] = 3 },
	}

	local boilers = {
		["bi-bio-boiler"] = { tint = util.color("#80801a") },
	}

	for name, map in pairs(boilers) do
		---@type data.BoilerPrototype
		local entity = data.raw[inputs.type][name]

		-- Check if entity exists, if not, skip this iteration
		if not entity then
			goto continue
		end

		inputs.tint = map.tint

		reskins.lib.setup_standard_entity(name, 0, inputs)

		-- Fetch remnant
		local remnant = data.raw["corpse"][name .. "-remnants"]

		-- Reskin remnants
		remnant.animation = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/boiler/remnants/boiler-remnants.png",
					width = 274,
					height = 220,
					direction_count = 4,
					shift = util.by_pixel(-0.5, -3),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/power/boiler/remnants/boiler-remnants-mask.png",
					width = 274,
					height = 220,
					direction_count = 4,
					shift = util.by_pixel(-0.5, -3),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/power/boiler/remnants/boiler-remnants-highlights.png",
					width = 274,
					height = 220,
					direction_count = 4,
					shift = util.by_pixel(-0.5, -3),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
			},
		}

		-- Reskin entities
		entity.structure = {
			north = {
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/boiler/boiler-N-idle.png",
						priority = "extra-high",
						width = 269,
						height = 221,
						shift = util.by_pixel(-1.25, 5.25),
						scale = 0.5,
					},
					-- Mask
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-N-idle-mask.png",
						priority = "extra-high",
						width = 269,
						height = 221,
						shift = util.by_pixel(-1.25, 5.25),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-N-idle-highlights.png",
						priority = "extra-high",
						width = 269,
						height = 221,
						shift = util.by_pixel(-1.25, 5.25),
						blend_mode = reskins.lib.settings.blend_mode, -- "additive",
						scale = 0.5,
					},
					-- Shadow
					{
						filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
						priority = "extra-high",
						width = 274,
						height = 164,
						scale = 0.5,
						shift = util.by_pixel(20.5, 9),
						draw_as_shadow = true,
					},
				},
			},
			east = {
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/boiler/boiler-E-idle.png",
						priority = "extra-high",
						width = 216,
						height = 301,
						shift = util.by_pixel(-3, 1.25),
						scale = 0.5,
					},
					-- Color mask
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-E-idle-mask.png",
						priority = "extra-high",
						width = 216,
						height = 301,
						shift = util.by_pixel(-3, 1.25),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-E-idle-highlights.png",
						priority = "extra-high",
						width = 216,
						height = 301,
						shift = util.by_pixel(-3, 1.25),
						blend_mode = reskins.lib.settings.blend_mode, -- "additive",
						scale = 0.5,
					},
					-- Shadow
					{
						filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
						priority = "extra-high",
						width = 184,
						height = 194,
						scale = 0.5,
						shift = util.by_pixel(30, 9.5),
						draw_as_shadow = true,
					},
				},
			},
			south = {
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/boiler/boiler-S-idle.png",
						priority = "extra-high",
						width = 260,
						height = 192,
						shift = util.by_pixel(4, 13),
						scale = 0.5,
					},
					-- Mask
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-S-idle-mask.png",
						priority = "extra-high",
						width = 260,
						height = 192,
						shift = util.by_pixel(4, 13),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-S-idle-highlights.png",
						priority = "extra-high",
						width = 260,
						height = 192,
						shift = util.by_pixel(4, 13),
						blend_mode = reskins.lib.settings.blend_mode, -- "additive",
						scale = 0.5,
					},
					-- Shadow
					{
						filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
						priority = "extra-high",
						width = 311,
						height = 131,
						scale = 0.5,
						shift = util.by_pixel(29.75, 15.75),
						draw_as_shadow = true,
					},
				},
			},
			west = {
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/boiler/boiler-W-idle.png",
						priority = "extra-high",
						width = 196,
						height = 273,
						shift = util.by_pixel(1.5, 7.75),
						scale = 0.5,
					},
					-- Mask
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-W-idle-mask.png",
						priority = "extra-high",
						width = 196,
						height = 273,
						shift = util.by_pixel(1.5, 7.75),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-bobs__/graphics/entity/power/boiler/boiler-W-idle-highlights.png",
						priority = "extra-high",
						width = 196,
						height = 273,
						shift = util.by_pixel(1.5, 7.75),
						blend_mode = reskins.lib.settings.blend_mode, -- "additive",
						scale = 0.5,
					},
					-- Shadow
					{
						filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
						priority = "extra-high",
						width = 206,
						height = 218,
						scale = 0.5,
						shift = util.by_pixel(19.5, 6.5),
						draw_as_shadow = true,
					},
				},
			},
		}

		entity.fluid_box.pipe_covers = pipecoverspictures()
		entity.output_fluid_box.pipe_covers = pipecoverspictures()

		-- Handle ambient-light
		entity.energy_source.light_flicker = {
			color = { 0, 0, 0 },
			minimum_light_size = 0,
			light_intensity_to_size_coefficient = 0,
		}

		-- Label to skip to next iteration
		::continue::
	end
end
