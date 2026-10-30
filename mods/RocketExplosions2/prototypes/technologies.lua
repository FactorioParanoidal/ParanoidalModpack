-- Rocket failure revision 1-7 (7 is infinite). The technologies have no engine effect: control.lua reads
-- the researched level; the "nothing" effect only explains it in the tooltip.
local tech_name = "rocket-failure-revision"
local mod_name = "__RocketExplosions2__"

local icons = {{icon = mod_name .. "/icons/" .. tech_name .. ".png", icon_size = 256}}
local icons_infinite = {{icon = mod_name .. "/icons/" .. tech_name .. "2.png", icon_size = 128}}

local ingredients = {
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
	{"chemical-science-pack", 1},
	{"production-science-pack", 1},
	{"military-science-pack", 1},
	{"utility-science-pack", 1},
}

local function effects()
	return {{
		type = "nothing",
		effect_description = {"re2-effect.revision"},
		icons = {{icon = "__base__/graphics/icons/rocket-silo.png", icon_size = 64}},
	}}
end

-- level -> {count, time}
local levels = {
	{100, 30},
	{200, 30},
	{400, 60},
	{600, 60},
	{800, 60},
	{1000, 60},
}

local technologies = {}
for level, cost in ipairs(levels) do
	technologies[#technologies + 1] = {
		type = "technology",
		name = level == 1 and tech_name or tech_name .. "-" .. level,
		icons = icons,
		effects = effects(),
		prerequisites = {level == 1 and "rocket-silo" or (level == 2 and tech_name or tech_name .. "-" .. (level - 1))},
		unit = {count = cost[1], ingredients = ingredients, time = cost[2]},
		upgrade = true,
		order = "g-3-" .. string.char(string.byte("a") + level - 1),
	}
end

technologies[#technologies + 1] = {
	type = "technology",
	name = tech_name .. "-7",
	icons = icons_infinite,
	effects = effects(),
	prerequisites = {tech_name .. "-6", "space-science-pack"},
	unit = {
		count_formula = "2^(L-7)*1000",
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"military-science-pack", 1},
			{"production-science-pack", 1},
			{"utility-science-pack", 1},
			{"space-science-pack", 1},
		},
		time = 60,
	},
	max_level = "infinite",
	upgrade = true,
	order = "g-3-g",
}

data:extend(technologies)
