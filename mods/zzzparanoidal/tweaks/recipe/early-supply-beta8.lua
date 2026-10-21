-- Beta 8 normal: снабжение ранней электронной цепочки.
-- Только цена постройки дробилки и связь водоочистки; механики/категории не меняются.
local crusher = data.raw.recipe["angels-burner-ore-crusher"]
if crusher then
	crusher.ingredients = {
		{ type = "item", name = "stone", amount = 10 },
		{ type = "item", name = "iron-plate", amount = 10 },
		{ type = "item", name = "motor", amount = 4 },
	}
end
local water = data.raw.technology["angels-water-treatment"]
if water and water.max_level ~= "infinite" then
	-- Гидростанция требует простой каркас, открываемый металлургией I.
	water.prerequisites = { "angels-fluid-control", "basic-fluid-handling", "angels-metallurgy-1" }
end
