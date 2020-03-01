
BI.Settings.Bio_Cannon = settings.startup["BI_Bio_Cannon"].value
BI.Settings.BI_Bio_Fuel = settings.startup["BI_Bio_Fuel"].value
BI.Settings.BI_Game_Tweaks_Stack_Size = settings.startup["BI_Game_Tweaks_Stack_Size"].value
BI.Settings.BI_Game_Tweaks_Recipe = settings.startup["BI_Game_Tweaks_Recipe"].value
BI.Settings.BI_Game_Tweaks_Tree = settings.startup["BI_Game_Tweaks_Tree"].value
BI.Settings.BI_Game_Tweaks_Player = settings.startup["BI_Game_Tweaks_Player"].value
BI.Settings.BI_Game_Tweaks_Disassemble = settings.startup["BI_Game_Tweaks_Disassemble"].value
BI.Settings.BI_Game_Tweaks_Bot = settings.startup["BI_Game_Tweaks_Bot"].value
BI.Settings.BI_Solar_Additions = settings.startup["BI_Solar_Additions"].value


----Update the Wood Pipe Images
require ("prototypes.Wood_Products.pipes")
--- Update the Rail Images


require ("prototypes.Wood_Products.wooden_rail_bridge_update")
--- Bridge Rail Remnants
require ("prototypes.Wood_Products.update_bridge_rails_remnants")
require ("prototypes.Wood_Products.tint_rails_remnants_function")


-- Concrete Rail
---- Update Standard Rails to use and look like concrete
set_tint_to_rails ({
data.raw["straight-rail"]["straight-rail"],
data.raw["curved-rail"]["curved-rail"]}, 
{r = 183/255, g = 183/255, b = 183/255, a = 1}) -- concrete
	
set_tint_to_remnants ({
data.raw["rail-remnants"]["straight-rail-remnants"],
data.raw["rail-remnants"]["curved-rail-remnants"]}, 
{r = 183/255, g = 183/255, b = 183/255, a = 1}) -- concrete

-- Wood Rail
set_tint_to_rails ({
data.raw["straight-rail"]["bi-straight-rail-wood"],
data.raw["curved-rail"]["bi-curved-rail-wood"]}, 
{r = 183/255, g = 125/255, b = 62/255, a = 1}) -- wood
	
set_tint_to_remnants ({
data.raw["rail-remnants"]["straight-rail-remnants-wood"],
data.raw["rail-remnants"]["curved-rail-remnants-wood"]}, 
{r = 183/255, g = 125/255, b = 62/255, a = 1}) -- wood

	--- Power Rail
set_tint_to_rails ({
data.raw["straight-rail"]["straight-rail"],
data.raw["curved-rail"]["curved-rail"]}, 
{r = 150/255, g = 150/255, b = 150/255, a = 1}) -- mix
	
-- vanilla rail recipe update
--bobmods.lib.recipe.add_new_ingredient("rail", {type="item", name="concrete", amount=8})

-- vanilla rail icon & images update
data.raw["straight-rail"]["straight-rail"].icon = "__Bio_Industries__/graphics/icons/straight-rail-concrete.png"
data.raw["curved-rail"]["curved-rail"].icon = "__Bio_Industries__/graphics/icons/curved-rail-concrete.png"
data.raw["rail-planner"]["rail"].icon = "__Bio_Industries__/graphics/icons/rail-concrete.png"


--- Wood Rail added to Tech 
bobmods.lib.tech.add_recipe_unlock("railway", "bi_recipe_rail_wood")

	
	
--- If Bob, move Vanilla Rail to Rail 2 also add Power Rail.
if data.raw.technology["bob-railway-2"] then
	bobmods.lib.tech.remove_recipe_unlock ("railway", "rail")
	bobmods.lib.tech.add_recipe_unlock("bob-railway-2", "rail")
	bobmods.lib.tech.add_recipe_unlock("bob-railway-2", "bi_recipe_rail_wood_to_concrete")
	bobmods.lib.tech.add_recipe_unlock("bob-railway-2", "bi_recipe_rail_wood_bridge")
	bobmods.lib.tech.add_recipe_unlock("bob-railway-2", "bi_rail_power")
	bobmods.lib.tech.add_recipe_unlock("bob-railway-2", "bi_recipe_power_to_rail_pole")
