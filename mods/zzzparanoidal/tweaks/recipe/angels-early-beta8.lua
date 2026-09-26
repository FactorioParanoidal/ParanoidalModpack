-- Beta 8 normal: цены, партии, выходы и время ранних производств Angels.
-- Категории, продуктивность, статистические метки и характеристики станков остаются 2.0.
local definitions = {
	["bob-polishing-wheel"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 1 },
			{ type = "item", name = "wood", amount = 5 },
		},
	},
	["angels-ore1-chunk"] = {
		["results"] = {
			{ type = "item", name = "angels-ore1-chunk", amount = 2 },
			{ type = "fluid", name = "angels-water-yellow-waste", amount = 50 },
			{ type = "item", name = "angels-geode-blue", amount = 1, probability = 0.5 },
		},
	},
	["angels-ore2-chunk"] = {
		["results"] = {
			{ type = "item", name = "angels-ore2-chunk", amount = 2 },
			{ type = "fluid", name = "angels-water-greenyellow-waste", amount = 50 },
			{ type = "item", name = "angels-geode-purple", amount = 1, probability = 0.5 },
		},
	},
	["angels-ore3-chunk"] = {
		["results"] = {
			{ type = "item", name = "angels-ore3-chunk", amount = 2 },
			{ type = "fluid", name = "angels-water-yellow-waste", amount = 50 },
			{ type = "item", name = "angels-geode-yellow", amount = 1, probability = 0.5 },
		},
	},
	["angels-ore4-chunk"] = {
		["results"] = {
			{ type = "item", name = "angels-ore4-chunk", amount = 2 },
			{ type = "fluid", name = "angels-water-green-waste", amount = 50 },
			{ type = "item", name = "angels-geode-lightgreen", amount = 1, probability = 0.5 },
		},
	},
	["angels-ore5-chunk"] = {
		["results"] = {
			{ type = "item", name = "angels-ore5-chunk", amount = 2 },
			{ type = "fluid", name = "angels-water-red-waste", amount = 50 },
			{ type = "item", name = "angels-geode-cyan", amount = 1, probability = 0.5 },
		},
	},
	["angels-ore6-chunk"] = {
		["results"] = {
			{ type = "item", name = "angels-ore6-chunk", amount = 2 },
			{ type = "fluid", name = "angels-water-yellow-waste", amount = 50 },
			{ type = "item", name = "angels-geode-red", amount = 1, probability = 0.5 },
		},
	},
	["angels-ore-crusher"] = {
		["ingredients"] = {
			{ type = "item", name = "stone-brick", amount = 10 },
			{ type = "item", name = "iron-gear-wheel", amount = 8 },
			{ type = "item", name = "electric-motor", amount = 4 },
			{ type = "item", name = "angels-burner-ore-crusher", amount = 2 },
		},
	},
	["angels-ore-floatation-cell"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 10 },
			{ type = "item", name = "stone-brick", amount = 20 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 12 },
			{ type = "item", name = "electric-motor", amount = 5 },
			{ type = "item", name = "basic-structure-components", amount = 1 },
		},
	},
	["angels-ore-sorting-facility"] = {
		["ingredients"] = {
			{ type = "item", name = "stone-brick", amount = 25 },
			{ type = "item", name = "iron-plate", amount = 50 },
			{ type = "item", name = "iron-gear-wheel", amount = 24 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 12 },
			{ type = "item", name = "electric-motor", amount = 12 },
		},
	},
	["angels-solid-mud-landfill"] = {
		["ingredients"] = {
			{ type = "item", name = "angels-solid-mud", amount = 250 },
		},
	},
	["angels-solid-rubber"] = {
		["results"] = {
			{ type = "item", name = "bob-rubber", amount = 8 },
		},
	},
	["angels-gas-epichlorohydrin"] = {
		["ingredients"] = {
			{ type = "fluid", name = "angels-gas-allylchlorid", amount = 100 },
			{ type = "fluid", name = "angels-liquid-hydrochloric-acid", amount = 50 },
			{ type = "item", name = "angels-solid-sodium-hydroxide", amount = 5 },
		},
	},
	["angels-solder"] = {
		["results"] = {
			{ type = "item", name = "bob-solder", amount = 3 },
		},
	},
	["angels-solder-2"] = {
		["results"] = {
			{ type = "item", name = "bob-solder", amount = 8 },
		},
	},
	["angels-wire-copper-2"] = {
		["results"] = {
			{ type = "item", name = "copper-cable", amount = 8 },
		},
	},
	["angels-solid-glass-mixture"] = {
		["energy_required"] = 10,
		["ingredients"] = {
			{ type = "item", name = "bob-quartz", amount = 3 },
		},
		["results"] = {
			{ type = "item", name = "angels-solid-glass-mixture", amount = 4 },
		},
	},
	["angels-plate-glass"] = {
		["energy_required"] = 5,
	},
	["angels-solid-cement"] = {
		["ingredients"] = {
			{ type = "item", name = "angels-solid-lime", amount = 1 },
			{ type = "item", name = "bob-quartz", amount = 1 },
		},
	},
	["angels-wire-tin-2"] = {
		["results"] = {
			{ type = "item", name = "bob-tinned-copper-cable", amount = 8 },
		},
	},
	["angels-algae-brown-burning"] = {
		["results"] = {
			{ type = "item", name = "angels-solid-lithium", amount = 1 },
		},
	},
	["angels-solid-wood-pulp"] = {
		["energy_required"] = 4,
		["ingredients"] = {
			{ type = "item", name = "angels-cellulose-fiber", amount = 20 },
			{ type = "item", name = "angels-solid-alginic-acid", amount = 5 },
		},
	},
	["angels-solid-paper"] = {
		["energy_required"] = 4,
		["ingredients"] = {
			{ type = "item", name = "angels-solid-wood-pulp", amount = 2 },
		},
		["results"] = {
			{ type = "item", name = "angels-solid-paper", amount = 4 },
		},
	},
	["angels-solid-paper-2"] = {
		["energy_required"] = 4,
		["ingredients"] = {
			{ type = "item", name = "angels-solid-wood-pulp", amount = 2 },
			{ type = "item", name = "angels-solid-sodium-hydroxide", amount = 2 },
			{ type = "fluid", name = "angels-gas-chlorine", amount = 60 },
		},
		["results"] = {
			{ type = "item", name = "angels-solid-paper", amount = 5 },
			{ type = "item", name = "angels-solid-sodium-hypochlorite", amount = 2 },
		},
	},
	["angels-algae-farm"] = {
		["ingredients"] = {
			{ type = "item", name = "iron-plate", amount = 33 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 4 },
			{ type = "item", name = "stone-brick", amount = 55 },
			{ type = "item", name = "pipe", amount = 54 },
		},
	},
	["angels-algae-farm-2"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 33 },
			{ type = "item", name = "electronic-circuit", amount = 4 },
			{ type = "item", name = "angels-clay-brick", amount = 55 },
			{ type = "item", name = "bob-steel-pipe", amount = 54 },
			{ type = "item", name = "basic-structure-components", amount = 5 },
			{ type = "item", name = "angels-algae-farm", amount = 2 },
		},
	},
	["angels-crop-farm"] = {
		["ingredients"] = {
			{ type = "item", name = "angels-solid-soil", amount = 15 },
			{ type = "item", name = "steel-plate", amount = 24 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "stone-brick", amount = 45 },
			{ type = "item", name = "bob-steel-pipe", amount = 9 },
		},
	},
	["angels-composter"] = {
		["ingredients"] = {
			{ type = "item", name = "wooden-chest", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 6 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "stone-brick", amount = 10 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 6 },
		},
	},
	["angels-seed-extractor"] = {
		["ingredients"] = {
			{ type = "item", name = "iron-plate", amount = 3 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 4 },
			{ type = "item", name = "stone-brick", amount = 5 },
			{ type = "item", name = "iron-gear-wheel", amount = 6 },
		},
	},
	["angels-bio-processor"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 15 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 8 },
			{ type = "item", name = "stone-brick", amount = 25 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 12 },
		},
	},
	["angels-bio-generator-temperate-1"] = {
		["ingredients"] = {
			{ type = "item", name = "angels-temperate-tree", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 6 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "stone-brick", amount = 5 },
			{ type = "item", name = "bob-steel-pipe", amount = 9 },
		},
	},
	["angels-bio-generator-swamp-1"] = {
		["ingredients"] = {
			{ type = "item", name = "angels-swamp-tree", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 6 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "stone-brick", amount = 5 },
			{ type = "item", name = "bob-steel-pipe", amount = 9 },
		},
	},
	["angels-bio-generator-desert-1"] = {
		["ingredients"] = {
			{ type = "item", name = "angels-desert-tree", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 6 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "stone-brick", amount = 5 },
			{ type = "item", name = "bob-steel-pipe", amount = 9 },
		},
	},
	["angels-bio-arboretum-1"] = {
		["ingredients"] = {
			{ type = "item", name = "bob-glass", amount = 6 },
			{ type = "item", name = "steel-plate", amount = 18 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "stone-brick", amount = 30 },
			{ type = "item", name = "bob-steel-pipe", amount = 24 },
		},
	},
	["angels-bio-tile"] = {
		["ingredients"] = {
			{ type = "item", name = "concrete", amount = 2 },
			{ type = "item", name = "angels-token-bio", amount = 1 },
			{ type = "item", name = "angels-solid-soil", amount = 2 },
			{ type = "item", name = "angels-solid-glass-mixture", amount = 1 },
		},
	},
	["angels-iron-gear-wheel-stack-converting"] = {
		["results"] = {
			{ type = "item", name = "iron-gear-wheel", amount = 5 },
		},
	},
	["angels-steel-gear-wheel-stack-converting"] = {
		["results"] = {
			{ type = "item", name = "bob-steel-gear-wheel", amount = 5 },
		},
	},
	["quartz-glass"] = {
		["energy_required"] = 10.5,
	},
	["bi-slag-slurry"] = {
		["ingredients"] = {
			{ type = "fluid", name = "angels-water-saline", amount = 50 },
			{ type = "item", name = "angels-stone-crushed", amount = 40 },
			{ type = "item", name = "bi-ash", amount = 40 },
		},
	},
	["angels-plastic-pipe-casting"] = {
		["ingredients"] = {
			{ type = "fluid", name = "angels-liquid-plastic", amount = 4 },
		},
	},
}
for name, fields in pairs(definitions) do
	local recipe = data.raw.recipe[name]
	if recipe then
		for field, value in pairs(fields) do recipe[field] = value end
	end
end

-- Отсутствовавший маршрут: две бумаги -> одна деревянная плата за 4 с.
-- Новая запись не меняет категории существующих рецептов.
if not data.raw.recipe["wooden-board-paper"] and data.raw.item["bob-wooden-board"]
	and data.raw.item["angels-solid-paper"] and data.raw.technology["angels-bio-paper-1"] then
	data:extend({ {
		["name"] = "wooden-board-paper",
		["category"] = "advanced-crafting",
		["energy_required"] = 4,
		["ingredients"] = {
			{ type = "item", name = "angels-solid-paper", amount = 2 },
		},
		["results"] = {
			{ type = "item", name = "bob-wooden-board", amount = 1 },
		},
		["allow_productivity"] = false,
		["order"] = "m",
		["enabled"] = false,
		["subgroup"] = "angels-bio-paper",
		["type"] = "recipe",
	} })
	local technology = data.raw.technology["angels-bio-paper-1"]
	technology.effects = technology.effects or {}
	table.insert(technology.effects, { type = "unlock-recipe", recipe = "wooden-board-paper" })
end
