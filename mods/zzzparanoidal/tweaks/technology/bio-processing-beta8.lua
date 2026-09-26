-- Beta 8 normal: отдельные исследования дробления, дротиков и переработки биомассы.
-- После bio-growing и OV.execute. Машины, энергетика и эффекты оружия остаются 2.0.
if not mods["Bio_Industries_2"] then return end
local technologies = data.raw.technology
local clones = {
	["bi-tech-stone-crushing-1"] = { "steel-processing", { "entity-name.bi-stone-crusher" } },
	["bi-dart-turret"] = { "military", { "entity-name.bi-dart-turret" } },
	["bi-tech-darts-1"] = { "military", { "item-name.bi-dart-magazine-standard" } },
	["bi-tech-darts-2"] = { "military-2", { "item-name.bi-dart-magazine-enhanced" } },
	["bi-tech-darts-3"] = { "military-3", { "item-name.bi-dart-magazine-poison" } },
	["bi-tech-biomass-reprocessing-1"] = { "bi-tech-advanced-biotechnology", { "recipe-name.bi-biomass-2" } },
	["bi-tech-biomass-reprocessing-2"] = { "bi-tech-advanced-biotechnology-2", { "recipe-name.bi-biomass-3" } },
	["bi-tech-biomass-conversion"] = { "bi-tech-advanced-biotechnology", { "recipe-name.bi-biomass-conversion-1" } },
	["bi-tech-cellulose-1"] = { "bi-tech-organic-plastic", { "recipe-name.bi-cellulose-1" } },
	["bi-tech-cellulose-2"] = { "bi-tech-organic-plastic", { "recipe-name.bi-cellulose-2" } },
}
-- Оформление берём из действующих прототипов 2.0, старую графику не возвращаем.
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
local definitions = {
	["bi-tech-stone-crushing-1"] = { 75, 30, { "automation-science-pack" }, { "steel-processing" } },
	["bi-dart-turret"] = { 1, 30, { "automation-science-pack" }, {} },
	["bi-tech-darts-1"] = { 50, 30, { "automation-science-pack" }, { "military" } },
	["bi-tech-darts-2"] = { 225, 30, { "automation-science-pack", "logistic-science-pack" }, { "bi-tech-darts-1", "plastics" } },
	["bi-tech-darts-3"] = { 120, 30, { "automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack" }, { "bi-tech-darts-2", "military-3" } },
	["bi-tech-biomass-reprocessing-1"] = { 250, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" }, { "bi-tech-biomass" } },
	["bi-tech-biomass-reprocessing-2"] = { 175, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack" }, { "bi-tech-biomass-reprocessing-1", "production-science-pack" } },
	["bi-tech-biomass-conversion"] = { 300, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" }, { "bi-tech-biomass", "lubricant" } },
	["bi-tech-cellulose-1"] = { 250, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" }, { "bi-tech-biomass" } },
	["bi-tech-cellulose-2"] = { 250, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack" }, { "bi-tech-cellulose-1", "battery", "production-science-pack" } },
	["bi-tech-organic-plastic"] = { 175, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack" }, { "bi-tech-cellulose-1", "angels-advanced-oil-processing", "production-science-pack" } },
}
for name, definition in pairs(definitions) do
	local technology = technologies[name]
	if technology and technology.max_level ~= "infinite" then
		local ingredients = {}
		for _, science in ipairs(definition[3]) do ingredients[#ingredients + 1] = { science, 1 } end
		technology.unit = { count = definition[1], time = definition[2], ingredients = ingredients }
		technology.prerequisites = definition[4]
		technology.research_trigger = nil
	end
end
-- В AAI пользовательской Beta 8 военная ветка начиналась после дротиковой турели.
if technologies["military"] and technologies["bi-dart-turret"] then
	technologies["military"].prerequisites = { "bi-dart-turret" }
end
local moves = {
	{ "bi-tech-stone-crushing-1", { "bi-stone-crusher", "bi-crushed-stone-1", "bi-sand", "stone-crushed-2" } },
	{ "bi-dart-turret", { "bi-dart-turret", "bi-dart-magazine-basic", "bi-dart-rifle" } },
	{ "bi-tech-darts-1", { "bi-dart-magazine-standard" } },
	{ "bi-tech-darts-2", { "bi-dart-magazine-enhanced" } },
	{ "bi-tech-darts-3", { "bi-dart-magazine-poison" } },
	{ "bi-tech-biomass-reprocessing-1", { "bi-biomass-2", "bi-bio-reactor-2" } },
	{ "bi-tech-biomass-reprocessing-2", { "bi-biomass-3", "bi-bio-reactor-3" } },
	{ "bi-tech-biomass-conversion", { "bi-biomass-conversion-1", "bi-biomass-conversion-2", "bi-biomass-conversion-3", "bi-biomass-conversion-4" } },
	{ "bi-tech-cellulose-1", { "bi-cellulose-1", "bi-sulfur-angels" } },
	{ "bi-tech-cellulose-2", { "bi-cellulose-2", "bi-plastic-2", "bi-battery" } },
	{ "bi-tech-organic-plastic", { "bi-plastic-1" } },
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
-- Прежний объединённый фиолетовый узел больше не имеет активных потребителей.
-- Сохраняем прототип и non-unlock эффекты, не удаляем сторонний код.
local obsolete = technologies["bi-tech-advanced-biotechnology-2"]
if obsolete and technologies["bi-tech-cellulose-2"] and technologies["bi-tech-biomass-reprocessing-2"] then
	obsolete.hidden = true
	obsolete.enabled = false
end
