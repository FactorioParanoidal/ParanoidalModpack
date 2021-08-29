------------------
---- data.lua ----
------------------

-- Fetch functions from library
--local add_tech_recipe = require ("utils.lib").add_tech_recipe

-- Offshore pump 1
--add_tech_recipe ("fluid-handling", "offshore-pump-1")
local offshore_technology_pump_1 =
{
	type = "technology",
	name = "offshore-pump-tech_1",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-1.png",
	prerequisites = {"basic-fluid-handling"},
	effects ={{type = "unlock-recipe", recipe = "offshore-pump-1"}},
	unit =
	{
		count = 50,
		ingredients =
		{
			{name="automation-science-pack", amount = 1}
		},
		time = 30
	},
	order = "d-a-a"
}	data:extend({offshore_technology_pump_1})



-- Offshore pump 2
local offshore_technology_pump_2 =
{
	type = "technology",
	name = "offshore-pump-tech_2",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-2.png",
	prerequisites = {"offshore-pump-tech_1", "fluid-handling"},
	effects ={{type = "unlock-recipe", recipe = "offshore-pump-2"}},
	unit =
	{
		count = 50,
		ingredients =
		{
			{name="automation-science-pack", amount = 2},
			{name="logistic-science-pack", amount = 1}
		},
		time = 60
	},
	order = "d-a-b"
}	data:extend({offshore_technology_pump_2})

-- Offshore pump 3
local offshore_technology_pump_3 =
{
	type = "technology",
	name = "offshore-pump-tech_3",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-3.png",
	effects = {{type = "unlock-recipe", recipe = "offshore-pump-3"}},
	prerequisites = {"offshore-pump-tech_2", "electronics"},
	unit =
	{
		count = 100,
		ingredients =
		{
			{name = "automation-science-pack", amount = 1},
			{name = "logistic-science-pack", amount = 2},
			{name = "chemical-science-pack", amount = 1}
		},
		time = 60
	},
	order = "d-a-b"
}	data:extend({offshore_technology_pump_3})

-- Offshore pump 4
local offshore_technology_pump_4 =
{
	type = "technology",
	name = "offshore-pump-tech_4",
	icon_size = 256,
	icon_mipmaps = 4,
	icon = "__P-U-M-P-S__/graphics/technology/offshore-pump-4.png",
	effects = {{type = "unlock-recipe", recipe = "offshore-pump-4"}},
	prerequisites = {"offshore-pump-tech_3", "advanced-electronics"},
	unit =
	{
		count = 200,
		ingredients =
			{
				{name = "automation-science-pack", amount = 1},
				{name = "logistic-science-pack", amount = 2},
				{name = "chemical-science-pack", amount = 1},
				{name = "production-science-pack", amount = 1}
			},
		time = 60
	},
	order = "d-a-b"
}	data:extend({offshore_technology_pump_4})

-- Water pumpjack
--[[
local ground_water_treatment =
{
	type = "technology",
	name = "water-pumpjack",
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
}	data:extend({ground_water_treatment})
]]--