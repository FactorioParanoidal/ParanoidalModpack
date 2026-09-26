-- Beta 8 normal: отдельные газовый и нефтяной паровой крекинг I/II.
-- Нынешние angels-steam-cracking сохраняем как газовую ветку; нефтяную восстанавливаем.
-- ПР-024 разрешает только связи электрокотлов I/II, не их рецепты/характеристики.
if not mods["angelspetrochem"] then return end
local technologies = data.raw.technology
if not technologies["angels-steam-cracking-1"] or not technologies["angels-steam-cracking-2"] then return end
for tier = 1, 2 do
	local name = "angels-oil-steam-cracking-" .. tier
	if not technologies[name] then
		local technology = table.deepcopy(technologies["angels-steam-cracking-" .. tier])
		technology.name = name
		technology.localised_name = {
			"", { "technology-name.angels-steam-cracking" }, " (",
			{ "technology-name.angels-oil-processing" }, ") " .. tier,
		}
		technology.localised_description = nil
		technology.effects = {}
		data:extend({ technology })
	end
end
-- Unit по ступеням уже совпадает: 50 красно-зелёных / красно-зелёно-синих по 15 с.
-- У наследованных нефтяных исследований сохраняем те же цены.
local prerequisites = {
	["angels-steam-cracking-1"] = { "angels-gas-processing" },
	["angels-steam-cracking-2"] = { "angels-steam-cracking-1", "angels-advanced-chemistry-2" },
	["angels-oil-steam-cracking-1"] = { "angels-oil-processing", "angels-advanced-chemistry-1" },
	["angels-oil-steam-cracking-2"] = { "angels-oil-steam-cracking-1", "angels-advanced-chemistry-2" },
	["angels-chlorine-processing-2"] = { "angels-chlorine-processing-1", "angels-steam-cracking-1" },
	["angels-plastic-1"] = { "angels-steam-cracking-1", "angels-oil-steam-cracking-1" },
	["angels-advanced-chemistry-2"] = {
		"angels-advanced-chemistry-1", "angels-steam-cracking-1", "angels-oil-steam-cracking-1",
		"chemical-science-pack", "angels-sulfur-processing-2", "angels-aluminium-smelting-1",
	},
	["angels-advanced-chemistry-3"] = {
		"angels-advanced-chemistry-2", "angels-advanced-gas-processing", "angels-oil-steam-cracking-2",
		"angels-thermal-water-extraction", "angels-ore-leaching",
	},
	["angels-advanced-gas-processing"] = { "angels-steam-cracking-2", "flammables" },
	["angels-advanced-oil-processing"] = { "angels-steam-cracking-1", "chemical-science-pack" },
	["lubricant"] = { "angels-oil-processing", "angels-steam-cracking-1" },
	["angels-electric-boiler"] = { "angels-oil-steam-cracking-1", "angels-steam-cracking-1" },
	["angels-electric-boiler-2"] = { "angels-electric-boiler", "angels-oil-steam-cracking-2", "angels-steam-cracking-2" },
}
for name, list in pairs(prerequisites) do
	local technology = technologies[name]
	if technology and technology.max_level ~= "infinite" then technology.prerequisites = list end
end
-- Общие постройки открываются каждой из двух веток своего уровня, как в Beta 8.
-- Переносим только эти рецепты; другие и non-unlock эффекты сохраняем.
local moves = {
	{ "angels-steam-cracker", { "angels-steam-cracking-1", "angels-oil-steam-cracking-1" } },
	{ "angels-steam-cracking-methane", { "angels-steam-cracking-1" } },
	{ "angels-gas-ethylene", { "angels-steam-cracking-1" } },
	{ "angels-steam-cracking-butane", { "angels-steam-cracking-1" } },
	{ "angels-gas-propene", { "angels-steam-cracking-1" } },
	{ "catalyst-steam-cracking-butane-2", { "angels-steam-cracking-1" } },
	{ "angels-steam-cracker-2", { "angels-steam-cracking-2", "angels-oil-steam-cracking-2" } },
	{ "angels-steam-cracking-gas-residual", { "angels-steam-cracking-2" } },
	{ "catalyst-steam-cracking-acetylene", { "angels-steam-cracking-2" } },
	{ "angels-gas-butadiene", { "angels-oil-steam-cracking-1" } },
	{ "angels-catalyst-steam-cracking-naphtha", { "angels-oil-steam-cracking-1" } },
	{ "angels-steam-cracking-naphtha", { "angels-oil-steam-cracking-2" } },
	{ "angels-steam-cracking-mineral-oil", { "angels-oil-steam-cracking-2" } },
	{ "angels-steam-cracking-fuel-oil", { "angels-oil-steam-cracking-2" } },
	{ "angels-steam-cracking-oil-residual", { "angels-oil-steam-cracking-2" } },
	{ "vinyl-acetlyene-chlorination", { "angels-chlorine-processing-2" } },
	{ "acetylene-diomerisation", { "angels-advanced-chemistry-2" } },
	{ "vinyl-chloride-synthesis", { "angels-chlorine-processing-2" } },
	{ "methyl-methacrylate-synthesis", { "angels-advanced-chemistry-2" } },
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
