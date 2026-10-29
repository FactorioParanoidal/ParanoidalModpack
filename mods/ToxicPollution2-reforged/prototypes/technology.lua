local C = require("shared.config")

local RED, GREEN = "automation-science-pack", "logistic-science-pack"
local MILITARY, BLUE, UTILITY = "military-science-pack", "chemical-science-pack", "utility-science-pack"

-- level → packs, research count, time, extra prerequisites (beyond the previous level), unlocked recipe
local LEVELS = {
	{ { RED }, 10, 5 },
	{ { RED }, 30, 10, { "steel-processing" }, C.GAS_MASK },
	{ { RED, GREEN }, 50, 15, { GREEN } },
	{ { RED, GREEN }, 75, 20 },
	{ { RED, GREEN, MILITARY }, 100, 30, { MILITARY, "modular-armor" }, C.FILTER_MODULE },
	{ { RED, GREEN, MILITARY }, 125, 40 },
	{ { RED, GREEN, MILITARY, BLUE }, 150, 50, { BLUE } },
	{ { RED, GREEN, MILITARY, BLUE }, 175, 60, nil, C.CLOSED_MODULE },
	{ { RED, GREEN, MILITARY, BLUE, UTILITY }, 200, 60, { UTILITY } },
	{ { RED, GREEN, MILITARY, BLUE, UTILITY }, 250, 60 },
}
assert(#LEVELS == C.TECH_LEVELS)

local per_level = tostring(math.floor(C.MODEL.tolerance_per_level * 100 + 0.5))
local resource_level = tostring(math.floor(C.MODEL.resource_per_level * 100 + 0.5))

for level, spec in ipairs(LEVELS) do
	local ingredients = {}
	for _, pack in ipairs(spec[1]) do
		ingredients[#ingredients + 1] = { pack, 1 }
	end
	local prerequisites = {}
	if level > 1 then
		prerequisites[1] = C.TECH .. "-" .. (level - 1)
	end
	for _, name in ipairs(spec[4] or {}) do
		prerequisites[#prerequisites + 1] = name
	end
	local effects = {
		{
			type = "nothing",
			icon = C.PATH .. "/graphics/icons/effect-tolerance.png",
			icon_size = 64,
			use_icon_overlay_constant = true,
			effect_description = { "tpr-effect.tolerance", per_level },
		},
		{
			type = "nothing",
			icon = C.PATH .. "/graphics/icons/effect-resource.png",
			icon_size = 64,
			use_icon_overlay_constant = true,
			effect_description = { "tpr-effect.resource", resource_level },
		},
	}
	if spec[5] then
		table.insert(effects, 1, { type = "unlock-recipe", recipe = spec[5] })
	end
	data:extend({
		{
			type = "technology",
			name = C.TECH .. "-" .. level,
			icon = C.PATH .. "/graphics/technology/smog-protection.png",
			icon_size = 256,
			effects = effects,
			prerequisites = prerequisites,
			unit = { count = spec[2], ingredients = ingredients, time = spec[3] },
			upgrade = true,
			order = "c-k-f-e",
		},
	})
end
