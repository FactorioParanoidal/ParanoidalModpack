-- Кастомная группировка items/recipes в Factoriopedia и инвентаре.
-- Запускается в data-final-fixes, чтобы все сторонние моды успели объявить
-- свои прототипы. Каждая секция ниже решает свою задачу и независима от
-- других — при добавлении нового кейса просто вписать ещё один assign().

local function assign(subgroup, entries)
	-- Если целевая subgroup не определена (например, angelsindustries опционально
	-- отсутствует и не создал angels-*-power-poles) — пропускаем тихо, чтобы не
	-- ронять загрузку при assignID-валидации.
	if not data.raw["item-subgroup"][subgroup] then return end
	for _, entry in ipairs(entries) do
		local name, order = entry[1], entry[2]
		if data.raw.item[name] then
			data.raw.item[name].subgroup = subgroup
			data.raw.item[name].order = order
		end
		if data.raw.recipe[name] then
			data.raw.recipe[name].subgroup = subgroup
			data.raw.recipe[name].order = order
		end
	end
end

-- ============================================================
-- Электрические столбы (issue #189).
-- В 2.0 lighted-варианты (Lighted-Poles-Plus), bob's small-iron-electric-pole,
-- bi-wooden-pole-*, bi-large-substation остались в ванильной energy-pipe-distribution,
-- из-за чего «голые» столбы оказывались далеко от своих тиров. В 1.1 решал блок
-- в prototypes/micro-final-fix.lua — восстанавливаем для 2.0.
--
-- Используем существующие angels-*-power-poles сабгруппы. Каждый lighted-вариант
-- ставим сразу после своего родителя через суффикс order=-lit.
-- ============================================================

assign("angels-power-poles", {
	{ "small-electric-pole",              "a" },
	{ "lighted-small-electric-pole",      "a-lit" },
	{ "small-iron-electric-pole",         "b" },
	{ "lighted-small-iron-electric-pole", "b-lit" },
	{ "bi-wooden-pole-big",               "c" },
	{ "lighted-bi-wooden-pole-big",       "c-lit" },
	{ "bi-wooden-pole-huge",              "d" },
	{ "lighted-bi-wooden-pole-huge",      "d-lit" },
})

assign("angels-medium-power-poles", {
	{ "medium-electric-pole",               "a" },
	{ "lighted-medium-electric-pole",       "a-lit" },
	{ "bob-medium-electric-pole-2",         "b" },
	{ "lighted-bob-medium-electric-pole-2", "b-lit" },
	{ "bob-medium-electric-pole-3",         "c" },
	{ "lighted-bob-medium-electric-pole-3", "c-lit" },
	{ "bob-medium-electric-pole-4",         "d" },
	{ "lighted-bob-medium-electric-pole-4", "d-lit" },
})

assign("angels-big-power-poles", {
	{ "big-electric-pole",               "a" },
	{ "lighted-big-electric-pole",       "a-lit" },
	{ "bob-big-electric-pole-2",         "b" },
	{ "lighted-bob-big-electric-pole-2", "b-lit" },
	{ "bob-big-electric-pole-3",         "c" },
	{ "lighted-bob-big-electric-pole-3", "c-lit" },
	{ "bob-big-electric-pole-4",         "d" },
	{ "lighted-bob-big-electric-pole-4", "d-lit" },
})

assign("angels-sub-power-poles", {
	{ "substation",                  "a" },
	{ "lighted-substation",          "a-lit" },
	{ "bob-substation-2",            "b" },
	{ "lighted-bob-substation-2",    "b-lit" },
	{ "bob-substation-3",            "c" },
	{ "lighted-bob-substation-3",    "c-lit" },
	{ "bob-substation-4",            "d" },
	{ "lighted-bob-substation-4",    "d-lit" },
	{ "bi-large-substation",         "e" },
	{ "lighted-bi-large-substation", "e-lit" },
})
