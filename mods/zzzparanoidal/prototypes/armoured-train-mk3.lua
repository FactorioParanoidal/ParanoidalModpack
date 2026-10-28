-- Бронепоезда Mk3 (решение пользователя 2026-10-28): локомотив, грузовой вагон и цистерна
-- следующим тиром за бронёй Bob Mk2. Копии Mk2 с новыми характеристиками, сетками 10×10,
-- сопротивлениями на ступень выше, рецептами на нитиноле и двумя исследованиями.
-- Создаются на этапе data, чтобы MultipleUnitTrainControl (data-updates) сделал MU-копию
-- локомотива, а пересборка переработки и система дефектов увидели новые предметы.
-- Графика — та же, что у брони Mk2 (ванильные спрайты Bob).
local MK2 = {
	locomotive = "bob-armoured-locomotive-2",
	["cargo-wagon"] = "bob-armoured-cargo-wagon-2",
	["fluid-wagon"] = "bob-armoured-fluid-wagon-2",
}
for entity_type, name in pairs(MK2) do
	if not (data.raw[entity_type][name] and data.raw["item-with-entity-data"][name] and data.raw.recipe[name]) then
		log("armoured-train-mk3: нет " .. entity_type .. " " .. name .. ", бронепоезда Mk3 не созданы")
		return
	end
end

