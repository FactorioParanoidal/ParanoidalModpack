require("sprite-generation")
require("sprite-segments")

local segmentsData = MergingChests.SpriteSegmentsData

function MergingChests.LimitInventorySize(id, tiles)
	local inventorySize = data.raw.container[id].inventory_size * tiles
	
	inventorySize = inventorySize * settings.startup["inventory-size-multiplier"].value
	if inventorySize > settings.startup["inventory-size-limit"].value then
		inventorySize = settings.startup["inventory-size-limit"].value
	end
	
	return inventorySize
end

function MergingChests.CreateEntity(merged_data, name, loc_name, subgroup, width, height, sprite, connector)
	return
	{
		type = "container",
		name = name,
		localised_name = loc_name,
		icon = merged_data.icon,
		icon_size = merged_data.iconSize,
		flags = { "placeable-player", "player-creation", "not-upgradable" },
		minable = { mining_time = 2, result = merged_data.id, count = width * height },
		placeable_by = { item = merged_data.id, count = width * height },
		max_health = data.raw.container[merged_data.id].max_health * math.min(width * height, 10),
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		collision_box = { { -width / 2 + 0.15, -height / 2 + 0.15 }, { width / 2 - 0.15, height / 2 - 0.15 } },
		selection_box = { { -width / 2, -height / 2 }, { width / 2, height / 2 } },
		inventory_size = MergingChests.LimitInventorySize(merged_data.id, width * height),
		subgroup = subgroup,
		picture =
		{
			layers = sprite
		},
		circuit_wire_connection_point = connector.points,
		circuit_connector_sprites = connector.sprites,
		circuit_wire_max_distance = default_circuit_wire_max_distance + math.min(width, height) - 1,
	}
end

function MergingChests.CreateWideChestEntity(data, size)
	return MergingChests.CreateEntity(
			data,
			"wide-"..data.type.."-chest-"..size,
			{ "chest-name.wide-"..data.type.."-chest", size },
			"wide-chests",
			size, 1,
			MergingChests.CreateSprite(size, 1, segmentsData.wide_segments),
			circuit_connector_definitions["chest"])
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
				show_shadow = false,
			},
		}
	)
	return MergingChests.CreateEntity(
			data,
			"high-"..data.type.."-chest-"..size,
			{ "chest-name.high-"..data.type.."-chest", size },
			"high-chests",
			1, size,
			MergingChests.CreateSprite(1, size, segmentsData.high_segments),
			connectorV)
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
				show_shadow = false,
			},
		}
	)
	return MergingChests.CreateEntity(
			data,
			data.type.."-warehouse-"..width.."x"..height,
			{ "chest-name."..data.type.."-warehouse", width, height },
			"warehouse",
			width, height,
			MergingChests.CreateSprite(width, height, segmentsData.warehouse_segments),
			connector)
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
				show_shadow = false,
			},
		}
	)
	return MergingChests.CreateEntity(
			data,
			data.type.."-trashdump-"..width.."x"..height,
			{ "chest-name."..data.type.."-trashdump", width, height },
			"trashdump",
			width, height,
			MergingChests.CreateSprite(width, height, segmentsData.trashdump_segments),
			connector)
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