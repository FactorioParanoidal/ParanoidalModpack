require("__zzzparanoidal__.paralib")

-- Восстанавливаем 1.1-цену космо-техов, которую 2.0-форк потерял: в 1.1 SpaceMod/technology-bobs.lua
-- bob_coefficient был = 10 и умножал стоимость всех космо-техов, а форк обнулил его до 1.
-- Для новых космо-техов сохраняем прежний ×10 до согласования их runtime-зависимостей.
-- Семь конечных FTL-исследований ниже задаются по итоговому normal-дампу Beta 8.
if mods["SpaceModFeorasFork"] then
	local techs = {
		"laser-cannon",
		"exploration-satellite", "space-ai-robots", "space-fluid-tanks", "space-cartography",
	}
	for _, name in ipairs(techs) do
		local t = data.raw.technology[name]
		if t and t.unit and t.unit.count then
			t.unit.count = math.floor(t.unit.count * 10)
		end
	end

	local ftl_science = {
		["ftl-theory-A"] = { "automation-science-pack" },
		["ftl-theory-B"] = { "automation-science-pack", "logistic-science-pack" },
		["ftl-theory-C"] = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" },
		["ftl-theory-D"] = {
			"automation-science-pack", "logistic-science-pack", "chemical-science-pack",
			"bob-advanced-logistic-science-pack", "military-science-pack",
		},
		["ftl-theory-D1"] = {
			"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack",
		},
		["ftl-theory-D2"] = {
			"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "utility-science-pack",
		},
		["ftl-propulsion"] = {
			"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack",
			"utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack", "military-science-pack",
		},
	}
	for name, science in pairs(ftl_science) do
		local t = data.raw.technology[name]
		if t and t.unit and t.max_level ~= "infinite" then
			local ingredients = {}
			for _, pack in ipairs(science) do
				ingredients[#ingredients + 1] = { pack, 1 }
			end
			t.unit = { count = 2000000, time = 60, ingredients = ingredients }
		end
	end

	-- Остальные шесть FTL-связей уже совпадают с Beta 8.
	-- god-module-5 заменён согласованным продуктивным модулем: его открывает bob-god-module.
	-- productivity-module-8 соответствует старшему bob-productivity-module-5, уже требуемому форком.
	local propulsion = data.raw.technology["ftl-propulsion"]
	if propulsion and propulsion.max_level ~= "infinite" and data.raw.technology["bob-god-module"] then
		propulsion.prerequisites = {
			"ftl-theory-D1", "ftl-theory-D2", "bob-god-module", "bob-productivity-module-5",
		}
	end
end
