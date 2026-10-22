-- Beta 8 normal: биокристаллы, разведение и вспомогательные установки.
-- После OV.execute; модули, эффекты и свойства животных/станков не изменяются.
if not mods["angelsbioprocessing"] then return end
local definitions = {
	["angels-bio-nutrient-paste-2"] = { ["prerequisites"] = { "angels-bio-nutrient-paste", "chemical-science-pack" }, ["unlocks"] = { "angels-nutrient-extractor-2", "angels-nutrient-extractor-3" } },
	["angels-bio-nutrient-paste-3"] = { ["enabled"] = false, ["hidden"] = true, ["unlocks"] = {  } },
	["angels-bio-pressing-1"] = { ["prerequisites"] = { "angels-bio-farm-1", "angels-slag-processing-1", "angels-oil-processing" } },
	["angels-bio-pressing-2"] = { ["unlocks"] = { "angels-liquid-raw-vegetable-oil-filtering-2", "angels-bio-press-2", "angels-bio-press-3" } },
	["angels-bio-pressing-3"] = { ["enabled"] = false, ["hidden"] = true, ["unlocks"] = {  } },
	["angels-bio-processing-alien-1"] = { ["unlocks"] = { "angels-alien-spores", "angels-alien-bacteria", "angels-petri-dish", "angels-substrate-dish", "angels-seeded-dish" } },
	["angels-bio-processing-alien-2"] = { ["prerequisites"] = { "angels-bio-processing-alien-1", "angels-geode-processing-2", "angels-ore-powderizer" }, ["unlocks"] = { "angels-crystal-powder-from-dust", "angels-crystal-powder-slurry", "angels-crystal-enhancer" } },
	["angels-bio-processing-alien-3"] = { ["prerequisites"] = { "angels-bio-processing-alien-2", "bob-gem-processing-2" }, ["unit"] = { ["count"] = 50, ["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "angels-token-bio", 1 } }, ["time"] = 30 } },
	["angels-bio-processing-crystal-full"] = { ["prerequisites"] = { "angels-bio-refugium-biter-3" } },
	["angels-bio-processing-crystal-shard-1"] = { ["prerequisites"] = { "angels-bio-processing-alien-1", "angels-bio-refugium-puffer-2", "angels-bio-processing-crystal-splinter-1", "angels-ore-powderizer" } },
	["angels-bio-processing-crystal-shard-2"] = { ["prerequisites"] = { "angels-bio-processing-alien-2", "angels-bio-processing-crystal-shard-1", "angels-bio-processing-crystal-splinter-2" }, ["unlocks"] = { "angels-crystal-shard-crystalization-2", "angels-crystal-shard-harmonic", "angels-crystal-powder-shard-blue", "angels-crystal-powder-shard-red", "angels-crystal-powder-shard-green" } },
	["angels-bio-processing-crystal-splinter-1"] = { ["prerequisites"] = { "angels-bio-refugium-fish-1", "angels-geode-processing-2", "bob-grinding" } },
	["angels-bio-processing-crystal-splinter-2"] = { ["prerequisites"] = { "angels-bio-processing-crystal-splinter-1", "angels-bio-processing-alien-1" } },
	["angels-bio-processing-crystal-splinter-3"] = { ["prerequisites"] = { "angels-bio-processing-crystal-splinter-2", "angels-bio-processing-alien-2" }, ["unlocks"] = { "angels-crystal-powder-splinter-blue", "angels-crystal-powder-splinter-red", "angels-crystal-powder-splinter-green" } },
	["angels-bio-refugium-biter-1"] = { ["prerequisites"] = { "angels-bio-farm-alien", "angels-bio-refugium-puffer-2", "angels-bio-processing-crystal-splinter-2", "stone-wall" }, ["unit"] = { ["count"] = 50, ["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "angels-token-bio", 1 } }, ["time"] = 30 } },
	["angels-bio-refugium-biter-2"] = { ["prerequisites"] = { "angels-bio-refugium-biter-1", "angels-bio-processing-crystal-shard-2" }, ["unit"] = { ["count"] = 100, ["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "angels-token-bio", 1 } }, ["time"] = 30 } },
	["angels-bio-refugium-butchery-3"] = { ["prerequisites"] = { "angels-bio-refugium-butchery-2", "chemical-science-pack", "angels-titanium-smelting-1", "processing-unit" }, ["unit"] = { ["count"] = 150, ["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } }, ["time"] = 30 } },
	["angels-bio-refugium-hatchery"] = { ["prerequisites"] = { "lamp", "chemical-science-pack" } },
	["angels-bio-refugium-hatchery-2"] = { ["prerequisites"] = { "angels-bio-refugium-hatchery", "chemical-science-pack" }, ["unit"] = { ["count"] = 100, ["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "angels-token-bio", 1 } }, ["time"] = 30 }, ["unlocks"] = { "angels-bio-hatchery-2", "angels-bio-hatchery-3" } },
	["angels-bio-refugium-hatchery-3"] = { ["enabled"] = false, ["hidden"] = true, ["unlocks"] = {  } },
	["angels-bio-refugium-puffer-1"] = { ["prerequisites"] = { "angels-bio-refugium-hatchery", "angels-bio-nutrient-paste", "angels-sulfur-processing-2", "angels-nitrogen-processing-2" } },
	["angels-bio-refugium-puffer-2"] = { ["unlocks"] = { "angels-bio-puffer-egg-1", "angels-bio-puffer-egg-2", "angels-bio-puffer-egg-3", "angels-bio-puffer-egg-4", "angels-bio-puffer-egg-5", "angels-bio-refugium-puffer-2" } },
	["angels-bio-refugium-puffer-3"] = { ["unlocks"] = { "angels-puffer-puffing-23", "angels-puffer-puffing-12", "angels-puffer-puffing-13", "angels-puffer-puffing-14", "angels-puffer-puffing-15", "angels-bio-refugium-puffer-3" } },
	["angels-bio-refugium-puffer-4"] = { ["prerequisites"] = { "angels-bio-refugium-puffer-3", "production-science-pack" }, ["unit"] = { ["count"] = 100, ["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "production-science-pack", 1 }, { "angels-token-bio", 1 } }, ["time"] = 30 } },
	["angels-bio-refugium-puffer-5"] = { ["enabled"] = false, ["hidden"] = true, ["unlocks"] = {  } },
	["angels-gardens-3"] = { ["prerequisites"] = { "angels-bio-farm-alien", "chemical-science-pack" } },
	["garden-mutation"] = { ["prerequisites"] = { "nuclear-power", "angels-gardens" } },
}
for name, definition in pairs(definitions) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		for field, value in pairs(definition) do
			if field ~= "unlocks" then technology[field] = value end
		end
		if definition.unlocks then
			local effects = {}
			for _, recipe in ipairs(definition.unlocks) do
				if data.raw.recipe[recipe] then effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe } end
			end
			for _, effect in ipairs(technology.effects or {}) do
				if effect.type ~= "unlock-recipe" then effects[#effects + 1] = effect end
			end
			technology.effects = effects
		end
	end
end
