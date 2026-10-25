-- Paranoidal fork: make every Yuoki technology reachable in the build. For each unlocked recipe, every ingredient
-- and the crafting machine of its category must be obtainable from the start or from a recipe unlocked by the
-- technology itself or one of its ancestors; otherwise the shallowest technology that unlocks a producer is added
-- as a prerequisite (no cycles). Then redundant prerequisites are dropped and the units get the packs of their
-- prerequisites. Log lines list every addition, so the derived tree can be reviewed (TECH-TREE.md).
local yuoki = YUOKI_PARANOIDAL.tech_names
local T = data.raw.technology

local function active(tech)
	return tech and not tech.hidden and tech.enabled ~= false
end

-- recipe -> technologies unlocking it
local unlocked_by = {}
for name, tech in pairs(T) do
	if active(tech) then
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" then
				unlocked_by[e.recipe] = unlocked_by[e.recipe] or {}
				table.insert(unlocked_by[e.recipe], name)
			end
		end
	end
end

-- product -> producing recipes; products available from the start
local producers, start = {}, {}
for name, recipe in pairs(data.raw.recipe) do
	if not recipe.hidden and recipe.category ~= "recycling" and not name:find("^empty%-.+%-barrel$") then
		local at_start = recipe.enabled ~= false and not unlocked_by[name]
		for _, r in pairs(recipe.results or {}) do
			producers[r.name] = producers[r.name] or {}
			table.insert(producers[r.name], name)
			if at_start then
				start[r.name] = true
			end
		end
	end
end
for _, resource in pairs(data.raw.resource or {}) do
	local m = resource.minable or {}
	if m.result then
		start[m.result] = true
	end
	for _, r in pairs(m.results or {}) do
		start[r.name] = true
	end
end
for _, kind in pairs({ "tree", "simple-entity", "fish", "plant" }) do
	for _, e in pairs(data.raw[kind] or {}) do
		local m = e.minable or {}
		if m.result then
			start[m.result] = true
		end
		for _, r in pairs(m.results or {}) do
			start[r.name] = true
		end
	end
end
for _, tile in pairs(data.raw.tile or {}) do
	if tile.fluid then
		start[tile.fluid] = true
	end
end
start.steam = true -- boilers and heat exchangers, not recipes

-- crafting category -> items placing a machine that has it
local machine_items = {}
local placed_by = {}
for _, item in pairs(data.raw.item) do
	if item.place_result then
		placed_by[item.place_result] = placed_by[item.place_result] or {}
		table.insert(placed_by[item.place_result], item.name)
	end
end
for _, kind in pairs({ "assembling-machine", "furnace", "rocket-silo" }) do
	for name, machine in pairs(data.raw[kind] or {}) do
		for _, c in pairs(machine.crafting_categories or {}) do
			machine_items[c] = machine_items[c] or {}
			for _, item in pairs(placed_by[name] or {}) do
				table.insert(machine_items[c], item)
			end
		end
	end
end
local handcraft = {}
for _, character in pairs(data.raw.character or {}) do
	for _, c in pairs(character.crafting_categories or {}) do
		handcraft[c] = true
	end
end

local depth_cache, ancestors_cache = {}, {}
local function reset()
	depth_cache, ancestors_cache = {}, {}
end
local function depth(name, stack)
	if depth_cache[name] then
		return depth_cache[name]
	end
	stack = stack or {}
	if stack[name] then
		return 0
	end
	stack[name] = true
	local d = 0
	for _, p in pairs((T[name] or {}).prerequisites or {}) do
		d = math.max(d, depth(p, stack) + 1)
	end
	stack[name] = nil
	depth_cache[name] = d
	return d
