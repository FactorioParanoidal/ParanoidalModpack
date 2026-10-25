-- Paranoidal fork: transmutation through UC-A2 is a late goal of the player, a source of needed resources, and must be
-- clearly more expensive than mining (user decisions 2026-10-23/24, all measures taken; balance later):
--  * selling (X -> UC-A2): 5x more input than in Yuoki 1.2.23 (20 -> 100 ore, 10 -> 50 for rare ores);
--  * buying (UC-A2 -> X): half the output, a "licence" of 5 Merchant Signs + 1 Charged F-C, 10 s instead of 2 s;
--    so a sell/buy round trip loses 90 % and needs the trade economy;
--  * fluids -> UC-A2 only with the startup setting (default off), then 500 fluid per UC-A2;
--  * the Cimota Restructor draws 8 MW instead of 1.2 MW.
-- Waste sinks (slag, data fragments, toxic dust, mud balls, contaminated water) and chunks keep their rates.
local P = require("prototypes.paranoidal.lib")

local waste = { ["y-ac-slag2uc"] = true, ["y-ac-crystal2uc"] = true, ["y-ac-toxic2uc"] = true, ["y-ac-mud2uc"] = true,
	["y-ac-y-res12uc"] = true, ["y-ac-y-res22uc"] = true }
local sold, bought = 0, 0
for name, recipe in pairs(data.raw.recipe) do
	if name:find("^y%-ac%-uc2") or name == "y-uc2crudeoil" then
		for _, r in pairs(recipe.results or {}) do
			if r.name ~= "y-unicomp-a2" then
				r.amount = math.max(1, math.floor(r.amount / 2))
			end
		end
		table.insert(recipe.ingredients, { type = "item", name = "ypfw_trader_sign", amount = 5 })
		table.insert(recipe.ingredients, { type = "item", name = "y-raw-fuelnium", amount = 1 })
		recipe.energy_required = 10
		bought = bought + 1
	elseif name:find("^y%-ac%-.+2uc$") and not waste[name] then
		for _, i in pairs(recipe.ingredients or {}) do
			if i.name ~= "y-unicomp-a2" then
				i.amount = i.amount * 5
			end
		end
		sold = sold + 1
	end
end

local fluids = { "y-lightoil2uc", "y-heavyoil2uc", "y-lubricant2uc", "y-petroleum" }
if settings.startup["yuoki-uc-from-fluids"].value then
	for _, name in pairs(fluids) do
		for _, i in pairs(P.recipe(name).ingredients) do
			i.amount = 500
		end
	end
else
	for _, name in pairs(fluids) do
		data.raw.recipe[name] = nil
	end
end

P.entity("assembling-machine", "y-atomic-constructor").energy_usage = "8MW"
log("Yuoki (Paranoidal): atomics — selling recipes x5 input: " .. sold .. ", buying recipes with licence: " .. bought)
