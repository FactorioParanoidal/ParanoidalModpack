data:extend({
	{
		type = "recipe",
		name = "orbital-ion-cannon",
		energy_required = 60,
		normal =
		{
			enabled = false,
			ingredients =
			{
				{"low-density-structure", 100},
				{"solar-panel", 100},
				{"accumulator", 200},
				{"radar", 10},
				{"processing-unit", 200},
				{"electric-engine-unit", 25},
				{"laser-turret", 50},
				{"rocket-fuel", 50}
			},
			result = "orbital-ion-cannon"
		},
		expensive =
		{
			enabled = false,
			ingredients =
			{
				{"low-density-structure", 250},
				{"solar-panel", 250},
				{"accumulator", 500},
				{"radar", 25},
				{"processing-unit", 500},
				{"electric-engine-unit", 50},
				{"laser-turret", 100},
				{"rocket-fuel", 100}
			},
			result = "orbital-ion-cannon"
		},
	},
	{
		type = "recipe",
		name = "ion-cannon-targeter",
		energy_required = 0.5,
		enabled = false,
		category = "crafting",
		ingredients =
		{
			{"processing-unit", 1},
			{"plastic-bar", 2},
			{"battery", 1}
		},
		result = "ion-cannon-targeter"
	},
})

if data.raw["item"]["advanced-processing-unit"] and settings.startup["ion-cannon-bob-updates"].value then
	data.raw["recipe"]["orbital-ion-cannon"].normal.ingredients[5] = {"advanced-processing-unit", 200}
	data.raw["recipe"]["orbital-ion-cannon"].expensive.ingredients[5] = {"advanced-processing-unit", 500}
end

if data.raw["item"]["bob-laser-turret-5"] and settings.startup["ion-cannon-bob-updates"].value then
	data.raw["recipe"]["orbital-ion-cannon"].normal.ingredients[7] = {"bob-laser-turret-5", 50}
	data.raw["recipe"]["orbital-ion-cannon"].expensive.ingredients[7] = {"bob-laser-turret-5", 100}
end

if data.raw["item"]["fast-accumulator-3"] and data.raw["item"]["solar-panel-large-3"] and settings.startup["ion-cannon-bob-updates"].value then
	data.raw["recipe"]["orbital-ion-cannon"].normal.ingredients[2] = {"solar-panel-large-3", 100}
	data.raw["recipe"]["orbital-ion-cannon"].expensive.ingredients[2] = {"solar-panel-large-3", 250}
	data.raw["recipe"]["orbital-ion-cannon"].normal.ingredients[3] = {"fast-accumulator-3", 200}
	data.raw["recipe"]["orbital-ion-cannon"].expensive.ingredients[3] = {"fast-accumulator-3", 500}
end
