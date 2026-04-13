local extend = KuxCoreLib.PrototypeData.extend

local isSpaceTravel = feature_flags["space_travel"]

local prerequision2level = 6
local prerequision2name= "laser-weapons-damage-"

if mods["space-exploration"] and settings.startup["ion-cannon-early-recipe"].value then prerequision2level = 2 end
if data.raw.technology["rampant-arsenal-technology-energy-weapons-damage-6"] then prerequision2name="rampant-arsenal-technology-energy-weapons-damage-" end

local rocketSiloPrerequisite = "rocket-silo"


local ingredientsCannon =
{
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
	{"chemical-science-pack", 1},
	{"military-science-pack", 1}
}

--Add rocket science pack prerequisite and research cost for SE 0.6
if data.raw["technology"]["se-rocket-science-pack"] then
	rocketSiloPrerequisite = "se-rocket-science-pack"
	table.insert(ingredientsCannon, {"se-rocket-science-pack", 1})
end

if not settings.startup["ion-cannon-early-recipe"].value then
	table.insert(ingredientsCannon, {"utility-science-pack", 1})
	table.insert(ingredientsCannon, {"production-science-pack", 1})
	table.insert(ingredientsCannon, {"space-science-pack", 1})
elseif not mods["space-exploration"] then
	table.insert(ingredientsCannon, {"utility-science-pack", 1})
	table.insert(ingredientsCannon, {"production-science-pack", 1})
end

local ingredientsTargeting =
{
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
	{"chemical-science-pack", 1},
	{"military-science-pack", 1},
	{"space-science-pack", 1}
}
if not mods["space-exploration"] or not settings.startup["ion-cannon-early-recipe"].value then
	table.insert(ingredientsTargeting, {"utility-science-pack", 1})
	table.insert(ingredientsTargeting, {"production-science-pack", 1})
end

local x = extend{prefix="", order = "k-"}
x:technology{ mod.tech.cannon,
	localised_name = {"technology-name.orbital-ion-cannon"},
	localised_description = isSpaceTravel and {"technology-description.orbital-ion-cannon-space-travel"} or {"technology-description.orbital-ion-cannon"},
	icon = mod.path.."graphics/icon64.png",
	icon_size = 64,
	prerequisites = {
		rocketSiloPrerequisite,
		prerequision2name..prerequision2level
	},
	effects = {
		{type = "unlock-recipe",recipe = mod.recipe.cannon},
		--[[{type = "unlock-recipe",recipe = mod.recipe.targeter}]]
	},
	unit = { count = 5000, ingredients = ingredientsCannon, time = 60 }
}


x:technology{mod.tech.area_fire,
	icon = mod.path.."graphics/tech-area-fire.png",
	icon_size = 256,
	prerequisites = {mod.tech.cannon},
	effects ={},
	unit = { count = 1000, ingredients = ingredientsCannon, time = 60 },
}
x:technology{ mod.tech.auto_targeting,
	icon = mod.path.."graphics/AutoTargetingTech.png",
	icon_size = 64,
	prerequisites = {mod.tech.cannon},
	effects = {},
	unit ={ count = 3000, ingredients = ingredientsTargeting, time = 60 }
}
if isSpaceTravel then
	x:technology{ mod.tech.cannon_mk2,
		localised_name = {"technology-name.orbital-ion-cannon-mk2"},
		localised_description = isSpaceTravel and {"technology-description.orbital-ion-cannon-mk2-space-travel"} or {"technology-description.orbital-ion-cannon-mk2"},
		icon = mod.path.."graphics/tech-mk2.png",
		icon_size = 256,
		prerequisites = {mod.tech.auto_targeting},
		effects = {{type = "unlock-recipe",recipe = mod.recipe.cannon_mk2}},
		unit ={ count = 5000, ingredients = ingredientsTargeting, time = 60 }
	}

	x:technology{ mod.tech.cannon_mk2_upgrade,
		icon = mod.path.."graphics/tech-mk2-upgrade.png",
		icon_size = 256,
		prerequisites = {mod.tech.cannon_mk2},
		effects = {},
		unit ={ count = 50, ingredients = ingredientsTargeting, time = 300 }
	}
end

--[[ --TODO implement this
if settings.startup["ion-cannon-bob-updates"].value then
	if data.raw["technology"]["energy-weapons-damage-6"] and data.raw["technology"]["bob-laser-turrets-5"] and data.raw["item"]["bob-laser-turret-5"] then
		table.insert(data.raw["technology"]["orbital-ion-cannon"].prerequisites, "energy-weapons-damage-6")
		table.insert(data.raw["technology"]["orbital-ion-cannon"].prerequisites, "bob-laser-turrets-5")
	end

	if data.raw["item"]["fast-accumulator-3"] and data.raw["technology"]["bob-electric-energy-accumulators-3"] then
		table.insert(data.raw["technology"]["orbital-ion-cannon"].prerequisites, "bob-electric-energy-accumulators-3")
	end

	if data.raw["item"]["solar-panel-large-3"] and data.raw["technology"]["bob-solar-energy-3"] then
		table.insert(data.raw["technology"]["orbital-ion-cannon"].prerequisites, "bob-solar-energy-3")
	end
end
]]