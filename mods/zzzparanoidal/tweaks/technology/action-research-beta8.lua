-- Технологии 2.0, открывавшиеся за действие (research_trigger), возвращены на обычную цену в банках из Beta 8.
-- Меняются только цена, количество и время; предварительные технологии и эффекты не трогаются.
-- Не созданные модом технологии пропускаются: бобовские топоры есть только при bobmods-mining-miningaxes.
local R, G, B = { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }
local P, U = { "production-science-pack", 1 }, { "utility-science-pack", 1 }

local units = {
	["advanced-aerodynamics"] = { count = 350, time = 45, ingredients = { R, G, B } },
	["steel-axe"] = { count = 50, time = 30, ingredients = { R } },
	["bob-steel-axe-2"] = { count = 150, time = 30, ingredients = { R, G } },
	["bob-steel-axe-3"] = { count = 250, time = 30, ingredients = { R, G } },
	["bob-steel-axe-4"] = { count = 250, time = 40, ingredients = { R, G, B } },
	["bob-steel-axe-5"] = { count = 250, time = 50, ingredients = { R, G, B, P } },
	["bob-titanium-processing"] = { count = 75, time = 30, ingredients = { R, G, B } },
	["bob-tungsten-processing"] = { count = 75, time = 30, ingredients = { R, G, B, P } },
	["bob-nitinol-processing"] = { count = 75, time = 30, ingredients = { R, G, B, U } },
	["uranium-processing"] = { count = 200, time = 30, ingredients = { R, G, B } },
}

for name, unit in pairs(units) do
	local technology = data.raw.technology[name]
	if technology then
		local ingredients = {}
		for index, ingredient in ipairs(unit.ingredients) do ingredients[index] = { ingredient[1], ingredient[2] } end
		technology.research_trigger = nil
		technology.unit = { count = unit.count, time = unit.time, ingredients = ingredients }
	end
end
