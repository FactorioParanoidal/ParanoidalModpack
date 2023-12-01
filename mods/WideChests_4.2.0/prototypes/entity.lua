require("sprite-generation")
require("sprite-segments")

function MergingChests.LimitInventorySize(default_inventory_size, tiles)
	return util.clamp(
		default_inventory_size * tiles * settings.startup["inventory-size-multiplier"].value,
		0,
		settings.startup["inventory-size-limit"].value
	)
end

function MergingChests.CreateEntity(chest_data, name, loc_name, subgroup, width, height, sprite, connector)
	local base
	if chest_data.logistic then
		base = {
			type = "logistic-container",
			max_health = data.raw["logistic-container"][chest_data.id].max_health * math.min(width * height, 10),
			inventory_size = MergingChests.LimitInventorySize(data.raw["logistic-container"][chest_data.id].inventory_size, width * height),
			animation_sound = data.raw["logistic-container"][chest_data.id].animation_sound,
			opened_duration = 7,
			animation =
			{
				layers = sprite
			}
		}
	else
		base = {
			type = "container",
			max_health = data.raw.container[chest_data.id].max_health * math.min(width * height, 10),
			inventory_size = MergingChests.LimitInventorySize(data.raw.container[chest_data.id].inventory_size, width * height),
			picture =
			{
				layers = sprite
			}
		}
	end

	return util.merge({
		base,
		chest_data.additional_properties or {},
		{
			name = name,
			localised_name = loc_name,
			flags = { "placeable-player", "player-creation", "not-upgradable" },
			minable = { mining_time = 2, result = chest_data.id, count = width * height },
			placeable_by = { item = chest_data.id, count = width * height },
			corpse = "medium-remnants",
			dying_explosion = "medium-explosion",
			open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
			close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
			vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
			collision_box = { { -width / 2 + 0.15, -height / 2 + 0.15 }, { width / 2 - 0.15, height / 2 - 0.15 } },
			selection_box = { { -width / 2, -height / 2 }, { width / 2, height / 2 } },
			subgroup = subgroup,
			circuit_wire_connection_point = connector.points,
			circuit_connector_sprites = connector.sprites,
			circuit_wire_max_distance = default_circuit_wire_max_distance + math.min(width, height) - 1,
		}
	})
end

function MergingChests.CreateWideChestEntity(data, size)
	return MergingChests.CreateEntity(
		data,
		"wide-"..data.type.."-chest-"..size,
		{ "chest-name.wide-"..data.type.."-chest", size },
		"wide-chests",
		size, 1,
		MergingChests.CreateSprite(size, 1, MergingChests.GetWideChestSpriteSegmentsData(data.id)),
		circuit_connector_definitions["chest"]
	)
end

function MergingChests.CreateHighChestEntity(data, size)
	local connectorV = circuit_connector_definitions.create
	(
		universal_connector_template,
		{
			{
				variation = 24,
				main_offset = util.by_pixel(-16, 0),
				shadow_offset = util.by_pixel(2.5, 4.5),
				show_shadow = false
			}
		}
	)
	return MergingChests.CreateEntity(
		data,
		"high-"..data.type.."-chest-"..size,
		{ "chest-name.high-"..data.type.."-chest", size },
		"high-chests",
		1, size,
		MergingChests.CreateSprite(1, size, MergingChests.GetHighChestSpriteSegmentsData(data.id)),
		connectorV
	)
end

function MergingChests.CreateWarehouseEntity(data, width, height)
	local connector = circuit_connector_definitions.create
	(
		universal_connector_template,
		{
			{
				variation = 24,
				main_offset = util.by_pixel(-16 * width, 0),
				shadow_offset = util.by_pixel(10 - 16 * width, 4),
				show_shadow = false
			}
		}
	)
	return MergingChests.CreateEntity(
		data,
		data.type.."-warehouse-"..width.."x"..height,
		{ "chest-name."..data.type.."-warehouse", width, height },
		"warehouse",
		width, height,
		MergingChests.CreateSprite(width, height, MergingChests.GetWarehouseSpriteSegmentsData(data.id)),
		connector
	)
end

function MergingChests.CreateTrashdumpEntity(data, width, height)
	local connector = circuit_connector_definitions.create
	(
		universal_connector_template,
		{
			{
				variation = 24,
				main_offset = util.by_pixel(14 - 16 * width, 0),
				shadow_offset = util.by_pixel(24 - 16 * width, 4),
				show_shadow = false
			}
		}
	)
	return MergingChests.CreateEntity(
		data,
		data.type.."-trashdump-"..width.."x"..height,
		{ "chest-name."..data.type.."-trashdump", width, height },
		"trashdump",
		width, height,
		MergingChests.CreateSprite(width, height, MergingChests.GetTrashdumpSpriteSegmentsData(data.id)),
		connector
	)
end

local limits = MergingChests.Limits()
for _, id in ipairs(MergingChests.MergableChestIds) do
	local chestData = MergingChests.MergableChestIdToData[id]
	for j = 2, math.min(limits.height, limits.area) do
		if MergingChests.CheckWhitelist(1, j) then
			data:extend({ MergingChests.CreateHighChestEntity(chestData, j) })
		end
	end

	for i = 2, math.min(limits.width, limits.area) do
		if MergingChests.CheckWhitelist(i, 1) then
			data:extend({ MergingChests.CreateWideChestEntity(chestData, i) })
		end

		for j = 2, math.min(limits.height, limits.area) do
			if MergingChests.CheckWhitelist(i, j) then
				if i > settings.startup["warehouse-threshold"].value and j > settings.startup["warehouse-threshold"].value then
					data:extend({ MergingChests.CreateTrashdumpEntity(chestData, i, j) })
				else
					data:extend({ MergingChests.CreateWarehouseEntity(chestData, i, j) })
				end
			end
		end
	end
end