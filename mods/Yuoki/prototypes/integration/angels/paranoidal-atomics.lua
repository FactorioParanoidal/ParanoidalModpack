-- Paranoidal fork: Atomics (UC-A2) recipes for Angels' ores, ported from zJatmnYiFixes 0.2.23
-- (user decision 2026-10-23: atomics are a late-game goal for the player; rates will be balanced later).
-- Rates follow Yuoki 1.2.x ores (20 ore <-> 1 UC-A2), not JATMN's 4 <-> 4.
-- Chrome and fluorite stay one-way (ore -> UC-A2) as in JATMN. Bob ores are handled by integration/bobores.
if mods["angelsrefining"] then
	local both_ways = { "angels-ore1", "angels-ore2", "angels-ore3", "angels-ore4", "angels-ore5", "angels-ore6" }
	local to_uc_only = { "angels-chrome-ore", "angels-fluorite-ore" }

	for _, name in pairs(both_ways) do
		if data.raw.item[name] then
			yi.lib.recipe.atomics.recipes_make_item(name, 64, 20, 1, "ore-int")
		end
	end
	for _, name in pairs(to_uc_only) do
		if data.raw.item[name] then
			yi.lib.recipe.atomics.recipes_make_item(name, 64, 20, 1, "ore-int")
			data.raw.recipe["y-ac-uc2" .. name] = nil
		end
	end
end
