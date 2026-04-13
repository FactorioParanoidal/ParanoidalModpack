local items = data.raw["item"]

local fuel_value_cache = {}
local function get_fuel_value(name)
	local value = fuel_value_cache[name]

	if not value then
		value = util.parse_energy(items[name.."-full"].fuel_value)
		fuel_value_cache[name] = value
	end

	return value
end

local battery_capacity = 4000000

local ingr_advc = {type = "item", name = "advanced-circuit",      amount = 1}
local ingr_proc = {type = "item", name = "processing-unit",       amount = 1}
local ingr_lowd = {type = "item", name = "low-density-structure", amount = 1}
local ingr_effm = {type = "item", name = "efficiency-module-3",   amount = 1}

local function MakeBatteryRecipe(name)
	local level = tonumber(name:sub(-1))
	local item_name = name.."-empty"

	local ingr = {
		{type = "item", name = "battery",     amount = math.floor(get_fuel_value(name) / battery_capacity + 0.9)},
		{type = "item", name = "steel-plate", amount = 2 * level},
		ingr_advc,
	}

	if level >= 2 then ingr[4] = ingr_proc end
	if level >= 3 then ingr[5] = ingr_lowd end
	if level >= 4 then ingr[6] = ingr_effm end

	return {
		type = "recipe",
		name = item_name,
		enabled = false,
		energy_required = 5*level,
		ingredients = ingr,
		results = {{type = "item", name = item_name, amount = 1}},
		allow_productivity = false,
		allow_quality = false,
	}
end


local charging_power = util.parse_energy(data.raw["furnace"][name_chg1].energy_usage) * 60 -- parse_energy() returns consumption per tick, so multiply with 60

local function MakeChargingRecipe(name)
	local item_name = name.."-full"

	return {
		type = "recipe",
		name = item_name,
		category = name_cat_recipe_chg,
		enabled = false,
		energy_required = math.floor(get_fuel_value(name) / charging_power / settings.startup[setting_charging_efficiency].value + 0.99),
		ingredients = {{type = "item", name = name.."-empty", amount = 1}},
		results = {{type = "item", name = item_name, amount = 1}},
		allow_decomposition = false,
		allow_productivity = false,
		allow_quality = false,
	}
end


local function MakeTertiaryChargerRecipe(basename, tname)
	return {
		type = "recipe",
		name = tname,
		enabled = false,
		energy_required = 5,
		ingredients = {
			{type = "item", name = basename,     amount = 1},
			{type = "item", name = "substation", amount = 1},
		},
		results = {{type = "item", name = tname, amount = 1}},
	}
end


data:extend({
	{
		type = "recipe",
		name = name_locomotive,
		energy_required = 4,
		enabled = false,
		ingredients = {
			{type = "item", name = "electric-engine-unit", amount = 16},
			{type = "item", name = "electronic-circuit",   amount = 20},
			{type = "item", name = "advanced-circuit",     amount =  5},
			{type = "item", name = "steel-plate",          amount = 30},
		},
		results = {{type = "item", name = name_locomotive, amount = 1}},
	},
	{
		type = "recipe",
		name = name_chg1,
		enabled = false,
		energy_required = 10,
		ingredients = {
			{type = "item", name = "steel-plate",        amount = 10},
			{type = "item", name = "copper-cable",       amount =  5},
			{type = "item", name = "electronic-circuit", amount =  5},
			{type = "item", name = "advanced-circuit",   amount =  5},
		},
		results = {{type = "item", name = name_chg1, amount = 1}},
	},
	{
		type = "recipe",
		name = name_chg2,
		enabled = false,
		energy_required = 15,
		ingredients = {
			{type = "item", name = name_chg1,            amount =  1},
			{type = "item", name = "copper-cable",       amount = 10},
			{type = "item", name = "electronic-circuit", amount = 10},
			{type = "item", name = "advanced-circuit",   amount = 10},
			{type = "item", name = "speed-module",       amount =  1},
		},
		results = {{type = "item", name = name_chg2, amount = 1}},
	},
	{
		type = "recipe",
		name = name_chg3,
		enabled = false,
		energy_required = 20,
		ingredients = {
			{type = "item", name = name_chg2,            amount =  1},
			{type = "item", name = "copper-cable",       amount = 20},
			{type = "item", name = "electronic-circuit", amount = 20},
			{type = "item", name = "advanced-circuit",   amount = 20},
			{type = "item", name = "speed-module-2",     amount =  1},
		},
		results = {{type = "item", name = name_chg3, amount = 1}},
	},
	MakeTertiaryChargerRecipe(name_chg1, name_chg1t),
	MakeTertiaryChargerRecipe(name_chg2, name_chg2t),
	MakeTertiaryChargerRecipe(name_chg3, name_chg3t),
	MakeBatteryRecipe(name_fuel1),
	MakeBatteryRecipe(name_fuel2),
	MakeBatteryRecipe(name_fuel3),
	MakeBatteryRecipe(name_fuel4),
	MakeChargingRecipe(name_fuel1),
	MakeChargingRecipe(name_fuel2),
	MakeChargingRecipe(name_fuel3),
	MakeChargingRecipe(name_fuel4),
})

if settings.startup[setting_recycling].value then
	local function MakeRecyclingRecipe(name)
		local level = tonumber(name:sub(-1))

		return {
			type = "recipe",
			name = name.."-recycling",
			icon = graphics_path..name.."-recycling-icon.png",
			icon_size = 64,
			subgroup = name_group_batteries,
			order = "c",
			category = "advanced-crafting",
			enabled = false,
			energy_required = 5*level,
			ingredients = {{type = "item", name = name.."-empty", amount = 1}},
			results = {{type = "item", name = "battery", amount = math.floor(get_fuel_value(name) / battery_capacity * 0.9)}},
			hide_from_stats = true,
			allow_as_intermediate = false, -- don't allow as intermediate, hand-crafting not allowed anyway (fixes incompatibility with Industrial Revolution 2)
			allow_decomposition = false,
			allow_productivity = false,
			allow_quality = false,
			main_product = "",
		}
	end

	data:extend({
		MakeRecyclingRecipe(name_fuel1),
		MakeRecyclingRecipe(name_fuel2),
		MakeRecyclingRecipe(name_fuel3),
		MakeRecyclingRecipe(name_fuel4),
	})
end
