-- Beta 8 normal: собственные открытия и связи military после переноса BI-дротиков.
-- Стоимость уже совпадает; сохраняем все нынешние non-unlock эффекты.
local prerequisites = {
	["military-2"] = { "military", "steel-processing", "logistic-science-pack" },
	["military-3"] = { "chemical-science-pack", "military-science-pack", "angels-aluminium-smelting-1", "flammables" },
}
for name, list in pairs(prerequisites) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then technology.prerequisites = list end
end
local military = data.raw.technology["military"]
if military and data.raw.recipe["light-armor"] then
	military.effects = military.effects or {}
	for _, effect in ipairs(military.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == "light-armor" then return end
	end
	table.insert(military.effects, { type = "unlock-recipe", recipe = "light-armor" })
end
