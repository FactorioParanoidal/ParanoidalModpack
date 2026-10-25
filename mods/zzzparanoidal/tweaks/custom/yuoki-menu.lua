-- Yuoki (Paranoidal fork) in the build's crafting tabs (user decision 2026-10-26): every Yuoki row (item-subgroup)
-- moves into the existing tab where its content belongs, at the end of that tab; the emptied Yuoki tabs are deleted.
-- Runs after recipe-item-icon-sync / recipe-product-menu-sync: they still see the Yuoki groups and keep build items
-- out of Yuoki rows (protected_groups). Without the Yuoki mod nothing here exists and nothing changes.
local yuoki_groups = { "yuoki", "yuoki-energy", "yuoki-atomics", "yuoki_liquids", "j_yuoki_logistics", "yi_engines",
	"yie_harvest" }

local target = {
	-- yuoki
	["y-ammo"] = "combat",
	["y-defense"] = "paranoidal-defense",
	["y_defense_walls"] = "paranoidal-defense",
	["y-tools"] = "production",
	["y_line1"] = "production",
	["y_line1b"] = "production",
	["y-parts"] = "bob-intermediate-products",
	["y_parts_e"] = "bob-intermediate-products",
	["y-raw-material"] = "intermediate-products",
	["y_line2"] = "angels-resource-refining",
	["y_line3"] = "angels-resource-refining",
	["y_line4"] = "angels-resource-refining",
	["yuoki-archaeology"] = "angels-resource-refining",
	["yuoki-formpress"] = "angels-resource-refining",
	-- yuoki-energy
	["y-boiler"] = "production",
	["y-energy-2"] = "production",
	["y_mastercrafted"] = "production",
	["y_ultimate_products"] = "production",
	["y-lamps"] = "logistics",
	["y-electric"] = "intermediate-products",
	["y-fuel"] = "intermediate-products",
	["y-tech"] = "intermediate-products",
	["y_personal"] = "equipment",
	-- yuoki-atomics (transmutation rows by prefix below; trade and currencies)
	["y-stargate-4"] = "intermediate-products",
	["y-stargate-f"] = "intermediate-products",
	["y-stargate-r"] = "intermediate-products",
	-- yuoki_liquids
	["y-fluid"] = "angels-petrochem-refining",
	["y_refine_material"] = "angels-petrochem-refining",
	["y_refine_raws"] = "angels-petrochem-refining",
	["y_refine_parts"] = "angels-petrochem-refining",
	["y_refine_machinery"] = "production",
	-- yi_engines
	["yie-engines"] = "production",
	["yie-exp"] = "production",
	["yie-fluids"] = "production",
	["yie_machinery"] = "production",
	["yie_machinery2"] = "production",
	["yie-parts"] = "bob-intermediate-products",
	["yie-processed"] = "bob-intermediate-products",
	["yie_tubes"] = "bob-logistics",
	-- yie_harvest
	["yie_animals"] = "angels-bio-processing-alien",
	["yie_dnaline"] = "angels-bio-processing-alien",
	["yie_fish"] = "angels-bio-processing-alien",
	["yie_trades_line1"] = "intermediate-products",
	["yie_trades_line2"] = "intermediate-products",
	["yie_trades_import_line1"] = "intermediate-products",
}
local by_prefix = {
	{ "^j%-y%-atomics", "angels-resource-refining" },
	{ "^yie_agro", "angels-bio-processing-vegetables" },
	{ "^yie_farming", "angels-bio-processing-vegetables" },
}

local groups, subgroups = data.raw["item-group"], data.raw["item-subgroup"]
local is_yuoki = {}
for _, name in ipairs(yuoki_groups) do
	if groups[name] then
		is_yuoki[name] = true
	end
end
if not next(is_yuoki) then
	return
end

local fallback = "intermediate-products"
local moved, defaulted = 0, {}
for name, subgroup in pairs(subgroups) do
	if is_yuoki[subgroup.group] then
		local dest = target[name]
		if not dest then
			for _, rule in ipairs(by_prefix) do
				if name:find(rule[1]) then
					dest = rule[2]
					break
				end
			end
		end
		if not dest or not groups[dest] then
			defaulted[#defaulted + 1] = name
			dest = fallback
		end
		-- Yuoki rows at the end of the tab, in their former relative order
		subgroup.order = "zy-" .. (groups[subgroup.group].order or "") .. "-" .. (subgroup.order or "")
		subgroup.group = dest
		moved = moved + 1
	end
end

local removed = {}
for name in pairs(is_yuoki) do
	local used = false
	for _, subgroup in pairs(subgroups) do
		if subgroup.group == name then
			used = true
		end
	end
	if not used then
		groups[name] = nil
		removed[#removed + 1] = name
	end
end
table.sort(removed)
table.sort(defaulted)
log("Yuoki menu: " .. moved .. " rows moved into the build's tabs; tabs removed: " .. table.concat(removed, ", ")
	.. (#defaulted > 0 and ("; rows without a mapping (-> " .. fallback .. "): " .. table.concat(defaulted, ", ")) or ""))
