------------------
---- data.lua ----
------------------

-- Burner offshore pump
local offshore_pump_0 =
{
	type = "recipe",
	name = "offshore-pump-0",
	enabled = true,
	ingredients =
	{
		{type = "item", name = "stone-furnace", amount = 1},
		{type = "item", name = "iron-plate", amount = 16},
		{type = "item", name = "motor", amount = 2},
		{type = "item", name = "iron-gear-wheel", amount = 4}
	},
	result = "offshore-pump-0"
}	data:extend({offshore_pump_0})

-- Offshore pump 1
local offshore_pump_1 =
{
	type = "recipe",
	name = "offshore-pump-1",
	enabled = false,
	ingredients =
	{
		{type = "item", name = "basic-circuit-board", amount = 5},
		{type = "item", name = "pipe", amount = 15},
		{type = "item", name = "electric-motor", amount = 4},
		{type = "item", name = "offshore-pump-0", amount = 2}
	},
	result = "offshore-pump-1"
}	data:extend({offshore_pump_1})

-- Offshore pump 2
local offshore_pump_2 =
{
	type = "recipe",
	name = "offshore-pump-2",
	enabled = false,
	ingredients =
	{																				-- BOB --
		{type = "item", name = "electronic-circuit", amount = 5},	--[[-------{"advanced-circuit"}-------]]
		{type = "item", name = "steel-plate", amount = 15},			--[[----------{"steel-pipe"}----------]]
		{type = "item", name = "iron-gear-wheel", amount = 12},		--[[-------{"steel-gear-wheel"}-------]]
		{type = "item", name = "electric-motor", amount = 10},
		{type = "item", name = "offshore-pump-1", amount = 2}
	},
	result = "offshore-pump-2"
}	data:extend({offshore_pump_2})

-- Offshore pump 3
local offshore_pump_3 =
{
	type = "recipe",
	name = "offshore-pump-3",
	enabled = false,
	ingredients =
	{																				-- BOB --
		{type = "item", name = "advanced-circuit", amount = 5},		--[[-------{"processing-unit"}-------]]
		{type = "item", name = "steel-plate", amount = 15},			--[[--------{"titanium-pipe"}--------]]
		{type = "item", name = "iron-gear-wheel", amount = 12},		--[[-----{"titanium-gear-wheel"}-----]]
		{type = "item", name = "engine-unit", amount = 4},
		{type = "item", name = "offshore-pump-2", amount = 2}
	},
	result = "offshore-pump-3"
}	data:extend({offshore_pump_3})

-- Offshore pump 4
local offshore_pump_4 =
{
	type = "recipe",
	name = "offshore-pump-4",
	enabled = false,
	ingredients =
	{																				-- BOB --
		{type = "item", name = "processing-unit", amount = 2},		--[[---{"advanced-processing-unit"}---]]
		{type = "item", name = "steel-plate", amount = 15},			--[[---------{"nitinol-pipe"}---------]]
		{type = "item", name = "iron-gear-wheel", amount = 12},		--[[------{"nitinol-gear-wheel"}------]]
		{type = "item", name = "electric-engine-unit", amount = 4},
		{type = "item", name = "offshore-pump-3", amount = 2}
	},
	result = "offshore-pump-4"
}	data:extend({offshore_pump_4})

-- Water pumpjack
--[[
local water_pumpjack =
{
	type = "recipe",
	name = "water-pumpjack-1",
	enabled = false,
	ingredients =
	{
		{type = "item", name = "iron-plate", amount = 10},
		{type = "item", name = "iron-gear-wheel", amount = 10},
		{type = "item", name = "pipe", amount = 10},
		{type = "item", name = "electronic-circuit", amount = 5},
	},
	result = "water-pumpjack-1"
}	data:extend({water_pumpjack})
]]--