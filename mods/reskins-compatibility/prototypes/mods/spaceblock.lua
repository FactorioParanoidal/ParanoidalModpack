-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["spaceblock"] then
	return
end

-- Fix one-off entities
local fixes = {
	["spaceblock-matter-furnace"] = {
		type_name = "furnace",
		icon = "__base__/graphics/icons/stone-furnace.png",
	},
	["spaceblock-matter-refinery"] = {
		type_name = "assembling-machine",
		icon = "__base__/graphics/icons/chemical-plant.png",
	},
}

for name, map in pairs(fixes) do
	---@type DeferrableIconData
	local deferrable_icon = {
		name = name,
		type_name = map.type_name,
		icon_data = {
			{
				icon = map.icon,
				icon_size = 64,
				scale = 0.5,
				tint = { r = 0.85, g = 0.5, b = 1, a = 1 },
			},
		},
	}

	reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
end

---
---Make the base boiler icons.
---
---Uses masked sprites from Artisanal Reskin's: Bob's Mods, if available and enabled.
---
---@param tint data.Color # The tint to apply to the icon.
---@return data.IconData[] # The icons to use for the boiler.
---@nodiscard
local function make_boiler_icons_base(tint)
	---@type data.IconData[]
	local icon_data

	if reskins.bobs and reskins.bobs.triggers.power.items then
		icon_data = {
			{
				icon = "__reskins-bobs__/graphics/icons/power/boiler/boiler-icon-base.png",
				icon_size = 64,
			},
			{
				icon = "__reskins-bobs__/graphics/icons/power/boiler/boiler-icon-mask.png",
				icon_size = 64,
				tint = tint,
			},
			{
				icon = "__reskins-bobs__/graphics/icons/power/boiler/boiler-icon-highlights.png",
				icon_size = 64,
				tint = { 1, 1, 1, 0 },
			},
		}
	else
		icon_data = {
			{
				icon = "__base__/graphics/icons/boiler.png",
				icon_size = 64,
				tint = tint,
			},
		}
	end

	return icon_data
end

---
---Ensure a tint is formatted as expected by reskins.lib functions
---
---@param color any
---@return data.Color
local function format_tint(color)
	---@type data.Color
	local tint = {
		r = color.r or color[1],
		g = color.g or color[2],
		b = color.b or color[3],
		a = color.a or color[4] or 1,
	}

	return tint
end

-- Returns a properly formatted icon definition
local function collect_icons(prototype)
	local icons = prototype.icons or {
		{
			icon = prototype.icon,
			icon_size = prototype.icon_size,
		},
	}

	-- Ensure icons is properly populated
	for _, icon_data in pairs(icons) do
		if not icon_data.icon_size then
			icon_data.icon_size = prototype.icon_size
		end
	end

	return icons
end

-- Returns the name and type of all the minable results of a given prototype
local function get_minable_results(prototype)
	local results = {}

	-- Retrieve the results
	if prototype.minable.results then
		for _, result in pairs(prototype.minable.results) do
			table.insert(results, {
				name = result.name or result,
				type = result.type or "item",
			})
		end
	elseif prototype.minable.result then
		table.insert(results, {
			name = prototype.minable.result,
			type = "item",
		})
	end

	return results
end

local boilers = {}

---@param resource_name string
---@param fluid data.FluidPrototype
local function reskin_boiler_icons(resource_name, fluid)
	local item = data.raw.item["spaceblock-dupe-boiler-" .. resource_name]
	local entity = data.raw.boiler["spaceblock-dupe-boiler-" .. resource_name]
	local recipe = data.raw.recipe["spaceblock-dupe-boiler-" .. resource_name]

	if not item or not entity or not recipe then
		return
	end

	local icon_tint = reskins.bobs and reskins.bobs.triggers.power.items and format_tint(fluid.base_color) or format_tint(fluid.flow_color)
	local entity_tint = reskins.bobs and reskins.bobs.triggers.power.entities and format_tint(fluid.base_color) or format_tint(fluid.flow_color)

	---@type PrototypeIconSource
	local fluid_icon_source = {
		name = fluid.name,
		type_name = "fluid",
		shift = { -8, 8 },
		scale = 0.5,
	}

	local icons_base = make_boiler_icons_base(icon_tint)
	local icons = reskins.lib.icons.add_icons_from_sources_to_icons(icons_base, { fluid_icon_source })

	if recipe then
		recipe.icons = icons
	end
	if entity then
		entity.icons = icons
		boilers["spaceblock-dupe-boiler-" .. resource_name] = { tint = entity_tint }
	end
	if item then
		item.icons = icons
	end
end

---@param resource_name string
---@param fluid data.FluidPrototype
local function reskin_chemical_plant_recipes(resource_name, fluid)
	local recipe = data.raw.recipe["spaceblock-dupe-boil-" .. resource_name]
	if recipe then
		---@type PrototypeIconSource
		local refinery_icon_source = {
			name = "spaceblock-matter-refinery",
			type_name = "assembling-machine",
			shift = { -8, 8 },
			scale = 0.5,
		}

		local icons_base = reskins.lib.icons.get_icon_from_prototype_by_reference(fluid)
		local icons = reskins.lib.icons.add_icons_from_sources_to_icons(icons_base, { refinery_icon_source })

		recipe.icons = icons
	end
end

---@param resource_name string
---@param item data.ItemPrototype
local function reskin_furnace_recipes(resource_name, item)
	local recipe = data.raw.recipe["spaceblock-dupe-smelt-" .. resource_name]
	if recipe then
		---@type PrototypeIconSource
		local furnace_icon_source = {
			name = "spaceblock-matter-furnace",
			type_name = "furnace",
			shift = { -8, 8 },
			scale = 0.5,
		}

		local icons_base = reskins.lib.icons.get_icon_from_prototype_by_reference(item)
		local icons = reskins.lib.icons.add_icons_from_sources_to_icons(icons_base, { furnace_icon_source })

		recipe.icons = icons
	end
end

-- Setup icons for spaceblock matter entities and recipes
for name, resource in pairs(data.raw.resource) do
	local results = get_minable_results(resource)

	for _, result in pairs(results) do
		if result.type == "fluid" then
			local fluid = data.raw.fluid[result.name]

			if fluid then
				reskin_boiler_icons(name, fluid)
				reskin_chemical_plant_recipes(name, fluid)
			end
		else
			local item = data.raw.item[result.name]

			if item then
				reskin_furnace_recipes(name, item)
			end
		end
	end
end

if reskins.bobs and reskins.bobs.triggers.power.entities then
	-- Set input parameters
	local inputs = {
		type = "boiler",
		base_entity_name = "boiler",
		mod = "bobs",
		group = "power",
		particles = { ["big"] = 3 },
		make_icons = false,
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
