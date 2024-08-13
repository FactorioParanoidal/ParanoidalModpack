local tech_util = require("__automated-utility-protocol__.util.technology-util")
require("__automated-utility-protocol__.util.main")
require("__hardcore-mode-for-playing__.prototypes.fuel-category.fuel-categories")
require("__hardcore-mode-for-playing__.prototypes.boiler-processing.main")
require("__hardcore-mode-for-playing__.prototypes.steam-recipes.main")

local function steam_processing(mode)
	local technology_names = tech_util.get_all_active_technology_names(mode)
	local boiler_by_temperature_sorted = boiler_processing(technology_names, mode)
	local steam_recipes_by_temperature_sorted = create_steam_recipe_and_fluids(boiler_by_temperature_sorted)
	log("steam_recipes_by_temperature_sorted " .. Utils.dump_to_console(steam_recipes_by_temperature_sorted))
	update_boiler_prototype_by_steam_recipe_prototype(steam_recipes_by_temperature_sorted)
end
if settings.startup["hardcore-mode-for-playing-use-separated-boilers-for-every-fuel"].value then
	_table.each(GAME_MODES, function(mode)
		steam_processing(mode)
	end)
end
