-- Порт Oberhaul gems2.lua + gems.lua (1.1, в 2.0 не портированы).
--   gems2: стоимость/энергия ступеней огранки bob-<gem>-3/4/5 как в 1.1.
--   gems:  рецепты Liquify <gem> (руда самоцвета → Crystal dust), в 1.1 default ON.
-- Имена 1.1→2.0: <gem>-ore→bob-<gem>-ore, <gem>-N→bob-<gem>-N, grinding/polishing-*→bob-*,
-- crystal-dust→angels-crystal-dust, geode-processing-2→angels-geode-processing-2.
require("__zzzparanoidal__.paralib")

local gems = { "ruby", "sapphire", "emerald", "amethyst", "topaz", "diamond" }

-- ── gems2: огранка ───────────────────────────────────────────
-- Категории/unlock-техи/инструменты — 2.0, не трогаем. Значения — из 1.1.
local gem5_energy = { ruby = 17.5 } -- остальные = 20

for _, g in ipairs(gems) do
	local raw = data.raw.recipe["bob-" .. g .. "-3"]
	if raw then
		raw.energy_required = 2.5
		raw.ingredients = { { type = "item", name = "bob-" .. g .. "-ore", amount = 5 } }
		raw.results = { { type = "item", name = "bob-" .. g .. "-3", amount = 4 } }
	end
	local cut = data.raw.recipe["bob-" .. g .. "-4"]
	if cut then
		cut.energy_required = 5.5
		cut.ingredients = {
			{ type = "item", name = "bob-" .. g .. "-3", amount = 5 },
			{ type = "item", name = "bob-grinding-wheel", amount = 1 },
			{ type = "fluid", name = "water", amount = 10 },
		}
		cut.results = { { type = "item", name = "bob-" .. g .. "-4", amount = 1 } }
	end
	local pol = data.raw.recipe["bob-" .. g .. "-5"]
	if pol then
		pol.energy_required = gem5_energy[g] or 20
		pol.ingredients = {
			{ type = "item", name = "bob-" .. g .. "-4", amount = 5 },
			{ type = "item", name = "bob-polishing-wheel", amount = 1 },
			{ type = "item", name = "bob-polishing-compound", amount = 1 },
		}
		pol.results = { { type = "item", name = "bob-" .. g .. "-5", amount = 1 } }
	end
end

-- ── gems: ликвефакция ────────────────────────────────────────
-- Только при наличии руд самоцветов (bobores) и crystal-dust (angelsrefining).
local dust = data.raw.item["angels-crystal-dust"]
if dust then
	local order = { ruby = "a", sapphire = "b", emerald = "c", amethyst = "d", topaz = "e", diamond = "f" }
	for _, g in ipairs(gems) do
		local ore = data.raw.item["bob-" .. g .. "-ore"]
		if ore then
			local recipe = {
				type = "recipe",
				name = "ober-liquify-" .. g,
				-- 1.1 ore-sorting; в 2.0 здесь живёт geode→crystal-dust
				category = "angels-ore-refining-t1",
				energy_required = 1,
				enabled = false,
				ingredients = { { type = "item", name = ore.name, amount = 1 } },
				results = { { type = "item", name = dust.name, amount = 5 } },
				subgroup = "bob-gems-ore",
				order = (order[g] or "z") .. "-0",
				localised_name = { "", { "item-name." .. ore.name }, " → ", { "item-name." .. dust.name } },
			}
			if dust.icon and ore.icon then -- наложение crystal-dust + руда самоцвета (как в 1.1)
				recipe.icons = {
					{ icon = dust.icon, icon_size = dust.icon_size or 32, scale = 1 },
					{ icon = ore.icon, icon_size = ore.icon_size or 32, scale = 0.5, shift = { -9, -9 } },
				}
			end
			data:extend({ recipe })
			paralib.bobmods.lib.tech.add_recipe_unlock("angels-geode-processing-2", "ober-liquify-" .. g)
		end
	end
end
