-- Bob/zzz 1.1: исследование пятого тира, с текущими именами технологий материалов.
local source = data.raw.technology["bob-plasma-turrets-4"]
if not source then
	return
end

local technology = table.deepcopy(source)
technology.name = "bob-plasma-turrets-5"
technology.localised_name = { "technology-name.bob-plasma-turrets-5" }
technology.order = "a-j-c-5"
technology.prerequisites = {
	"bob-plasma-turrets-4",
	"military-4",
	"bob-advanced-processing-unit",
	"bob-battery-3",
	"bob-nitinol-processing",
}
technology.unit = {
	count = 500,
	time = 30,
	ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
		{ "military-science-pack", 1 },
		{ "production-science-pack", 1 },
		{ "utility-science-pack", 1 },
	},
}
technology.effects = { { type = "unlock-recipe", recipe = "bob-plasma-turret-5" } }
require("prototypes.plasma-turret-5-graphics")(technology)
data:extend({ technology })
