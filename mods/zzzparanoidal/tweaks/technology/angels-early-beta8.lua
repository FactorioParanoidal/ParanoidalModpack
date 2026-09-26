-- Beta 8 normal: ранняя металлургия, химия и биопереработка.
-- Только проверенные unit/prerequisites и открытия; механики и бесконечные технологии не меняются.
-- После OV.execute и предыдущих пачек прогрессии.
local definitions = {
	["steel-processing"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 5,
		},
		["prerequisites"] = { "angels-steel-smelting-1", "electric-mining-drill" },
	},
	["plastics"] = {
		["prerequisites"] = { "angels-basic-chemistry-2", "angels-advanced-chemistry-1", "angels-plastic-1" },
	},
	["bob-alloy-processing"] = {
		["unit"] = {
			["count"] = 25,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-bronze-smelting-1" },
	},
	["bob-polishing"] = {
		["prerequisites"] = { "angels-oil-processing", "angels-aluminium-smelting-1" },
	},
	["bob-silicon-processing"] = {
		["unit"] = {
			["count"] = 50,
			["time"] = 30,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
		},
		["prerequisites"] = { "angels-silicon-smelting-1", "angels-coal-processing", "angels-chlorine-processing-2" },
	},
	["angels-advanced-ore-refining-1"] = {
		["prerequisites"] = { "angels-slag-processing-1" },
	},
	["angels-slag-processing-1"] = {
		["prerequisites"] = { "angels-sulfur-processing-1", "basic-fluid-handling" },
	},
	["angels-ore-floatation"] = {
		["prerequisites"] = { "angels-basic-chemistry-3" },
	},
	["angels-water-treatment-2"] = {
		["prerequisites"] = { "angels-water-treatment", "angels-ore-floatation", "angels-metallurgy-2" },
	},
	["angels-water-washing-1"] = {
		["unit"] = {
			["count"] = 30,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 15,
		},
		["prerequisites"] = { "angels-water-treatment" },
	},
	["angels-water-washing-2"] = {
		["prerequisites"] = { "angels-water-washing-1", "landfill", "angels-metallurgy-2" },
	},
	["angels-basic-chemistry-3"] = {
		["prerequisites"] = { "angels-basic-chemistry-2", "angels-coal-processing", "fluid-handling" },
	},
	["angels-coal-processing-2"] = {
		["prerequisites"] = { "angels-coal-processing", "angels-advanced-chemistry-1" },
	},
	["angels-nitrogen-processing-1"] = {
		["prerequisites"] = { "angels-basic-chemistry" },
	},
	["angels-nitrogen-processing-2"] = {
		["prerequisites"] = { "angels-nitrogen-processing-1", "angels-sulfur-processing-1", "angels-advanced-chemistry-1", "angels-chlorine-processing-1" },
	},
	["angels-chlorine-processing-1"] = {
		["prerequisites"] = { "angels-gas-processing" },
	},
	["angels-advanced-chemistry-1"] = {
		["prerequisites"] = { "angels-ore-floatation", "angels-metallurgy-2" },
	},
	["angels-resin-1"] = {
		["prerequisites"] = { "angels-nitrogen-processing-2", "angels-resins" },
	},
	["angels-rubbers"] = {
		["prerequisites"] = { "angels-oil-processing", "circuit-network" },
	},
	["angels-gunmetal-smelting-1"] = {
		["prerequisites"] = { "angels-zinc-smelting-1", "angels-copper-smelting-1" },
	},
	["angels-invar-smelting-1"] = {
		["prerequisites"] = { "angels-nickel-smelting-1", "bob-brass-processing" },
	},
	["angels-steel-smelting-1"] = {
		["prerequisites"] = { "angels-iron-smelting-1", "angels-nitrogen-processing-1", "angels-flare-stack" },
	},
	["angels-copper-smelting-2"] = {
		["prerequisites"] = { "angels-ore-processing-1", "angels-copper-smelting-1" },
	},
	["angels-glass-smelting-1"] = {
		["prerequisites"] = { "angels-powder-metallurgy-2" },
	},
	["angels-iron-smelting-2"] = {
		["prerequisites"] = { "angels-ore-processing-1", "angels-iron-smelting-1" },
	},
	["angels-iron-casting-2"] = {
		["prerequisites"] = { "angels-strand-casting-1", "angels-manganese-smelting-1", "angels-silicon-smelting-1" },
	},
	["angels-lead-smelting-2"] = {
		["prerequisites"] = { "angels-ore-processing-1", "angels-lead-smelting-1" },
	},
	["angels-lead-casting-2"] = {
		["prerequisites"] = { "angels-strand-casting-1" },
	},
	["angels-manganese-smelting-1"] = {
		["prerequisites"] = { "angels-ore-advanced-crushing", "angels-coal-processing", "angels-iron-smelting-1" },
	},
	["angels-silicon-smelting-1"] = {
		["prerequisites"] = { "angels-metallurgy-2", "angels-nitrogen-processing-1" },
	},
	["angels-stone-smelting-1"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-water-washing-1", "angels-metallurgy-1" },
	},
	["angels-stone-smelting-2"] = {
		["prerequisites"] = { "angels-powder-metallurgy-2", "angels-stone-smelting-1" },
	},
	["angels-metallurgy-2"] = {
		["prerequisites"] = { "angels-metallurgy-1", "advanced-material-processing", "bob-brass-processing" },
	},
	["angels-powder-metallurgy-2"] = {
		["prerequisites"] = { "angels-metallurgy-2" },
	},
	["angels-strand-casting-1"] = {
		["prerequisites"] = { "angels-metallurgy-2", "angels-stone-smelting-1" },
	},
	["angels-ore-processing-1"] = {
		["prerequisites"] = { "angels-metallurgy-2" },
	},
	["angels-cooling"] = {
		["prerequisites"] = { "advanced-material-processing" },
	},
	["angels-tin-smelting-2"] = {
		["prerequisites"] = { "angels-ore-processing-1", "angels-tin-smelting-1" },
	},
	["angels-tin-casting-2"] = {
		["prerequisites"] = { "angels-copper-casting-2" },
	},
	["angels-zinc-smelting-1"] = {
		["prerequisites"] = { "angels-ore-floatation", "angels-metallurgy-2" },
	},
	["angels-bio-processing-brown"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "burner-mechanics", "basic-fluid-handling" },
	},
	["angels-bio-processing-green"] = {
		["prerequisites"] = { "angels-bio-processing-brown", "angels-water-treatment", "basic-fluid-handling", "angels-metallurgy-1", "electronics" },
	},
	["angels-bio-arboretum-1"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-bio-wood-processing", "angels-bio-farm-1" },
	},
	["angels-bio-paper-1"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-bio-processing-brown" },
	},
	["angels-bio-paper-2"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-bio-paper-1", "angels-nitrogen-processing-2", "angels-sulfur-processing-2" },
	},
	["angels-bio-processing-paste"] = {
		["prerequisites"] = { "angels-bio-processing-brown", "angels-bio-nutrient-paste", "angels-chlorine-processing-1" },
	},
	["angels-bio-processing-alien-1"] = {
		["prerequisites"] = { "angels-bio-refugium-fish-1", "angels-bio-processing-red", "angels-bio-processing-paste" },
	},
	["angels-gardens"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "steel-processing" },
	},
	["angels-gardens-2"] = {
		["prerequisites"] = { "angels-bio-farm-1", "angels-bio-paper-1", "logistic-science-pack" },
	},
	["angels-bio-farm-1"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-gardens", "angels-water-washing-1", "phosphorus-processing-1" },
	},
	["angels-bio-farm-2"] = {
		["prerequisites"] = { "angels-bio-farm-1", "angels-nitrogen-processing-2", "angels-stone-smelting-2", "angels-glass-smelting-1" },
	},
	["angels-bio-farm-alien"] = {
		["prerequisites"] = { "angels-bio-farm-2", "angels-bio-processing-alien-1", "angels-bio-refugium-butchery-1", "angels-gardens-2" },
	},
	["angels-bio-nutrient-paste"] = {
		["prerequisites"] = { "angels-bio-farm-1", "angels-gas-processing" },
	},
	["angels-bio-refugium-fish-1"] = {
		["prerequisites"] = { "angels-bio-nutrient-paste" },
	},
	["phosphorus-processing-1"] = {
		["unit"] = {
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
			["count"] = 50,
		},
		["prerequisites"] = { "angels-sulfur-processing-1" },
	},
	["angels-alloys-smelting-1"] = {
		["prerequisites"] = { "angels-zinc-smelting-1", "bob-alloy-processing" },
	},
	["angels-ironworks-2"] = {
		["prerequisites"] = { "angels-steel-smelting-1", "angels-ironworks-1" },
	},
}
for name, fields in pairs(definitions) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		for field, value in pairs(fields) do technology[field] = value end
		technology.research_trigger = nil
	end
