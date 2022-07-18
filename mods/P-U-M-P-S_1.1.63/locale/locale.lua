--------------------------
---- data-updates.lua ----
--------------------------

-- EDITING THESE FIELDS WILL MESS NAMES AND DESCRIPTIONS! YOU'RE WARNED!
-- IF YOU WISH TO CHANGE SOMETHING DO IT IN THE CFG FILE, NO LOCALES ARE STORED HERE!

local power_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-power")
local burner_enabled = OSM.lib.get_setting_boolean("osm-pumps-burner-offshore-pump")
local water_pumpjack_enabled = OSM.lib.get_setting_boolean("osm-pumps-enable-ground-water-pumpjacks")

local unpowered_pump = data.raw["offshore-pump"]
local powered_pump = data.raw["assembling-machine"]
local item = data.raw.item
local technology = data.raw.technology

local brn_tooltip = "[img=tooltip-category-chemical]"
local pwr_tooltip = "[img=tooltip-category-electricity]"
local tooltip_font = "[font=default-bold][color=#f5cb48]"
local end_tooltip = "[/color][/font]"
local field_font = "\n[font=default-semibold][color=#ffe6c0]"
local field_font_2 = "[font=default-semibold][color=#ffe6c0]"
local end_font = ": [/color][/font]"

local offshore_name = {"entity-name.offshore-pump"}
local pumpjack_name = {"string.water-pumpjack"}
local offshore_desc = {"entity-description.offshore-pump"}
local electric_offshore = {"string.electric-offshore-pump"}
local burner_offshore = {"string.burner-offshore-pump"}

local pumpjack_tech_desc = {"technology-description.water-pumpjack"}

local seafloor_pump = {"entity-name.seafloor-pump"}
local water_bore = {"entity-name.ground-water-pump"}

local consumes = {"tooltip-category.consumes"}
local burnable_fuel = {"fuel-category-name.chemical"}
local electricity = {"tooltip-category.electricity"}
local pumping_speed = {"description.pumping-speed"}
local max_consumption = {"description.max-energy-consumption"}
local min_consumption = {"description.min-energy-consumption"}

