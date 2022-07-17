--[[ Copyright (c) 2017 David-John Miller AKA Anoyomouse
 * rewritten by Optera 2019
 *
 * extended by dgw 2021
 *
 * Part of the Warehousing mod
 *
 * See License.txt in the project directory for license information.
--]]

ICONPATH = "__Warehousing__/graphics/icons/"
ENTITYPATH = "__Warehousing__/graphics/entity/"
local sounds = require("__base__/prototypes/entity/sounds")

local warehouse_slots = 1800
local storehouse_slots = 450
local storage_warehouse_slots = 2000
local storage_storehouse_slots = 500

-- Support legacy mode
if settings.startup["Warehousing-sixteen-mode"].value then
	warehouse_slots = 800
	storehouse_slots = 150
	storage_warehouse_slots = 2000
	storage_storehouse_slots = 300
end

-- Utility for placing circuit connector graphics
function connectorSprite(shift, shiftshadow)
return
	{
		connector_main =
		{
			filename = ENTITYPATH.."connector.png",
			width = 42,
			height = 68,
			shift = shift,
			hr_version = {
				filename = ENTITYPATH.."hr-connector.png",
				width = 84,
				height = 136,
				scale = 0.5,
				shift = shift,
			}
		},
		connector_shadow =
		{
			filename = ENTITYPATH.."connector-shadow.png",
			width = 34,
			height = 17,
			draw_as_shadow = true,
			shift = shiftshadow,
			hr_version = {
				filename = ENTITYPATH.."hr-connector-shadow.png",
				width = 68,
				height = 33,
				scale = 0.5,
				draw_as_shadow = true,
				shift = shiftshadow,
			}
		},
		led_blue = { filename = "__core__/graphics/empty.png", size = 1 },
		led_green = { filename = "__core__/graphics/empty.png", size = 1 },
		led_red = { filename = "__core__/graphics/empty.png", size = 1 },
		led_light = { type = "basic", intensity = 0, size = 0 }
	}
end

-- generate base storehouse and warehouse
data:extend({
	{
		type = "container",
		name = "warehouse-basic",
		icon = ICONPATH.."warehouse-basic.png",
		icon_size = 64,
		icon_mipmaps = 3,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 2, result = "warehouse-basic"},
		max_health = 450,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			}
		},
		collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
		selection_box = {{-3.0, -3.0}, {3.0, 3.0}},
		landing_location_offset = {1.0, -1.0},
		fast_replaceable_group = "container",
		inventory_size = warehouse_slots,
		scale_info_icons = settings.startup["Warehousing-icon-scaling"].value,
		picture = {
			layers = {
				{
					filename = ENTITYPATH.."warehouse/warehouse-basic.png",
					width = 260,
					height = 240,
					hr_version = {
						filename = ENTITYPATH.."warehouse/hr-warehouse-basic.png",
						width = 520,
						height = 480,
						scale = 0.5,
					}
				},
				{
					filename = ENTITYPATH.."warehouse/warehouse-basic-shadow.png",
					width = 260,
					height = 240,
					shift = {1, 0},
					draw_as_shadow = true,
					hr_version = {
						filename = ENTITYPATH.."warehouse/hr-warehouse-basic-shadow.png",
						width = 520,
						height = 480,
						shift = {1, 0},
						scale = 0.5,
						draw_as_shadow = true,
					}
				},
			},
		},
		circuit_wire_max_distance = 7.5,
		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {144/32, 79/32},
				green = {126/32, 79/32}
			},
			wire =
			{
				red = {67/32, 6/32},
				green = {49/32, 6/32}
			}
		},
		circuit_connector_sprites = connectorSprite({58/32, 6/32}, {135/32, 79/32}),
	},
	{
		type = "container",
		name = "storehouse-basic",
		icon = ICONPATH.."storehouse-basic.png",
		icon_size = 64,
		icon_mipmaps = 3,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 2, result = "storehouse-basic"},
		max_health = 250,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		resistances =
		{
			{
				type = "fire",
				percent = 90
			}
		},
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		fast_replaceable_group = "container",
		inventory_size = storehouse_slots,
		scale_info_icons = settings.startup["Warehousing-icon-scaling"].value,
		picture = {
			layers = {
				{
					filename = ENTITYPATH.."storehouse/storehouse-basic.png",
					width = 128,
					height = 128,
					hr_version = {
						filename = ENTITYPATH.."storehouse/hr-storehouse-basic.png",
						width = 256,
						height = 256,
						scale = 0.5,
					}
				},
				{
					filename = ENTITYPATH.."storehouse/storehouse-basic-shadow.png",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					hr_version = {
						filename = ENTITYPATH.."storehouse/hr-storehouse-basic-shadow.png",
						width = 256,
						height = 256,
						scale = 0.5,
						draw_as_shadow = true,
					}
				},
			},
		},
		circuit_wire_max_distance = 7.5,
		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {82/32, 22/32},
				green = {64/32, 22/32}
			},
			wire =
			{
				red = {32/32, -22/32},
				green = {14/32, -22/32}
			}
		},
		circuit_connector_sprites = connectorSprite({23/32, -22/32}, {73/32, 22/32}),
	},
})

