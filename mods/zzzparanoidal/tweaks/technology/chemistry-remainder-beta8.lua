-- Beta 8 normal: отдельная PCP-химия, полимеры и оставшиеся открытия advanced chemistry.
-- После OV.execute. Эффекты существующих технологий и топливные ворота не выравниваем.
if not mods["angelspetrochem"] or not mods["PCPRedux"] then return end
local technologies = data.raw.technology
local pcp = "k-angels-advanced-chemistry-5"
if not technologies[pcp] and technologies["angels-advanced-chemistry-5"] then
	local technology = table.deepcopy(technologies["angels-advanced-chemistry-5"])
	technology.name = pcp
	technology.localised_name = { "technology-name.k-angels-advanced-chemistry" }
	technology.localised_description = nil
	technology.effects = {}
	technology.order = ""
	data:extend({ technology })
end
local prerequisites = {
	["angels-advanced-chemistry-4"] = {
		"angels-advanced-chemistry-3", "processing-unit", "production-science-pack", "angels-titanium-smelting-1",
	},
	["angels-advanced-chemistry-5"] = {
		"angels-advanced-chemistry-4", "utility-science-pack", "angels-tungsten-smelting-1", "bob-advanced-processing-unit",
	},
	[pcp] = { "angels-advanced-chemistry-4" },
	["plastic-abs"] = { "angels-plastic-3", pcp },
	["plastic-pc"] = { "angels-advanced-chemistry-4" },
	["plastic-pmma"] = { "angels-nitrogen-processing-2", "angels-advanced-chemistry-2" },
}
for name, list in pairs(prerequisites) do
	local technology = technologies[name]
	local available = technology and technology.max_level ~= "infinite"
	for _, prerequisite in ipairs(list) do available = available and technologies[prerequisite] ~= nil end
	if available then technology.prerequisites = list end
end
-- Низкая собственная цена PCP не отменяет более поздних предков из Beta 8.
local units = { [pcp] = { 50, 2 }, ["plastic-abs"] = { 75, 3 }, ["plastic-pc"] = { 75, 3 }, ["plastic-pmma"] = { 100, 2 } }
local science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" }
for name, definition in pairs(units) do
	local technology = technologies[name]
	if technology and technology.max_level ~= "infinite" then
		local ingredients = {}
		for index = 1, definition[2] do ingredients[#ingredients + 1] = { science[index], 1 } end
		technology.unit = { count = definition[1], time = 30, ingredients = ingredients }
	end
end
local moves = {
	{ "angels-liquid-toluene", { "angels-advanced-chemistry-3" } },
	{ "angels-liquid-toluene-from-benzene", { "angels-advanced-chemistry-3" } },
	{ "angels-catalyst-metal-yellow", { "angels-advanced-chemistry-4", "angels-advanced-chemistry-5" } },
	{ "angels-liquid-phenol", { "angels-advanced-chemistry-5", pcp } },
	{ "nitrous-oxide-synthesis-1", { pcp } },
	{ "nitrous-oxide-synthesis-2", { pcp } },
	{ "sodium-nitrate-synthesis", { pcp } },
	{ "acrylonitrile-synthesis", { pcp } },
	{ "catalyst-metal-cyan", { pcp } },
}
for _, move in ipairs(moves) do
	local available = data.raw.recipe[move[1]] ~= nil
	for _, name in ipairs(move[2]) do available = available and technologies[name] ~= nil end
	if available then
		for _, technology in pairs(technologies) do
			if technology.max_level ~= "infinite" then
				for index = #(technology.effects or {}), 1, -1 do
					local effect = technology.effects[index]
					if effect.type == "unlock-recipe" and effect.recipe == move[1] then table.remove(technology.effects, index) end
				end
			end
		end
		for _, name in ipairs(move[2]) do
			local technology = technologies[name]
			technology.effects = technology.effects or {}
			table.insert(technology.effects, { type = "unlock-recipe", recipe = move[1] })
		end
	end
end