end
local function ancestors(name)
	if ancestors_cache[name] then
		return ancestors_cache[name]
	end
	local seen, stack = {}, { name }
	while #stack > 0 do
		local n = table.remove(stack)
		for _, p in pairs((T[n] or {}).prerequisites or {}) do
			if not seen[p] then
				seen[p] = true
				stack[#stack + 1] = p
			end
		end
	end
	ancestors_cache[name] = seen
	return seen
end

-- technologies that make `thing` (an item/fluid name) available, or true if it is available from the start
local function sources(thing)
	if start[thing] then
		return true
	end
	local out = {}
	for _, recipe in pairs(producers[thing] or {}) do
		for _, tech in pairs(unlocked_by[recipe] or {}) do
			out[tech] = true
		end
	end
	return out
end

local added, unresolved = {}, {}
local function require_one(tech_name, need, label)
	if need == true then
		return false
	end
	local anc = ancestors(tech_name)
	local best, best_depth
	for cand in pairs(need) do
		if cand == tech_name or anc[cand] then
			return false
		end
		if not ancestors(cand)[tech_name] then -- would not create a cycle
			local d = depth(cand)
			if not best or d < best_depth or (d == best_depth and cand < best) then
				best, best_depth = cand, d
			end
		end
	end
	if not best then
		unresolved[#unresolved + 1] = tech_name .. ": " .. label
		return false
	end
	table.insert(T[tech_name].prerequisites, best)
	added[#added + 1] = tech_name .. " <- " .. best .. " (" .. label .. ")"
	reset()
	return true
end

local names = {}
for name in pairs(yuoki) do
	names[#names + 1] = name
end
table.sort(names)

for pass = 1, 30 do
	local changed = false
	unresolved = {}
	for _, tech_name in ipairs(names) do
		for _, e in pairs(T[tech_name].effects) do
			local recipe = data.raw.recipe[e.recipe]
			for _, ing in pairs(recipe.ingredients or {}) do
				local need = sources(ing.name)
				if need ~= true and next(need) == nil then
					unresolved[#unresolved + 1] = tech_name .. ": no source for " .. ing.name .. " (" .. e.recipe .. ")"
				elseif require_one(tech_name, need, ing.name .. " in " .. e.recipe) then
					changed = true
				end
			end
			local category = recipe.category or "crafting"
			if not handcraft[category] then
				local need = {}
				for _, item in pairs(machine_items[category] or {}) do
					local s = sources(item)
					if s == true then
						need = true
						break
					end
					for t in pairs(s) do
						need[t] = true
					end
				end
				if need ~= true and next(need) == nil then
					unresolved[#unresolved + 1] = tech_name .. ": no machine for category " .. category .. " (" .. e.recipe .. ")"
				elseif require_one(tech_name, need, "machine for " .. category) then
					changed = true
				end
			end
		end
	end
	if not changed then
		break
	end
end

-- drop prerequisites implied by another prerequisite
for _, tech_name in ipairs(names) do
	local prereqs = T[tech_name].prerequisites
	local keep = {}
	for _, p in ipairs(prereqs) do
		local implied = false
		for _, q in ipairs(prereqs) do
			if q ~= p and ancestors(q)[p] then
				implied = true
			end
		end
		if not implied and not keep[p] then
			keep[p] = true
			keep[#keep + 1] = p
		end
	end
	local list = {}
	for _, p in ipairs(keep) do
		list[#list + 1] = p
	end
	T[tech_name].prerequisites = list
end
reset()

-- packs: union with the packs of the prerequisites (Yuoki technologies in depth order)
table.sort(names, function(a, b)
	if depth(a) ~= depth(b) then
		return depth(a) < depth(b)
	end
	return a < b
end)
local pack_changes = {}
for _, tech_name in ipairs(names) do
	local unit = T[tech_name].unit
	local have = {}
	for _, ing in pairs(unit.ingredients) do
		have[ing[1] or ing.name] = true
	end
	for _, p in pairs(T[tech_name].prerequisites) do
		for _, ing in pairs(((T[p] or {}).unit or {}).ingredients or {}) do
			local pack = ing[1] or ing.name
			if not have[pack] then
				have[pack] = true
				table.insert(unit.ingredients, { pack, 1 })
				pack_changes[#pack_changes + 1] = tech_name .. " +" .. pack .. " (from " .. p .. ")"
			end
		end
	end
end

table.sort(added)
log("Yuoki (Paranoidal): derived prerequisites (" .. #added .. "): " .. table.concat(added, "; "))
log("Yuoki (Paranoidal): packs taken from prerequisites (" .. #pack_changes .. "): " .. table.concat(pack_changes, "; "))
if #unresolved > 0 then
	table.sort(unresolved)
	error("Yuoki (Paranoidal): unreachable Yuoki recipes:\n" .. table.concat(unresolved, "\n"))
end
