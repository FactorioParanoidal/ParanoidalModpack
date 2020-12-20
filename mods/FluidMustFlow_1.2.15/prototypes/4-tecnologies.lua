-- -- -- Library
local entity_utils = require("__FluidMustFlow__/linver-lib/entity-utils")

-- -- -- Tecnologies Effects

iron_ducts_effect = 
{
	{
		type = "unlock-recipe",
		recipe = "duct-small",
	},
	{
		type = "unlock-recipe",
		recipe = "duct-t-junction",
	},
	{
		type = "unlock-recipe",
		recipe = "duct-curve",
	},
	{
		type = "unlock-recipe",
		recipe = "duct-cross",
	},
	{
		type = "unlock-recipe",
		recipe = "duct-underground",
	},	
	{
		type = "unlock-recipe",
		recipe = "non-return-duct",
	},	
	{
		type = "unlock-recipe",
		recipe = "duct-end-point-intake",
	},
	{
		type = "unlock-recipe",
		recipe = "duct-end-point-outtake",
	}
}

if not settings.startup["fmf-enable-duct-auto-join"].value then
	table.insert(iron_ducts_effect, 
		{
			type = "unlock-recipe",
			recipe = "duct",
		}
	)
	table.insert(iron_ducts_effect,
		{
			type = "unlock-recipe",
			recipe = "duct-long",
		}
	)
end

-- calculate prerequisites
local _prerequisites = {}
local chemical_science_pack = entity_utils.getTechnologyThatUnlockRecipe("chemical-science-pack")
local pseudo_fluid_handling = entity_utils.getTechnologyThatUnlockRecipe("pump")
if chemical_science_pack then
	table.insert(_prerequisites, chemical_science_pack)
end
if pseudo_fluid_handling then
	table.insert(_prerequisites, pseudo_fluid_handling)
end

-- -- -- Tecnologies 

iron_ducts =	
{
	type = "technology",
	name = "Ducts",
	icon_size = 128,
	icon = "__FluidMustFlow__/graphics/icon/technologies/iron_duct_tecnology.png",
	upgrade = false,
	effects = iron_ducts_effect,
	prerequisites = _prerequisites,
	unit = 
	{
		count = 30,
		ingredients = {{"automation-science-pack", 2}, {"logistic-science-pack", 2}, {"chemical-science-pack", 1}},
		time = 20,
	}
}

data:extend({iron_ducts})
