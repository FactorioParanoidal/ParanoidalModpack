-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Set input parameters
local inputs = {
	type = "container",
	mod = "angels",
	tint = util.color("#403630"),
	icon_layers = 1,
	make_remnants = false,
	-- make_explosions = false,
}

-- Reskin Warehouses
if reskins.angels and reskins.angels.triggers.storage.entities then
	local name = "angels-warehouse"

	---@type data.ContainerPrototype
	local entity = data.raw[inputs.type][name]
	if entity then
		inputs.group = "addons-storage"
		inputs.icon_name = "warehouse"
		inputs.base_entity_name = "oil-refinery"
		inputs.particles = { ["big-tint"] = 5, ["medium"] = 2 }

		reskins.lib.setup_standard_entity(name, 0, inputs)

		entity.picture = {
			layers = {
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
			},
		}
	end
end

-- Reskin Silos
if reskins.angels and reskins.angels.triggers.storage.entities then
	-- local name = "angels-warehouse"

	-- ---@type data.ContainerPrototype
	-- local entity = data.raw[inputs.type][name]

	-- -- Check if entity exists, if not, skip this iteration
	-- if entity then
	--     inputs.group = "addons-storage"
	--     inputs.icon_name = "warehouse"

	--     reskins.lib.setup_standard_entity(name, 0, inputs)

	--     entity.picture = {
	--         layers = {
	--             -- Base
	--             {
	--                 filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse.png",
	--                 priority = "extra-high",
	--                 width = 391,
	--                 height = 446,
	--                 shift = util.by_pixel(-0.5, -15),
	--                 scale = 0.5,
	--             },
	--             -- Shadow
	--             {
	--                 filename = "__reskins-angels__/graphics/entity/addons-storage/warehouse/warehouse-shadow.png",
	--                 priority = "extra-high",
	--                 width = 592,
	--                 height = 276,
	--                 shift = util.by_pixel(52.5, 30.5),
	--                 draw_as_shadow = true,
	--                 scale = 0.5,
	--             },
	--         }
	--     }
	-- end
end

-- Reskin Big Chests
if reskins.angels and reskins.angels.triggers.industries.entities then
	local name = "angels-big-chest"

	---@type data.ContainerPrototype
	local entity = data.raw[inputs.type][name]
	if entity then
		inputs.group = "addons-storage"
		inputs.icon_name = "big-chest"
		inputs.base_entity_name = "storage-tank"
		inputs.particles = { ["big"] = 1 }

		reskins.lib.setup_standard_entity(name, 0, inputs)

		entity.picture = {
			layers = {
				-- Base
				{
					filename = "__reskins-angels__/graphics/entity/addons-storage/big-chest/big-chest.png",
					priority = "extra-high",
					width = 135,
					height = 169,
					shift = util.by_pixel(-0.5, -10),
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__reskins-angels__/graphics/entity/addons-storage/big-chest/big-chest-shadow.png",
					priority = "extra-high",
					width = 209,
					height = 97,
					shift = util.by_pixel(18.5, 8.5),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		}
	end
end
