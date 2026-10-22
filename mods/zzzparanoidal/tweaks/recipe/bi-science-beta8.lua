-- Bio Industries Beta 8: альтернативные фиолетовые колбы, потерянные в BI2.
-- Согласованная адаптация: нынешние модули I тира, без изменения самих модулей.
if not mods["Bio_Industries_2"] then return end
local technology = data.raw.technology["production-science-pack"]
if not technology or not data.raw.tool["production-science-pack"] then return end

if not data.raw.recipe["bi-production-science-pack"] then
	data:extend({
		{
			type = "recipe",
			name = "bi-production-science-pack",
			category = "crafting",
			enabled = false,
			energy_required = 21,
			ingredients = {
				{ type = "item", name = "electric-furnace", amount = 1 },
				{ type = "item", name = "productivity-module", amount = 1 },
				{ type = "item", name = "efficiency-module", amount = 1 },
				{ type = "item", name = "speed-module", amount = 1 },
			},
			results = { { type = "item", name = "production-science-pack", amount = 2 } },
			allow_productivity = true,
			always_show_products = true,
			show_amount_in_title = false,
		},
	})
end

technology.effects = technology.effects or {}
for _, effect in ipairs(technology.effects) do
	if effect.type == "unlock-recipe" and effect.recipe == "bi-production-science-pack" then return end
end
table.insert(technology.effects, { type = "unlock-recipe", recipe = "bi-production-science-pack" })
