-- Paranoidal fork: N4 (y-res1, УниКомпозитный кусок) and F7 (y-res2, Энергоминерал) come only from centrifuging
-- Angels' super-pure ores (user decisions 2026-10-23/24):
--   N4 = super-pure saphirite + rubyte + bobmonium (angels-ore1/5/6-pure),
--   F7 = super-pure jivolite + stiratite + crotinnium (angels-ore2/3/4-pure).
-- 1 + 1 + 1 -> 3 in any centrifuge; a crystal seed raises it to 5 (centrifuge 2+), a seed plus a Lachnan crystal
-- catalyst (returned with 90 %) to 8 (centrifuge 3). Crystallisation no longer makes chunks itself: it grows seeds.
local P = require("prototypes.paranoidal.lib")

data:extend({
	{
		type = "item",
		name = "y-crystal-seed",
		icons = {
			{ icon = "__Yuoki__/graphics/icons/yb-dusts.png", icon_size = 64 },
			{ icon = "__Yuoki__/graphics/icons/crystal_3.png", icon_size = 64, scale = 0.25, shift = { 8, 8 } },
		},
		subgroup = "y_line2",
		order = "q0",
		stack_size = 100,
	},
})

-- Seeded washing emulsion: the crystallisation line starts from Yuoki rich dust, not from stone alone.
P.ingredients("y_emulsion", {
	{ "y_steinmehl", 4 },
	{ "y-richdust", 1 },
	{ "water", 200, "fluid" },
})
P.result_amount("y_emulsion", "y_emulsion", 100)

local function seed_recipe(name, ingredients, order)
	table.insert(ingredients, { "steam", 100, "fluid" })
	data:extend({
		{
			type = "recipe",
			name = name,
			category = "yrcat_crystalize",
			energy_required = 8,
			enabled = false,
			ingredients = P.list(ingredients),
			results = { { type = "item", name = "y-crystal-seed", amount = 1 } },
			main_product = "y-crystal-seed",
			subgroup = "y_line2",
			order = order,
		},
	})
end
seed_recipe("y-crystal-seed", { { "y_crystal_dust", 4 } }, "q1")
seed_recipe("y-crystal-seed-fragment", { { "y_crystal_dust", 2 }, { "y-crystal2", 4 } }, "q2")
seed_recipe("y-crystal-seed-geode", { { "y_crystal_dust", 2 }, { "angels-crystal-dust", 10 } }, "q3")

if mods["angelsrefining"] then
	local ores = {
		n4 = { result = "y-res1", ores = { "angels-ore1-pure", "angels-ore5-pure", "angels-ore6-pure" }, order = "r1" },
		f7 = { result = "y-res2", ores = { "angels-ore2-pure", "angels-ore3-pure", "angels-ore4-pure" }, order = "r2" },
	}
	for key, o in pairs(ores) do
		local function make(suffix, category, time, extra, amount, extra_results)
			local ingredients = {}
			for _, ore in ipairs(o.ores) do
				ingredients[#ingredients + 1] = { ore, 1 }
			end
			for _, e in ipairs(extra) do
				ingredients[#ingredients + 1] = e
			end
			local results = { { type = "item", name = o.result, amount = amount } }
			for _, r in ipairs(extra_results or {}) do
				results[#results + 1] = r
			end
			data:extend({
				{
					type = "recipe",
					name = "y-centrifuge-" .. key .. suffix,
					category = category,
					energy_required = time,
					enabled = false,
					ingredients = P.list(ingredients),
					results = results,
					main_product = o.result,
					allow_productivity = true,
					subgroup = "y_line2",
					order = o.order .. suffix,
				},
			})
		end
		make("", "centrifuging", 5, {}, 3)
		make("-seeded", "angels-centrifuging-2", 8, { { "y-crystal-seed", 1 } }, 5)
		make("-catalytic", "angels-centrifuging-3", 12, { { "y-crystal-seed", 1 }, { "y-crystal-cnd", 1 } }, 8, {
			{
				type = "item",
				name = "y-crystal-cnd",
				amount = 1,
				probability = 0.9,
				ignored_by_productivity = 1,
				ignored_by_stats = 1,
			},
		})
	end
end
