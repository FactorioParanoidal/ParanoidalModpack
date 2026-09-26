-- Beta 8 normal: разъединяем слитые исследования выращивания, удобрений, садов и сундуков.
-- После OV.execute. Только прогрессия; характеристики машин и чужие дополнительные unlock не меняются.
if not mods["Bio_Industries_2"] then return end
local technologies = data.raw.technology
local clones = {
	["bi-tech-timber"] = { "bi-tech-bio-farming", { "entity-name.bi-bio-farm" } },
	["bi-tech-ash"] = { "bi-tech-coal-processing-1", { "item-name.bi-ash" } },
	["bi-tech-biomass"] = { "bi-tech-advanced-biotechnology", { "fluid-name.bi-biomass" } },
}
for tier = 2, 4 do
	clones["bi-tech-bio-farming-" .. tier] = {
		"bi-tech-bio-farming", { "", { "technology-name.bi-tech-bio-farming" }, " " .. tier },
	}
end
for tier, suffix in ipairs({ "", "-large", "-huge" }) do
	clones["bi-tech-garden-" .. tier] = { "bi-tech-fertilizer", { "entity-name.bi-bio-garden" .. suffix } }
end
for tier = 1, 2 do
	clones["bi-tech-depollution-" .. tier] = { "bi-tech-fertilizer", { "recipe-name.bi-purified-air-" .. tier } }
end
for tier, suffix in ipairs({ "large", "huge", "giga" }) do
	clones["bi-tech-wooden-storage-" .. tier] = { "logistics", { "entity-name.bi-wooden-chest-" .. suffix } }
end
-- Новые узлы используют оформление действующих прототипов 2.0, не графику из эталона.
for name, definition in pairs(clones) do
	if not technologies[name] and technologies[definition[1]] then
		local technology = table.deepcopy(technologies[definition[1]])
		technology.name = name
		technology.localised_name = definition[2]
		technology.localised_description = nil
		technology.effects = {}
		data:extend({ technology })
	end
end

-- count, time, число цветов науки, упорядоченные предки из конечного normal-дампа.
local definitions = {
	["bi-tech-bio-farming"] = { 10, 20, 1, { "automation", "lamp" } },
	["bi-tech-timber"] = { 30, 20, 1, { "angels-ore-crushing", "bi-tech-bio-farming" } },
	["bi-tech-ash"] = { 50, 30, 1, { "bi-tech-timber", "steel-processing" } },
	["bi-tech-bio-farming-2"] = { 50, 30, 2, { "bi-tech-ash", "logistic-science-pack" } },
	["bi-tech-bio-farming-3"] = { 100, 30, 2, { "bi-tech-bio-farming-2", "bi-tech-fertilizer", "concrete" } },
	["bi-tech-bio-farming-4"] = { 100, 30, 3, { "bi-tech-bio-farming-3", "bi-tech-advanced-biotechnology" } },
	["bi-tech-fertilizer"] = { 100, 30, 2, { "angels-sulfur-processing-1", "bi-tech-ash" } },
	["bi-tech-advanced-biotechnology"] = { 225, 30, 3, { "bi-tech-biomass" } },
	["bi-tech-biomass"] = { 100, 30, 3, { "chemical-science-pack", "bi-tech-fertilizer" } },
	["bi-tech-coal-processing-1"] = { 100, 30, 2, { "advanced-material-processing", "bi-tech-ash" } },
	["bi-tech-garden-1"] = { 50, 30, 2, { "concrete" } },
	["bi-tech-garden-2"] = { 200, 30, 3, { "bi-tech-garden-1", "angels-stone-smelting-2", "chemical-science-pack" } },
	["bi-tech-garden-3"] = { 270, 30, 4, { "bi-tech-garden-2", "production-science-pack" } },
	["bi-tech-depollution-1"] = { 100, 30, 2, { "bi-tech-garden-1" } },
	["bi-tech-depollution-2"] = { 100, 30, 3, { "bi-tech-depollution-1", "bi-tech-advanced-biotechnology" } },
	["bi-tech-wooden-storage-1"] = { 10, 10, 1, { "logistics", "bi-tech-timber" } },
	["bi-tech-wooden-storage-2"] = { 30, 20, 2, { "bi-tech-wooden-storage-1", "logistics-2" } },
	["bi-tech-wooden-storage-3"] = { 50, 30, 3, { "bi-tech-wooden-storage-2", "logistics-3", "concrete" } },
}
local science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack" }
for name, definition in pairs(definitions) do
	local technology = technologies[name]
	if technology and technology.max_level ~= "infinite" then
		local ingredients = {}
		for index = 1, definition[3] do ingredients[#ingredients + 1] = { science[index], 1 } end
		technology.unit = { count = definition[1], time = definition[2], ingredients = ingredients }
		technology.prerequisites = definition[4]
	end
end

-- Переносим только доказанные старые открытия. Порядок остальных эффектов сохраняется.
local moves = {
	{ "bi-tech-timber", { "bi-bio-farm", "bi-logs-1", "bi-woodpulp", "bi-resin-pulp", "bi-wood-from-pulp" } },
	{ "bi-tech-ash", { "bi-cokery", "bi-ash-1", "bi-ash-2" } },
	{ "bi-tech-bio-farming-2", { "bi-seed-2", "bi-seedling-2", "bi-logs-2" } },
	{ "bi-tech-bio-farming-3", { "bi-seed-3", "bi-seedling-3", "bi-logs-3", "bi-bio-farm-2", "bi-bio-greenhouse-2" } },
	{ "bi-tech-bio-farming-4", { "bi-seed-4", "bi-seedling-4", "bi-logs-4", "bi-bio-farm-3", "bi-bio-greenhouse-3" } },
	{ "bi-tech-advanced-biotechnology", { "bi-adv-fertilizer-1" } },
	{ "bi-tech-biomass", { "bi-bio-reactor", "bi-biomass-1" } },
	{ "bi-tech-garden-1", { "bi-bio-garden", "bi-purified-air-0" } },
	{ "bi-tech-garden-2", { "bi-bio-garden-large" } },
	{ "bi-tech-garden-3", { "bi-bio-garden-huge" } },
	{ "bi-tech-depollution-1", { "bi-purified-air-1" } },
	{ "bi-tech-depollution-2", { "bi-purified-air-2" } },
	{ "bi-tech-wooden-storage-1", { "bi-wooden-chest-large" } },
	{ "bi-tech-wooden-storage-2", { "bi-wooden-chest-huge" } },
	{ "bi-tech-wooden-storage-3", { "bi-wooden-chest-giga" } },
}
for _, move in ipairs(moves) do
	local target = technologies[move[1]]
	if target then
		for _, recipe in ipairs(move[2]) do
			if data.raw.recipe[recipe] then
				for _, technology in pairs(technologies) do
					if technology.max_level ~= "infinite" then
						for index = #(technology.effects or {}), 1, -1 do
							local effect = technology.effects[index]
							if effect.type == "unlock-recipe" and effect.recipe == recipe then table.remove(technology.effects, index) end
						end
					end
				end
				target.effects = target.effects or {}
				table.insert(target.effects, { type = "unlock-recipe", recipe = recipe })
			end
		end
	end
end
