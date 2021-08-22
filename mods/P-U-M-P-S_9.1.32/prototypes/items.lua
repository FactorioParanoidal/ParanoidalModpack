------------------
---- data.lua ----
------------------

-- Sets entity place results
local place_result_0
local place_result_1
local place_result_2
local place_result_3
local place_result_4

if settings.startup["enable-power"].value == true then
	place_result_0 = "offshore-pump-0-placeholder"
	place_result_1 = "offshore-pump-1-placeholder"
	place_result_2 = "offshore-pump-2-placeholder"
	place_result_3 = "offshore-pump-3-placeholder"
	place_result_4 = "offshore-pump-4-placeholder"
else
	place_result_0 = "offshore-pump-0"
	place_result_1 = "offshore-pump-1"
	place_result_2 = "offshore-pump-2"
	place_result_3 = "offshore-pump-3"
	place_result_4 = "offshore-pump-4"
end

-- Burner offshore pump
local offshore_pump_0 =
{
	type = "item",
	name = "offshore-pump-0",
	icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-0.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "extraction-machine",
	order = "b[fluids]-a[offshore-pump-0]",
	place_result = place_result_0,
	stack_size = 20,
}	data:extend({offshore_pump_0})

-- Offshore pump 1
local offshore_pump_1 =
{
	type = "item",
	name = "offshore-pump-1",
	icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-1.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "extraction-machine",
	order = "b[fluids]-a[offshore-pump-1]",
	place_result = place_result_1,
	stack_size = 20,
}	data:extend({offshore_pump_1})

-- Offshore pump 2
local offshore_pump_2 =
{
	type = "item",
	name = "offshore-pump-2",
	icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-2.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "extraction-machine",
	order = "b[fluids]-a[offshore-pump-2]",
	place_result = place_result_2,
	stack_size = 20,
}	data:extend({offshore_pump_2})

-- Offshore pump 3
local offshore_pump_3 =
{
	type = "item",
	name = "offshore-pump-3",
	icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-3.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "extraction-machine",
	order = "b[fluids]-a[offshore-pump-3]",
	place_result = place_result_3,
	stack_size = 20,
}	data:extend({offshore_pump_3})

-- Offshore pump 4
local offshore_pump_4 =
{
	type = "item",
	name = "offshore-pump-4",
	icon = "__P-U-M-P-S__/graphics/icons/offshore-pump-4.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "extraction-machine",
	order = "b[fluids]-a[offshore-pump-4]",
	place_result = place_result_4,
	stack_size = 20,
}	data:extend({offshore_pump_4})

-- Water pumpjack
--[[
local water_pumpjack =
{
	type = "item",
	name = "water-pumpjack-1",
	icon = "__P-U-M-P-S__/graphics/icons/water-pumpjack.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "extraction-machine",
	order = "b[fluids]-a[offshore-pump-4]",
	place_result = "water-pumpjack-1",
	stack_size = 20,
}	data:extend({water_pumpjack})
]]--