else
	bobmods.lib.tech.add_recipe_unlock("railway", "bi_recipe_rail_wood_to_concrete")
	bobmods.lib.tech.add_recipe_unlock("rail-signals", "bi_recipe_rail_wood_bridge")
	bobmods.lib.tech.add_recipe_unlock("rail-signals", "bi_rail_power")
	bobmods.lib.tech.add_recipe_unlock("rail-signals", "bi_recipe_power_to_rail_pole")
end
	
-- Damage Bonus to Ammo
-- Don't duplicate what NE does
if not mods["Natural_Evolution_Buildings"] then
	
	bobmods.lib.tech.add_recipe_unlock ("military", "bi_recipe_standard_dart_magazine")
	bobmods.lib.tech.add_recipe_unlock ("military-2", "bi_recipe_enhanced_dart_magazine")
	bobmods.lib.tech.add_recipe_unlock ("military-3", "bi_recipe_poison_dart_magazine")
	
end
require("prototypes.Bio_Turret.technology-updates")


require("prototypes.Bio_Cannon.technology-updates")
if not mods["Natural_Evolution_Buildings"] and BI.Settings.Bio_Cannon then
	-- add Prototype Artillery as pre req for artillery
	bobmods.lib.tech.add_prerequisite("artillery", "bi_tech_bio_cannon")
end

--- Move Stone Crusher up in tech tree
bobmods.lib.tech.add_recipe_unlock("automation", "bi_recipe_stone_crusher")
bobmods.lib.tech.add_recipe_unlock("automation", "bi_recipe_crushed_stone")

-- Add Wooden Chests
bobmods.lib.tech.add_recipe_unlock("logistics", "bi_recipe_large_wooden_chest")
bobmods.lib.tech.add_recipe_unlock("logistics-2", "bi_recipe_huge_wooden_chest")
bobmods.lib.tech.add_recipe_unlock("logistics-3", "bi_recipe_giga_wooden_chest")

	-- Add Big and Huge electric poles to tech tree
bobmods.lib.tech.add_recipe_unlock ("logistics", "bi_recipe_big_wooden_pole")
bobmods.lib.tech.add_recipe_unlock ("electric-energy-distribution-2", "bi_recipe_huge_wooden_pole")
	
--- Wood Floors
data.raw.item["wood"].place_as_tile =
	{
		result = "bi-wood-floor",
		condition_size = 4,
		condition = { "water-tile" }
	}
	


--- Make it so that the Base game tile "grass" can't be placed in blueprints
--- New as of 0.16
data.raw["tile"]["grass-1"].can_be_part_of_blueprint = false
data.raw["tile"]["grass-2"].can_be_part_of_blueprint = false
data.raw["tile"]["grass-3"].can_be_part_of_blueprint = false
data.raw["tile"]["grass-4"].can_be_part_of_blueprint = false