end

-- Перемещаем только перечисленные старые рецепты, не подменяем весь effects.
local moves = {
	{
		["recipe"] = "bi-slag-slurry",
		["technologies"] = { "angels-slag-processing-1" },
	},
	{
		["recipe"] = "chemical-plant",
		["technologies"] = { "angels-basic-chemistry" },
	},
	{
		["recipe"] = "angels-clarifier",
		["technologies"] = { "angels-water-treatment" },
	},
	{
		["recipe"] = "angels-solid-clay",
		["technologies"] = { "angels-water-washing-1" },
	},
	{
		["recipe"] = "angels-solid-limestone",
		["technologies"] = { "angels-water-washing-1" },
	},
	{
		["recipe"] = "angels-water-viscous-mud",
		["technologies"] = { "angels-water-washing-1" },
	},
	{
		["recipe"] = "angels-crystal-dust-liquify",
		["technologies"] = { "angels-geode-processing-2" },
	},
	{
		["recipe"] = "angels-crystal-slurry-filtering-conversion-1",
		["technologies"] = { "angels-geode-processing-2" },
	},
	{
		["recipe"] = "angels-gas-chlor-methane",
		["technologies"] = { "angels-chlorine-processing-1" },
	},
	{
		["recipe"] = "acetone-cyanohydrin-synthesis",
		["technologies"] = { "angels-nitrogen-processing-2" },
	},
	{
		["recipe"] = "bob-silicon-powder",
		["technologies"] = { "bob-silicon-processing" },
	},
	{
		["recipe"] = "angels-solid-alginic-acid",
		["technologies"] = { "angels-bio-processing-brown" },
	},
	{
		["recipe"] = "angels-algae-brown-burning",
		["technologies"] = { "angels-bio-processing-green" },
	},
	{
		["recipe"] = "angels-algae-brown-burning-wash",
		["technologies"] = { "angels-bio-processing-green" },
	},
	{
		["recipe"] = "angels-cellulose-fiber-raw-wood",
		["technologies"] = { "angels-bio-wood-processing" },
	},
	{
		["recipe"] = "angels-bio-processor",
		["technologies"] = { "angels-bio-farm-1" },
	},
	{
		["recipe"] = "angels-composter",
		["technologies"] = { "angels-bio-farm-1" },
	},
	{
		["recipe"] = "angels-solid-soil",
		["technologies"] = { "angels-bio-farm-1" },
	},
	{
		["recipe"] = "angels-solid-soil-alternative",
		["technologies"] = { "angels-bio-farm-2" },
	},
	{
		["recipe"] = "angels-bio-tile",
		["technologies"] = { "angels-bio-farm-2" },
	},
	{
		["recipe"] = "angels-petri-dish",
		["technologies"] = { "angels-bio-processing-alien-1" },
	},
	{
		["recipe"] = "angels-substrate-dish",
		["technologies"] = { "angels-bio-processing-alien-1" },
	},
	{
		["recipe"] = "angels-seeded-dish",
		["technologies"] = { "angels-bio-processing-alien-1" },
	},
	{
		["recipe"] = "angels-liquid-polluted-fish-atmosphere-raw-meat",
		["technologies"] = { "angels-bio-farm-alien" },
	},
	{
		["recipe"] = "temperate-garden-generation",
		["technologies"] = { "angels-bio-farm-1" },
	},
	{
		["recipe"] = "desert-garden-generation",
		["technologies"] = { "angels-bio-farm-1" },
	},
	{
		["recipe"] = "swamp-garden-generation",
		["technologies"] = { "angels-bio-farm-1" },
	},
}
for _, move in ipairs(moves) do
	local available = data.raw.recipe[move.recipe] ~= nil
	for _, name in ipairs(move.technologies) do available = available and data.raw.technology[name] ~= nil end
	if available then
		for _, technology in pairs(data.raw.technology) do
			if technology.max_level ~= "infinite" then
				for index = #(technology.effects or {}), 1, -1 do
					local effect = technology.effects[index]
					if effect.type == "unlock-recipe" and effect.recipe == move.recipe then table.remove(technology.effects, index) end
				end
			end
		end
		for _, name in ipairs(move.technologies) do
			local technology = data.raw.technology[name]
			technology.effects = technology.effects or {}
			table.insert(technology.effects, { type = "unlock-recipe", recipe = move.recipe })
		end
	end
end
