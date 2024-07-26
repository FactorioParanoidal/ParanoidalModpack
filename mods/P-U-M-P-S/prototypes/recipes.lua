------------------
---- data.lua ----
------------------

-- Settings host
local water_pumpjack_enabled = settings.startup["osm-pumps-enable-ground-water-pumpjacks"].value

-- Burner offshore pump
local offshore_pump_0 =
{
	type = "recipe",
	name = "offshore-pump-0",
	ingredients =
	{
		{"stone-brick", 5},
		{"pipe", 1},
		{"iron-gear-wheel", 5}
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
		{"electronic-circuit", 2},
		{"pipe", 1},
		{"iron-gear-wheel", 5}
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
		{"advanced-circuit", 2},	--[[-------{"advanced-circuit"}-------]]
		{"steel-plate", 2},			--[[----------{"steel-pipe"}----------]]
		{"iron-gear-wheel", 5},		--[[-------{"steel-gear-wheel"}-------]]
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
		{"advanced-circuit", 2},	--[[-------{"processing-unit"}-------]]
		{"steel-plate", 4},			--[[--------{"titanium-pipe"}--------]]
		{"iron-gear-wheel", 5},		--[[-----{"titanium-gear-wheel"}-----]]
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
		{"processing-unit", 2},		--[[---{"advanced-processing-unit"}---]]
		{"steel-plate", 8},			--[[---------{"nitinol-pipe"}---------]]
		{"iron-gear-wheel", 5},		--[[------{"nitinol-gear-wheel"}------]]
	},
	result = "offshore-pump-4"
}	data:extend({offshore_pump_4})

-- Water pumpjacks
if water_pumpjack_enabled then

	-- Water pumpjack 1
	local water_pumpjack_1 =
	{
		type = "recipe",
		name = "water-pumpjack-1",
		enabled = false,
		ingredients =
		{
			{"iron-plate", 10},
			{"iron-gear-wheel", 10},
			{"pipe", 10},
			{"electronic-circuit", 5}
		},
		result = "water-pumpjack-1"
	}	data:extend({water_pumpjack_1})
	
	-- Water pumpjack 2
	local water_pumpjack_2 =
	{
		type = "recipe",
		name = "water-pumpjack-2",
		energy_required = 2,
		ingredients =
		{
			{"water-pumpjack-1", 1},
			{"steel-plate", 10},
			{"iron-gear-wheel", 10},
			{"electronic-circuit", 5},
			{"pipe", 10}
		},
		result = "water-pumpjack-2",
		enabled = false
	}	data:extend({water_pumpjack_2})
	
	-- Water pumpjack 3
	local water_pumpjack_3 =
	{
		type = "recipe",
		name = "water-pumpjack-3",
		energy_required = 2,
		ingredients =
		{
			{"water-pumpjack-2", 1},
			{"steel-plate", 10},
			{"iron-gear-wheel", 10},
			{"advanced-circuit", 5},
			{"pipe", 10}
		},
		result = "water-pumpjack-3",
		enabled = false
	}	data:extend({water_pumpjack_3})
	
	-- Water pumpjack 4
	local water_pumpjack_4 =
	{
		type = "recipe",
		name = "water-pumpjack-4",
		energy_required = 2,
		ingredients =
		{
			{"water-pumpjack-3", 1},
			{"steel-plate", 10},
			{"iron-gear-wheel", 10},
			{"processing-unit", 5},
			{"pipe", 10}
		},
		result = "water-pumpjack-4",
		enabled = false
	}	data:extend({water_pumpjack_4})
	
	-- Water pumpjack 5
	local water_pumpjack_5 =
	{
		type = "recipe",
		name = "water-pumpjack-5",
		energy_required = 2,
		ingredients =
		{
			{"water-pumpjack-4", 1},
			{"steel-plate", 10},
			{"iron-gear-wheel", 10},
			{"processing-unit", 5},
			{"pipe", 10}
		},
		result = "water-pumpjack-5",
		enabled = false
	}	data:extend({water_pumpjack_5})
end