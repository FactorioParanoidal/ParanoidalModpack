-- Space Age in Paranoidal (Space Age branch, user decision 2026-11-08, ПР-078; before it ПР-077). Data stage.
-- Up to the rocket the build is classic Paranoidal. Space Age's own data.lua (base-data-updates.lua) rebuilds the base
-- game for its planets: technologies, recipes and items get planet sciences, other prices and prerequisites, the
-- satellite is removed. This puts the technologies, recipes and items back as they were right before Space Age's
-- data.lua, so the mods loaded after it build on the same base game as without the expansion. After the rocket come the
-- space platforms and the Space Age planets with their technologies. A planet material that has the name of a home
-- one (Bob's tungsten and lithium plate, Bob's ammonia, the BnL start scrap) becomes a separate prototype with its own
-- name: the home material keeps its recipes, every planet has its own. Kept from Space Age: the rocket silo launches to
-- platforms, space science is made on a platform (no satellite), its changes to buildings (where they may be built,
-- heating, frozen graphics). A prototype of another mod that Space Age defines again under the same name keeps the
-- mod's version. Without Space Age nothing here runs.
local SELF = "paranoidal-space-age-filter"
local SPACE_AGE = "space-age"
local wube = {core = true, base = true, quality = true, recycler = true, ["elevated-rails"] = true, [SPACE_AGE] = true}

-- Base technology kept as Space Age made it: it unlocks the space science recipe made on platforms (zzzparanoidal sets
-- its Beta 8 cost and prerequisites later, with the space platform among them).
local keep_technology = {["space-science-pack"] = true}
-- Removed by Space Age and left removed: space science comes from platforms.
local keep_removed = {item = {satellite = true}, recipe = {satellite = true}}
-- Travel to platforms by rocket: in Space Age the planet discoveries unlock it; the space platform technology
-- (researched by creating a platform) unlocks it too, so the platform can be visited before the first planet.
local travel_technology = "space-platform"
local TRAVEL = "unlock-travel-to-space-platforms"
-- Base technologies that keep what Space Age adds for platforms: unlocking them and the recipes of its own items
-- (the starter pack and the foundation).
local platform_effects = {["rocket-silo"] = true}
-- Item fields Space Age sets that stay: the rocket silo item draws the logistic requests of the silo.
local carried_item_fields = {"flags"}

-- Planet materials that have the name of a home material: Space Age's prototype (item, resource, recipe, fluid of that
-- name) goes under the new name, and every reference in Space Age's own prototypes follows it (user 2026-11-08: own new
-- materials on every planet, new names).
local own_materials = {
	["tungsten-ore"] = "paranoidal-wolframite", -- Vulcanus; Bob's tungsten ore
	["tungsten-plate"] = "paranoidal-refractory-beam", -- Vulcanus; Bob's tungsten plate
	["tungsten-carbide"] = "paranoidal-pobedit", -- Vulcanus; Bob's tungsten carbide
	["lithium-plate"] = "paranoidal-ice-silver", -- Aquilo; Bob's lithium plate
	ammonia = "paranoidal-cryogas", -- Aquilo; Bob's ammonia
	scrap = "paranoidal-ancient-debris", -- Fulgora; the scrap of the BnL start
}
local material_kinds = {"item", "resource", "recipe", "fluid"}
-- Space Age recipes that have the name of a home recipe while their product stays shared: only the recipe is renamed.
local own_recipes = {
	carbon = "paranoidal-carbon-from-coal", -- Vulcanus; carbon itself stays the home carbon (user 2026-11-08)
	["scrap-recycling"] = "paranoidal-ancient-debris-salvage", -- Fulgora; the BnL start has its own scrap recycling
}
-- A home resource listed by a planet: the planet gets an own deposit of the same product (Angels removes the home one).
local own_deposits = {
	gleba = {stone = {name = "paranoidal-stone-outcrop", control = "gleba_stone",
		probability = "gleba_stone_probability", richness = "gleba_stone_richness"}},
}
-- Map generator controls of the planets named after a home resource: Angels keeps a home resource whose name a planet
-- control has (Bob's tungsten ore went to RSO at home) and removes the control with the home resource (gleba_stone).
-- They get the name of the planet's own resource (with underscores: noise expressions read control:<name>:size, a
-- hyphen would be a minus); the planet and every expression of Space Age follow.
local own_controls = {
	tungsten_ore = "paranoidal_wolframite", -- Vulcanus
	gleba_stone = "paranoidal_stone_outcrop", -- Gleba
}
-- Keys whose string values are names of other kinds and never follow a renamed material; prerequisites name
-- technologies (Space Age has a technology tungsten-carbide).
local not_a_reference = {control = true, type = true, prerequisites = true}
-- The Fulgora chain hangs off recycling, a home technology in Paranoidal (Space Age ties recycling to Fulgora);
-- kovarex enrichment is hidden in Paranoidal.
local add_prerequisites = {["holmium-processing"] = {"planet-discovery-fulgora"}}
-- Space Age unlocks the scrap recycling with recycling (put back as it was): Fulgora's own debris comes with Fulgora.
local add_unlocks = {["planet-discovery-fulgora"] = {"paranoidal-ancient-debris-salvage"}}
local drop_prerequisites = {["captive-biter-spawner"] = {["kovarex-enrichment-process"] = true}}

