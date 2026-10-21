local shared = require("kts_shared")

local cfg = shared.read(settings.startup)
if not cfg.research then
	return
end

local path = shared.root .. "/graphics/"

-- Level cost: base * 2.5 (size) or rate * 25 (recharge) per order of magnitude, as in 1.1.
local function cost(scale, steps)
	local inverse = 1 / steps
	return scale .. "*10^(L*" .. inverse .. ")-" .. scale .. "*" .. inverse
end

data:extend({
	{
		type = "technology",
		name = shared.tech_base,
		icon = path .. "base-research.png",
		icon_size = 128,
		effects = {
			{type = "unlock-recipe", recipe = shared.generator},
		},
		-- The military pack technology (military-2 and gun-turret behind it) unlocks the pack this research needs.
		prerequisites = {"military-science-pack"},
		unit = {
			count = 100,
			ingredients = {
				{"automation-science-pack", 2},
				{"logistic-science-pack", 2},
				{"military-science-pack", 1},
			},
			time = 30,
		},
		order = "e-l-a",
	},
	{
		type = "technology",
		name = shared.tech_size,
		icon = path .. "size-research.png",
		icon_size = 128,
		effects = {
			{type = "nothing", effect_description = {"modifier-description.turret-shields-size"}},
		},
		prerequisites = {shared.tech_base, "chemical-science-pack"},
		unit = {
			count_formula = cost(cfg.base_hp * 2.5, cfg.size_steps),
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 2},
			},
			time = 60,
		},
		max_level = cfg.max_level,
		upgrade = true,
		order = "e-l-b",
	},
	{
		type = "technology",
		name = shared.tech_rate,
		icon = path .. "speed-research.png",
		icon_size = 128,
		effects = {
			{type = "nothing", effect_description = {"modifier-description.turret-shields-speed"}},
		},
		prerequisites = {shared.tech_base, "production-science-pack"},
		unit = {
			count_formula = cost(cfg.base_rate * 25, cfg.rate_steps),
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"military-science-pack", 2},
			},
			time = 60,
		},
		max_level = cfg.max_level,
		upgrade = true,
		order = "e-l-c",
	},
})
