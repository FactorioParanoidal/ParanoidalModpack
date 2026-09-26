-- Beta 8 normal: конечные ветки боеприпасов. После OV.execute, без правки эффектов.
-- Старый zinc-processing открывал латунные изделия: его роль здесь bob-brass-processing.
if not mods["bobwarfare"] then return end
local prerequisites = {
	["bob-bullets"] = { "bob-cordite-processing", "bob-brass-processing", "angels-gunmetal-smelting-1" },
	["bob-shotgun-shells"] = { "bob-cordite-processing", "bob-brass-processing", "angels-gunmetal-smelting-1" },
	["bob-laser-rifle-ammo-3"] = { "bob-laser-rifle-ammo-2", "bob-battery-2" },
	["bob-laser-rifle-ammo-5"] = { "bob-laser-rifle-ammo-4", "bob-battery-3" },
	["bob-rocket"] = { "rocketry", "military-3", "bob-tungsten-processing" },
	["bob-poison-artillery-shells"] = { "artillery", "bob-alien-green-research" },
	["bob-fire-artillery-shells"] = { "artillery", "bob-alien-red-research" },
	["bob-explosive-artillery-shells"] = { "artillery", "bob-alien-yellow-research" },
	["bob-plasma-bullets"] = { "angels-water-chemistry-2", "bob-bullets", "bob-alien-research" },
	["bob-shotgun-plasma-shells"] = { "angels-water-chemistry-2", "bob-shotgun-shells", "bob-alien-research" },
	["bob-plasma-rocket"] = { "angels-water-chemistry-2", "bob-alien-research", "rocketry" },
	["laser-weapons-damage-4"] = { "laser-weapons-damage-3", "chemical-science-pack" },
}
local special = {
	{ "ap", "blue" }, { "electric", "orange" }, { "he", "yellow" },
	{ "flame", "red" }, { "acid", "purple" }, { "poison", "green" },
}
for _, pair in ipairs(special) do
	local alien = "bob-alien-" .. pair[2] .. "-research"
	prerequisites["bob-" .. pair[1] .. "-bullets"] = { "bob-bullets", alien }
	local shotgun = pair[1] == "he" and "explosive" or pair[1]
	prerequisites["bob-shotgun-" .. shotgun .. "-shells"] = { "bob-shotgun-shells", alien }
end
for name, list in pairs(prerequisites) do
	local technology = data.raw.technology[name]
	local available = technology and technology.max_level ~= "infinite"
	for _, prerequisite in ipairs(list) do available = available and data.raw.technology[prerequisite] ~= nil end
	if available then technology.prerequisites = list end
end
local rocket = data.raw.technology["bob-rocket"]
if rocket and rocket.max_level ~= "infinite" then
	rocket.unit = {
		count = 100, time = 30,
		ingredients = {
			{ "automation-science-pack", 1 },
			{ "logistic-science-pack", 1 },
			{ "military-science-pack", 1 },
			{ "chemical-science-pack", 1 },
			{ "production-science-pack", 1 },
		},
	}
end
