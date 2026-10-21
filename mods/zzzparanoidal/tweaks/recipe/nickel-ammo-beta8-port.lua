-- Clowns проверяет старый bronze-alloy и не создаёт никелевый вариант патронов.
-- Итоговый рецепт Beta 8 normal, после OV и flowfix; металлы используют имена Bob 2.0.
local technology = data.raw.technology["bob-alloy-processing"]
if not technology or not data.raw.item["bob-nickel-plate"]
	or not data.raw.item["bob-bronze-alloy"]
	or not data.raw.ammo["firearm-magazine"]
	or not data.raw.ammo["piercing-rounds-magazine"] then return end

local name = "nickel-piercing-rounds-magazine"
if not data.raw.recipe[name] then
	data:extend({
		{
			type = "recipe",
			name = name,
			enabled = false,
			energy_required = 3,
			ingredients = {
				{ type = "item", name = "firearm-magazine", amount = 1 },
				{ type = "item", name = "bob-nickel-plate", amount = 5 },
				{ type = "item", name = "bob-bronze-alloy", amount = 3 },
			},
			results = { { type = "item", name = "piercing-rounds-magazine", amount = 1 } },
			always_show_products = true,
			show_amount_in_title = false,
		},
	})
end

technology.effects = technology.effects or {}
for _, effect in ipairs(technology.effects) do
	if effect.type == "unlock-recipe" and effect.recipe == name then return end
end
table.insert(technology.effects, { type = "unlock-recipe", recipe = name })
