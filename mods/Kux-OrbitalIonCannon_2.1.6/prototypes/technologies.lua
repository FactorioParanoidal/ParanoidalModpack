local tech = {}

tech.init = function ()
	local prerequision2level = 6
	local prerequision2name= "energy-weapons-damage-"

	if mods["space-exploration"] and settings.startup["ion-cannon-early-recipe"].value then prerequision2level = 4 end
	if data.raw.technology["rampant-arsenal-technology-energy-weapons-damage-6"] then prerequision2name="rampant-arsenal-technology-energy-weapons-damage-" end

	local ingredients =
				{
					{"automation-science-pack", 2},
					{"logistic-science-pack", 2},
					{"chemical-science-pack", 2},
					{"military-science-pack", 2},
					{"utility-science-pack", 2},
					{"production-science-pack", 2}
				}

	if not settings.startup["ion-cannon-early-recipe"].value then
		table.insert(ingredients, {"space-science-pack", 2})
	end

	data:extend({
		{
			type = "technology",
			name = "orbital-ion-cannon",
			icon = modFolder.."/graphics/icon64.png",
			icon_size = 64,
			prerequisites = {"rocket-silo", prerequision2name..prerequision2level},
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "orbital-ion-cannon"
				},
				{
					type = "unlock-recipe",
					recipe = "ion-cannon-targeter"
				}
			},
			unit =
			{
				count = 2500,
				ingredients = ingredients,
				time = 60
			},
			order = "k-a"
		},
		{
			type = "technology",
			name = "auto-targeting",
			icon = modFolder.."/graphics/AutoTargetingTech.png",
			icon_size = 64,
			prerequisites = {"orbital-ion-cannon"},
			effects = {},
			unit =
			{
				count = 2000,
				ingredients =
				{
					{"automation-science-pack", 2},
					{"logistic-science-pack", 2},
					{"chemical-science-pack", 2},
					{"military-science-pack", 2},
					{"utility-science-pack", 2},
					{"production-science-pack", 2},
					{"space-science-pack", 2}
				},
				time = 60
			},
			order = "k-b"
		},
	})

	if data.raw["item"]["bob-laser-turret-5"] and settings.startup["ion-cannon-bob-updates"].value then
		data.raw["technology"]["orbital-ion-cannon"].prerequisites = {"rocket-silo", "energy-weapons-damage-6", "bob-laser-turrets-5"}
	end

	if data.raw["item"]["fast-accumulator-3"] and data.raw["item"]["solar-panel-large-3"] and settings.startup["ion-cannon-bob-updates"].value then
		data.raw["technology"]["orbital-ion-cannon"].prerequisites = {"rocket-silo", "energy-weapons-damage-6",	"bob-solar-energy-4", "bob-electric-energy-accumulators-4"}
	end

	if data.raw["item"]["fast-accumulator-3"] and data.raw["item"]["solar-panel-large-3"] and data.raw["item"]["bob-laser-turret-5"] and settings.startup["ion-cannon-bob-updates"].value then
		data.raw["technology"]["orbital-ion-cannon"].prerequisites = {"rocket-silo", "energy-weapons-damage-6", "bob-solar-energy-4", "bob-electric-energy-accumulators-4", "bob-laser-turrets-5"}
	end
end

tech.updates = function ()

end

tech.finalFixes = function ()
	
end

return tech
