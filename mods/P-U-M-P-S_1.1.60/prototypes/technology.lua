------------------
---- data.lua ----
------------------

-- Settings host
local water_pumpjack_enabled = settings.startup["osm-pumps-enable-ground-water-pumpjacks"].value

local offshore_techs =
{
	"offshore-pump-2",
	"offshore-pump-3",
	"offshore-pump-4"
}

local pumpjack_techs =
{
	"water-pumpjack-1",
	"water-pumpjack-2",
	"water-pumpjack-3",
	"water-pumpjack-4",
	"water-pumpjack-5"
}

-- Offshore pump 1
OSM.lib.technology_add_unlock("offshore-pump-1", "fluid-handling")

-- Offshore pump 2
local offshore_pump_2 =
{
	type = "technology",
	name = "offshore-pump-2",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-2.png",
	prerequisites = {"fluid-handling"},
	effects ={{type = "unlock-recipe", recipe = "offshore-pump-2"}},
	unit =
	{
		count = 50,
		ingredients =
		{
			{name="automation-science-pack", amount = 1},
			{name="logistic-science-pack", amount = 1}
		},
		time = 30
	},
	order = "d-a-a"
}	data:extend({offshore_pump_2})

-- Offshore pump 3
local offshore_pump_3 =
{
	type = "technology",
	name = "offshore-pump-3",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-3.png",
	effects = {{type = "unlock-recipe", recipe = "offshore-pump-3"}},
	prerequisites = {"offshore-pump-2", "advanced-electronics"},
	unit =
	{
		count = 75,
		ingredients =
		{
			{name = "automation-science-pack", amount = 1},
			{name = "logistic-science-pack", amount = 1},
			{name = "chemical-science-pack", amount = 1}
		},
		time = 30
	},
	order = "d-a-b"
}	data:extend({offshore_pump_3})

-- Offshore pump 4
local offshore_pump_4 =
{
	type = "technology",
	name = "offshore-pump-4",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-4.png",
	effects = {{type = "unlock-recipe", recipe = "offshore-pump-4"}},
	prerequisites = {"offshore-pump-3", "advanced-electronics-2"},
	unit =
	{
		count = 100,
		ingredients =
			{
				{name = "automation-science-pack", amount = 1},
				{name = "logistic-science-pack", amount = 1},
				{name = "chemical-science-pack", amount = 1},
				{name = "production-science-pack", amount = 1}
			},
		time = 30
	},
	order = "d-a-b"
}	data:extend({offshore_pump_4})

-- Assign locales
for _, tech in pairs (offshore_techs) do
	if data.raw.technology[tech] then
		if settings.startup["osm-pumps-burner-offshore-pump"].value == true then -- Burner check
			data.raw.technology[tech].localised_name = {"technology-name."..tech.."-brn"}
		else
			data.raw.technology[tech].localised_name = {"technology-name."..tech.."-pwr"}
		end
		data.raw.technology[tech].localised_description = {"technology-description."..tech}
	end
end

-- Water pumpjacks
if water_pumpjack_enabled then

	-- Water pumpjack 1
	local water_pumpjack_1 =
	{
		type = "technology",
		name = "water-pumpjack-1",
		icon_size = 256,
		icon_mipmaps = 4,
		icon = "__P-U-M-P-S__/graphics/technology/water-pumpjack.png",
		prerequisites = {},
		unit =
		{
		count = 10,
		time = 30,
		ingredients =
		{
			{name = "automation-science-pack", amount = 1}
		}
	},
		effects =
		{
		{type = "unlock-recipe", recipe = "water-pumpjack-1"}
	},
		order = "d-a-d-1",
	}	data:extend({water_pumpjack_1})
	
	-- Water pumpjack 2
	local water_pumpjack_2 =
	{
		type = "technology",
		name = "water-pumpjack-2",
		icon = "__P-U-M-P-S__/graphics/technology/water-pumpjack.png",
		icon_size = 256,
		icon_mipmaps = 4,	
		order = "d-a-d-2",
		prerequisites =
		{
		"water-pumpjack-1",
		"steel-processing",
		"electronics"
	},
		unit =
		{
		count = 30,
		time = 30,
		ingredients =
		{
			{"automation-science-pack", 1},
		},
	},
		effects =
		{
			{type="unlock-recipe", recipe="water-pumpjack-2"}
		}
	}	data:extend({water_pumpjack_2})
	
	-- Water pumpjack 3
	local water_pumpjack_3 =
	{
		type = "technology",
		name = "water-pumpjack-3",
		icon = "__P-U-M-P-S__/graphics/technology/water-pumpjack.png",
		icon_size = 256,
		icon_mipmaps = 4,
		order = "d-a-d-3",
		prerequisites =
		{
		"water-pumpjack-2",
		"advanced-electronics"
	},
		unit =
		{
		count = 50,
		time = 30,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
		},
	},
		effects =
		{
			{type="unlock-recipe", recipe="water-pumpjack-3"}
		},
	}	data:extend({water_pumpjack_3})
	
	-- Water pumpjack 4
	local water_pumpjack_4 =
	{
		type = "technology",
		name = "water-pumpjack-4",
		icon = "__P-U-M-P-S__/graphics/technology/water-pumpjack.png",
		icon_size = 256,
		icon_mipmaps = 4,
		order = "d-a-d-4",
		prerequisites =
		{
		"water-pumpjack-3",
		"advanced-electronics-2"
	},
		unit =
		{
		count = 75,
		time = 30,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
		},
	},
		effects =
		{
			{type="unlock-recipe", recipe="water-pumpjack-4"}
		},
	}	data:extend({water_pumpjack_4})
	
	-- Water pumpjack 5
	local water_pumpjack_5 =
	{
		type = "technology",
		name = "water-pumpjack-5",
		icon = "__P-U-M-P-S__/graphics/technology/water-pumpjack.png",
		icon_size = 256,
		icon_mipmaps = 4,
		order = "d-a-d-5",
		prerequisites =
		{
		"water-pumpjack-4",
	},
		unit =
		{
		count = 100,
		time = 30,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"production-science-pack", 1},
		},
	},
		effects =
		{
			{type="unlock-recipe", recipe="water-pumpjack-5"}
		}
	}	data:extend({water_pumpjack_5})

	-- Assign locales
	for _, tech in pairs (pumpjack_techs) do
		if data.raw.technology[tech] then
			data.raw.technology[tech].localised_description = {"technology-description."..tech}
		end
	end
end