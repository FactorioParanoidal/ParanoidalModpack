--equipment.lua
--Defines the equipment grid and the modules for the modular locomotive

local category = {
	type = "equipment-category",
	name = "electric-loco-modules"
}

local grid = {
	type = "equipment-grid",
	name = "modular-locomotive-grid",
	equipment_categories = { "electric-loco-modules" },
	width = 8,
	height = 4	
}

data:extend{category, grid}


local train_speed_module = {
	type = "battery-equipment",
	name = "ret-train-speed-module",
	sprite = {
		filename = graphics .. "equipment/train-speed-module.png",
		width = 64, height = 64
	},
	shape = { width = 2, height = 2, type = "full" },
	categories = { "electric-loco-modules" },
	energy_source = {
		type = "electric",
		buffer_capacity = "0J",
		usage_priority = "secondary-output"
	},
	background_color = { r = 0.21, g = 0.45, b = 0.65 }
}

local train_productivity_module = {
	type = "battery-equipment",
	name = "ret-train-productivity-module",
	sprite = { 
		filename = graphics .. "equipment/train-productivity-module.png",
		width = 64, height = 64
	},
	shape = { width = 2, height = 2, type = "full" },
	categories = { "electric-loco-modules" },
	energy_source = {
		type = "electric",
		buffer_capacity = "0J",
		usage_priority = "secondary-output"
	},
	background_color = { r = 0.73, g = 0.33, b = 0.23 }
}

local train_efficiency_module = {
	type = "battery-equipment",
	name = "ret-train-efficiency-module",
	sprite = {
		filename = graphics .. "equipment/train-efficiency-module.png",
		width = 64, height = 64
	},
	shape = { width = 2, height = 2, type = "full" },
	categories = { "electric-loco-modules" },
	energy_source = {
		type = "electric",
		buffer_capacity = "0J",
		usage_priority = "secondary-output"
	},
	background_color = { r = 0.26, g = 0.58, b = 0.19 }
}

local train_battery_module = {
	type = "battery-equipment",
	name = "ret-train-battery-module",
	sprite = {
		filename = graphics .. "equipment/train-battery-module.png",
		width = 64, height = 64
	},
	shape = { width = 2, height = 2, type = "full" },
	categories = { "electric-loco-modules" },
	energy_source = {
		type = "electric",
		buffer_capacity = "0J",
		usage_priority = "secondary-output"
	},
	background_color = { r = 0.5, g = 0.5, b = 0.5 }
}

data:extend{train_speed_module, train_productivity_module, train_efficiency_module, train_battery_module}