if mods["alien-biomes"] then

	data.raw["tile"]["frozen-snow-0"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-7"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-8"].can_be_part_of_blueprint = false
	data.raw["tile"]["frozen-snow-9"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-aubergine-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-beige-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-black-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-brown-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-cream-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-dustyrose-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-grey-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-purple-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-red-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-tan-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-violet-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-dirt-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-dirt-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-dirt-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-dirt-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-dirt-5"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-dirt-6"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-sand-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-sand-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["mineral-white-sand-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-blue-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-blue-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-green-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-green-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-green-grass-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-green-grass-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-mauve-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-mauve-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-olive-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-olive-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-orange-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-orange-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-purple-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-purple-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-red-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-red-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-turquoise-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-turquoise-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-violet-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-violet-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-yellow-grass-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["vegetation-yellow-grass-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-blue-heat-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-blue-heat-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-blue-heat-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-blue-heat-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-green-heat-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-green-heat-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-green-heat-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-green-heat-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-orange-heat-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-orange-heat-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-orange-heat-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-orange-heat-4"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-purple-heat-1"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-purple-heat-2"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-purple-heat-3"].can_be_part_of_blueprint = false
	data.raw["tile"]["volcanic-purple-heat-4"].can_be_part_of_blueprint = false

end


--- Adds Solar Farm, Solar Plant, Musk Floor, Bio Accumulator and Substation to Tech tree
if BI.Settings.BI_Solar_Additions then

	if data.raw.technology["bob-solar-energy-2"] then
		
		bobmods.lib.tech.add_recipe_unlock("bob-electric-energy-accumulators-3", "bi_recipe_accumulator")
		bobmods.lib.tech.add_recipe_unlock("electric-energy-distribution-2", "bi_recipe_huge_substation")
		bobmods.lib.tech.add_recipe_unlock("bob-solar-energy-2", "bi_recipe_bio_solar_farm")
		bobmods.lib.tech.add_recipe_unlock("bob-solar-energy-2", "bi_recipe_solar_boiler_panel")
		
	else

		bobmods.lib.tech.add_recipe_unlock("electric-energy-accumulators", "bi_recipe_accumulator")
		bobmods.lib.tech.add_recipe_unlock("electric-energy-distribution-2", "bi_recipe_huge_substation")
		bobmods.lib.tech.add_recipe_unlock("solar-energy", "bi_recipe_bio_solar_farm")
		bobmods.lib.tech.add_recipe_unlock("solar-energy", "bi_recipe_solar_boiler_panel")
		
	end	
	
	if data.raw.technology["bob-solar-energy-3"] then
		
		bobmods.lib.tech.add_recipe_unlock("bob-solar-energy-3", "bi_recipe_solar_mat")
		
	else

		bobmods.lib.tech.add_recipe_unlock("solar-energy", "bi_recipe_solar_mat")
	
	end	
	
	
	--- Electric redo if Bob' Electric
	-- Huge Electric Pole
	if data.raw.item["tinned-copper-cable"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_huge_wooden_pole", "wood")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_huge_wooden_pole", {type = "item", name = "tinned-copper-cable", amount = 15})
		
	end

	-- Solar Farm
	if data.raw.item["solar-panel-large-2"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_bio_solar_farm", "solar-panel")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_bio_solar_farm", {type = "item", name = "solar-panel-large-2", amount = 20})
		
	end

	-- Huge Sub Station
	if data.raw.item["substation-3"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_huge_substation", "substation")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_huge_substation", {type = "item", name = "substation-3", amount = 6})
		
	end
	if data.raw.item["electrum-alloy"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_huge_substation", "steel-plate")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_huge_substation", {type = "item", name = "electrum-alloy", amount = 10})
		
	end

	-- Huge Accumulator
	if data.raw.item["large-accumulator-2"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_accumulator", "accumulator")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_accumulator", {type = "item", name = "large-accumulator", amount = 30})
		
	end
	if data.raw.item["aluminium-plate"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_accumulator", "copper-cable")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_accumulator", {type = "item", name = "aluminium-plate", amount = 50})
		
	end
	
	-- Solar Mat
	if data.raw.item["aluminium-plate"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_solar_mat", "steel-plate")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_solar_mat", {type = "item", name = "aluminium-plate", amount = 1})
		
	end
	if data.raw.item["silicon-wafer"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_solar_mat", "copper-cable")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_solar_mat", {type = "item", name = "silicon-wafer", amount = 4})
		
	end

	-- Solar Boiler / Plant
	if data.raw.item["angels-electric-boiler"] then
	
		bobmods.lib.recipe.remove_ingredient ("bi_recipe_solar_boiler_panel", "boiler")
		bobmods.lib.recipe.add_new_ingredient ("bi_recipe_solar_boiler_panel", {type = "item", name = "angels-electric-boiler", amount = 1})
		
	end
end



require("prototypes.Bio_Farm.compatible_recipes") -- Bob and Angels mesh
require("prototypes.Bio_Farm.technology2")
if BI.Settings.BI_Bio_Fuel or mods["Natural_Evolution_Buildings"] then

	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_clean_air_2")
	
end

-- Adds Bio recipes
if BI.Settings.BI_Bio_Fuel then 

	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_bioreactor")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_cellulose_1")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_cellulose_2")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_biomass_1")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_biomass_2")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_biomass_3")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_battery")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_biomass_conversion_1")	
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_biomass_conversion_2")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_biomass_conversion_3")
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_acid")	
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_boiler")

	if mods["angelspetrochem"] then
		bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_sulfur_angels")	
	else
		bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_sulfur")	
	end
	
	bobmods.lib.recipe.add_new_ingredient("bi_recipe_adv_fertiliser_1", {type="fluid", name="bi-biomass", amount=10})
	bobmods.lib.recipe.add_new_ingredient("bi_recipe_adv_fertiliser_2", {type="fluid", name="bi-biomass", amount=10})

else
	
	bobmods.lib.recipe.add_new_ingredient("bi_recipe_adv_fertiliser_1", {type="item", name="fertiliser", amount=50})
	bobmods.lib.recipe.remove_ingredient ("bi_recipe_adv_fertiliser_2", "fertiliser")
	bobmods.lib.recipe.add_new_ingredient("bi_recipe_adv_fertiliser_2", {type="item", name="fertiliser", amount=30})
	
