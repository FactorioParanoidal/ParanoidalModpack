-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Set input parameters
local inputs = {
	type = "logistic-container",
	mod = "angels",
	icon_layers = 1,
	make_remnants = false,
	-- make_explosions = false,
}

local logistic_map = {
	["active-provider"] = { tint = util.color("#760fd6") },
	["buffer"] = { tint = util.color("#00bf13") },
	["passive-provider"] = { tint = util.color("#ff0000") },
	["requester"] = { tint = util.color("#227dae") },
	["storage"] = { tint = util.color("#ba7713") },
}

-- Reskin Warehouses
if reskins.angels and reskins.angels.triggers.storage.entities then
	for chest, map in pairs(logistic_map) do
		local name = "angels-warehouse-" .. chest

		---@type data.LogisticContainerPrototype
		local entity = data.raw[inputs.type][name]

		-- Check if entity exists, if not, skip this iteration
		if not entity then
			goto continue
		end

		inputs.tint = map.tint

		inputs.group = "addons-storage"

		-- Setup icon details
		inputs.icon_name = "warehouse"
		inputs.icon_base = "logistic-warehouse-" .. chest
		inputs.base_entity_name = "oil-refinery"
		inputs.particles = { ["big-tint"] = 5, ["medium"] = 2 }

		reskins.lib.setup_standard_entity(name, 0, inputs)

		entity.picture = {
			layers = {
				-- Base
				{
					filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/logistic-warehouse-" .. chest .. ".png",
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
			},
		}

		-- Label to skip to next iteration
		::continue::
	end
end

-- Reskin Silos
if reskins.angels and reskins.angels.triggers.storage.entities then
	--     for chest, map in pairs(logistic_map) do
	--         local name = "angels-warehouse-"..chest

	--         ---@type data.LogisticContainerPrototype
	--         local entity = data.raw[inputs.type][name]

	--         -- Check if entity exists, if not, skip this iteration
	--         if not entity then goto continue end

	--         inputs.tint = map.tint

	--         inputs.icon_name = "warehouse"

	--         reskins.lib.setup_standard_entity(name, 0, inputs)

	--         entity.picture = {
	--             layers = {
	--                 -- Base
	--                 {
	--                     filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse-"..chest.."-base.png",
	--                     priority = "extra-high",
	--                     width = 328,
	--                     height = 376,
	--                     shift = util.by_pixel(0, 0),
	--                     scale = 0.5,
	--                 },
	--                 -- Shadow
	--                 {
	--                     filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse-"..chest.."-shadow.png",
	--                     priority = "extra-high",
	--                     width = 328,
	--                     height = 376,
	--                     shift = util.by_pixel(0, 0),
	--                     draw_as_shadow = true,
	--                     scale = 0.5,
	--                 },
	--                 -- Light
	--                 {
	--                     filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse-"..chest.."-light.png",
	--                     priority = "extra-high",
	--                     width = 328,
	--                     height = 376,
	--                     shift = util.by_pixel(0, 0),
	--                     draw_as_light = true,
	--                     scale = 0.5,
	--                 },
	--             }
	--         }

	--         -- Label to skip to next iteration
	--         ::continue::
	--     end
end

-- Reskin Big Chests from Angel's Industries
if reskins.angels and reskins.angels.triggers.industries.entities then
	for chest, map in pairs(logistic_map) do
		local name = "angels-logistic-chest-" .. chest

		---@type data.LogisticContainerPrototype
		local entity = data.raw[inputs.type][name]

		-- Check if entity exists, if not, skip this iteration
		if not entity then
			goto continue
		end

		inputs.tint = map.tint

		inputs.group = "addons-storage"

		-- Setup icon details
		inputs.icon_name = "big-chest"
		inputs.icon_base = "logistic-big-chest-" .. chest
		inputs.base_entity_name = "storage-tank"
		inputs.particles = { ["big"] = 1 }

		reskins.lib.setup_standard_entity(name, 0, inputs)

		entity.picture = {
			layers = {
				-- Base
				{
					filename = "__reskins-angels__/graphics/entity/addons-storage/big-chest/logistic-big-chest-" .. chest .. ".png",
					priority = "extra-high",
					width = 135,
					height = 169,
					shift = util.by_pixel(-0.5, -10.5),
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__reskins-angels__/graphics/entity/addons-storage/big-chest/logistic-big-chest-shadow.png",
					priority = "extra-high",
					width = 209,
					height = 97,
					shift = util.by_pixel(18.5, 8.5),
					draw_as_shadow = true,
					scale = 0.5,
				},
				-- Light
				{
					filename = "__reskins-angels__/graphics/entity/addons-storage/big-chest/logistic-big-chest-light.png",
					priority = "extra-high",
					width = 5,
					height = 15,
					shift = util.by_pixel(20.5, -41.5),
					draw_as_light = true,
					scale = 0.5,
				},
			},
		}

		-- Label to skip to next iteration
		::continue::
	end
end
