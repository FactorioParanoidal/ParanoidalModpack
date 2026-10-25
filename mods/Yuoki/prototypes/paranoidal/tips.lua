-- Paranoidal fork: "Tips and tricks" for Yuoki (user, 2026-10-26): how every Yuoki mechanic works, for a player who
-- has never seen the mod. Each tip unlocks when its technology is researched (no spoilers); pictures are static
-- language-neutral schemes in graphics/tips (simulations are not used: they crash in the build). Texts:
-- locale/*/tips.cfg. zzzparanoidal keeps the category "yuoki" in its tips cleanup (removals/tips-and-tricks.lua).
local CATEGORY = "yuoki"

-- name, tag, picture, technology that unlocks the tip
local tips = {
	{ "yuoki-intro", "[item=y-res1]", "intro", nil },
	{ "yuoki-solar-dish", "[item=y-stirling-solar-dish]", "solar-dish", "yuoki-solar-dish" },
	{ "yuoki-mf", "[fluid=y-mechanical-force]", "mf-basics", "yuoki-mechanical-force" },
	{ "yuoki-mf-engines", "[item=y-sfe]", "mf-engines", "yuoki-mechanical-force" },
	{ "yuoki-mf-resource", "[item=y-electric-air-heater]", "mf-resource", "yuoki-mechanical-force-2" },
	{ "yuoki-materials", "[item=y-res2]", "materials", "yuoki-materials" },
	{ "yuoki-fabricators", "[item=ye_fassembly1]", "fabricators", "yuoki-materials" },
	{ "yuoki-currencies", "[item=y_rwtechsign]", "currencies", "yuoki-electronics" },
	{ "yuoki-archaeology", "[item=y-dirtwasher]", "archaeology", "yuoki-archaeology" },
	{ "yuoki-transmutation", "[item=y-atomic-constructor]", "transmutation", "yuoki-transmutation" },
	{ "yuoki-crystallization", "[item=y-crystal-seed]", "crystallization", "yuoki-crystallization" },
	{ "yuoki-smelting", "[item=y_smelter]", "smelting", "yuoki-smelting" },
	{ "yuoki-storage", "[item=y_compensator_25]", "storage", "yuoki-accumulators" },
	{ "yuoki-agronomy", "[item=ye_farm]", "agronomy", "yuoki-agronomy" },
	{ "yuoki-alien", "[item=y-quantrinum]", "alien", "yuoki-alien-technology" },
	{ "yuoki-catalysis", "[item=y-crystal-cnd]", "centrifuge", "yuoki-catalytic-centrifuging" },
	{ "yuoki-genetics", "[item=ye_dnasplicer]", "genetics", "yuoki-genetics" },
	{ "yuoki-late-energy", "[item=ye_rheinsberg]", "nuclear", "yuoki-heavy-mf" },
	{ "yuoki-sol-ray", "[item=y_alien_solar2]", "sol-ray", "yuoki-solar" },
	{ "yuoki-trade", "[item=y-stargate]", "trade", "yuoki-reputation" },
	{ "yuoki-reverse-transmutation", "[item=y-unicomp-a2]", "transmutation", "yuoki-transmutation-2" },
	{ "yuoki-food-trade", "[item=ye_icemaker]", "food-trade", "yuoki-food-trade" },
	{ "yuoki-defense", "[item=y_turret_laser22f12]", "defense", "yuoki-defense" },
	{ "yuoki-repair", "[item=y-repair-durotal]", "repair", "yuoki-repair" },
	{ "yuoki-armor", "[item=yi_armor_gray]", "armor", "yuoki-armor" },
	{ "yuoki-ultimates", "[item=y_trade_ultimate]", "ultimates", "yuoki-ultimates" },
}

local list = { { type = "tips-and-tricks-item-category", name = CATEGORY, order = "c-y" } }
for index, t in ipairs(tips) do
	local name, tag, picture, technology = t[1], t[2], t[3], t[4]
	local trigger
	if technology then
		trigger = { type = "research", technology = technology }
	else
		-- the first Yuoki research of the player: the solar dish (green science) or mechanical force (blue)
		trigger = { type = "or", triggers = {
			{ type = "research", technology = "yuoki-solar-dish" },
			{ type = "research", technology = "yuoki-mechanical-force" },
		} }
	end
	list[#list + 1] = {
		type = "tips-and-tricks-item",
		name = name,
		category = CATEGORY,
		order = string.format("%02d", index),
		indent = technology and 1 or 0,
		is_title = technology == nil,
		tag = tag,
		image = "__Yuoki__/graphics/tips/" .. picture .. ".png",
		starting_status = "locked",
		trigger = trigger,
	}
end
data:extend(list)
