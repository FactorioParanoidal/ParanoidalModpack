-- Paranoidal fork: energy.
-- 1. Perpetual-motion fixes (machine/generator chains that returned more energy than they took). Real balance of the
--    outputs is a later task (user, 2026-10-23); these are only the minimum to keep every chain below 100 %.
-- 2. The mechanical-force (MF) power plant of Yuoki Engines and the simple Yuoki steam machines are decoupled from
--    Yuoki materials and built from mid-game products of the build (user, 2026-10-24: generators/turbines/motors are
--    not near-end-game content). Heavy MF, Obninsk, Rheinsberg and TMFW stay in the late Yuoki branch.
local P = require("prototypes.paranoidal.lib")

-- generators above 100 % turn the Angels electric boiler into an energy source
for _, generator in pairs(data.raw.generator) do
	if generator.name:find("^y") and (generator.effectivity or 1) > 1 then
		generator.effectivity = 1
	end
end
P.entity("burner-generator", "y_bg-1").burner.effectivity = 0.5

-- MF made from water by the water generator is "cold" (power transfer for machines), not a heat carrier
for _, r in pairs(P.recipe("y_mpump_mf").results) do
	if r.name == "y-mechanical-force" then
		r.temperature = 10
	end
end
P.result_amount("ye_mf_mfheatmotor_m", "y-mechanical-force", 6) -- 6 MW in, ~5 MW out
P.results("ye_steam2mf", { { type = "fluid", name = "y-mechanical-force", amount = 22, temperature = 400 },
	{ type = "fluid", name = "water", amount = 180 } }, "y-mechanical-force")
P.results("ye_steam3mf", { { type = "fluid", name = "y-mechanical-force", amount = 60, temperature = 400 },
	{ type = "fluid", name = "steam", amount = 75, temperature = 265 } }, "y-mechanical-force")
for _, r in pairs(P.recipe("ye_makesteam").results) do
	if r.name == "steam" then
		r.amount = 280
	end
end
for name, amount in pairs({ ye_rheins_HT = 380, ye_rheins_MT = 770 }) do
	for _, r in pairs(P.recipe(name).results) do
		if r.name == "steam" then
			r.amount = amount
		end
	end
end
-- liquid/gas fuel engines below the fuel value of Angels fuel oil (250 kJ) and methane (230 kJ)
P.result_amount("y-mf2b", "y-mechanical-force", 5)
P.result_amount("y-mf2c", "y-mechanical-force", 7)
-- solid-fuel engine: about 0.95 / 0.83 / 0.71 of the burned fuel instead of 1.43 / 1.19 / 1.07
P.result_amount("y-mf1a", "y-mechanical-force", 4)
P.result_amount("y-mf1a1", "y-mechanical-force", 3.5)
P.result_amount("y-mf1f", "y-mechanical-force", 3)

-- Research Center: JATMN's values instead of 208 MW / 440 pollution
local rc = P.entity("assembling-machine", "yie_science_blue_gen")
rc.energy_usage = "45MW"
rc.energy_source.emissions_per_minute = { pollution = 100 }

-- H-Metal for MF shafts, iron housings and engines is made in an ordinary assembler
P.set("yie_hard_metals", { category = "crafting" })
P.ingredients("yie_hard_metals", { { "steel-plate", 2 }, { "coal", 3 } })

local mid = {
	["y-sfe"] = { { "engine-unit", 4 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "bob-steel-gear-wheel", 6 } },
	["y-ffe"] = { { "engine-unit", 4 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "bob-steel-pipe", 6 },
		{ "advanced-circuit", 2 } },
	ye_gasmotor = { { "electric-engine-unit", 2 }, { "y-iron-case", 4 }, { "steel-plate", 6 }, { "advanced-circuit", 4 } },
	["y-seg"] = { { "electric-engine-unit", 2 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "advanced-circuit", 4 },
		{ "copper-cable", 10 } },
	["y-meg-s"] = { { "electric-engine-unit", 4 }, { "y-iron-case", 4 }, { "steel-plate", 20 }, { "advanced-circuit", 8 },
		{ "bob-steel-bearing", 4 } },
	["y_bg-1"] = { { "engine-unit", 2 }, { "y-iron-case", 2 }, { "steel-plate", 10 }, { "electronic-circuit", 2 } },
	["y-notfall-generator-s2"] = { { "steel-plate", 10 }, { "bob-steel-gear-wheel", 4 }, { "copper-cable", 4 },
		{ "y-winding", 2 } },
	["y-steam-turbine"] = { { "steam-engine", 1 }, { "y-iron-case", 2 }, { "y-winding", 4 }, { "steel-plate", 10 },
		{ "advanced-circuit", 4 } },
	["y-boiler-iv"] = { { "boiler", 1 }, { "steel-plate", 10 }, { "bob-steel-pipe", 4 }, { "y-iron-case", 2 } },
}
for name, ingredients in pairs(mid) do
	P.ingredients(name, ingredients)
end

-- Small Generator-P (primary output) had no recipe
local seg_p = table.deepcopy(P.recipe("y-seg"))
seg_p.name = "y-seg-p"
seg_p.results = { { type = "item", name = "y-seg-p", amount = 1 } }
seg_p.main_product = "y-seg-p"
data:extend({ seg_p })

-- Mixed fuel -> rocket fuel shows the product icon: a recipe icon of its own would replace the build's rocket fuel
-- icon through zzzparanoidal's recipe-item-icon-sync.
P.set("y_mixedfuel2rocketfuel", { icon = nil, icon_size = nil, icons = nil })