-- Make entity description
if power_enabled then
	if burner_enabled then
		unpowered_pump["offshore-pump-0-placeholder"].localised_name = {"", burner_offshore}
		unpowered_pump["offshore-pump-1-placeholder"].localised_name = {"", electric_offshore}
		unpowered_pump["offshore-pump-2-placeholder"].localised_name = {"", electric_offshore, " 2"}
		unpowered_pump["offshore-pump-3-placeholder"].localised_name = {"", electric_offshore, " 3"}
		unpowered_pump["offshore-pump-4-placeholder"].localised_name = {"", electric_offshore, " 4"}
		unpowered_pump["offshore-pump-0-placeholder"].localised_description = {"", brn_tooltip, " ", tooltip_font, consumes, " ", burnable_fuel, " ", end_tooltip..field_font, max_consumption, end_font.."600 kW"..field_font, pumping_speed, end_font.."300/s"}
		powered_pump["offshore-pump-0"].localised_name = {"", burner_offshore}
		powered_pump["offshore-pump-1"].localised_name = {"", electric_offshore}
		powered_pump["offshore-pump-2"].localised_name = {"", electric_offshore, " 2"}
		powered_pump["offshore-pump-3"].localised_name = {"", electric_offshore, " 3"}
		powered_pump["offshore-pump-4"].localised_name = {"", electric_offshore, " 4"}
		item["offshore-pump-0"].localised_description = {"", brn_tooltip, " ", tooltip_font, consumes, " ", burnable_fuel, " ", end_tooltip..field_font, max_consumption, end_font.."600 kW"}
		technology["offshore-pump-2"].localised_name = {"", offshore_name, " 2"}
		technology["offshore-pump-3"].localised_name = {"", offshore_name, " 3"}
		technology["offshore-pump-4"].localised_name = {"", offshore_name, " 4"}
	else
		unpowered_pump["offshore-pump-0-placeholder"].localised_name = {"", electric_offshore}
		unpowered_pump["offshore-pump-1-placeholder"].localised_name = {"", electric_offshore, " 2"}
		unpowered_pump["offshore-pump-2-placeholder"].localised_name = {"", electric_offshore, " 3"}
		unpowered_pump["offshore-pump-3-placeholder"].localised_name = {"", electric_offshore, " 4"}
		unpowered_pump["offshore-pump-4-placeholder"].localised_name = {"", electric_offshore, " 5"}
		unpowered_pump["offshore-pump-0-placeholder"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."413 kW"..field_font, min_consumption, end_font.."13.33 kW"..field_font, pumping_speed, end_font.."300/s"}
		powered_pump["offshore-pump-0"].localised_name = {"", electric_offshore}
		powered_pump["offshore-pump-1"].localised_name = {"", electric_offshore, " 2"}
		powered_pump["offshore-pump-2"].localised_name = {"", electric_offshore, " 3"}
		powered_pump["offshore-pump-3"].localised_name = {"", electric_offshore, " 4"}
		powered_pump["offshore-pump-4"].localised_name = {"", electric_offshore, " 5"}
		item["offshore-pump-0"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."413 kW"..field_font, min_consumption, end_font.."13.33 kW"}
		technology["offshore-pump-2"].localised_name = {"", offshore_name, " 3"}
		technology["offshore-pump-3"].localised_name = {"", offshore_name, " 4"}
		technology["offshore-pump-4"].localised_name = {"", offshore_name, " 5"}
	end
	unpowered_pump["offshore-pump-1-placeholder"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."1.24 MW"..field_font, min_consumption, end_font.."40 kW"..field_font, pumping_speed, end_font.."1200/s"}
	unpowered_pump["offshore-pump-2-placeholder"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."2.07 MW"..field_font, min_consumption, end_font.."66.67 kW"..field_font, pumping_speed, end_font.."2400/s"}
	unpowered_pump["offshore-pump-3-placeholder"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."2.89 MW"..field_font, min_consumption, end_font.."93.33 kW"..field_font, pumping_speed, end_font.."3600/s"}
	unpowered_pump["offshore-pump-4-placeholder"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."3.72 MW"..field_font, min_consumption, end_font.."120 kW"..field_font, pumping_speed, end_font.."4800/s"}
	powered_pump["offshore-pump-0"].localised_description = {"", field_font_2, pumping_speed, end_font.."300/s"}
	powered_pump["offshore-pump-1"].localised_description = {"", field_font_2, pumping_speed, end_font.."1200/s"}
	powered_pump["offshore-pump-2"].localised_description = {"", field_font_2, pumping_speed, end_font.."2400/s"}
	powered_pump["offshore-pump-3"].localised_description = {"", field_font_2, pumping_speed, end_font.."3600/s"}
	powered_pump["offshore-pump-4"].localised_description = {"", field_font_2, pumping_speed, end_font.."4800/s"}
	item["offshore-pump-1"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."1.24 MW"..field_font, min_consumption, end_font.."40 kW"}
	item["offshore-pump-2"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."2.07 MW"..field_font, min_consumption, end_font.."66.67 kW"}
	item["offshore-pump-3"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."2.89 MW"..field_font, min_consumption, end_font.."93.33 kW"}
	item["offshore-pump-4"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."3.72 MW"..field_font, min_consumption, end_font.."120 kW"}

	-- Angels refining
	if unpowered_pump["seafloor-pump-placeholder"] then
		unpowered_pump["seafloor-pump-placeholder"].localised_name = {"", seafloor_pump}
		unpowered_pump["seafloor-pump-placeholder"].localised_description = {"", pwr_tooltip," ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."310 kW"..field_font, min_consumption, end_font.."10 kW"..field_font, pumping_speed, end_font.."300/s"}
		powered_pump["seafloor-pump"].localised_description = {"", field_font_2, pumping_speed, end_font.."300/s"}
		item["seafloor-pump"].localised_description = {"", pwr_tooltip," ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."310 kW"..field_font, min_consumption, end_font.."10 kW"}
	end
	if unpowered_pump["ground-water-pump-placeholder"] then
		unpowered_pump["ground-water-pump-placeholder"].localised_name = {"", water_bore}
		unpowered_pump["ground-water-pump-placeholder"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."124 kW"..field_font, min_consumption, end_font.."4 kW"..field_font, pumping_speed, end_font.."60/s"}
		powered_pump["ground-water-pump"].localised_description = {"", field_font_2, pumping_speed, end_font.."60/s"}
		item["ground-water-pump"].localised_description = {"", pwr_tooltip, " ", tooltip_font, consumes, " ", electricity, " ", end_tooltip..field_font, max_consumption, end_font.."124 kW"..field_font, min_consumption, end_font.."4 kW"}
	end
else
	unpowered_pump["offshore-pump-0"].localised_name = {"", offshore_name}
	unpowered_pump["offshore-pump-1"].localised_name = {"", offshore_name, " 2"}
	unpowered_pump["offshore-pump-2"].localised_name = {"", offshore_name, " 3"}
	unpowered_pump["offshore-pump-3"].localised_name = {"", offshore_name, " 4"}
	unpowered_pump["offshore-pump-4"].localised_name = {"", offshore_name, " 5"}
	item["offshore-pump-0"].localised_description = {"", offshore_desc}
	item["offshore-pump-1"].localised_description = {"", offshore_desc}
	item["offshore-pump-2"].localised_description = {"", offshore_desc}
	item["offshore-pump-3"].localised_description = {"", offshore_desc}
	item["offshore-pump-4"].localised_description = {"", offshore_desc}
	technology["offshore-pump-2"].localised_name = {"", offshore_name, " 3"}
	technology["offshore-pump-3"].localised_name = {"", offshore_name, " 4"}
	technology["offshore-pump-4"].localised_name = {"", offshore_name, " 5"}
end

-- Water pumpjacks
if water_pumpjack_enabled then
	powered_pump["water-pumpjack-1"].localised_name = {"", pumpjack_name}
	powered_pump["water-pumpjack-2"].localised_name = {"", pumpjack_name, " 2"}
	powered_pump["water-pumpjack-3"].localised_name = {"", pumpjack_name, " 3"}
	powered_pump["water-pumpjack-4"].localised_name = {"", pumpjack_name, " 4"}
	powered_pump["water-pumpjack-5"].localised_name = {"", pumpjack_name, " 5"}
	powered_pump["water-pumpjack-1"].localised_description = {"", field_font_2, pumping_speed, end_font.."150/s"}
	powered_pump["water-pumpjack-2"].localised_description = {"", field_font_2, pumping_speed, end_font.."300/s"}
	powered_pump["water-pumpjack-3"].localised_description = {"", field_font_2, pumping_speed, end_font.."450/s"}
	powered_pump["water-pumpjack-4"].localised_description = {"", field_font_2, pumping_speed, end_font.."600/s"}
	powered_pump["water-pumpjack-5"].localised_description = {"", field_font_2, pumping_speed, end_font.."750/s"}
	technology["water-pumpjack-1"].localised_description = {"", pumpjack_tech_desc}
	technology["water-pumpjack-2"].localised_description = {"", pumpjack_tech_desc}
	technology["water-pumpjack-3"].localised_description = {"", pumpjack_tech_desc}
	technology["water-pumpjack-4"].localised_description = {"", pumpjack_tech_desc}
	technology["water-pumpjack-5"].localised_description = {"", pumpjack_tech_desc}	
end