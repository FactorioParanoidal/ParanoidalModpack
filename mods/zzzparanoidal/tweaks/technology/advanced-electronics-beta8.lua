-- Beta 8 normal: четыре открытия electronics III соответствуют нынешним контроллерам Bob.
-- Только цена и предки; рецепты/свойства модулей и внешних потребителей не меняем.
local technology = data.raw.technology["bob-advanced-processing-unit"]
if technology and technology.max_level ~= "infinite" and data.raw.technology["bob-ceramics"] then
	technology.prerequisites = { "processing-unit", "production-science-pack", "bob-ceramics" }
	technology.unit = {
		count = 100, time = 30,
		ingredients = {
			{ "automation-science-pack", 1 }, { "logistic-science-pack", 1 },
			{ "chemical-science-pack", 1 }, { "production-science-pack", 1 },
		},
	}
end
