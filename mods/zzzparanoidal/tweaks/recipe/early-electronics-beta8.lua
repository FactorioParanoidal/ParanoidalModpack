-- Beta 8 normal: цены и выход ранней электронной цепочки.
-- Категории, продуктивность, графика и характеристики машин остаются 2.0.
local ingredients = {
	["transport-belt"] = {
		{ type = "item", name = "bob-tin-plate", amount = 2 },
		{ type = "item", name = "motor", amount = 1 },
		{ type = "item", name = "bob-basic-transport-belt", amount = 2 },
	},
	["inserter"] = {
		{ type = "item", name = "burner-inserter", amount = 1 },
		{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
		{ type = "item", name = "electric-motor", amount = 2 },
	},
	["burner-inserter"] = {
		{ type = "item", name = "iron-plate", amount = 5 },
		{ type = "item", name = "motor", amount = 1 },
	},
	["repair-pack"] = {
		{ type = "item", name = "iron-gear-wheel", amount = 2 },
		{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
	},
	["bob-basic-electronic-components"] = {
		{ type = "item", name = "bob-tinned-copper-cable", amount = 1 },
		{ type = "item", name = "angels-solid-carbon", amount = 1 },
	},
	["bob-basic-circuit-board"] = {
		{ type = "item", name = "bob-wooden-board", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 3 },
		{ type = "item", name = "condensator", amount = 2 },
	},
	["burner-lab"] = {
		{ type = "item", name = "motor", amount = 10 },
		{ type = "item", name = "copper-plate", amount = 50 },
		{ type = "item", name = "stone-brick", amount = 10 },
	},
	["burner-assembling-machine"] = {
		{ type = "item", name = "iron-plate", amount = 24 },
		{ type = "item", name = "stone-brick", amount = 10 },
		{ type = "item", name = "motor", amount = 4 },
	},
}
for name, list in pairs(ingredients) do
	if data.raw.recipe[name] then data.raw.recipe[name].ingredients = list end
end
local times = { ["motor"] = 1, ["electric-motor"] = 1.5, ["burner-lab"] = 5, ["burner-assembling-machine"] = 5 }
for name, time in pairs(times) do
	if data.raw.recipe[name] then data.raw.recipe[name].energy_required = time end
end
for _, name in ipairs({ "motor", "electric-motor", "copper-cable", "burner-lab" }) do
	if data.raw.recipe[name] then data.raw.recipe[name].enabled = true end
end
if data.raw.recipe["transport-belt"] then
	data.raw.recipe["transport-belt"].results = { { type = "item", name = "transport-belt", amount = 1 } }
end
if data.raw.recipe["bob-wooden-board"] then
	data.raw.recipe["bob-wooden-board"].results = { { type = "item", name = "bob-wooden-board", amount = 2 } }
end
-- Видимый аналог electronic-circuit Beta 8; скрытый stone-tablet рецепт не трогаем.
if data.raw.recipe["electronic-circuit-wood"] then data.raw.recipe["electronic-circuit-wood"].order = nil end
