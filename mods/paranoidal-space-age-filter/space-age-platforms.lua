-- Space Age for the space platforms only (Space Age branch, user decision 2026-11-07, ПР-077). Data stage.
-- Space Age's own data.lua (base-data-updates.lua) rebuilds the base game for its planets: technologies, recipes and
-- items get planet sciences, other prices and prerequisites, the satellite is removed. This puts the technologies,
-- recipes and items back as they were right before Space Age's data.lua, so the mods loaded after it build on the same
-- base game as without the expansion. Kept from Space Age: the platforms (the rocket silo launches to them, its
-- technology unlocks them), space science made on a platform (no satellite), and its changes to buildings: where they
-- may be built and heating, which only matter on platforms. Its other technologies (planets and their content) are
-- hidden. A prototype of another mod that Space Age defines again under the same name keeps the mod's version.
-- Without Space Age nothing here runs.
local SELF = "paranoidal-space-age-filter"
local SPACE_AGE = "space-age"
local wube = {core = true, base = true, quality = true, recycler = true, ["elevated-rails"] = true, [SPACE_AGE] = true}

-- Base technology kept as Space Age made it: it unlocks the space science recipe made on platforms (zzzparanoidal sets
-- its Beta 8 cost and prerequisites later, with the space platform among them).
local keep_technology = {["space-science-pack"] = true}
-- Removed by Space Age and left removed: space science comes from platforms.
local keep_removed = {item = {satellite = true}, recipe = {satellite = true}}
-- Space Age technologies left visible: platforms, their thrusters, the landing pad unloading bay.
local visible_technology = {["space-platform"] = true, ["space-platform-thruster"] = true, ["landing-pad-unloading-bay"] = true}
-- Travel to platforms by rocket: in Space Age only the planet discoveries unlock it, and they are hidden here; the space
-- platform technology (researched by creating a platform) unlocks it instead.
local travel_technology = "space-platform"
local TRAVEL = "unlock-travel-to-space-platforms"
-- Base technologies that keep what Space Age adds for platforms: unlocking them and the recipes of its own items
-- (the starter pack and the foundation).
local platform_effects = {["rocket-silo"] = true}
-- Item fields Space Age sets that stay: the rocket silo item draws the logistic requests of the silo.
local carried_item_fields = {"flags"}

local state = {phase = "before", owner = {}, collisions = {}}

-- The mod whose data file runs: the outermost frame of a mod other than core.
local function running_mod()
	local outer
	local level = 3
	while true do
		local info = debug.getinfo(level, "S")
		if not info then return outer end
		local mod = type(info.source) == "string" and info.source:match("^@?__(.-)__/") or nil
		if mod and mod ~= "core" then outer = mod end
		level = level + 1
	end
end

