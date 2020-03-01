require("prototypes.globals")

local tech = data.raw.technology["optics"]

table.insert(tech.effects, {
	type = "unlock-recipe",
	recipe = DLL.name
})
