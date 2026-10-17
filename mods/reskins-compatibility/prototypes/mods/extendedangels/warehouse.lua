-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then
	return
end
if not (reskins.angels and reskins.angels.triggers.storage.entities) then
	return
end

local inputs = {
	mod = "compatibility",
	group = "extendedangels",
	icon_name = "warehouse",
	base_entity_name = "oil-refinery",
	particles = { ["big-tint"] = 5, ["medium"] = 2 },
	make_explosions = false,
	make_remnants = false,
}

local types = {
	["warehouse"] = { particle_tint = util.color("#403630") },
	["warehouse-active-provider"] = { particle_tint = util.color("#760fd6"), is_logistics = true },
	["warehouse-passive-provider"] = { particle_tint = util.color("#ff0000"), is_logistics = true },
	["warehouse-storage"] = { particle_tint = util.color("#ba7713"), is_logistics = true },
	["warehouse-buffer"] = { particle_tint = util.color("#00bf13"), is_logistics = true },
	["warehouse-requester"] = { particle_tint = util.color("#227dae"), is_logistics = true },
}

local function create_logistic_warehouse_picture(chest)
	return {
		-- Base
		{
			filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/logistic-" .. chest .. ".png",
			priority = "extra-high",
			width = 391,
			height = 446,
			shift = util.by_pixel(-0.5, -15),
			scale = 0.5,
		},
		-- Shadow
		{
			filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/logistic-warehouse-shadow.png",
			priority = "extra-high",
			width = 592,
			height = 276,
			shift = util.by_pixel(52.5, 30.5),
			draw_as_shadow = true,
			scale = 0.5,
		},
		-- Light
		{
			filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/logistic-warehouse-light.png",
			priority = "extra-high",
			width = 9,
			height = 28,
			shift = util.by_pixel(71.5, -104),
			draw_as_light = true,
			scale = 0.5,
		},
	}
end

local function create_standard_warehouse_picture()
	return {
		-- Base
		{
			filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse.png",
			priority = "extra-high",
			width = 391,
			height = 446,
			shift = util.by_pixel(-0.5, -15),
			scale = 0.5,
		},
		-- Shadow
		{
			filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse-shadow.png",
			priority = "extra-high",
			width = 592,
			height = 276,
			shift = util.by_pixel(52.5, 30.5),
			draw_as_shadow = true,
			scale = 0.5,
		},
	}
end

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

-- Reskin Extended Angels warehouses
for warehouse, map in pairs(types) do
	for n = 1, 4 do
		-- Fetch the current entity
		local name
		if n == 1 then
			name = "angels-" .. warehouse
		else
			name = "angels-" .. warehouse .. "-mk" .. n
		end

		inputs.type = map.is_logistics and "logistic-container" or "container"

		---@type data.LogisticContainerPrototype|data.ContainerPrototype
		local entity = data.raw[inputs.type][name]
		if not entity then
			goto continue
		end

		-- Handle tier
		local tier = n
		if reskins.lib.settings.get_value("reskins-lib-tier-mapping") == "progression-map" then
			tier = n + 1
		end

		-- Construct icon base
		local filename = map.is_logistics and "logistic-" .. warehouse .. "-icon-base" or warehouse .. "-icon-base"
		inputs.icon_filename = "__reskins-angels__/graphics/icons/addons-storage/warehouse/" .. filename .. ".png"

		inputs.tint = map.tint or reskins.lib.tiers.get_tint(tier)

		if reskins.lib.settings.get_value("reskins-compatibility-extendedangels-warehouse-tiering") then
			inputs.icon_layers = 3
		else
			inputs.icon_layers = 1
		end

		if n == 1 then
			reskins.lib.construct_icon(name, tier, inputs)
		else
			reskins.lib.setup_standard_entity(name, tier, inputs)

			-- Setup explosions
			reskins.lib.create_explosions_and_particles(name, { base_entity_name = inputs.base_entity_name, type = inputs.type, tint = map.particle_tint, particles = inputs.particles })

			-- Reskin entities
			local picture
			if map.is_logistics then
				picture = create_logistic_warehouse_picture(warehouse)
			else
				picture = create_standard_warehouse_picture()
			end

			entity.picture = {
				layers = picture,
			}
		end

		if reskins.lib.settings.get_value("reskins-compatibility-extendedangels-warehouse-tiering") then
			table.insert(entity.picture.layers, {
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/warehouse/warehouse-mask.png",
				priority = "extra-high",
				width = 391,
				height = 446,
				shift = util.by_pixel(-0.5, -15),
				tint = inputs.tint,
				scale = 0.5,
			})

			table.insert(entity.picture.layers, {
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/warehouse/warehouse-highlights.png",
				priority = "extra-high",
				width = 391,
				height = 446,
				shift = util.by_pixel(-0.5, -15),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			})
		end

		-- Label to skip to next iteration
		::continue::
	end
end