local state = {phase = "before", owner = {}, collisions = {}, space_age = {}}

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

local name_section = {item = "item-name", resource = "entity-name", fluid = "fluid-name", recipe = "recipe-name"}

-- A new prototype from Space Age's one: own name and name key, no description of the old name.
local function copy_as(prototype, new_name, kind)
	local copy = table.deepcopy(prototype)
	copy.name = new_name
	copy.localised_description = nil
	local product = copy.main_product or (copy.results and #copy.results == 1 and copy.results[1].name)
	if kind == "recipe" and product and (own_materials[product] or product) == new_name then
		copy.localised_name = nil -- named after its product
	else
		copy.localised_name = {name_section[kind] .. "." .. new_name}
	end
	return copy
end

-- Space Age's planet materials under their own names, taken while they are still Space Age's (before the home ones
-- come back). Returns the new prototypes.
local function take_own_materials(raw)
	local copies = {}
	for _, kind in ipairs(material_kinds) do
		for old, new in pairs(own_materials) do
			local prototype = raw[kind] and raw[kind][old]
			if prototype and state.space_age[prototype] then copies[#copies + 1] = copy_as(prototype, new, kind) end
		end
	end
	for old, new in pairs(own_recipes) do
		local prototype = raw.recipe[old]
		if prototype and state.space_age[prototype] then copies[#copies + 1] = copy_as(prototype, new, "recipe") end
	end
	for _, deposits in pairs(own_deposits) do
		for old, deposit in pairs(deposits) do
			local prototype = raw.resource and raw.resource[old]
			if prototype then
				local copy = copy_as(prototype, deposit.name, "resource")
				copy.autoplace = {control = deposit.control, order = "b[" .. deposit.name .. "]",
					probability_expression = deposit.probability, richness_expression = deposit.richness}
				copies[#copies + 1] = copy
			end
		end
	end
	for old, new in pairs(own_controls) do
		local control = raw["autoplace-control"] and raw["autoplace-control"][old]
		if control and state.space_age[control] then
			local copy = table.deepcopy(control)
			copy.name = new
			-- Named after the planet's own resource (Space Age names the home one, which Angels removes).
			local resource = new:gsub("_", "-")
			copy.localised_name = {"", "[entity=" .. resource .. "] ", {"entity-name." .. resource}}
			copy.localised_description = nil
			copies[#copies + 1] = copy
		end
	end
	return copies
end

-- A string with the renamed controls in noise expressions ("control:<name>:size").
local function retarget_controls(v)
	for old, new in pairs(own_controls) do
		local from, to = "control:" .. old .. ":", "control:" .. new .. ":"
		local start = v:find(from, 1, true)
		while start do
			v = v:sub(1, start - 1) .. to .. v:sub(start + #from)
			start = v:find(from, start + #to, true)
		end
	end
	return v
end

-- Every string value naming a renamed material becomes the new name; a `recipe` field (technology effects) also
-- follows the renamed recipes; a `control` field and noise expressions follow the renamed controls. Prototype names
-- stay.
local function repoint(value, seen, top)
	for key, v in pairs(value) do
		if type(v) == "string" then
			if key == "control" then
				if own_controls[v] then value[key] = own_controls[v] end
			elseif v:find("control:", 1, true) then
				value[key] = retarget_controls(v)
			elseif not not_a_reference[key] and not (top and key == "name") then
				local new = own_materials[v] or (key == "recipe" and own_recipes[v])
				if new then value[key] = new end
			end
		elseif type(v) == "table" and not seen[v] and not not_a_reference[key] then
			seen[v] = true
			repoint(v, seen, false)
		end
	end
end

-- A planet lists the entities it places by name: the renamed resources and the own deposits.
local function rekey_planet(name, planet)
	local renames = {}
	for old, new in pairs(own_materials) do renames[old] = new end
	for old, deposit in pairs(own_deposits[name] or {}) do renames[old] = deposit.name end
	local settings = planet.map_gen_settings
	local controls = settings and settings.autoplace_controls
	for old, new in pairs(own_controls) do
		if controls and controls[old] ~= nil then
			controls[new] = controls[old]
			controls[old] = nil
		end
	end
	local entities = settings and settings.autoplace_settings and settings.autoplace_settings.entity
	local list = entities and entities.settings
	for old, new in pairs(renames) do
		if list and list[old] ~= nil then
			list[new] = list[old]
			list[old] = nil
		end
	end
	local overrides = settings and settings.property_expression_names
	if overrides then
		local keys = {}
		for key in pairs(overrides) do keys[#keys + 1] = key end
		for _, key in ipairs(keys) do
			local entity, property = key:match("^entity:([^:]+):(.+)$")
			if entity and renames[entity] then
				overrides["entity:" .. renames[entity] .. ":" .. property] = overrides[key]
				overrides[key] = nil
			end
		end
	end
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

	local copies = take_own_materials(raw)

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

	-- Prototypes of other mods that Space Age defined again under the same name.
	local names = {}
	for _, collision in pairs(state.collisions) do
		raw[collision.kind][collision.name] = collision.ref
		names[#names + 1] = collision.kind .. "/" .. collision.name .. " (" .. collision.owner .. ")"
	end
	table.sort(names)

	-- The planet materials under their own names; Space Age's prototypes point to them.
	state.extend(data, copies)
	local seen, renamed = {}, {}
	for prototype in pairs(state.space_age) do
		local list = raw[prototype.type]
		if list and list[prototype.name] == prototype then repoint(prototype, seen, true) end
	end
	state.copies = {}
	for _, copy in ipairs(copies) do
		repoint(copy, seen, true)
		renamed[#renamed + 1] = copy.type .. "/" .. copy.name
		state.copies[copy] = true
	end
	table.sort(renamed)
	local planets = {}
	for name, planet in pairs(raw.planet or {}) do
		if not state.before.planet[name] then
			rekey_planet(name, planet)
			planets[#planets + 1] = name
		end
	end
	table.sort(planets)
	-- RSO Reforged places the home resources; the planets and their own resources are left to the game's generator
	-- (its hook, read in its data-final-fixes).
	data.rso_ignore_planets = data.rso_ignore_planets or {}
	data.rso_ignore_resource_entities = data.rso_ignore_resource_entities or {}
	for _, name in ipairs(planets) do data.rso_ignore_planets[name] = true end
	state.rso_resources = {}
	for name in pairs(raw.resource or {}) do
		if not state.before.resource[name] then
			data.rso_ignore_resource_entities[name] = true
			state.rso_resources[name] = true
		end
	end

	state.fluids = {}
	for name in pairs(raw.fluid or {}) do
		if not state.before.fluid[name] then state.fluids[name] = true end
	end

	-- Space Age's own technologies: all of them after the rocket. The space platform technology also unlocks travel.
	state.technologies = {}
	local fixed = {}
	for name, technology in pairs(raw.technology) do
		if not technologies[name] then
			state.technologies[name] = true
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
			local prerequisites = technology.prerequisites
			if prerequisites and drop_prerequisites[name] then
				for i = #prerequisites, 1, -1 do
					if drop_prerequisites[name][prerequisites[i]] then
						fixed[#fixed + 1] = name .. " -" .. prerequisites[i]
						table.remove(prerequisites, i)
					end
				end
			end
			for _, recipe in ipairs(add_unlocks[name] or {}) do
				if raw.recipe[recipe] then
					technology.effects = technology.effects or {}
					table.insert(technology.effects, {type = "unlock-recipe", recipe = recipe})
					fixed[#fixed + 1] = name .. " unlocks " .. recipe
				end
			end
			for _, prerequisite in ipairs(add_prerequisites[name] or {}) do
				if raw.technology[prerequisite] then
					technology.prerequisites = technology.prerequisites or {}
					table.insert(technology.prerequisites, prerequisite)
					fixed[#fixed + 1] = name .. " +" .. prerequisite
				end
			end
		end
	end
	table.sort(fixed)
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
		state.technologies[name] = nil
		removed_names[#removed_names + 1] = name
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
	state.snapshot = nil
	log("paranoidal-space-age-filter: Space Age data.lua done (noticed in " .. where .. "): " .. restored
		.. " technologies, recipes and items as before it; rocket parts per rocket " .. tostring(state.rocket_parts_required)
		.. "; kept from Space Age: technology space-science-pack, no satellite, platform effects of the rocket silo technology; "
		.. "other mods' prototypes back (" .. #names .. "): " .. table.concat(names, ", ") .. "; planet materials under own names ("
		.. #renamed .. "): " .. table.concat(renamed, ", ") .. "; planets left to the game's generator: "
		.. table.concat(planets, ", ") .. "; technology fixes: " .. table.concat(fixed, ", ")
		.. "; removed (after an infinite level): " .. table.concat(removed_names, ", "))
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
					if key then state.space_age[prototype] = true end
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
	data.paranoidal_space_age_filter = {check = check, finish = finish, hide_recipes = M.hide_recipes,
		payload_weight = M.payload_weight, space_age_recipes = M.space_age_recipes}
end

-- Names of the recipes that are Space Age's own prototypes or its planet materials under own names (zzzparanoidal: they
-- do not decide the icons of home items). A home recipe of the same name defined after Space Age is not one of them.
function M.space_age_recipes()
	local names = {}
	for name, recipe in pairs(data.raw.recipe) do
		if state.space_age[recipe] or (state.copies or {})[recipe] then names[name] = true end
	end
	return names
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

-- Rocket payloads that return something to the ground (Expanded Rocket Payloads shuttles, satellites, the space lab,
-- the orbital solar collector) weigh 500 kg (user, 2026-11-07): without Space Age the rocket holds one item, with it any
-- items up to 1 t, and at 1 kg (their own weight) one rocket took ten. Now two fit, platform cargo is unchanged.
local PAYLOAD_WEIGHT = 500000 -- 500 kg; weight is in grams (the base satellite: 1 t = 1000000)

function M.payload_weight()
	local names = {}
	for kind in pairs(defines.prototypes.item) do
		for name, item in pairs(data.raw[kind] or {}) do
			if item.rocket_launch_products and next(item.rocket_launch_products)
				and (item.send_to_orbit_mode == "manual" or item.send_to_orbit_mode == "automated") then
				item.weight = PAYLOAD_WEIGHT
				names[#names + 1] = name
			end
		end
	end
	table.sort(names)
	log("paranoidal-space-age-filter: rocket payloads weigh 500 kg: " .. table.concat(names, ", "))
end

-- Items and fluids that are Space Age's own (still its prototypes) or its planet materials under own names.
local function space_age_names()
	local names = {}
	for prototype in pairs(state.space_age) do
		local list = data.raw[prototype.type]
		local material = prototype.type == "fluid" or defines.prototypes.item[prototype.type]
		if material and list and list[prototype.name] == prototype then names[prototype.name] = true end
	end
	for _, new in pairs(own_materials) do names[new] = true end
	return names
end

local function uses_any(recipe, names)
	for _, side in ipairs({recipe.ingredients or {}, recipe.results or {}}) do
		for _, part in ipairs(side) do
			if part.name and names[part.name] then return part.name end
		end
	end
end

-- data-final-fixes.lua of this mod. Up to the rocket nothing changes: Space Age technologies unlock only Space Age's
-- recipes (a home recipe of the same name or a home recipe again goes; a technology left with nothing is hidden, the
-- technologies after it take its prerequisites), home technologies do not unlock recipes with Space Age's items or
-- fluids (they go to the Space Age technology that unlocks their source, without one they are hidden; recycling is
-- rebuilt later by zzzparanoidal). Space Age recipes no visible technology unlocks are hidden, and so are recipes of any
-- mod with a Space Age fluid no visible recipe makes.
function M.hide_recipes()
	local raw = data.raw
	local copies = state.copies or {}
	local function space_age(prototype) return prototype and (state.space_age[prototype] or copies[prototype]) end
	-- Technologies of Space Age by prototype, not by name: a mod may define a technology of the same name after it
	-- (Bob's battery mk3 equipment), which is a home one.
	local technologies = {}
	for name, technology in pairs(raw.technology) do
		if space_age(technology) then technologies[name] = technology end
	end

	-- Space Age technologies: only Space Age recipes.
	local dropped, emptied = {}, {}
	for name, technology in pairs(technologies) do
		local effects = technology.effects
		if effects then
			for i = #effects, 1, -1 do
				local effect = effects[i]
				if effect.type == "unlock-recipe" and not space_age(raw.recipe[effect.recipe]) then
					dropped[#dropped + 1] = name .. ":" .. tostring(effect.recipe)
					table.remove(effects, i)
				end
			end
			if #effects == 0 then
				technology.hidden = true
				technology.enabled = false
				emptied[name] = technology.prerequisites or {}
			end
		end
	end
	local emptied_names = {}
	for name in pairs(emptied) do emptied_names[#emptied_names + 1] = name end
	table.sort(emptied_names)
	if #emptied_names > 0 then
		for _, technology in pairs(raw.technology) do
			local prerequisites = technology.prerequisites
			if prerequisites then
				local list, present = {}, {}
				for _, prerequisite in ipairs(prerequisites) do
					for _, inherited in ipairs(emptied[prerequisite] or {prerequisite}) do
						if not present[inherited] then
							present[inherited] = true
							list[#list + 1] = inherited
						end
					end
				end
				technology.prerequisites = list
			end
		end
	end
	table.sort(dropped)

	-- Resources another mod defined again after Space Age (the BnL start scrap) are home ones: RSO keeps them.
	local keep = {}
	for name, resource in pairs(raw.resource or {}) do
		if space_age(resource) then keep[name] = true end
	end
	for name in pairs(state.rso_resources or {}) do
		if not keep[name] then data.rso_ignore_resource_entities[name] = nil end
	end

	-- Home technologies: recipes with Space Age's items or fluids move to the Space Age technology of their source.
	local own = space_age_names()
	local source_of = {}
	for name, technology in pairs(technologies) do
		if not technology.hidden then
			for _, effect in ipairs(technology.effects or {}) do
				local recipe = effect.type == "unlock-recipe" and raw.recipe[effect.recipe]
				for _, result in ipairs(recipe and recipe.results or {}) do
					if own[result.name] and not source_of[result.name] then source_of[result.name] = name end
				end
			end
		end
	end
	local moved = {}
	for name, technology in pairs(raw.technology) do
		local effects = not technologies[name] and technology.effects
		for i = #(effects or {}), 1, -1 do
			local effect = effects[i]
			local recipe = effect.type == "unlock-recipe" and raw.recipe[effect.recipe]
			local recycling = type(effect.recipe) == "string" and effect.recipe:sub(-10) == "-recycling"
			local material = recipe and not recycling and not space_age(recipe) and uses_any(recipe, own)
			if material then
				table.remove(effects, i)
				local target = source_of[material] and raw.technology[source_of[material]]
				if target then
					table.insert(target.effects, effect)
					moved[#moved + 1] = effect.recipe .. " " .. name .. " -> " .. source_of[material]
				else
					recipe.hidden = true
					recipe.enabled = false
					moved[#moved + 1] = effect.recipe .. " " .. name .. " -> hidden"
				end
			end
		end
	end
	table.sort(moved)

	local unlocked = visible_unlocks()
	local hidden = 0
	for name, recipe in pairs(raw.recipe) do
		if space_age(recipe) and recipe.enabled == false and not unlocked[name] and not recipe.hidden then
			recipe.hidden = true
			hidden = hidden + 1
		end
	end

	-- A fluid comes from a visible recipe (but not from emptying what was filled with it: barrels, canisters, such a
	-- recipe takes an item that another recipe makes from that fluid), from a tile (offshore pumps: lava, oceans) or from
	-- a resource (geysers, brine, vents).
	local filled = {}
	for _, recipe in pairs(raw.recipe) do
		for fluid in pairs(fluids_of(recipe.ingredients, {})) do
			filled[fluid] = filled[fluid] or {}
			for _, result in ipairs(recipe.results or {}) do
				if result.type ~= "fluid" then filled[fluid][result.name] = true end
			end
		end
	end
	local made = {}
	for name, recipe in pairs(raw.recipe) do
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
	for _, tile in pairs(raw.tile or {}) do
		if type(tile.fluid) == "string" then made[tile.fluid] = true end
	end
	for _, resource in pairs(raw.resource or {}) do
		local minable = resource.minable
		for fluid in pairs(fluids_of(minable and minable.results, {})) do made[fluid] = true end
	end
	local unusable, cut = {}, {}
	for name, recipe in pairs(raw.recipe) do
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
	for _, technology in pairs(raw.technology) do
		local effects = technology.effects
		if effects then
			for i = #effects, 1, -1 do
				if effects[i].type == "unlock-recipe" and unusable[effects[i].recipe] then table.remove(effects, i) end
			end
		end
	end
	table.sort(cut)

	-- Every Space Age technology comes after the rocket silo. One that hangs off home technologies only gets the
	-- technology of its planet science pack as a prerequisite, or space science when it has none (Space Age's home
	-- planet technologies: electric weapons damage 1, steel plate productivity).
	local memo = {}
	local function after_silo(name)
		if memo[name] ~= nil then return memo[name] end
		memo[name] = false
		local result = false
		for _, prerequisite in ipairs((raw.technology[name] or {}).prerequisites or {}) do
			if prerequisite == "rocket-silo" or after_silo(prerequisite) then result = true break end
		end
		memo[name] = result
		return result
	end
	local tied, early = {}, {}
	for name, technology in pairs(technologies) do
		if not technology.hidden and not after_silo(name) then
			local source
			for _, ingredient in ipairs(technology.unit and technology.unit.ingredients or {}) do
				local pack = ingredient[1] or ingredient.name
				if pack and own[pack] and source_of[pack] and source_of[pack] ~= name then
					source = source_of[pack]
					break
				end
			end
			source = source or (raw.technology["space-science-pack"] and "space-science-pack")
			if source then
				technology.prerequisites = technology.prerequisites or {}
				table.insert(technology.prerequisites, source)
				tied[#tied + 1] = name .. " +" .. source
			end
		end
	end
	memo = {}
	for name, technology in pairs(technologies) do
		if not technology.hidden and not after_silo(name) then early[#early + 1] = name end
	end
	table.sort(tied)
	table.sort(early)
	log("paranoidal-space-age-filter: Space Age technologies no longer unlocking home recipes: "
		.. table.concat(dropped, ", ") .. "; hidden as empty: " .. table.concat(emptied_names, ", ")
		.. "; home technologies' recipes with Space Age materials moved: " .. table.concat(moved, ", ")
		.. "; Space Age recipes hidden (no visible technology unlocks them): " .. hidden
		.. "; recipes with Space Age fluids that nothing makes hidden: " .. table.concat(cut, ", ")
		.. "; tied to the technology of their science pack: " .. table.concat(tied, ", ")
		.. "; Space Age technologies NOT after the rocket silo: " .. (#early > 0 and table.concat(early, ", ") or "none"))
end

return M