end


	
--- if the Alien Artifact is in the game, use if for some recipes
if data.raw.item["alien-artifact"] then
	--- Advanced Fertiliser will use Alien Artifact
	bobmods.lib.recipe.remove_ingredient ("bi_recipe_adv_fertiliser_1", "bi-biomass")
	bobmods.lib.recipe.add_new_ingredient("bi_recipe_adv_fertiliser_1", {type="item", name="alien-artifact", amount=5})
	bobmods.lib.tech.add_recipe_unlock("bi_tech_advanced_biotechnology", "bi_recipe_adv_fertiliser_1")	
	
end	


------- Adds a Mk3 recipe for wood if you're playing with Natural Evolution Buildings
if mods["Natural_Evolution_Buildings"] then
		
	bobmods.lib.recipe.remove_ingredient ("bi_recipe_adv_fertiliser_1", "bi-biomass")	
	bobmods.lib.recipe.remove_ingredient ("bi_recipe_adv_fertiliser_1", "alien-artifact")
	bobmods.lib.recipe.add_new_ingredient ("bi_recipe_adv_fertiliser_1", {type="fluid", name="NE_enhanced-nutrient-solution", amount=50})

end


------------ Support for Bob's Greenhouse
if data.raw["item"]["bob-greenhouse"] then 

	data.raw["item"]["seedling"].place_result = "seedling"
	data.raw["item"]["seedling"].icon = "__Bio_Industries__/graphics/icons/Seedling.png"
	data.raw["item"]["fertiliser"].icon = "__Bio_Industries__/graphics/icons/fertiliser_32.png"
	
	if mods["alien-biomes"] then
		data.raw["item"]["fertiliser"].place_as_tile = {result = "vegetation-green-grass-3",	condition_size = 1,	condition = { "water-tile" }}
	else
		data.raw["item"]["fertiliser"].place_as_tile = {result = "grass-3",	condition_size = 1,	condition = { "water-tile" }}
	end
		
