local function MakeCharger(name)
	return {
		type = "item",
		name = name,
		icon = graphics_path..name.."-icon.png",
		icon_size = 32,
		subgroup = name_group_chargers,
		order = "b",
		place_result = name,
		stack_size = 50,
	}
end

data:extend({
	{
		type = "item-with-entity-data",
		name = name_locomotive,
		icon = graphics_path..name_locomotive.."-icon.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = name_group_chargers,
		order = "a",
		place_result = name_locomotive,
		stack_size = 5,
	},
	MakeCharger(name_chg1),
	MakeCharger(name_chg2),
	MakeCharger(name_chg3),
	MakeCharger(name_chg1t),
	MakeCharger(name_chg2t),
	MakeCharger(name_chg3t),
})


local function EmptyFuel(output)
	return {
		type		= "item",
		name		= output.."-empty",
		icon		= graphics_path..output.."-empty-icon.png",
		icon_size	= 64,
		icon_mipmaps	= 4,
		stack_size	= 1,
		subgroup	= name_group_batteries,
		order		= "a",
	}
end

local vanilla_stacks = 3
local vloc = data.raw["locomotive"]["locomotive"]
if vloc and vloc.burner and vloc.burner.fuel_inventory_size and vloc.burner.fuel_inventory_size > 0 then
	vanilla_stacks = vloc.burner.fuel_inventory_size
end

local function FullFuel(infuel, output)
	return {
		type		= "item",
		name		= output.."-full",
		icon		= graphics_path..output.."-full-icon.png",
		icon_size	= 64,
		icon_mipmaps	= 4,
		burnt_result	= output.."-empty",
		fuel_category	= name_cat_fuel_battery,
		fuel_value	= (vanilla_stacks * infuel.stack_size * util.parse_energy(infuel.fuel_value)).."J",
		fuel_acceleration_multiplier = infuel.fuel_acceleration_multiplier,
		fuel_top_speed_multiplier    = infuel.fuel_top_speed_multiplier,
		stack_size	= 1,
		subgroup	= name_group_batteries,
		order		= "b",
	}
end

local items = data.raw["item"]

local function AddFuel(input, output, fval, mulacc, multop, stacksize)
	local infuel = items[input]

	if not infuel then
		log("Vanilla fuel '"..input.."' not found. Using equivalent dummy item.")
		infuel = {
			fuel_value = fval,
			fuel_acceleration_multiplier = mulacc,
			fuel_top_speed_multiplier = multop,
			stack_size = stacksize,
		}
	end

	data:extend({
		EmptyFuel(output),
		FullFuel(infuel, output),
	})
end

AddFuel("coal",		name_fuel1,    "4MJ", nil,  nil, 50)
AddFuel("solid-fuel",	name_fuel2,   "12MJ", 1.2, 1.05, 50)
AddFuel("rocket-fuel",	name_fuel3,  "100MJ", 1.8, 1.15, 10)
AddFuel("nuclear-fuel",	name_fuel4, "1.21GJ", 2.5, 1.15,  1)
