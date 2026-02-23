-- Fetch external properties
local ofshore_pump_template = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])

-- base create
local function CreateOffshorePump(pumpName, energySource, energyUsage, pumpingSpeed)
	local pump = table.deepcopy(ofshore_pump_template)
	pump.name = pumpName
	pump.minable = { mining_time = 1, result = pumpName }
	pump.energy_source = energySource
	pump.energy_usage = energyUsage
	pump.pumping_speed = pumpingSpeed
	data:extend({ pump })
end

local energySources = {
	burner = {
		type = "burner",
		fuel_categories = { "chemical" },
		effectivity = 1,
		fuel_inventory_size = 1,
		emissions_per_minute = { pollution = 9 },
	},
	electric = {
		type = "electric",
		usage_priority = "secondary-input",
		emissions_per_minute = { pollution = 1 },
	},
}

CreateOffshorePump("offshore-mk0-pump", energySources.burner, "900kW", 5)
CreateOffshorePump("offshore-pump", energySources.electric, "1200kW", 10)
CreateOffshorePump("offshore-mk2-pump", energySources.electric, "2000kW", 20)
CreateOffshorePump("offshore-mk3-pump", energySources.electric, "2800kW", 40)
CreateOffshorePump("offshore-mk4-pump", energySources.electric, "3700kW", 80)

-- tweak default (mk1) pump
bobmods.lib.recipe.set_ingredients("offshore-pump", {
	{ type = "item", name = "electronic-circuit", amount = 2 },
	{ type = "item", name = "pipe", amount = 5 },
	{ type = "item", name = "iron-gear-wheel", amount = 5 },
})
bobmods.lib.tech.add_recipe_unlock("electronics", "offshore-pump")