function chestAnim(img, hrimg, shadow, hrshadow, shadowshift, width, height, chestanim, hrchestanim, chestshift, chestanimsize)
return
	{
		layers = {
			{
				filename = img,
				width = width/2,
				height = height/2,
				repeat_count = 7,
				hr_version = {
					filename = hrimg,
					width = width,
					height = height,
					repeat_count = 7,
					scale = 0.5,
				}
			},
			{
				filename = chestanim,
				width = chestanimsize/2,
				height = chestanimsize/2,
				frame_count = 7,
				shift = chestshift,
				hr_version = {
					filename = hrchestanim,
					width = chestanimsize,
					height = chestanimsize,
					frame_count = 7,
					shift = chestshift,
					scale = 0.5,
				}
			},
			{
				filename = shadow,
				width = width/2,
				height = height/2,
				shift = shadowshift,
				repeat_count = 7,
				draw_as_shadow = true,
				hr_version = {
					filename = hrshadow,
					width = width,
					height = height,
					shift = shadowshift,
					scale = 0.5,
					repeat_count = 7,
					draw_as_shadow = true,
				}
			},
		},
	}
end

-- generate logistic variants
function createLogisticContainer(name, logistic_type)
	local p = table.deepcopy(data.raw["container"][name.."-basic"])
	p.name = name.."-"..logistic_type
	local img = ENTITYPATH..name.."/"..p.name..".png"
	local hrimg = ENTITYPATH..name.."/hr-"..p.name..".png"
	local shadow = ENTITYPATH..name.."/"..name.."-shadow.png"
	local hrshadow = ENTITYPATH..name.."/hr-"..name.."-shadow.png"
	local chestanim = ENTITYPATH..name.."/"..name.."-chest-anim.png"
	local hrchestanim = ENTITYPATH..name.."/hr-"..name.."-chest-anim.png"
	p.minable.result = p.name
	p.icon = ICONPATH..p.name..".png"
	p.type = "logistic-container"
	p.logistic_mode = logistic_type
	p.animation_sound = sounds.logistics_chest_open
	p.opened_duration = 7
	if name == "warehouse" then
		p.animation = chestAnim(img, hrimg, shadow, hrshadow, {1, 0}, 520, 480, chestanim, hrchestanim, {1, -44/32}, 44)
	end
	if name == "storehouse" then
		p.animation = chestAnim(img, hrimg, shadow, hrshadow, {0, 0}, 256, 256, chestanim, hrchestanim, {0, 3/32}, 74)
	end
	if logistic_type == "storage" then
		p.max_logistic_slots = 1
	end
	return p
end

local storehouse_active_provider = createLogisticContainer("storehouse", "active-provider")
local storehouse_passive_provider = createLogisticContainer("storehouse", "passive-provider")
local storehouse_storage = createLogisticContainer("storehouse", "storage")
storehouse_storage.inventory_size = storage_storehouse_slots
local storehouse_buffer = createLogisticContainer("storehouse", "buffer")
local storehouse_requester = createLogisticContainer("storehouse", "requester")
local warehouse_active_provider = createLogisticContainer("warehouse", "active-provider")
local warehouse_passive_provider = createLogisticContainer("warehouse", "passive-provider")
local warehouse_storage = createLogisticContainer("warehouse", "storage")
warehouse_storage.inventory_size = storage_warehouse_slots
local warehouse_buffer = createLogisticContainer("warehouse", "buffer")
local warehouse_requester = createLogisticContainer("warehouse", "requester")

-- generate linked variants
function createLinkedContainer(name)
	local p = table.deepcopy(data.raw["container"][name.."-basic"])
	p.type = "linked-container"
	p.name = "linked-"..name
	p.minable.result = p.name
	p.circuit_wire_connection_point = nil
	p.circuit_connector_sprites = nil
	p.circuit_wire_max_distance = nil
	p.gui_mode = "admins" -- all, none, admins
	p.icon = ICONPATH..name.."-linked.png"
	p.icon_size = 64
	p.picture.layers[1].filename = ENTITYPATH..name.."/"..name.."-linked.png"
	p.picture.layers[1].hr_version.filename = ENTITYPATH..name.."/hr-"..name.."-linked.png"
	return p
end

local linked_warehouse = createLinkedContainer("warehouse")
linked_warehouse.inventory_size = warehouse_slots
local linked_storehouse = createLinkedContainer("storehouse")
linked_storehouse.inventory_size = storehouse_slots


-- add generated entities to data table
data:extend({
	storehouse_active_provider,
	storehouse_passive_provider,
	storehouse_storage,
	storehouse_buffer,
	storehouse_requester,
	warehouse_active_provider,
	warehouse_passive_provider,
	warehouse_storage,
	warehouse_buffer,
	warehouse_requester,
	linked_warehouse,
	linked_storehouse,
})
