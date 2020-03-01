--items.lua

-- assuming this is called from data.lua only
require("copy_prototype")
require("logic.modular_locomotive")

-- Add electric train subgroup
local train_group = "logistics"
if mods["SchallTransportGroup"] then
	train_group = "transport"
end

-- Add electric train subgroup
data:extend{{
	type = "item-subgroup",
	name = "electric-trains",
	group = train_group,
	order = "e-a"
}}

data:extend{{
	type = "item-subgroup",
	name = "electric-train-modules",
	group = train_group,
	order = "e-b"
}}

-- Placer

local simple_pole_placer = {
	type = "item",
	name = "ret-pole-placer",
	icon = graphics .. "items/power-pole.png",
	icon_size = 32,
	place_result = "ret-pole-placer",
	stack_size = 50,
	subgroup = "electric-trains",
	order = "a[poles]-a"
}

local signal_pole_placer = {
	type = "item",
	name = "ret-signal-pole-placer",
	icon = graphics .. "items/signal-pole.png",
	icon_size = 32,
	place_result = "ret-signal-pole-placer",
	stack_size = 50,
	subgroup = "electric-trains",
	order = "a[poles]-b"
}

local chain_pole_placer = {
	type = "item",
	name = "ret-chain-pole-placer",
	icon = graphics .. "items/chain-pole.png",
	icon_size = 32,
	place_result = "ret-chain-pole-placer",
	stack_size = 50,
	subgroup = "electric-trains",
	order = "a[poles]-c"
}

local pole_debugger = {
	type = "selection-tool",
	name = "ret-pole-debugger",
	icon = graphics .. "items/pole-debugger.png",
	icon_size = 32,
	stack_size = 5,
	selection_color = {b = 1.0, g = 0.5},
	alt_selection_color = {b = 1.0, g = 0.5},
	selection_mode = {"blueprint"},
	alt_selection_mode = {"blueprint"},
	selection_cursor_box_type = "electricity",
	alt_selection_cursor_box_type = "electricity",
	subgroup = "electric-trains",
	order = "a[poles]-d"
}

data:extend{simple_pole_placer, signal_pole_placer, chain_pole_placer, pole_debugger}

--==============================================================================

-- Electric locomotive

local electric_locomotive = {
	type = "item-with-entity-data",
	name = "ret-electric-locomotive",
	icon = graphics .. "items/electric-locomotive.png",
	icon_size = 32,
	place_result = "ret-electric-locomotive",
	stack_size = 5,
	subgroup = "electric-trains",
	order = "b[locomotives]-a"
}

local electric_locomotive_mk2 = {
	type = "item-with-entity-data",
	name = "ret-electric-locomotive-mk2",
	icon = graphics .. "items/electric-locomotive-2.png",
	icon_size = 32,
	place_result = "ret-electric-locomotive-mk2",
	stack_size = 5,
	subgroup = "electric-trains",
	order = "b[locomotives]-b"
}

local modular_locomotive = {
	type = "item-with-entity-data",
	name = "ret-modular-locomotive",
	icon = graphics .. "items/modular-locomotive.png",
	icon_size = 32,
	place_result = "ret-modular-locomotive",
	stack_size = 5,
	subgroup = "electric-trains",
	order = "b[locomotives]-c"
}

data:extend{electric_locomotive, electric_locomotive_mk2, modular_locomotive}

--==============================================================================

-- Train modules

local train_speed_module = {
	type = "item",
	name = "ret-train-speed-module",
	icon = graphics .. "items/train-speed-module.png",
	icon_size = 32,
	placed_as_equipment_result = "ret-train-speed-module",
	stack_size = 20,
	subgroup = "electric-train-modules",
	order = "a"
}

local train_productivity_module = {
	type = "item",
	name = "ret-train-productivity-module",
	icon = graphics .. "items/train-productivity-module.png",
	icon_size = 32,
	placed_as_equipment_result = "ret-train-productivity-module",
	stack_size = 20,
	subgroup = "electric-train-modules",
	order = "c"
}

local train_efficiency_module = {
	type = "item",
	name = "ret-train-efficiency-module",
	icon = graphics .. "items/train-efficiency-module.png",
	icon_size = 32,
	placed_as_equipment_result = "ret-train-efficiency-module",
	stack_size = 20,
	subgroup = "electric-train-modules",
	order = "b"
}

local train_battery_module = {
	type = "item",
	name = "ret-train-battery-module",
	icon = graphics .. "items/train-battery-module.png",
	icon_size = 32,
	placed_as_equipment_result = "ret-train-battery-module",
	stack_size = 20,
	subgroup = "electric-train-modules",
	order = "d"
}

data:extend{train_speed_module, train_productivity_module, train_efficiency_module,
			train_battery_module}

--==============================================================================

-- Dummy items

local dummy_pole_energy = {
	type = "item",
	name = "ret-dummy-pole-energy",
	icon = graphics .. "items/pole-wire.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1
}

local dummy_pole_holder = {
	type = "item",
	name = "ret-dummy-pole-holder",
	icon = graphics .. "items/pole-wire.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1
}

data:extend{{
	type = "fuel-category",
	name = "dummy"
}}

local dummy_fuel_1 = {
	type = "item",
	name = "ret-dummy-fuel-1",
	icon = graphics .. "items/dummy-fuel.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1,
	fuel_category = "dummy",
	fuel_value = toJ(config.locomotive_storage),
	fuel_acceleration_multiplier = 1.5,
	fuel_top_speed_multiplier = 1.0,
	fuel_emission_multiplier = 0.1
	-- For Locomotive Mk1
	-- Adjusted acceleration: 150%
}

local dummy_fuel_2 = {
	type = "item",
	name = "ret-dummy-fuel-2",
	icon = graphics .. "items/dummy-fuel.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1,
	fuel_category = "dummy",
	fuel_value = toJ(config.advanced_locomotive_storage),
	fuel_acceleration_multiplier = 1.0,
	fuel_top_speed_multiplier = 1.0,
	fuel_emission_multiplier = 0.1
	-- For Locomotive Mk2
	-- Adjusted acceleration: 200%
}

data:extend{dummy_pole_energy, dummy_pole_holder, dummy_fuel_1, dummy_fuel_2}


-- Generate dummy fuel items for the modular locomotive
-- Adjusted base acceleration: 300%

for s = 0, 4 do
	for p = 0, 4 - s do
		for e = 0, 4 - s - p do
			for b = 0, 4 - s - p - e do
				if s + p + e + b <= 4 then
					local name = get_module_string(s, p, e, b)
					local stats = get_module_stats(s, p, e, b)

					local item = {
						type = "item",
						name = "ret-dummy-fuel-modular-" .. name,
						icon = graphics .. "items/dummy-fuel.png",
						icon_size = 32,
						flags = { "hidden" },
						stack_size = 1,
						fuel_category = "dummy",
						-- The power factor can't be added to the locomotive directly,
						-- therefore we multiply it in during the recharge process.
						-- The internal fuel value is displayed_power / power_factor
						fuel_value = toJ(config.modular_locomotive_storage + stats.storage / stats.power),
						fuel_acceleration_multiplier = stats.acceleration,
						fuel_top_speed_multiplier = stats.speed,
						fuel_emission_multiplier = 0.1
					}

					data:extend{item}
				end
			end
		end
	end
end


