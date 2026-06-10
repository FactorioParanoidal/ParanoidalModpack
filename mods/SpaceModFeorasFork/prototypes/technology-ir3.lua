local classicMode = settings.startup["SpaceX-classic-mode"].value or false
local replaceNuclear = settings.startup["SpaceX-no-nuclear"].value or false

if not classicMode and not replaceNuclear then
	table.insert(data.raw["technology"]["exploration-satellite"].effects, {
		type = "unlock-recipe",
		recipe = "spaceship-fuel",
	})
	table.insert(data.raw["technology"]["space-fluid-tanks"].effects, {
		type = "unlock-recipe",
		recipe = "spaceship-fuel",
	})
end