end

	
--[[
-------- Use Alternative Solar Farm Image
if BI.Settings.BI_Solar_Additions and settings.startup["BI_Alt_Solar_Farm_Image"] and settings.startup["BI_Alt_Solar_Farm_Image"].value then

	data.raw["solar-panel"]["bi-bio-solar-farm"].icon = "__Bio_Industries__/graphics/icons/Bio_Solar_Farm_Icon_alt.png"
	data.raw["item"]["bi-bio-solar-farm"].icon = "__Bio_Industries__/graphics/icons/Bio_Solar_Farm_Icon_alt.png"
	data.raw["solar-panel"]["bi-bio-solar-farm"].picture =
		{
		  filename = "__Bio_Industries__/graphics/entities/bio_solar_farm/Bio_Solar_Farm_On_alt.png",
		  priority = "low",
		  width = 208,
		  height = 192,
		  frame_count = 1,
		  direction_count = 1,
		  scale = 3/2,
		}

end


---- Bio Drill Enable!
-- New Fluid Ores
require("prototypes.Bio_Drill.resources")
require("prototypes.Bio_Drill.angel-over-rides")	
if settings.startup["BI_Bio_Infinite_Fluids"] and settings.startup["BI_Bio_Infinite_Fluids"].value == true then
	
	if data.raw.resource["ground-water"] then
		data.raw.resource["ground-water"] = nil
		data.raw["autoplace-control"]["ground-water"] = nil
	end
	
	
	infinite_fluids = require("prototypes.Bio_Drill.supported-resources")
	for _, resource in pairs(infinite_fluids) do

		if settings.startup["bi_" .. resource.name] ~= nil and settings.startup["bi_" .. resource.name].value == true and data.raw["resource"][resource.name] ~= nil then
			data.raw["resource"][resource.name]["infinite"] = false
			data.raw["resource"][resource.name]["minimum"]	= 0
		end
	end	
	
	--- Override the vanilla offshore-pump output from "water" to "water-saline"
	data.raw["offshore-pump"]["offshore-pump"].fluid = "water-saline"
	--- Make it so that the normal off-shore pump needs a battery
	thxbob.lib.recipe.add_new_ingredient("offshore-pump", {type="item", name="battery", amount=4})

		
	infinite_fluids = require("prototypes.Bio_Drill.supported-resources")	
	--- Mk1 Recipies
	for _, resource in pairs(infinite_fluids) do
		local r1_name = "bi_recipe_mk1_" .. resource.fluid
		if mods[resource.dependency] then
			thxbob.lib.tech.add_recipe_unlock("bi-tech-bio-prospecting-1", r1_name)
		end
	end
	--- Mk2 Recipies
	for _, resource in pairs(infinite_fluids) do
		local r2_name = "bi_recipe_mk2_" .. resource.fluid
		if mods[resource.dependency] then
			thxbob.lib.tech.add_recipe_unlock("bi-tech-bio-prospecting-2", r2_name)
		end
	end
	--- Mk3 Recipies
	for _, resource in pairs(infinite_fluids) do
		local r3_name = "bi_recipe_mk3_" .. resource.fluid
		if mods[resource.dependency] then
			thxbob.lib.tech.add_recipe_unlock("bi-tech-bio-prospecting-3", r3_name)
		end 
	end

	
	if settings.startup["BI_Bio_Alter_Water_Appearance"] and settings.startup["BI_Bio_Alter_Water_Appearance"].value == true then
	
	-- update the look of Saline Water
	data.raw.fluid["water-saline"].base_color = {r = 0.3, g = 0.4, b = 0.9}
	data.raw.fluid["water-saline"].flow_color = {r = 0.3, g = 0.4, b = 0.9}


		--- Update water tiles
		data.raw.tile["deepwater"].variants =
		{
		  main =
		  {
			{
			  picture = "__Bio_Industries__/graphics/terrain/deepwater/deepwater1.png",
			  count = 8,
			  size = 1,
			  hr_version = {
				picture = "__Bio_Industries__/graphics/terrain/deepwater/hr-deepwater1.png",
				count = 8,
				scale = 0.5,
				size = 1
			  }
			},
			{
			  picture = "__Bio_Industries__/graphics/terrain/deepwater/deepwater2.png",
			  count = 8,
			  size = 2,
			  hr_version = {
				picture = "__Bio_Industries__/graphics/terrain/deepwater/hr-deepwater2.png",
				count = 8,
				scale = 0.5,
				size = 2
			  }
			},
			{
			  picture = "__Bio_Industries__/graphics/terrain/deepwater/deepwater4.png",
			  count = 6,
			  size = 4,
			  hr_version = {
				picture = "__Bio_Industries__/graphics/terrain/deepwater/hr-deepwater4.png",
				count = 8,
				scale = 0.5,
				size = 4
			  }
			}
		  },
		  inner_corner =
		  {
			picture = "__Bio_Industries__/graphics/terrain/deepwater/deepwater-inner-corner.png",
			count = 6,
			hr_version = {
			  picture = "__Bio_Industries__/graphics/terrain/deepwater/hr-deepwater-inner-corner.png",
			  count = 6,
			  scale = 0.5
			}
		  },
		  outer_corner =
		  {
			picture = "__Bio_Industries__/graphics/terrain/deepwater/deepwater-outer-corner.png",
			count = 6,
			hr_version = {
			  picture = "__Bio_Industries__/graphics/terrain/deepwater/hr-deepwater-outer-corner.png",
			  count = 6,
			  scale = 0.5
			}
		  },
		  side =
		  {
			picture = "__Bio_Industries__/graphics/terrain/deepwater/deepwater-side.png",
			count = 8,
			hr_version = {
			  picture = "__Bio_Industries__/graphics/terrain/deepwater/hr-deepwater-side.png",
			  count = 8,
			  scale = 0.5
			}
		  }
		}
		
		
		data.raw.tile["water"].variants =
		{
		  main =
		  {
			{
			  picture = "__Bio_Industries__/graphics/terrain/water/water1.png",
			  count = 8,
			  size = 1,
			  hr_version =
			  {
				picture = "__Bio_Industries__/graphics/terrain/water/hr-water1.png",
				count = 8,
				scale = 0.5,
				size = 1
			  },
			},
			{
			  picture = "__Bio_Industries__/graphics/terrain/water/water2.png",
			  count = 8,
			  size = 2,
			  hr_version =
			  {
				picture = "__Bio_Industries__/graphics/terrain/water/hr-water2.png",
				count = 8,
				scale = 0.5,
				size = 2
			  },
			},
			{
			  picture = "__Bio_Industries__/graphics/terrain/water/water4.png",
			  count = 6,
			  size = 4,
			  hr_version =
			  {
				picture = "__Bio_Industries__/graphics/terrain/water/hr-water4.png",
				count = 8,
				scale = 0.5,
				size = 4
			  },
			}
		  },
		  inner_corner =
		  {
			picture = "__Bio_Industries__/graphics/terrain/water/water-inner-corner.png",
			count = 0
		  },
		  outer_corner =
		  {
			picture = "__Bio_Industries__/graphics/terrain/water/water-outer-corner.png",
			count = 0
		  },
		  side =
		  {
			picture = "__Bio_Industries__/graphics/terrain/water/water-side.png",
			count = 0
		  }
		}
	end
end
]]--

