-- Late placement, after the technology and menu rework of other mods.
local SUIT = "hazmat-suit"

-- Unlock with Plastics (Beta 8: aai-industry tech_lock_recipes), after the other recipe unlocks
-- so that non-recipe effects (research notes) stay last.
local tech = data.raw.technology.plastics
if tech then
	tech.effects = tech.effects or {}
	local effects, position = tech.effects, 1
	for index, effect in ipairs(effects) do
		if effect.type == "unlock-recipe" then
			if effect.recipe == SUIT then position = nil break end
			position = index + 1
		end
	end
	if position then table.insert(effects, position, { type = "unlock-recipe", recipe = SUIT }) end
else
	log("[Radioactive-Damage-Reforged] technology plastics is missing; " .. SUIT .. " stays locked")
end

-- Menu: right after Heavy armor, wherever the menu rework has put it (Beta 8 order "b[heavy-armor]").
local function follow(kind)
	local template, prototype = data.raw[kind]["heavy-armor"], data.raw[kind][SUIT]
	if template and prototype and template.subgroup then
		prototype.subgroup = template.subgroup
		prototype.order = (template.order or "") .. "-b[hazmat-suit]"
	end
end
follow("armor")
follow("recipe")
