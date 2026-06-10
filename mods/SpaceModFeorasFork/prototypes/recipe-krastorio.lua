local productionCost = settings.startup["SpaceX-production"].value or 1
local classicMode = settings.startup["SpaceX-classic-mode"].value or false

local function replace_ingredient(ingredients, old, new, new_amount)
	local amount = 0
	if ingredients then
		for i, ingredient in pairs(ingredients) do
			if ingredient then
				if ingredient[1] == old or ingredient.name == old then
					amount = ingredient[2] or ingredient.amount
					table.remove(ingredients, i)
					break
				end
			end
		end
		if new_amount then
			table.insert(ingredients, { type = "item", name = new, amount = new_amount })
		elseif amount ~= 0 then
			table.insert(ingredients, { type = "item", name = new, amount = amount })
		end
	end
end

local function replace(recipe_name, old, new, new_amount)
	local recipe = data.raw["recipe"][recipe_name]
	if recipe then
		for _, diff in pairs({ recipe }) do
			if diff then
				if diff.ingredients then
					replace_ingredient(diff.ingredients, old, new, new_amount)
				end
			end
		end
	end
end

local function insert_ingredient(recipe_name, ingredient, amount)
	local recipe = data.raw["recipe"][recipe_name]
	if recipe then
		for _, diff in pairs({ recipe }) do
			if diff then
				if diff.ingredients then
					table.insert(diff.ingredients, { type = "item", name = ingredient, amount = amount })
				end
			end
		end
	end
end

replace("drydock-assembly", "solar-panel", "kr-advanced-solar-panel")
insert_ingredient("drydock-assembly", "kr-ai-core", 10 * productionCost)

replace("hull-component", "steel-plate", "kr-imersium-plate", 50 * productionCost)

replace("protection-field", "energy-shield-mk2-equipment", "kr-energy-shield-mk3-equipment")
insert_ingredient("protection-field", "kr-ai-core", 25 * productionCost)

replace("space-thruster", "pipe", "kr-steel-pipe")
replace("space-thruster", "electric-engine-unit", "kr-advanced-additional-engine-equipment")

replace("fuel-cell", "nuclear-reactor", "kr-fusion-reactor")

replace("life-support", "pipe", "kr-steel-pipe")
insert_ingredient("life-support", "kr-greenhouse", 50 * productionCost)

insert_ingredient("command", "kr-ai-core", 50 * productionCost)

replace("laser-cannon", "laser-turret", "kr-laser-artillery-turret", 100 * productionCost)
insert_ingredient("laser-cannon", "kr-ai-core", 25 * productionCost)

replace("astrometrics", "lab", "kr-advanced-lab")

if not classicMode then
	insert_ingredient("exploration-satellite", "kr-ai-core", 5 * productionCost)
	replace("exploration-satellite", "nuclear-fuel", "kr-dt-fuel-cell")
	replace("exploration-satellite", "rocket-fuel", "kr-dt-fuel-cell")

	replace("space-ai-robot-frame", "power-armor-mk2", "kr-power-armor-mk3")
	replace("space-ai-robot-frame", "personal-laser-defense-equipment", "kr-personal-laser-defense-mk3-equipment")

	replace("space-ai-robot", "radar", "kr-advanced-radar")
	replace("space-ai-robot", "battery-mk2-equipment", "kr-big-battery-mk3-equipment")
	replace("space-ai-robot", "exoskeleton-equipment", "kr-advanced-exoskeleton-equipment")
	insert_ingredient("space-ai-robot", "kr-ai-core", 100 * productionCost)

	replace("space-water-tank", "storage-tank", "kr-big-storage-tank")
	replace("space-water-tank", "pump", "kr-steel-pump")
	replace("space-water-tank", "pipe", "kr-steel-pipe")

	replace("space-fuel-tank", "storage-tank", "kr-big-storage-tank")
	replace("space-fuel-tank", "pump", "kr-steel-pump")
	replace("space-fuel-tank", "pipe", "kr-steel-pipe")
	replace("space-fuel-tank", "nuclear-fuel", "kr-dt-fuel-cell")
	replace("space-fuel-tank", "rocket-fuel", "kr-dt-fuel-cell")

	replace("space-oxygen-tank", "storage-tank", "kr-big-storage-tank")
	replace("space-oxygen-tank", "pump", "kr-steel-pump")
	replace("space-oxygen-tank", "pipe", "kr-steel-pipe")
end