if settings.startup["angels-use-angels-barreling"] and settings.startup["angels-use-angels-barreling"].value then
   data.raw.technology["bi_tech_fertiliser"].prerequisites = 
      {
         "bi_tech_bio_farming",
         -- AND (
         "water-treatment", -- sulfur
         -- OR
         "angels-fluid-barreling", -- barreling (needed 'water-treatment' as prerequisites)
         -- )
      }
end

----- Angels Merge ----
if mods["angelspetrochem"] then

    data.raw.item["pellet-coke"].icon = "__angelspetrochem__/graphics/icons/pellet-coke.png"
	data.raw.item["pellet-coke"].fuel_acceleration_multiplier = 1.1
	data.raw.item["pellet-coke"].fuel_top_speed_multiplier = 1.025
	
	data.raw.recipe["pellet-coke"].category = "biofarm-mod-smelting"	
	bobmods.lib.tech.remove_recipe_unlock ("angels-coal-processing-2", "pellet-coke")
	bobmods.lib.tech.add_recipe_unlock("angels-coal-cracking", "pellet-coke")

end

--- Enanble Productivity in Recipies
BI_Functions.lib.allow_productivity("bi_recipe_seed_1")
BI_Functions.lib.allow_productivity("bi_recipe_seed_2")
BI_Functions.lib.allow_productivity("bi_recipe_seed_3")
BI_Functions.lib.allow_productivity("bi_recipe_seed_4")

BI_Functions.lib.allow_productivity("bi_recipe_seedling_mk1")
BI_Functions.lib.allow_productivity("bi_recipe_seedling_mk2")
BI_Functions.lib.allow_productivity("bi_recipe_seedling_mk3")
BI_Functions.lib.allow_productivity("bi_recipe_seedling_mk4")

BI_Functions.lib.allow_productivity("bi_recipe_logs_mk1")
BI_Functions.lib.allow_productivity("bi_recipe_logs_mk2")
BI_Functions.lib.allow_productivity("bi_recipe_logs_mk3")
BI_Functions.lib.allow_productivity("bi_recipe_logs_mk4")

BI_Functions.lib.allow_productivity("bi_recipe_stone_brick")

BI_Functions.lib.allow_productivity("bi_recipe_resin_pulp")
BI_Functions.lib.allow_productivity("bi_recipe_press_wood")
BI_Functions.lib.allow_productivity("bi_recipe_resin_wood")
BI_Functions.lib.allow_productivity("bi_recipe_woodpulp")

BI_Functions.lib.allow_productivity("bi_recipe_liquid_air")
BI_Functions.lib.allow_productivity("bi_recipe_nitrogen")

BI_Functions.lib.allow_productivity("bi_recipe_biomass_1")
BI_Functions.lib.allow_productivity("bi_recipe_biomass_2")
BI_Functions.lib.allow_productivity("bi_recipe_biomass_3")

BI_Functions.lib.allow_productivity("bi_recipe_biomass_conversion_1")
BI_Functions.lib.allow_productivity("bi_recipe_biomass_conversion_2")
BI_Functions.lib.allow_productivity("bi_recipe_biomass_conversion_3")

BI_Functions.lib.allow_productivity("bi_recipe_battery")
BI_Functions.lib.allow_productivity("bi_recipe_acid")
BI_Functions.lib.allow_productivity("bi_recipe_sulfur")
BI_Functions.lib.allow_productivity("bi_recipe_sulfur_angels")
BI_Functions.lib.allow_productivity("bi_recipe_plastic_1")
BI_Functions.lib.allow_productivity("bi_recipe_plastic_2")
BI_Functions.lib.allow_productivity("bi_recipe_cellulose_1")
BI_Functions.lib.allow_productivity("bi_recipe_cellulose_2")