local function snapshot_types()
	local kinds = {"technology", "recipe"}
	for kind in pairs(defines.prototypes.item) do kinds[#kinds + 1] = kind end
	return kinds
end

-- Right before Space Age's data.lua: every technology, recipe and item as it is, and the silo's rocket size.
local function start()
	state.phase = "in"
	state.snapshot = {}
	state.items = {}
	for _, kind in ipairs(snapshot_types()) do
		if kind ~= "technology" and kind ~= "recipe" then state.items[kind] = true end
		local saved = {}
		for name, prototype in pairs(data.raw[kind] or {}) do
			saved[name] = {ref = prototype, copy = table.deepcopy(prototype)}
		end
		state.snapshot[kind] = saved
	end
	local silo = data.raw["rocket-silo"] and data.raw["rocket-silo"]["rocket-silo"]
	state.rocket_parts_required = silo and silo.rocket_parts_required
	state.before = {}
	for _, kind in ipairs({"planet", "resource", "fluid", "space-location", "space-connection"}) do
		local names = {}
		for name in pairs(data.raw[kind] or {}) do names[name] = true end
		state.before[kind] = names
	end
end

-- The same table back with its earlier contents: other mods may hold references to it.
local function restore(target, copy)
	local keys = {}
	for key in pairs(target) do keys[#keys + 1] = key end
	for _, key in ipairs(keys) do target[key] = nil end
	for key, value in pairs(copy) do target[key] = value end
end

local function finish(where)
	if state.phase ~= "in" then return end
	state.phase = "after"
	data.extend = state.extend
	local raw = data.raw
	local technologies, recipes = state.snapshot.technology, state.snapshot.recipe

	-- What Space Age adds to the kept base technologies for platforms.
	local added = {}
	for name in pairs(platform_effects) do
		local technology = raw.technology[name]
		local list = {}
		for _, effect in ipairs(technology and technology.effects or {}) do
			if effect.type == "unlock-space-platforms"
				or (effect.type == "unlock-recipe" and raw.recipe[effect.recipe] and not recipes[effect.recipe]) then
				list[#list + 1] = table.deepcopy(effect)
			end
		end
		added[name] = list
	end

	local restored = 0
	for kind, saved in pairs(state.snapshot) do
		local all = raw[kind]
		for name, entry in pairs(saved) do
			local kept = (kind == "technology" and keep_technology[name]) or (keep_removed[kind] and keep_removed[kind][name])
			if not kept then
				local current = all and all[name]
				local carried = {}
				if state.items[kind] and current == entry.ref then
					for _, field in ipairs(carried_item_fields) do carried[field] = current[field] end
				end
				restore(entry.ref, entry.copy)
				for field, value in pairs(carried) do entry.ref[field] = value end
				if not all then
					all = {}
					raw[kind] = all
				end
				all[name] = entry.ref
				restored = restored + 1
			end
		end
	end
	for name, list in pairs(added) do
		local technology = raw.technology[name]
		if technology then
			technology.effects = technology.effects or {}
			for _, effect in ipairs(list) do table.insert(technology.effects, effect) end
		end
	end
	local silo = raw["rocket-silo"] and raw["rocket-silo"]["rocket-silo"]
	if silo and state.rocket_parts_required then silo.rocket_parts_required = state.rocket_parts_required end

	-- Space Age planets keep no resources: they are never visited, and a resource another planet uses is kept by
	-- Angels (stone, tungsten ore) and placed at home by RSO. Its own resources are not placed anywhere.
	local stripped = 0
	for name, planet in pairs(raw.planet or {}) do
		local settings = not state.before.planet[name] and planet.map_gen_settings
		if settings then
			local entity = settings.autoplace_settings and settings.autoplace_settings.entity
			for resource in pairs(entity and entity.settings or {}) do
				if raw.resource[resource] then
					entity.settings[resource] = nil
					stripped = stripped + 1
				end
			end
			for control in pairs(settings.autoplace_controls or {}) do
				local prototype = raw["autoplace-control"] and raw["autoplace-control"][control]
				if prototype and prototype.category == "resource" then settings.autoplace_controls[control] = nil end
			end
		end
	end
	for name, resource in pairs(raw.resource or {}) do
		if not state.before.resource[name] then resource.autoplace = nil end
	end
	-- Its planets, other places in space and the routes between them stay locked and are hidden too.
	for _, kind in ipairs({"planet", "space-location", "space-connection"}) do
		for name, place in pairs(raw[kind] or {}) do
			if not state.before[kind][name] then place.hidden = true end
		end
	end
	state.fluids = {}
	for name in pairs(raw.fluid or {}) do
		if not state.before.fluid[name] then state.fluids[name] = true end
	end

	-- Prototypes of other mods that Space Age defined again under the same name.
	local names = {}
	for _, collision in pairs(state.collisions) do
		raw[collision.kind][collision.name] = collision.ref
		names[#names + 1] = collision.kind .. "/" .. collision.name .. " (" .. collision.owner .. ")"
	end
	table.sort(names)

	-- Space Age's own technologies: planets and their content are hidden.
	local hidden, shown = 0, {}
	state.recipes = {}
	for name, technology in pairs(raw.technology) do
		if not technologies[name] then
			if visible_technology[name] then
				shown[#shown + 1] = name
				if name == travel_technology then
					technology.effects = technology.effects or {}
					local present = false
					for _, effect in pairs(technology.effects) do
						if effect.type == TRAVEL then present = true end
					end
					if not present then
						table.insert(technology.effects, {type = TRAVEL, modifier = true})
					end
				end
			else
				technology.hidden = true
				technology.enabled = false
				hidden = hidden + 1
			end
		end
	end
	-- An infinite level must be the last of its series. Space Age continues base series that are infinite again now
	-- (worker robot speed 6, then its own 7): its levels after the infinite one go.
	local series, removed = {}, {}
	for name in pairs(raw.technology) do
		local prefix, level = name:match("^(.-)%-(%d+)$")
		if prefix then
			series[prefix] = series[prefix] or {}
			series[prefix][tonumber(level)] = name
		end
	end
	for _, levels in pairs(series) do
		local infinite
		for level, name in pairs(levels) do
			if raw.technology[name].max_level == "infinite" and (not infinite or level < infinite) then infinite = level end
		end
		for level, name in pairs(levels) do
			if infinite and level > infinite and not technologies[name] then removed[name] = true end
		end
	end
	local removed_names = {}
	for name in pairs(removed) do
		raw.technology[name] = nil
		removed_names[#removed_names + 1] = name
		hidden = hidden - 1
	end
	if #removed_names > 0 then
		for _, technology in pairs(raw.technology) do
			local prerequisites = technology.prerequisites
			if prerequisites then
				for i = #prerequisites, 1, -1 do
					if removed[prerequisites[i]] then table.remove(prerequisites, i) end
				end
			end
		end
	end
	table.sort(removed_names)
	for name in pairs(raw.recipe) do
		if not recipes[name] then state.recipes[name] = true end
	end
	table.sort(shown)
	state.snapshot = nil
	log("paranoidal-space-age-filter: Space Age data.lua done (noticed in " .. where .. "): " .. restored
		.. " technologies, recipes and items as before it; rocket parts per rocket " .. tostring(state.rocket_parts_required)
		.. "; kept from Space Age: technology space-science-pack, no satellite, platform effects of the rocket silo technology; "
		.. "other mods' prototypes back (" .. #names .. "): " .. table.concat(names, ", ") .. "; Space Age technologies hidden "
		.. hidden .. ", removed (after an infinite level): " .. table.concat(removed_names, ", ") .. ", left: "
		.. table.concat(shown, ", ") .. "; resources taken off Space Age planets: " .. stripped)
end

local function check()
	if state.phase ~= "in" then return end
	local mod = running_mod()
	if mod ~= SPACE_AGE then finish(tostring(mod)) end
end

local M = {}

-- data.lua of this mod: from now on every data:extend tells which mod defines what, and when Space Age runs.
function M.install()
	state.extend = data.extend
	data.extend = function(self, otherdata)
		local list = otherdata
		if self ~= data and otherdata == nil then list = self end
		local mod = running_mod()
		if mod == SPACE_AGE then
			if state.phase == "before" then start() end
			if state.phase == "in" and type(list) == "table" then
				for _, prototype in ipairs(list) do
					local kind, name = type(prototype) == "table" and prototype.type, type(prototype) == "table" and prototype.name
					local key = type(kind) == "string" and type(name) == "string" and kind .. "/" .. name
					local existing = key and data.raw[kind] and data.raw[kind][name]
					if existing and state.owner[key] and not state.collisions[key] then
						state.collisions[key] = {kind = kind, name = name, ref = existing, owner = state.owner[key]}
					end
				end
			end
		else
			if state.phase == "in" then finish(tostring(mod)) end
			if state.phase == "before" and mod and not wube[mod] and mod ~= SELF and type(list) == "table" then
				for _, prototype in ipairs(list) do
					if type(prototype) == "table" and type(prototype.type) == "string" and type(prototype.name) == "string" then
						state.owner[prototype.type .. "/" .. prototype.name] = mod
					end
				end
			end
		end
		return state.extend(self, otherdata)
	end
	data.paranoidal_space_age_filter = {check = check, finish = finish, hide_recipes = M.hide_recipes}
end

local function visible_unlocks()
	local unlocked = {}
	for _, technology in pairs(data.raw.technology) do
		if not technology.hidden and technology.enabled ~= false then
			for _, effect in ipairs(technology.effects or {}) do
				if effect.type == "unlock-recipe" then unlocked[effect.recipe] = true end
			end
		end
	end
	return unlocked
end

local function fluids_of(list, into)
	for _, part in ipairs(list or {}) do
		if part.type == "fluid" then into[part.name] = true end
	end
	return into
end

-- data-final-fixes.lua of this mod: Space Age recipes that no visible technology unlocks are hidden too, and so are
-- recipes of any mod that use a Space Age fluid no visible recipe makes (barrels of its planet fluids); visible
-- technologies stop unlocking those.
function M.hide_recipes()
	local unlocked = visible_unlocks()
	local hidden = 0
	for name in pairs(state.recipes or {}) do
		local recipe = data.raw.recipe[name]
		if recipe and recipe.enabled == false and not unlocked[name] and not recipe.hidden then
			recipe.hidden = true
			hidden = hidden + 1
		end
	end

	-- A fluid is made by a visible recipe, but not by emptying what was filled with it (barrels, canisters): such a
	-- recipe takes an item that another recipe makes from that fluid.
	local filled = {}
	for _, recipe in pairs(data.raw.recipe) do
		for fluid in pairs(fluids_of(recipe.ingredients, {})) do
			filled[fluid] = filled[fluid] or {}
			for _, result in ipairs(recipe.results or {}) do
				if result.type ~= "fluid" then filled[fluid][result.name] = true end
			end
		end
	end
	local made = {}
	for name, recipe in pairs(data.raw.recipe) do
		if not recipe.hidden and (recipe.enabled ~= false or unlocked[name]) then
			for fluid in pairs(fluids_of(recipe.results, {})) do
				local emptying = false
				for _, ingredient in ipairs(recipe.ingredients or {}) do
					if ingredient.type ~= "fluid" and filled[fluid] and filled[fluid][ingredient.name] then emptying = true end
				end
				if not emptying then made[fluid] = true end
			end
		end
	end
	local unusable, cut = {}, {}
	for name, recipe in pairs(data.raw.recipe) do
		local used = fluids_of(recipe.results, fluids_of(recipe.ingredients, {}))
		for fluid in pairs(used) do
			if (state.fluids or {})[fluid] and not made[fluid] then
				unusable[name] = true
				if not recipe.hidden then
					recipe.hidden = true
					recipe.enabled = false
					cut[#cut + 1] = name
				end
				break
			end
		end
	end
	for _, technology in pairs(data.raw.technology) do
		local effects = technology.effects
		if effects then
			for i = #effects, 1, -1 do
				if effects[i].type == "unlock-recipe" and unusable[effects[i].recipe] then table.remove(effects, i) end
			end
		end
	end
	table.sort(cut)
	log("paranoidal-space-age-filter: Space Age recipes hidden (no visible technology unlocks them): " .. hidden
		.. "; recipes with Space Age fluids that nothing makes hidden: " .. table.concat(cut, ", "))
end

return M
