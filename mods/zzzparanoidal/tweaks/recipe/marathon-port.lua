-- Marathon-port: restores 1.1 in-game recipe state in 2.0. Target = recipe
-- after the full 1.1 mod chain (marathon + bobpower-updates + angelsrefining
-- OV.patch + KaoExtended), not raw marathon source.

require("__zzzparanoidal__.paralib")


-- Ammo

paralib.bobmods.lib.recipe.set_ingredients("firearm-magazine", {
	{ type = "item", name = "iron-plate", amount = 5 },
})
data.raw.recipe["firearm-magazine"].energy_required = 2

paralib.bobmods.lib.recipe.set_ingredients("rocket", {
	{ type = "item", name = "electronic-circuit", amount = 1 },
	{ type = "item", name = "explosives", amount = 2 },
	{ type = "item", name = "angels-rocket-booster", amount = 1 },
})
data.raw.recipe["rocket"].energy_required = 8


-- Armor

-- light-armor: just bump iron-plate so other mods can still add their ingredients
-- (e.g., toxicPollution restoring respirator × 1).
paralib.bobmods.lib.recipe.set_ingredient("light-armor", { type = "item", name = "iron-plate", amount = 100 })
data.raw.recipe["light-armor"].energy_required = 5

paralib.bobmods.lib.recipe.set_ingredients("heavy-armor", {
	{ type = "item", name = "copper-plate", amount = 500 },
	{ type = "item", name = "steel-plate", amount = 50 },
	{ type = "item", name = "light-armor", amount = 1 },
})
data.raw.recipe["heavy-armor"].energy_required = 10


-- Bob pipes

