local DLL = require("prototypes.globals")

table.insert(data.raw.technology[DLL.technology].effects, {
	type = "unlock-recipe",
	recipe = DLL.name
})
