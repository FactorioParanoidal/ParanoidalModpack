-- Beta 8 normal: однозначные военные ветки и общие для normal/filter ворота шести тиров лоадеров.
-- Сжатая плазменная линейка, верхняя броня/модули, энергетика и бесконечные исследования не затрагиваются.
local prerequisites = {
	["tank"] = { "automobilism", "military-3", "explosives" },
	["power-armor"] = { "modular-armor", "electric-engine", "processing-unit" },
	["power-armor-mk2"] = { "power-armor", "military-4", "speed-module-2", "efficiency-module-2" },
	["laser-turret"] = { "laser", "military-science-pack" },
	["distractor"] = { "defender", "military-3", "laser", "bob-robotics-2", "bob-brass-processing" },
	["destroyer"] = { "distractor", "speed-module", "bob-robotics-3", "bob-gem-processing-3" },
	["artillery"] = { "tank", "processing-unit", "angels-invar-smelting-1", "artillery-prototype" },
	["bob-laser-rifle"] = { "advanced-circuit", "military-science-pack", "laser" },
	["bob-robot-gun-drones"] = { "defender", "gun-turret" },
	["bob-robot-laser-drones"] = { "defender", "laser-turret" },
	["bob-robot-flamethrower-drones"] = { "defender", "flamethrower" },
	["bob-turrets-3"] = { "bob-turrets-2", "military-science-pack", "angels-invar-smelting-1", "bob-brass-processing" },
	["bob-turrets-5"] = { "bob-turrets-4", "bob-nitinol-processing" },
	["bob-laser-turrets-3"] = { "bob-laser-turrets-2", "military-3", "angels-invar-smelting-1", "bob-battery-2" },
	["bob-sniper-turrets-2"] = { "bob-sniper-turrets-1", "military-3", "bob-cobalt-processing", "angels-invar-smelting-1" },
	["bob-sniper-turrets-3"] = { "bob-sniper-turrets-2", "military-4", "bob-nitinol-processing" },
	["bob-artillery-turret-2"] = { "artillery", "military-4" },
	["bob-laser-robot"] = { "destroyer", "bob-robotics-4", "bob-nitinol-processing" },
	["bob-artillery-wagon-2"] = { "artillery", "military-4" },
}
for name, list in pairs(prerequisites) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		technology.prerequisites = list
	end
end

local function set_unit(name, count, time, science)
	local technology = data.raw.technology[name]
	if not technology or technology.max_level == "infinite" then return end
	local ingredients = {}
	for _, pack in ipairs(science) do
		ingredients[#ingredients + 1] = type(pack) == "table" and pack or { pack, 1 }
	end
	technology.unit = { count = count, time = time, ingredients = ingredients }
end
set_unit("power-armor", 200, 30, { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" })
set_unit("power-armor-mk2", 400, 30, {
	"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack", "utility-science-pack",
})