local TIER3 = { r = 0.2, g = 0.7059, b = 1 } -- цвет тира 3 reskins (#33b4ff)
local MENU = "__zzzparanoidal__/graphics/transport-menu-beta8/"
-- Иконки как у брони Mk1/Mk2 в меню транспорта (слои Beta 8 + метка тира reskins), тир 3.
local function icons(base, mask, highlights)
	return {
		{ icon = MENU .. base, icon_size = 64 },
		{ icon = MENU .. mask, icon_size = 64, tint = TIER3 },
		{ icon = MENU .. highlights, icon_size = 64, tint = { 1, 1, 1, 0 } },
		{ icon = MENU .. "2dae66539132991103b6.png", icon_size = 64 },
		{ icon = MENU .. "2dae66539132991103b6.png", icon_size = 64, tint = { r = TIER3.r, g = TIER3.g, b = TIER3.b, a = 0.75 } },
		{ icon = "__reskins-library__/graphics/icons/tiers/rounded-rectangle/3.png", icon_size = 64 },
		{ icon = "__reskins-library__/graphics/icons/tiers/rounded-rectangle/3.png", icon_size = 64, tint = { r = TIER3.r, g = TIER3.g, b = TIER3.b, a = 0.75 } },
	}
end
local ICONS = {
	locomotive = icons("1b95d0f68036387cb4b5.png", "f9ca76040a613076ffff.png", "f0a36cbebdc56e780962.png"),
	["cargo-wagon"] = icons("ae4e585f3c6c8cf1fd12.png", "775e725c0e1edf81d858.png", "a0ecefc10743d27d5cce.png"),
	["fluid-wagon"] = icons("0e618e5cb98a807aab83.png", "b987919c8ed7dd51ff6e.png", "42c4cba143af32be697d.png"),
}

-- Сопротивления брони Mk1/Mk2 (boblogistics), четыре типа на ступень выше.
local RAISED = {
	physical = { decrease = 30, percent = 60 },
	explosion = { decrease = 30, percent = 60 },
	acid = { decrease = 25, percent = 40 },
	laser = { decrease = 15, percent = 60 },
}
-- boblogistics добавляет броне Mk1/Mk2 эти типы в своём data-updates по именам; копии — здесь, те же значения.
local BOB_EXTRA = {
	["bob-pierce"] = { decrease = 15, percent = 90 },
	["bob-plasma"] = { decrease = 25, percent = 90 },
}
local function resistances(source)
	local result = table.deepcopy(source or {})
	local present = {}
	for _, resistance in pairs(result) do
		present[resistance.type] = true
		local raised = RAISED[resistance.type]
		if raised then
			resistance.decrease = raised.decrease
			resistance.percent = raised.percent
		end
	end
	for damage, values in pairs(BOB_EXTRA) do
		if data.raw["damage-type"][damage] and not present[damage] then
			result[#result + 1] = { type = damage, decrease = values.decrease, percent = values.percent }
		end
	end
	return result
end

local STATS = {
	locomotive = {
		name = "bob-armoured-locomotive-3",
		grid = { name = "bob-armoured-locomotive-3", categories = { "train", "vehicle", "locomotive", "armoured-vehicle", "armoured-train", "armoured-locomotive" } },
		fields = {
			max_health = 12500,
			weight = 5000,
			max_power = "1600kW",
			max_speed = 1.6,
			reversing_power_modifier = 0.95,
			braking_force = 20,
			friction_force = 0.5,
			air_resistance = 0.0045,
		},
	},
	["cargo-wagon"] = {
		name = "bob-armoured-cargo-wagon-3",
		grid = { name = "bob-armoured-cargo-wagon-3", categories = { "train", "vehicle", "cargo-wagon", "armoured-vehicle", "armoured-train", "armoured-cargo-wagon" } },
		fields = {
			max_health = 7500,
			weight = 3500,
			inventory_size = 80,
			max_speed = 2,
			braking_force = 6,
			friction_force = 0.5,
			air_resistance = 0.005,
			quality_affects_inventory_size = feature_flags["quality"] or nil,
		},
	},
	["fluid-wagon"] = {
		name = "bob-armoured-fluid-wagon-3",
		grid = { name = "bob-armoured-wagon-4", categories = { "train", "vehicle", "armoured-vehicle", "armoured-train" } },
		fields = {
			max_health = 7500,
			weight = 3500,
			capacity = 50000,
			max_speed = 2,
			braking_force = 6,
			friction_force = 0.5,
			air_resistance = 0.01,
		},
	},
}

local prototypes = {}
for entity_type, stats in pairs(STATS) do
	local mk2 = MK2[entity_type]
	local entity = table.deepcopy(data.raw[entity_type][mk2])
	entity.name = stats.name
	entity.minable = { mining_time = (entity.minable and entity.minable.mining_time) or 0.5, result = stats.name }
	entity.placeable_by = nil
	entity.next_upgrade = nil
	entity.factoriopedia_alternative = nil
	entity.localised_name = nil
	entity.localised_description = nil
	entity.icon = nil
	entity.icon_size = nil
	entity.icons = table.deepcopy(ICONS[entity_type])
	for field, value in pairs(stats.fields) do
		entity[field] = value
	end
	entity.resistances = resistances(entity.resistances)
	entity.equipment_grid = stats.grid.name
	if entity_type == "locomotive" then
		entity.energy_source = table.deepcopy(entity.energy_source)
		entity.energy_source.effectivity = 1.3
		entity.energy_source.fuel_inventory_size = 5
	end

	local item = table.deepcopy(data.raw["item-with-entity-data"][mk2])
	item.name = stats.name
	item.place_result = stats.name
	item.localised_name = nil
	item.localised_description = nil
	item.icon = nil
	item.icon_size = nil
	item.icons = table.deepcopy(ICONS[entity_type])
	item.order = (item.order or "") .. "-3"

	local recipe = table.deepcopy(data.raw.recipe[mk2])
	recipe.name = stats.name
	recipe.enabled = false
	recipe.localised_name = nil
	recipe.icon = nil
	recipe.icon_size = nil
	recipe.icons = nil
	recipe.results = { { type = "item", name = stats.name, amount = 1 } }
	recipe.main_product = nil

	local grid = {
		type = "equipment-grid",
		name = stats.grid.name,
		width = 10,
		height = 10,
		equipment_categories = stats.grid.categories,
	}
	prototypes[#prototypes + 1] = entity
	prototypes[#prototypes + 1] = item
	prototypes[#prototypes + 1] = recipe
	if not data.raw["equipment-grid"][grid.name] then
		prototypes[#prototypes + 1] = grid
	end
end
data:extend(prototypes)

local function item(name, amount)
	return { type = "item", name = name, amount = amount }
end
data.raw.recipe["bob-armoured-locomotive-3"].ingredients = {
	item("bob-armoured-locomotive-2", 1),
	item("bob-advanced-processing-unit", 5),
	item("bob-nitinol-alloy", 25),
	item("bob-nitinol-gear-wheel", 20),
	item("bob-nitinol-bearing", 16),
	item("bob-copper-tungsten-alloy", 15),
}
data.raw.recipe["bob-armoured-cargo-wagon-3"].ingredients = {
	item("bob-armoured-cargo-wagon-2", 1),
	item("bob-nitinol-alloy", 25),
	item("bob-nitinol-gear-wheel", 12),
	item("bob-nitinol-bearing", 8),
	item("bob-copper-tungsten-alloy", 15),
}
data.raw.recipe["bob-armoured-fluid-wagon-3"].ingredients = {
	item("bob-armoured-fluid-wagon-2", 1),
	item("bob-storage-tank-4", 1),
	item("bob-nitinol-alloy", 25),
	item("bob-copper-tungsten-pipe", 8),
	item("bob-nitinol-bearing", 12),
	item("bob-copper-tungsten-alloy", 15),
}

local PACKS = {
	{ "automation-science-pack", 1 },
	{ "logistic-science-pack", 1 },
	{ "chemical-science-pack", 1 },
	{ "production-science-pack", 1 },
	{ "bob-advanced-logistic-science-pack", 1 },
	{ "utility-science-pack", 1 },
}
data:extend({
	{
		type = "technology",
		name = "bob-armoured-railway-3",
		icon = "__base__/graphics/technology/railway.png",
		icon_size = 256,
		effects = {
			{ type = "unlock-recipe", recipe = "bob-armoured-locomotive-3" },
			{ type = "unlock-recipe", recipe = "bob-armoured-cargo-wagon-3" },
		},
		prerequisites = {
			"bob-armoured-railway-2",
			"bob-railway-3",
			"bob-nitinol-processing",
			"bob-advanced-processing-unit",
			"angels-copper-tungsten-smelting-1",
		},
		unit = { count = 250, time = 30, ingredients = table.deepcopy(PACKS) },
		order = "c-g-a-a-3",
	},
	{
		type = "technology",
		name = "bob-armoured-fluid-wagon-3",
		icon = "__base__/graphics/technology/fluid-wagon.png",
		icon_size = 256,
		effects = {
			{ type = "unlock-recipe", recipe = "bob-armoured-fluid-wagon-3" },
		},
		prerequisites = {
			"bob-armoured-fluid-wagon-2",
			"bob-armoured-railway-3",
			"bob-fluid-wagon-3",
			"bob-fluid-handling-4",
		},
		unit = { count = 250, time = 30, ingredients = table.deepcopy(PACKS) },
		order = "c-g-a-b-a-3",
	},
})
