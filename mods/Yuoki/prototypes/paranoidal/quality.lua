-- Paranoidal fork: Yuoki currencies never get quality (user decision 2026-10-24): Techanic, Merchant, Nature and
-- Science Signs, Reputation, UC-A2, transmuted UC-A2 and the three Mighty Domination Symbols (trophies).
--  1. A finished product (placeable item, armor, repair tool, ammo, gun) keeps quality: currency by-products are
--     removed from its recipe.
--  2. Every remaining Yuoki recipe that yields a currency, and all trade recipes (Laika-Gate / Trade Node) and
--     transmutation recipes, get allow_quality = false.
-- Defects are not a concern: the build has none after green science (ic-more-qualities after-gate rule).
local currency = {
	y_rwtechsign = true, ypfw_trader_sign = true, y_greensign = true, ye_science_blue = true, ["y-fame"] = true,
	["y-unicomp-a2"] = true, ["y-infused-uca2"] = true, ye_science_ultimate = true, y_trade_ultimate = true,
	ye_green_ultimate = true,
}
local no_quality_categories = { ["yuoki-stargate"] = true, ["yuoki-atomics"] = true }

local function finished(name)
	local item = data.raw.item[name]
	if item and (item.place_result or item.place_as_equipment_result) then
		return true
	end
	for _, t in pairs({ "armor", "repair-tool", "ammo", "gun", "capsule" }) do
		if data.raw[t] and data.raw[t][name] then
			return true
		end
	end
	return false
end

local function main_product(recipe)
	if recipe.main_product and recipe.main_product ~= "" then
		return recipe.main_product
	end
	local results = recipe.results or {}
	if #results >= 1 then
		return results[1].name
	end
end

local stripped, locked = {}, {}
for name in pairs(YUOKI_PARANOIDAL.owned_recipes) do
	local recipe = data.raw.recipe[name]
	if recipe then
		local main = main_product(recipe)
		if main and finished(main) and not currency[main] then
			local kept = {}
			for _, r in pairs(recipe.results or {}) do
				if currency[r.name] and r.name ~= main then
					stripped[#stripped + 1] = name .. ":" .. r.name
				else
					kept[#kept + 1] = r
				end
			end
			recipe.results = kept
		end
		local yields_currency = false
		for _, r in pairs(recipe.results or {}) do
			if currency[r.name] then
				yields_currency = true
			end
		end
		if yields_currency or no_quality_categories[recipe.category or "crafting"] then
			recipe.allow_quality = false
			locked[#locked + 1] = name
		end
	end
end
table.sort(stripped)
log("Yuoki (Paranoidal): currency by-products removed from finished-product recipes (" .. #stripped .. "): "
	.. table.concat(stripped, ", "))
log("Yuoki (Paranoidal): recipes without quality (" .. #locked .. ")")