paralib.bobmods.lib.recipe.set_ingredient("bob-copper-pipe", { type = "item", name = "copper-plate", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("bob-copper-pipe-to-ground", {
	{ type = "item", name = "bob-copper-pipe", amount = 10 },
	{ type = "item", name = "copper-plate", amount = 15 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-steel-pipe", { type = "item", name = "steel-plate", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("bob-steel-pipe-to-ground", {
	{ type = "item", name = "bob-steel-pipe", amount = 15 },
	{ type = "item", name = "steel-plate", amount = 15 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-plastic-pipe", { type = "item", name = "plastic-bar", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("bob-plastic-pipe-to-ground", {
	{ type = "item", name = "bob-plastic-pipe", amount = 100 },
	{ type = "item", name = "plastic-bar", amount = 200 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-bronze-pipe", { type = "item", name = "bob-bronze-alloy", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("bob-bronze-pipe-to-ground", {
	{ type = "item", name = "bob-bronze-pipe", amount = 15 },
	{ type = "item", name = "bob-bronze-alloy", amount = 15 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-brass-pipe", { type = "item", name = "bob-brass-alloy", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("bob-brass-pipe-to-ground", {
	{ type = "item", name = "bob-brass-pipe", amount = 20 },
	{ type = "item", name = "bob-brass-alloy", amount = 15 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-titanium-pipe", { type = "item", name = "bob-silicon-nitride", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("bob-titanium-pipe-to-ground", {
	{ type = "item", name = "bob-titanium-pipe", amount = 25 },
	{ type = "item", name = "bob-silicon-nitride", amount = 15 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-titanium-pipe", { type = "item", name = "bob-titanium-plate", amount = 2 })

paralib.bobmods.lib.recipe.set_ingredients("bob-titanium-pipe-to-ground", {
	{ type = "item", name = "bob-titanium-pipe", amount = 25 },
	{ type = "item", name = "bob-titanium-plate", amount = 10 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-tungsten-pipe", { type = "item", name = "tungsten-plate", amount = 2 })

paralib.bobmods.lib.recipe.set_ingredients("bob-tungsten-pipe-to-ground", {
	{ type = "item", name = "bob-tungsten-pipe", amount = 25 },
	{ type = "item", name = "tungsten-plate", amount = 10 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-copper-tungsten-pipe", { type = "item", name = "bob-nitinol-alloy", amount = 2 })

paralib.bobmods.lib.recipe.set_ingredients("bob-copper-tungsten-pipe-to-ground", {
	{ type = "item", name = "bob-copper-tungsten-pipe", amount = 250 },
	{ type = "item", name = "bob-nitinol-alloy", amount = 100 },
})

paralib.bobmods.lib.recipe.set_ingredient("bob-copper-tungsten-pipe", { type = "item", name = "bob-copper-tungsten-alloy", amount = 2 })

paralib.bobmods.lib.recipe.set_ingredients("bob-copper-tungsten-pipe-to-ground", {
	{ type = "item", name = "bob-copper-tungsten-pipe", amount = 250 },
	{ type = "item", name = "bob-copper-tungsten-alloy", amount = 100 },
})

paralib.bobmods.lib.recipe.set_ingredients("bob-small-inline-storage-tank", {
	{ type = "item", name = "iron-plate", amount = 25 },
	{ type = "item", name = "pipe", amount = 4 },
})


-- Bob pumps

paralib.bobmods.lib.recipe.set_ingredients("bob-pump-2", {
	{ type = "item", name = "pump", amount = 2 },
	{ type = "item", name = "bob-aluminium-plate", amount = 10 },
	{ type = "item", name = "bob-bronze-pipe", amount = 6 },
})
data.raw.recipe["bob-pump-2"].energy_required = 5

paralib.bobmods.lib.recipe.set_ingredients("bob-pump-3", {
	{ type = "item", name = "bob-pump-2", amount = 2 },
	{ type = "item", name = "bob-titanium-plate", amount = 10 },
	{ type = "item", name = "bob-brass-pipe", amount = 6 },
})
data.raw.recipe["bob-pump-3"].energy_required = 5

paralib.bobmods.lib.recipe.set_ingredients("bob-pump-4", {
	{ type = "item", name = "bob-pump-3", amount = 2 },
	{ type = "item", name = "bob-nitinol-alloy", amount = 10 },
	{ type = "item", name = "bob-copper-tungsten-pipe", amount = 6 },
})
data.raw.recipe["bob-pump-4"].energy_required = 5


-- Steam-engine 2..5 — moved here from final-fixes/recipies.lua (was PR #236).
-- bob-steam-engine-3: brass-gear-wheel + steel-bearing 20 — Angels OV.patch downgrades
-- the cobalt-steel-* variants to brass+steel in both 1.1 and 2.0.

paralib.bobmods.lib.recipe.set_ingredients("bob-steam-engine-2", {
	{ type = "item", name = "steel-plate", amount = 75 },
	{ type = "item", name = "bob-steel-pipe", amount = 25 },
	{ type = "item", name = "bob-steel-gear-wheel", amount = 25 },
	{ type = "item", name = "bob-steel-bearing", amount = 20 },
	{ type = "item", name = "basic-structure-components", amount = 1 },
	{ type = "item", name = "steam-engine", amount = 2 },
})
data.raw.recipe["bob-steam-engine-2"].energy_required = 50

paralib.bobmods.lib.recipe.set_ingredients("bob-steam-engine-3", {
	{ type = "item", name = "bob-brass-pipe", amount = 25 },
	{ type = "item", name = "bob-brass-alloy", amount = 45 },
	{ type = "item", name = "bob-brass-gear-wheel", amount = 25 },
	{ type = "item", name = "bob-steel-bearing", amount = 20 },
	{ type = "item", name = "intermediate-structure-components", amount = 1 },
	{ type = "item", name = "bob-steam-engine-2", amount = 2 },
})
data.raw.recipe["bob-steam-engine-3"].energy_required = 40

paralib.bobmods.lib.recipe.set_ingredients("bob-steam-engine-4", {
	{ type = "item", name = "bob-titanium-pipe", amount = 25 },
	{ type = "item", name = "bob-titanium-plate", amount = 40 },
	{ type = "item", name = "bob-titanium-gear-wheel", amount = 25 },
	{ type = "item", name = "bob-titanium-bearing", amount = 25 },
	{ type = "item", name = "bob-steam-engine-3", amount = 2 },
})
data.raw.recipe["bob-steam-engine-4"].energy_required = 30

paralib.bobmods.lib.recipe.set_ingredients("bob-steam-engine-5", {
	{ type = "item", name = "bob-copper-tungsten-pipe", amount = 25 },
	{ type = "item", name = "bob-nitinol-alloy", amount = 40 },
	{ type = "item", name = "bob-nitinol-gear-wheel", amount = 25 },
	{ type = "item", name = "bob-nitinol-bearing", amount = 25 },
	{ type = "item", name = "bob-steam-engine-4", amount = 2 },
})
data.raw.recipe["bob-steam-engine-5"].energy_required = 20


-- Circuit

paralib.bobmods.lib.recipe.set_ingredient("copper-cable", { type = "item", name = "copper-plate", amount = 5 })
data.raw.recipe["copper-cable"].energy_required = 2

-- electronic-circuit (stone-tablet path): hidden, electronic-circuit-wood takes over (see below).
paralib.bobmods.lib.recipe.hide("electronic-circuit")

paralib.bobmods.lib.recipe.set_ingredients("bob-circuit-board", {
	{ type = "item", name = "bob-phenolic-board", amount = 2 },
	{ type = "item", name = "copper-plate", amount = 4 },
	{ type = "fluid", name = "angels-liquid-ferric-chloride-solution", amount = 10 },
	{ type = "item", name = "bob-tin-plate", amount = 3 },
})

paralib.bobmods.lib.recipe.set_ingredients("bob-superior-circuit-board", {
	{ type = "item", name = "bob-fibreglass-board", amount = 2 },
	{ type = "item", name = "copper-plate", amount = 5 },
	{ type = "fluid", name = "angels-liquid-ferric-chloride-solution", amount = 15 },
	{ type = "item", name = "bob-silver-plate", amount = 1 },
})


-- Intermediates

data.raw.recipe["iron-gear-wheel"].energy_required = 1.5

paralib.bobmods.lib.recipe.set_ingredients("low-density-structure", {
	{ type = "item", name = "plastic-bar", amount = 15 },
	{ type = "item", name = "bob-titanium-plate", amount = 15 },
	{ type = "item", name = "bob-aluminium-plate", amount = 30 },
})
data.raw.recipe["low-density-structure"].energy_required = 45


-- Logistics

paralib.bobmods.lib.recipe.set_ingredient("iron-chest", { type = "item", name = "iron-plate", amount = 20 })

paralib.bobmods.lib.recipe.set_ingredients("steel-chest", {
	{ type = "item", name = "steel-plate", amount = 32 },
	{ type = "item", name = "iron-chest", amount = 2 },
})

paralib.bobmods.lib.recipe.set_ingredients("bob-brass-chest", {
	{ type = "item", name = "bob-brass-alloy", amount = 16 },
	{ type = "item", name = "steel-chest", amount = 2 },
})

paralib.bobmods.lib.recipe.set_ingredients("bob-titanium-chest", {
	{ type = "item", name = "bob-titanium-plate", amount = 16 },
	{ type = "item", name = "bob-brass-chest", amount = 2 },
})

paralib.bobmods.lib.recipe.set_ingredient("wooden-chest", { type = "item", name = "wood", amount = 16 })

paralib.bobmods.lib.recipe.set_ingredient("pipe", { type = "item", name = "iron-plate", amount = 4 })

paralib.bobmods.lib.recipe.set_ingredients("pipe-to-ground", {
	{ type = "item", name = "pipe", amount = 10 },
	{ type = "item", name = "iron-plate", amount = 10 },
})

paralib.bobmods.lib.recipe.set_ingredients("rail", {
	{ type = "item", name = "iron-stick", amount = 2 },
	{ type = "item", name = "steel-plate", amount = 2 },
	{ type = "item", name = "stone-crushed", amount = 10 },
	{ type = "item", name = "concrete", amount = 6 },
})


-- Other

paralib.bobmods.lib.recipe.set_ingredients("small-lamp", {
	{ type = "item", name = "iron-stick", amount = 4 },
	{ type = "item", name = "iron-plate", amount = 2 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
})

paralib.bobmods.lib.recipe.set_ingredients("gun-turret", {
	{ type = "item", name = "iron-plate", amount = 25 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 8 },
	{ type = "item", name = "iron-gear-wheel", amount = 16 },
	{ type = "item", name = "motor", amount = 4 },
})
data.raw.recipe["gun-turret"].energy_required = 10

data.raw.recipe["landfill"].energy_required = 2


-- Production / machines

paralib.bobmods.lib.recipe.set_ingredients("electric-mining-drill", {
	{ type = "item", name = "iron-plate", amount = 100 },
	{ type = "item", name = "iron-gear-wheel", amount = 10 },
	{ type = "item", name = "electric-motor", amount = 4 },
	{ type = "item", name = "burner-mining-drill", amount = 1 },
	{ type = "item", name = "mining-drill-bit-mk1", amount = 1 },
})
data.raw.recipe["electric-mining-drill"].energy_required = 10

paralib.bobmods.lib.recipe.set_ingredients("steel-furnace", {
	{ type = "item", name = "steel-plate", amount = 25 },
	{ type = "item", name = "stone-brick", amount = 10 },
	{ type = "item", name = "stone-furnace", amount = 2 },
})
data.raw.recipe["steel-furnace"].energy_required = 10

data.raw.recipe["assembling-machine-1"].energy_required = 5

paralib.bobmods.lib.recipe.set_ingredients("assembling-machine-2", {
	{ type = "item", name = "electronic-circuit", amount = 25 },
	{ type = "item", name = "assembling-machine-1", amount = 2 },
	{ type = "item", name = "electric-motor", amount = 4 },
	{ type = "item", name = "basic-structure-components", amount = 1 },
})
data.raw.recipe["assembling-machine-2"].energy_required = 10

paralib.bobmods.lib.recipe.set_ingredients("boiler", {
	{ type = "item", name = "iron-plate", amount = 20 },
	{ type = "item", name = "stone-furnace", amount = 2 },
	{ type = "item", name = "pipe", amount = 15 },
})

data.raw.recipe["steam-engine"].energy_required = 60

paralib.bobmods.lib.recipe.set_ingredients("accumulator", {
	{ type = "item", name = "iron-plate", amount = 10 },
	{ type = "item", name = "battery", amount = 10 },
	{ type = "item", name = "electronic-circuit", amount = 3 },
})
data.raw.recipe["accumulator"].energy_required = 20


-- Science packs

paralib.bobmods.lib.recipe.set_ingredients("lab", {
	{ type = "item", name = "electronic-circuit", amount = 25 },
	{ type = "item", name = "electric-motor", amount = 10 },
	{ type = "item", name = "burner-lab", amount = 2 },
})
data.raw.recipe["lab"].energy_required = 20

data.raw.recipe["automation-science-pack"].energy_required = 10
data.raw.recipe["logistic-science-pack"].energy_required = 15


-- Weapons

paralib.bobmods.lib.recipe.set_ingredients("pistol", {
	{ type = "item", name = "copper-plate", amount = 25 },
	{ type = "item", name = "iron-plate", amount = 25 },
})
data.raw.recipe["pistol"].energy_required = 1

paralib.bobmods.lib.recipe.set_ingredients("submachine-gun", {
	{ type = "item", name = "iron-gear-wheel", amount = 25 },
	{ type = "item", name = "copper-plate", amount = 25 },
	{ type = "item", name = "iron-plate", amount = 25 },
})
data.raw.recipe["submachine-gun"].energy_required = 3

paralib.bobmods.lib.recipe.set_ingredients("shotgun", {
	{ type = "item", name = "iron-plate", amount = 25 },
	{ type = "item", name = "iron-gear-wheel", amount = 10 },
	{ type = "item", name = "copper-plate", amount = 50 },
	{ type = "item", name = "wood", amount = 5 },
})
data.raw.recipe["shotgun"].energy_required = 4

paralib.bobmods.lib.recipe.set_ingredients("combat-shotgun", {
	{ type = "item", name = "steel-plate", amount = 15 },
	{ type = "item", name = "iron-gear-wheel", amount = 10 },
	{ type = "item", name = "copper-plate", amount = 50 },
	{ type = "item", name = "wood", amount = 10 },
})
data.raw.recipe["combat-shotgun"].energy_required = 8


-- Stack-size buffs (1.1: prototypes/item.lua)

data.raw.item["bob-basic-electronic-components"].stack_size = 400
data.raw.item["iron-plate"].stack_size = 400
data.raw.item["copper-plate"].stack_size = 400
data.raw.item["copper-cable"].stack_size = 400


-- electronic-circuit-wood: replaces the hidden electronic-circuit (stone-tablet path).
-- Icon dropped to single-layer; recipe order matches the electronic-circuit item so
-- bob-basic-circuit-board sorts to the left of it.

paralib.bobmods.lib.recipe.set_ingredients("electronic-circuit-wood", {
	{ type = "item", name = "bob-basic-electronic-components", amount = 16 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 1 },
	{ type = "item", name = "copper-cable", amount = 4 },
	{ type = "item", name = "bob-solder", amount = 1 },
})
data.raw.recipe["electronic-circuit-wood"].energy_required = 6
do
	local r = data.raw.recipe["electronic-circuit-wood"]
	r.icons = nil
	r.icon = "__bobelectronics__/graphics/icons/basic-electronic-circuit-board.png"
	r.icon_size = 64
end
data.raw.recipe["electronic-circuit-wood"].order = "y[vanilla]-a"


-- stone-tablet: orphan after electronic-circuit hidden (it was the only consumer).

paralib.bobmods.lib.recipe.hide("stone-tablet")
bobmods.lib.item.hide("stone-tablet")
