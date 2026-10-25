-- Paranoidal fork: YI suits and walkers are improved versions of the build's power armor (user, 2026-10-26).
-- Each YI armor consumes the power armor of its tier and is one step above it: a bigger equipment grid (fixed by the
-- YI grids: 9x9, 10x10, 11x11, 12x12, 13x13 against 8x9, 9x10, 10x11, 11x12), the base armor's resistances
-- +5 % and +2 flat, 5 more inventory slots and a quarter more durability. Stats are taken from the base armor here
-- (data-final-fixes; zzzparanoidal changes only the recipes of Bob's armor).
local P = require("prototypes.paranoidal.lib")

local tiers = {
	-- YI armor, base armor, extra ingredients (besides the base armor)
	{ "yi_armor_gray", "power-armor-mk2", {
		{ "y_structure_element", 22 }, { "y-basic-t2-mf", 6 }, { "y_quantrinum_infused", 2 }, { "y-fame", 1 },
		{ "y_rwtechsign", 400 } } },
	{ "yi_armor_red", "bob-power-armor-mk3", {
		{ "y_structure_element", 22 }, { "y-basic-t2-mf", 6 }, { "y-chip-2", 10 }, { "y_quantrinum_infused", 2 },
		{ "y-fame", 1 }, { "y_rwtechsign", 600 } } },
	{ "yi_armor_gold", "bob-power-armor-mk4", {
		{ "y_structure_element", 30 }, { "y-basic-t2-mf", 8 }, { "y-chip-2", 15 }, { "y_quantrinum_infused", 3 },
		{ "y_compensator_25", 1 }, { "y-fame", 6 }, { "y_rwtechsign", 1200 } } },
	{ "yi_walker_a", "bob-power-armor-mk5", {
		{ "y_structure_element", 40 }, { "y-basic-t2-mf", 12 }, { "y-chip-2", 20 }, { "y_quantrinum_infused", 4 },
		{ "y-accumulator-b-tx", 1 }, { "y-fame", 8 }, { "y_rwtechsign", 2500 } } },
	-- the top walker improves the first walker
	{ "yi_walker_c", "yi_walker_a", {
		{ "y_structure_element", 100 }, { "y-basic-t2-mf", 25 }, { "y_quantrinum_infused", 10 },
		{ "y-accumulator-crystal-m", 1 }, { "ye_science_blue", 20 }, { "y-fame", 20 }, { "y_rwtechsign", 6000 } } },
}

local function improved_resistances(base)
	local out = {}
	for _, r in pairs(base or {}) do
		local percent = r.percent
		if percent then
			percent = percent >= 100 and percent or math.min(95, percent + 5)
		end
		out[#out + 1] = { type = r.type, decrease = (r.decrease or 0) + 2, percent = percent }
	end
	return out
end

local done = {}
for _, t in ipairs(tiers) do
	local name, base_name, extra = t[1], t[2], t[3]
	local armor, base = P.entity("armor", name), P.entity("armor", base_name)
	armor.resistances = improved_resistances(base.resistances)
	armor.inventory_size_bonus = (base.inventory_size_bonus or 0) + 5
	armor.durability = math.floor((base.durability or 10000) * 1.25)
	local ingredients = { { base_name, 1 } }
	for _, e in ipairs(extra) do
		ingredients[#ingredients + 1] = e
	end
	P.ingredients(name, ingredients)
	done[#done + 1] = name .. " <- " .. base_name
end
log("Yuoki (Paranoidal): YI armor improves the build's power armor: " .. table.concat(done, ", "))
