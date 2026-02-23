local EntityData = KuxCoreLib.EntityData
local util = require("util")
local isSpaceTravel = feature_flags["space_travel"]

if isSpaceTravel then
	local entity = EntityData.clone("radar", "radar", "orbital-ion-cannon") --[[@as data.RadarPrototype]]
	entity.rotation_speed = 0
	entity.energy_per_sector = "1MJ"
	entity.energy_per_nearby_scan = "1MJ"
	entity.energy_usage = "50kW"
	entity.max_distance_of_sector_revealed = 0
	entity.max_distance_of_nearby_sector_revealed = 0
	entity.minable = {mining_time = 0.1, result = "radar"}
	entity.fast_replaceable_group = nil
	entity.next_upgrade = nil
	if settings.startup["ion-cannon-1x1-controler"].value ==true then
		entity.collision_box = {{-0.45, -0.45}, {0.45, 0.45}}
		entity.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
		entity.hit_visualization_box = {{-0.5, -0.5}, {0.5, 0.5}}
		entity.integration_patch.scale = entity.integration_patch.scale / 3
		entity.integration_patch.shift = util.by_pixel(0, -5)
		entity.pictures.layers[1].scale = entity.pictures.layers[1].scale / 3
		entity.pictures.layers[1].shift = util.by_pixel(0, -5)
		entity.pictures.layers[2].scale = entity.pictures.layers[2].scale / 3
		entity.pictures.layers[2].shift = util.by_pixel(14, 2)
	end
	entity.connects_to_other_radars = false
	entity.working_sound = nil

	data:extend{entity}
end

local item = {
	type = "item",
	name = "orbital-ion-cannon",
	localised_name = isSpaceTravel and {"item-name.orbital-ion-cannon-space-travel"} or {"item-name.orbital-ion-cannon"},
	localised_description = isSpaceTravel and {"item-description.orbital-ion-cannon-space-travel"} or {"item-description.orbital-ion-cannon"},
	icon = mod.path.."graphics/icon64.png",
	icon_size = 64,
	subgroup = "defensive-structure",
	order = "e[orbital-ion-cannon]",
	stack_size = 1,
	weight = 1000000,
	send_to_orbit_mode = "automated",
}
if isSpaceTravel then
	item.place_result = "orbital-ion-cannon"
end
data:extend({item})

data:extend({
	{
		type = "recipe",
		name = "orbital-ion-cannon",
		localised_name = isSpaceTravel and {"recipe-name.orbital-ion-cannon-space-travel"} or {"recipe-name.orbital-ion-cannon"},
		localised_description = isSpaceTravel and {"recipe-description.orbital-ion-cannon-space-travel"} or {"recipe-description.orbital-ion-cannon"},
		energy_required = 60,
		enabled = false,
		ingredients = {
			{ type = "item", name = "low-density-structure", amount = 100 },
			{ type = "item", name = "solar-panel", amount = 100 },
			{ type = "item", name = "accumulator", amount = 200 },
			{ type = "item", name = "radar", amount = 10 },
			{ type = "item", name = "processing-unit", amount = 200 },
			{ type = "item", name = "electric-engine-unit", amount = 25 },
			{ type = "item", name = "laser-turret", amount = 50 },
			{ type = "item", name = "rocket-fuel", amount = 50 }
		},
		results = {
			{ type = "item", name = "orbital-ion-cannon", amount = 1 }
		}
	},
})

--[[
--TODO update to not use array indices
if data.raw["item"]["advanced-processing-unit"] and settings.startup["ion-cannon-bob-updates"].value then
	data.raw["recipe"]["orbital-ion-cannon"].ingredients[5] = {type = "item", name = "advanced-processing-unit", amount=200}
end

if data.raw["item"]["bob-laser-turret-5"] and settings.startup["ion-cannon-bob-updates"].value then
	data.raw["recipe"]["orbital-ion-cannon"].ingredients[7] = {type = "item", name = "bob-laser-turret-5", amount=50}
end

if data.raw["item"]["fast-accumulator-3"] and data.raw["item"]["solar-panel-large-3"] and settings.startup["ion-cannon-bob-updates"].value then
	data.raw["recipe"]["orbital-ion-cannon"].ingredients[2] = {type = "item", name = "solar-panel-large-3", amount=100}
	data.raw["recipe"]["orbital-ion-cannon"].ingredients[3] = {type = "item", name = "fast-accumulator-3", amount=200}
end
]]

if isSpaceTravel then
	local entity = EntityData.clone("radar", "orbital-ion-cannon", "orbital-ion-cannon-mk2") --[[@as data.RadarPrototype]]
	data:extend{entity}


	data:extend({
		{
			type = "item",
			name = "orbital-ion-cannon-mk2",
			localised_name = isSpaceTravel and {"item-name.orbital-ion-cannon-mk2-space-travel"} or {"item-name.orbital-ion-cannon-mk2"},
			localised_description = isSpaceTravel and {"item-description.orbital-ion-cannon-mk2-space-travel"} or {"item-description.orbital-ion-cannon-mk2"},
			icon = mod.path.."graphics/tech-mk2.png",
			icon_size = 256,
			subgroup = "defensive-structure",
			order = "e[orbital-ion-cannon]",
			stack_size = 1,
			weight = 5000000, --must be build on space platform
			place_result = entity.name,
		},
	})

	--TODO ingredients Vanilla
	--TODO ingredients Space-Age
	data:extend({
		{
			type = "recipe",
			name = "orbital-ion-cannon-mk2",
			localised_name = isSpaceTravel and {"recipe-name.orbital-ion-cannon-mk2-space-travel"} or {"recipe-name.orbital-ion-cannon-mk2"},
			localised_description = isSpaceTravel and {"recipe-description.orbital-ion-cannon-mk2-space-travel"} or {"recipe-description.orbital-ion-cannon-mk2"},
			energy_required = 60,
			enabled = false,
			ingredients = {
				{ type = "item", name = "low-density-structure", amount = 100 },
				{ type = "item", name = "solar-panel", amount = 100 },
				{ type = "item", name = "accumulator", amount = 200 },
				{ type = "item", name = "radar", amount = 10 },
				{ type = "item", name = "processing-unit", amount = 200 },
				{ type = "item", name = "electric-engine-unit", amount = 25 },
				{ type = "item", name = "laser-turret", amount = 50 },
				{ type = "item", name = "rocket-fuel", amount = 50 }
			},
			results = {
				{ type = "item", name = "orbital-ion-cannon-mk2", amount = 1 }
			}
		},
	})
end