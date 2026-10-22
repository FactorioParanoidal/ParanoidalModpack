--[[ RSO Reforged (Resource Spawner Overhaul, Paranoidal fork) — control stage.

Resources are placed by the map generator from the noise expressions of prototypes/noise.lua;
this file reads the same expressions (LuaSurface.calculate_tile_properties) to know the field
sites, and places what the map generator cannot:

* enemy bases: the map is split into regions of rso-region-size chunks; when the first chunk of
  a region is generated, a region RNG seeded from the region position and the map seed picks
  the chunks that get bases, which are spawned when those chunks are generated;
* when the chunk holding the centre of a field is generated: an enemy base along the field, a
  guard nest and an old mine ruin (AbandonedRuins-paranoidal) by a rich field (vein or infinite
  core), the counters of the achievements;
* geological survey forecasts (Ore Radar), new veins under depleted ore, charting of new fields.
]]--

local util = require("util")
local C = require("config")
local loadResourceConfig = require("resourceconfigs.mainconfig")
local fillEnemies = require("resourceconfigs.vanilla_enemies")

local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local pi = math.pi
local max = math.max
local min = math.min
local distance = util.distance

local DEBUG = C.debug_enabled

local CHUNK_SIZE = 32
local NEGATIVE_MODIFICATOR = 9973
local REGION_TILE_SIZE = CHUNK_SIZE * settings.startup["rso-region-size"].value
local RUINS = "AbandonedRuins-paranoidal"
local RUIN_HALF = {small = 4, medium = 8, large = 16}
local FORECAST_CELLS = 5 -- forecasts look this many cells around the radar
-- Sites are read in blocks of BLOCK x BLOCK cells: every calculate_tile_properties call compiles
-- a noise program (about 17 ms whatever is asked), the number of positions costs little.
local BLOCK = 12
local GUARD_RADIUS = 40

-- sites of the noise generator per planet: {prefix, cell, region, resources = {index -> name}}
local PLANETS = prototypes.mod_data["rso-reforged"].data.planets

local function debug(str)
	log(str)
end

local function setting(name)
	return settings.global[name].value
end

--[[ HELPERS ]]--

local function normalize(n) -- keep numbers at 32 bits
	return floor(n) % 0xffffffff
end

local function rng_for_reg_pos(surfaceIndex, pos)
	local x = pos.x
	local y = pos.y
	local rng = game.create_random_generator()

	if x == 0 then x = 0.5 end
	if y == 0 then y = 0.5 end
	if x < 0 then x = abs(x) + NEGATIVE_MODIFICATOR end
	if y < 0 then y = abs(y) + NEGATIVE_MODIFICATOR end

	rng.re_seed(normalize(x * 65536))
	local valX = rng(65536)
	rng.re_seed(normalize(y * 32768))
	local valY = rng(32768)

	rng.re_seed(normalize(valX * valY * storage.surfaces[surfaceIndex].seed))
	return rng
end

local TREE_TYPES = {"tree", "simple-entity"}

local function remove_trees(surface, x, y, x_size, y_size)
	for _, entity in pairs(surface.find_entities_filtered{area = {{x - x_size, y - y_size}, {x + x_size, y + y_size}}, type = TREE_TYPES}) do
		if entity.valid then
			entity.destroy()
		end
	end
end

local function remove_trees_based_on_bb(surface, x, y, boundingBox)
	local bb = {{x + boundingBox.left_top.x, y + boundingBox.left_top.y}, {x + boundingBox.right_bottom.x, y + boundingBox.right_bottom.y}}
	for _, entity in pairs(surface.find_entities_filtered{area = bb, type = TREE_TYPES}) do
		if entity.valid then
			entity.destroy()
		end
	end
end

-- Flat key of an integer position (|x|, |y| < 2^21).
local function tile_key(x, y)
	return (x + 2097152) * 4194304 + (y + 2097152)
end

local function chunk_key(x, y)
	return tile_key(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
end

local function find_random_chunk(r_x, r_y, rng)
	local region_size = REGION_TILE_SIZE / CHUNK_SIZE
	local offset_x = rng(region_size) - 1
	local offset_y = rng(region_size) - 1
	return r_x*REGION_TILE_SIZE + offset_x*CHUNK_SIZE, r_y*REGION_TILE_SIZE + offset_y*CHUNK_SIZE
end

local function isInStartingArea(surfaceIndex, tileX, tileY)
	local surfaceData = storage.surfaces[surfaceIndex]
	if surfaceData and surfaceData.startingAreas then
		local size = surfaceData.starting_area_size
		for _, data in pairs(surfaceData.startingAreas) do
			local adjustedX = (tileX - data.x) / REGION_TILE_SIZE
			local adjustedY = (tileY - data.y) / REGION_TILE_SIZE
			if (adjustedX * adjustedX + adjustedY * adjustedY) <= size * size then
				return true
			end
		end
	end
	return false
end

-- distance in regions from the nearest starting area
local function distanceFromStartingAreas(surfaceData, regionX, regionY)
	local minDistance = nil
	local region = {x = regionX, y = regionY}
	for _, data in pairs(surfaceData.startingAreas) do
		local dist = distance({x = data.x / REGION_TILE_SIZE, y = data.y / REGION_TILE_SIZE}, region)
		minDistance = minDistance and min(minDistance, dist) or dist
	end
	return minDistance or distance({x = 0, y = 0}, region)
end

-- counters of the Reforged mechanics (remote "stats")
local function count(name)
	storage.stats = storage.stats or {}
	storage.stats[name] = (storage.stats[name] or 0) + 1
end

--[[ ENEMIES ]]--
local spawnerTable = nil

local function initSpawnerTable()
	if spawnerTable == nil then
		spawnerTable = {}
		for name, prototype in pairs(prototypes.get_entity_filtered{{filter = "type", type = "unit-spawner"}}) do
			spawnerTable[name] = prototype
		end
	end
end

-- weights of the entries available at this distance; stores allotment_range in every entry
local function computeAllotments(entityTable, regionDistance)
	local allotment_max = 0
	if not entityTable then
		return allotment_max
	end
	for _, v in pairs(entityTable) do
		if v then
			if not v.min_distance or regionDistance > v.min_distance then
				local allotment = v.allotment
				if v.allotment_distance_factor then
					local dist_factor = regionDistance^v.allotment_distance_factor
					if v.max_probability_distance_factor then
						dist_factor = max(dist_factor, v.max_probability_distance_factor)
					end
					allotment = allotment * dist_factor
				end
				v.allotment_range = {min = allotment_max, max = allotment_max + allotment}
				allotment_max = allotment_max + allotment
			else
				v.allotment_range = nil
			end
		end
	end
	return allotment_max
end

local function spawn_entity_helper(surface, prototype, x, y, config)
	local position = {x, y}
	if surface.entity_prototype_collides(prototype, position, true) then
		remove_trees_based_on_bb(surface, x, y, prototype.map_generator_bounding_box)
		if surface.entity_prototype_collides(prototype, position, true) then
			return false
		end
	end
	surface.create_entity{name = prototype.name, position = position, force = game.forces[config.force], spawn_decorations = true, raise_built = true}
	return true
end

-- an enemy base of config r_config around (x, y); returns the number of spawners placed
local function spawn_entity(surface, ent, r_config, x, y, rng, sizeMult)
	local size = rng(r_config.size.min, r_config.size.max)

	local surfaceData = storage.surfaces[surface.index]
	local r_distance = distanceFromStartingAreas(surfaceData, x/REGION_TILE_SIZE, y/REGION_TILE_SIZE)
	if surfaceData.starting_area_size then
		r_distance = max(r_distance - surfaceData.starting_area_size, 0.5)
	end

	local distanceMultiplier = 1
	if r_config.size_per_region_factor then
		distanceMultiplier = min(r_distance^r_config.size_per_region_factor, 5)
		size = size*distanceMultiplier
	end
	size = size * setting("rso-enemy-base-size") * (sizeMult or 1)

	if DEBUG then debug("spawn_entity "..ent.." "..x..","..y.." size:"..size.." dist:"..r_distance) end

	local maxAttemptCount = 16
	local distancePerBatch = 0.25
	initSpawnerTable()
	local base_allotment_max = computeAllotments(r_config.bases, r_distance)
	local failCount = 0
	local total = 0

	for i = 1, size do
		if failCount > 5 and failCount / (i - 1) > 0.75 then
			break
		end

		local baseSpawned = false
		local baseX, baseY
		for attempt = 1, maxAttemptCount do
			local max_d = floor(CHUNK_SIZE * (0.5 + (attempt/4) * distancePerBatch))
			baseX = x + rng(0, floor(max_d)) - max_d/2
			baseY = y + rng(0, floor(max_d)) - max_d/2

			if surface.get_tile(baseX, baseY).valid then
				if base_allotment_max == 0 then
					log("RSO: no enemy base definition available for "..ent)
					return total
				end
				local spawnerName = nil
				local base_type = rng(0, base_allotment_max)
				for base_name, v in pairs(r_config.bases) do
					if v and v.allotment_range and base_type >= v.allotment_range.min and base_type <= v.allotment_range.max then
						spawnerName = base_name
						break
					end
				end

				if spawnerName and spawnerTable[spawnerName] then
					if spawn_entity_helper(surface, spawnerTable[spawnerName], baseX, baseY, r_config) then
						total = total + 1
						baseSpawned = true
						break
					elseif attempt == maxAttemptCount then
						failCount = failCount + 1
					end
				else
					log("RSO: enemy base entity "..tostring(spawnerName).." doesn't exist")
				end
			end
		end

		if r_config.sub_spawn_probability and baseSpawned then
			local sub_spawn_prob = r_config.sub_spawn_probability*min(r_config.sub_spawn_max_distance_factor, r_config.sub_spawn_distance_factor^r_distance)
			if rng() < sub_spawn_prob then
				local allotment_max = computeAllotments(r_config.sub_spawns, r_distance)
				for _ = 1, (rng(r_config.sub_spawn_size.min, r_config.sub_spawn_size.max)*distanceMultiplier) do
					local sub_type = rng(0, allotment_max)
					for sub_spawn, v in pairs(r_config.sub_spawns) do
						if v.allotment_range and sub_type >= v.allotment_range.min and sub_type <= v.allotment_range.max then
							local turretPrototype = prototypes.entity[sub_spawn]
							if turretPrototype then
								for attempt = 1, maxAttemptCount do
									local max_d = floor((attempt/4) * CHUNK_SIZE * distancePerBatch)
									local s_x = baseX + rng(max_d) - max_d/2
									local s_y = baseY + rng(max_d) - max_d/2
									remove_trees(surface, s_x, s_y, v.clear_range[1], v.clear_range[2])
									if spawn_entity_helper(surface, turretPrototype, s_x, s_y, r_config) then
										break
									end
								end
							end
							break
						end
					end
				end
			end
		end
	end

	if DEBUG then debug("spawn_entity placed "..total.." fails "..failCount.." size "..size) end
	return total
end

--[[ CONFIG ]]--

local function modifyMinMax(value, mod)
	value.min = floor(value.min * mod + 0.5)
	value.max = floor(value.max * mod + 0.5)
end

local function adjustSizeMod(sizeMod)
	if sizeMod > 1 then
		sizeMod = 1 + (sizeMod - 1) / 2
	end
	return sizeMod
end

local CONFIG_ENV = {
	has = function(name)
		local prototype = prototypes.entity[name]
		return prototype ~= nil and prototype.autoplace_specification ~= nil
	end,
	mods = script.active_mods,
}

-- resource configs (new veins) and enemy bases of the surface; the enemy sliders are applied
local function loadAndPrepareConfig(surface)
	local surfaceData = storage.surfaces[surface.index]
	local planet = surface.planet
	local all = loadResourceConfig(CONFIG_ENV)
	fillEnemies(all)
	local config = planet and all[planet.name] or {}
	surfaceData.config = config
	surfaceData.enemyName = nil

	local controls = surface.map_gen_settings.autoplace_controls
	local entities = {}
	for name, cfg in pairs(config) do
		if type(cfg) == "table" and cfg.type == "entity" then
			local slider = controls and controls[cfg.autoplace_name or name]
			local keep = true
			if slider then
				if slider.frequency then cfg.absolute_probability = cfg.absolute_probability * slider.frequency end
				if slider.size then
					keep = slider.size > 0
					local sizeMod = adjustSizeMod(slider.size)
					modifyMinMax(cfg.size, sizeMod)
					modifyMinMax(cfg.spawns_per_region, sizeMod)
					if cfg.sub_spawn_size then modifyMinMax(cfg.sub_spawn_size, sizeMod) end
				end
			end
			if keep then
				cfg.name = name
				entities[#entities + 1] = cfg
				if cfg.bases and (not surfaceData.enemyName or name < surfaceData.enemyName) then
					surfaceData.enemyName = name
				end
			end
		end
	end
	table.sort(entities, function(a, b) return a.name < b.name end)
	surfaceData.configIndexed = entities
	surfaceData.starting_area_size = C.starting_area_size * (surface.map_gen_settings.starting_area or 1)
end

local function isIgnoredSurface(surface)
	return storage.ignoreSurfaceNames and storage.ignoreSurfaceNames[surface.name]
end

local function planet_info(surface)
	local planet = surface.planet
	return planet and not isIgnoredSurface(surface) and PLANETS[planet.name] or nil
end

--[[ ENEMY REGIONS ]]--

local function add_chunk_entry(r_data, c_x, c_y, name)
	local column = r_data[c_x]
	if not column then
		column = {}
		r_data[c_x] = column
	end
	local c_data = column[c_y]
	if not c_data then
		c_data = {}
		column[c_y] = c_data
	end
	c_data[#c_data + 1] = {name, 1}
end

local function roll_region(surface, c_x, c_y)
	if isInStartingArea(surface.index, c_x, c_y) then
		return
	end
	local r_x = floor(c_x/REGION_TILE_SIZE)
	local r_y = floor(c_y/REGION_TILE_SIZE)
	local surfaceData = storage.surfaces[surface.index]
	local regions = surfaceData.regions
	local column = regions[r_x]
	if column and column[r_y] then
		return -- already rolled
	end
	if not column then
		column = {}
		regions[r_x] = column
	end
	local r_data = {}
	column[r_y] = r_data

	local rng = rng_for_reg_pos(surface.index, {x = r_x, y = r_y})
	for _, v in ipairs(surfaceData.configIndexed) do
		if v.absolute_probability then
			local prob_factor = 1
			if v.probability_distance_factor then
				prob_factor = min(v.max_probability_distance_factor, v.probability_distance_factor^distance({x = 0, y = 0}, {x = r_x, y = r_y}))
			end
			if rng() < v.absolute_probability*prob_factor then
				for _ = 1, rng(v.spawns_per_region.min, v.spawns_per_region.max) do
					local s_x, s_y = find_random_chunk(r_x, r_y, rng)
					if not isInStartingArea(surface.index, s_x, s_y) then
						add_chunk_entry(r_data, s_x, s_y, v.name)
					end
				end
			end
		end
	end
end

local function roll_chunk(surface, c_x, c_y)
	local surfaceData = storage.surfaces[surface.index]
	local r_x = floor(c_x/REGION_TILE_SIZE)
	local r_y = floor(c_y/REGION_TILE_SIZE)
	local column = surfaceData.regions[r_x]
	local r_data = column and column[r_y]
	local list = r_data and r_data[c_x] and r_data[c_x][c_y]
	if not list then
		return
	end
	r_data[c_x][c_y] = nil
	if next(r_data[c_x]) == nil then
		r_data[c_x] = nil
	end
	if storage.skipEnemies then return end

	local c_center_x = c_x + CHUNK_SIZE/2
	local c_center_y = c_y + CHUNK_SIZE/2
	local rng = rng_for_reg_pos(surface.index, {x = c_center_x, y = c_center_y})
	for _, entry in ipairs(list) do
		-- regions rolled before 9.1.0 may also list resources: those are placed by the map generator now
		local r_config = surfaceData.config[entry[1]]
		if r_config and r_config.type == "entity" then
			spawn_entity(surface, entry[1], r_config, c_center_x, c_center_y, rng)
		end
	end
end

--[[ FIELD SITES ]]--

-- Sites of the noise generator, cached per cell: storage.cells[surface index][cell key] =
-- {x, y, name, liquid, radius, estimate, vein, core, partner}; storage.blocks[surface index]
-- [block key] = true once a block is read. The values are those of the expressions, the same on
-- every peer.
local function query_cells(surface, info, wanted)
	local p, G = info.prefix, info.cell
	local cells = storage.cells[surface.index]
	local positions = {}
	for i, c in ipairs(wanted) do positions[i] = {(c[1] + 0.5) * G, (c[2] + 0.5) * G} end
	local r = surface.calculate_tile_properties({p .. "cell_on", p .. "cell_x", p .. "cell_y"}, positions)
	local on, centres = {}, {}
	for i, c in ipairs(wanted) do
		if r[p .. "cell_on"][i] > 0 then
			on[#on + 1] = c
			centres[#centres + 1] = {r[p .. "cell_x"][i], r[p .. "cell_y"][i]}
		end
	end
	if #on == 0 then return end
	local names = {"kind", "valid", "liq", "rad", "estimate", "veinon", "coretiles", "multi", "partner"}
	local props = {}
	for i, name in ipairs(names) do props[i] = p .. name end
	local d = surface.calculate_tile_properties(props, centres)
	local function v(name, i) return d[p .. name][i] end
	for i, c in ipairs(on) do
		local name = info.resources[floor(v("kind", i) + 0.5)]
		if v("valid", i) > 0 and name then
			cells[tile_key(c[1], c[2])] = {
				x = centres[i][1], y = centres[i][2], name = name, liquid = v("liq", i) > 0, radius = v("rad", i),
				estimate = v("estimate", i), vein = v("veinon", i) > 0 and v("liq", i) == 0,
				core = v("liq", i) == 0 and v("coretiles", i) >= C.infinite_core_tiles,
				partner = v("multi", i) > 0 and info.resources[floor(v("partner", i) + 0.5)] or nil,
			}
		end
	end
end

local function block_of(c)
	return floor((c + BLOCK / 2) / BLOCK)
end

-- sites of the cells ci1..ci2 x cj1..cj2 (read by blocks)
local function sites_in(surface, info, ci1, cj1, ci2, cj2)
	storage.cells = storage.cells or {}
	storage.blocks = storage.blocks or {}
	local index = surface.index
	storage.cells[index] = storage.cells[index] or {}
	storage.blocks[index] = storage.blocks[index] or {}
	local cells, blocks = storage.cells[index], storage.blocks[index]
	for bi = block_of(ci1), block_of(ci2) do
		for bj = block_of(cj1), block_of(cj2) do
			local key = tile_key(bi, bj)
			if not blocks[key] then
				blocks[key] = true
				local wanted = {}
				for ci = bi * BLOCK - BLOCK / 2, bi * BLOCK + BLOCK / 2 - 1 do
					for cj = bj * BLOCK - BLOCK / 2, bj * BLOCK + BLOCK / 2 - 1 do
						wanted[#wanted + 1] = {ci, cj}
					end
				end
				query_cells(surface, info, wanted)
			end
		end
	end
	local out = {}
	for ci = ci1, ci2 do
		for cj = cj1, cj2 do
			local site = cells[tile_key(ci, cj)]
			if site then out[#out + 1] = site end
		end
	end
	return out
end

-- Sites of rich veins and guard nests, for the per-force counters read by achievements (remote
-- "force_stats"): storage.sites[surface index][chunk key] = list of {kind, x, y, found = {force index}}
local function add_site(surface, kind, x, y)
	storage.sites = storage.sites or {}
	local sites = storage.sites[surface.index] or {}
	storage.sites[surface.index] = sites
	local key = chunk_key(x, y)
	sites[key] = sites[key] or {}
	table.insert(sites[key], {kind = kind, x = x, y = y, found = {}})
end

local function credit(force, stat)
	storage.forceStats = storage.forceStats or {}
	local stats = storage.forceStats[force.index] or {}
	storage.forceStats[force.index] = stats
	stats[stat] = (stats[stat] or 0) + 1
end

-- the chunk holding the centre of a field is generated: enemies along it, guards and mine ruins
-- by a rich field
local function field_extras(surface, surfaceData, site)
	local rng = rng_for_reg_pos(surface.index, {x = site.x, y = site.y})
	local dist = distanceFromStartingAreas(surfaceData, site.x / REGION_TILE_SIZE, site.y / REGION_TILE_SIZE)
	local enemyName = surfaceData.enemyName
	local enemy = enemyName and surfaceData.config[enemyName]
	local fight = enemy and not storage.skipEnemies

	-- an enemy base along the field (RSO along_resource_probability)
	if fight and enemy.along_resource_probability and rng() < enemy.along_resource_probability then
		spawn_entity(surface, enemyName, enemy, site.x, site.y, rng)
	end

	if not (site.vein or site.core) then return end
	-- a regeneration (command) places the guards again, but no second ruin and no counters
	local fresh = not storage.regenerating
	if site.vein and fresh then
		count("veins")
		add_site(surface, "vein", site.x, site.y)
	end
	local guardChance = setting("rso-guard-chance")
	if fight and guardChance > 0 and dist >= C.guard_min_distance and rng() < guardChance then
		if DEBUG then debug("Guard nest for the field at "..site.x..","..site.y) end
		if spawn_entity(surface, enemyName, enemy, site.x, site.y, rng, C.guard_size_mult) > 0 and fresh then
			count("guards")
			add_site(surface, "guard", site.x, site.y)
		end
	end

	local mineChance = setting("rso-mine-ruin-chance")
	local iface = remote.interfaces[RUINS]
	if fresh and mineChance > 0 and iface and iface.spawn_mine and dist >= C.mine_min_distance and rng() < mineChance then
		local size = site.core and "large" or (rng() < 0.5 and "medium" or "small")
		local half = RUIN_HALF[size]
		local gap = site.radius * 1.4 + half + 3
		local angle = rng() * 2 * pi
		local x, y = floor(site.x + cos(angle) * gap), floor(site.y + sin(angle) * gap)
		-- only on generated ground
		for _, corner in ipairs({{x - half, y - half}, {x + half, y - half}, {x - half, y + half}, {x + half, y + half}}) do
			if not surface.is_chunk_generated({floor(corner[1] / CHUNK_SIZE), floor(corner[2] / CHUNK_SIZE)}) then
				return
			end
		end
		if remote.call(RUINS, "spawn_mine", surface.index, {x = x, y = y}, size) then count("mines") end
	end
end

local function generate_chunk(surface, c_x, c_y)
	local surfaceData = storage.surfaces[surface.index]
	if not surfaceData or isIgnoredSurface(surface) then return end
	if #surfaceData.configIndexed > 0 then
		roll_region(surface, c_x, c_y)
		roll_chunk(surface, c_x, c_y)
	end

	local info = planet_info(surface)
	if not info then return end
	local G = info.cell
	for _, site in ipairs(sites_in(surface, info, floor(c_x / G), floor(c_y / G),
		floor((c_x + CHUNK_SIZE - 1) / G), floor((c_y + CHUNK_SIZE - 1) / G))) do
		if site.x >= c_x and site.y >= c_y and site.x < c_x + CHUNK_SIZE and site.y < c_y + CHUNK_SIZE then
			field_extras(surface, surfaceData, site)
		end
	end

	if setting("rso-reveal-spawned-resources") then
		local area = {{c_x, c_y}, {c_x + CHUNK_SIZE, c_y + CHUNK_SIZE}}
		if surface.count_entities_filtered{area = area, type = "resource", limit = 1} > 0 then
			for _, force in pairs(game.forces) do
				force.chart(surface, area)
			end
		end
	end
end

--[[ REGENERATION ]]--

-- resource prototypes placed by RSO on the surface (with their infinite variants)
local function resource_names(info)
	local names = {}
	for _, name in ipairs(info and info.resources or {}) do
		names[#names + 1] = name
		if prototypes.entity["infinite-" .. name] then names[#names + 1] = "infinite-" .. name end
	end
	return names
end

local function enemy_names(surfaceData)
	local names = {}
	for _, v in ipairs(surfaceData.configIndexed or {}) do
		for base in pairs(v.bases or {}) do names[#names + 1] = base end
		for ent in pairs(v.sub_spawns or {}) do names[#names + 1] = ent end
	end
	return names
end

-- clears RSO resources (and enemy bases unless storage.skipEnemies) outside the starting areas;
-- then the map generator places the resources again and the enemy regions are rolled anew
local function regenerateSurface(surface, clearOnly)
	local surfaceData = storage.surfaces[surface.index]
	local info = planet_info(surface)
	if not surfaceData or isIgnoredSurface(surface) then return end
	local resources = resource_names(info)
	local enemies = storage.skipEnemies and {} or enemy_names(surfaceData)
	local chunks = {}
	for chunk in surface.get_chunks() do
		local x, y = chunk.x * CHUNK_SIZE, chunk.y * CHUNK_SIZE
		if not isInStartingArea(surface.index, x, y) then
			chunks[#chunks + 1] = {chunk.x, chunk.y}
			local area = {{x, y}, {x + CHUNK_SIZE, y + CHUNK_SIZE}}
			if #resources > 0 then
				for _, entity in pairs(surface.find_entities_filtered{area = area, name = resources}) do entity.destroy() end
			end
			if #enemies > 0 then
				for _, entity in pairs(surface.find_entities_filtered{area = area, name = enemies}) do entity.destroy() end
				for _, entity in pairs(surface.find_entities_filtered{area = area, type = "unit", force = "enemy"}) do entity.destroy() end
			end
		end
	end
	surfaceData.regions = {}
	if storage.cells then storage.cells[surface.index] = nil end
	if storage.blocks then storage.blocks[surface.index] = nil end
	if not clearOnly then
		if #resources > 0 and #chunks > 0 then
			surface.regenerate_entity(resources, chunks)
		end
		storage.regenerating = true
		for _, chunk in ipairs(chunks) do
			generate_chunk(surface, chunk[1] * CHUNK_SIZE, chunk[2] * CHUNK_SIZE)
		end
		storage.regenerating = nil
	end
	log(clearOnly and "RSO: ore clear done on " .. surface.name or "RSO: ore regeneration done on " .. surface.name)
end

local function regenerate_everything(clearOnly, noEnemies)
	storage.skipEnemies = noEnemies
	for index in pairs(storage.surfaces) do
		local surface = game.surfaces[index]
		if surface then
			regenerateSurface(surface, clearOnly)
		end
	end
	storage.skipEnemies = nil
end

--[[ DIAGNOSTICS ]]--

local function IsIgnoreResource(prototype)
	local name = prototype.name
	if string.find(name, "underground-", 1, true) or string.find(name, "infinite-", 1, true) then
		return true
	end
	local autoplace = prototype.autoplace_specification
	return autoplace == nil or autoplace.tile_restriction ~= nil
end

-- tells the player about resources with autoplace that RSO has no config for (they are not spawned)
local function checkForUnusedResources(player)
	if script.active_mods["space-age"] then return end
	local info = planet_info(player.surface)
	if not info then return end
	local used = {}
	for _, name in ipairs(info.resources) do used[name] = true end
	for name, prototype in pairs(prototypes.get_entity_filtered{{filter = "type", type = "resource"}}) do
		if not used[name] and not IsIgnoreResource(prototype) then
			player.print("The resource " .. name .. " is not configured in RSO. It won't be spawned!")
		end
	end
end

--[[ LIFECYCLE ]]--

local function updateSurfaceConfig(surface)
	storage.surfaces[surface.index] = storage.surfaces[surface.index] or {}
	local surfaceData = storage.surfaces[surface.index]
	surfaceData.seed = surface.map_gen_settings.seed
	surfaceData.regions = surfaceData.regions or {}
	if not surfaceData.startingAreas then
		surfaceData.startingAreas = {}
		for _, startingPoint in pairs(surface.map_gen_settings.starting_points or {}) do
			table.insert(surfaceData.startingAreas, {x = startingPoint.x, y = startingPoint.y})
		end
	end
	-- 9.0.0 data of the scripted ore generation
	surfaceData.provinces, surfaceData.guarantees, surfaceData.rollCount, surfaceData.maxAllotment = nil, nil, nil, nil
	loadAndPrepareConfig(surface)
end

local function updateConfig()
	storage.surfaces = storage.surfaces or {}
	storage.regions = nil -- very old saves
	for _, surface in pairs(game.surfaces) do
		updateSurfaceConfig(surface)
	end
	for index in pairs(storage.surfaces) do
		if not game.get_surface(index) then storage.surfaces[index] = nil end
	end
	storage.useBobEntity = nil
	storage.mapSeedOverride = nil
	storage.disableStartingArea = nil
	-- the cell grid follows startup settings (region size, resource chance): sites are read again
	storage.cells, storage.blocks = nil, nil
	log("RSO: Updated resource configurations")
end

local function localGenerateChunk(event)
	generate_chunk(event.surface, event.area.left_top.x, event.area.left_top.y)
end

local function registerChunkHandler()
	if not storage.disableEventHandler then
		script.on_event(defines.events.on_chunk_generated, localGenerateChunk)
	end
end

script.on_init(function()
	updateConfig()
	registerChunkHandler()
end)

script.on_load(registerChunkHandler)

script.on_configuration_changed(updateConfig)

local function notify(event, message)
	local player = event.player_index and game.get_player(event.player_index)
	if player then
		player.print(message)
	else
		game.print(message)
	end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "rso-enemy-chance" then
		for _, surface in pairs(game.surfaces) do
			if storage.surfaces[surface.index] then loadAndPrepareConfig(surface) end
		end
		notify(event, "Enemy spawn chance update - it will be applied to new regions.")
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if not storage.surfaces[player.surface.index] then
		updateSurfaceConfig(player.surface)
	end
	checkForUnusedResources(player)
end)

script.on_event(defines.events.on_surface_created, function(event)
	local surface = game.surfaces[event.surface_index]
	if not isIgnoredSurface(surface) then
		updateSurfaceConfig(surface)
	end
end)

--[[ GEOLOGICAL SURVEY ]]--

-- storage.forecasts[surface index][chunk key][force index] = map label (LuaRenderObject); the chunk
-- key is tile_key of the chunk's top left tile
local function forecast_marks(surface_index)
	storage.forecasts = storage.forecasts or {}
	local marks = storage.forecasts[surface_index]
	if not marks then
		marks = {}
		storage.forecasts[surface_index] = marks
	end
	return marks
end

local function clear_forecasts(surface_index)
	local marks = storage.forecasts and storage.forecasts[surface_index]
	if not marks then return end
	for _, forces in pairs(marks) do
		for _, label in pairs(forces) do
			if label.valid then label.destroy() end
		end
	end
	storage.forecasts[surface_index] = nil
end

local function amount_text(amount)
	if amount >= 1e6 then
		return string.format("~%.1fM", amount / 1e6)
	end
	return string.format("~%dk", floor(amount / 1000 + 0.5))
end

-- marks for the force on its map the nearest field around position that the force has not charted
local function forecast(surface_index, force_index, position)
	local surface = game.get_surface(surface_index)
	local force = game.forces[force_index]
	local info = surface and planet_info(surface)
	if not (info and force and type(position) == "table" and position.x and position.y) then
		return nil
	end
	local marks = forecast_marks(surface_index)
	local G = info.cell
	local ci, cj = floor(position.x / G), floor(position.y / G)
	local best, bestD, bestKey = nil, nil, nil
	for _, site in ipairs(sites_in(surface, info, ci - FORECAST_CELLS, cj - FORECAST_CELLS, ci + FORECAST_CELLS, cj + FORECAST_CELLS)) do
		local chunk = {floor(site.x / CHUNK_SIZE), floor(site.y / CHUNK_SIZE)}
		local key = tile_key(chunk[1] * CHUNK_SIZE, chunk[2] * CHUNK_SIZE)
		local d = (site.x - position.x)^2 + (site.y - position.y)^2
		if (not bestD or d < bestD) and not (marks[key] and marks[key][force_index])
			and not force.is_chunk_charted(surface, chunk) then
			best, bestD, bestKey = site, d, key
		end
	end
	if not best then return nil end

	local x, y = floor(best.x), floor(best.y)
	local icon = "[img=entity/" .. best.name .. "]" .. (best.partner and "[img=entity/" .. best.partner .. "]" or "")
	local label = rendering.draw_text{
		text = icon .. " " .. amount_text(best.estimate),
		surface = surface, target = {x, y}, color = {1, 0.85, 0.4}, forces = {force},
		render_mode = "chart", scale = 1.5, scale_with_zoom = true, use_rich_text = true,
		alignment = "center", vertical_alignment = "middle",
	}
	marks[bestKey] = marks[bestKey] or {}
	marks[bestKey][force_index] = label
	count("forecasts")
	force.print({"rso-message.forecast", icon, string.format("[gps=%d,%d,%s]", x, y, surface.name)})
	return {x = x, y = y}
end

-- a forecast disappears when its chunk is charted by the force: the field is on the map then;
-- a rich vein in the chunk counts as found by the force
script.on_event(defines.events.on_chunk_charted, function(event)
	local force = event.force
	local marks = storage.forecasts and storage.forecasts[event.surface_index]
	if marks then
		local key = tile_key(event.position.x * CHUNK_SIZE, event.position.y * CHUNK_SIZE)
		local forces = marks[key]
		local label = forces and forces[force.index]
		if label then
			if label.valid then label.destroy() end
			forces[force.index] = nil
			if next(forces) == nil then marks[key] = nil end
		end
	end
	local sites = storage.sites and storage.sites[event.surface_index]
	local list = sites and sites[tile_key(event.position.x, event.position.y)]
	if list then
		for _, site in ipairs(list) do
			if site.kind == "vein" and not site.found[force.index] then
				site.found[force.index] = true
				credit(force, "veins")
			end
		end
	end
end)

-- the last nest of a guard site killed by a force clears the site for it
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	local sites = storage.sites and storage.sites[entity.surface.index]
	if not sites then return end
	local p = entity.position
	local cx, cy = floor(p.x / CHUNK_SIZE), floor(p.y / CHUNK_SIZE)
	for dx = -1, 1 do
		for dy = -1, 1 do
			local key = tile_key(cx + dx, cy + dy)
			local list = sites[key]
			if list then
				for i = #list, 1, -1 do
					local site = list[i]
					if site.kind == "guard" and (site.x - p.x)^2 + (site.y - p.y)^2 <= GUARD_RADIUS^2
						and entity.surface.count_entities_filtered{position = {site.x, site.y}, radius = GUARD_RADIUS,
							type = "unit-spawner", force = entity.force} <= 1 then
						table.remove(list, i)
						local force = event.force
						if force and force.valid and #force.players > 0 then
							credit(force, "guards")
						end
					end
				end
				if #list == 0 then sites[key] = nil end
			end
		end
	end
end, {{filter = "type", type = "unit-spawner"}})

--[[ NEW VEINS UNDER DEPLETED FIELDS ]]--

-- a small field of name around pos on free ground; returns the placed box or nil
local function spawn_vein(surface, name, pos, size, richness, min_amount, rng)
	local radius = size / 2
	local reach = ceil(radius)
	local density = richness * 7.5 * size ^ 0.6 * 3 / (pi * radius * radius)
	local spots = {}
	local total = 0
	for dx = -reach, reach do
		for dy = -reach, reach do
			local d = sqrt(dx * dx + dy * dy) / radius
			if d <= 0.8 + 0.4 * rng() then
				total = total + 1
				local position = {pos.x + dx, pos.y + dy}
				if surface.can_place_entity{name = name, position = position} then
					spots[#spots + 1] = {position, max(0, 1 - d)}
				end
			end
		end
	end
	if #spots == 0 or #spots < 0.1 * total then return nil end
	local box = {1e9, 1e9, -1e9, -1e9}
	local neutral = game.forces.neutral
	for _, spot in ipairs(spots) do
		local position = spot[1]
		surface.create_entity{name = name, position = position, force = neutral,
			amount = floor(min_amount + density * spot[2]), raise_built = true}
		box = {min(box[1], position[1]), min(box[2], position[2]), max(box[3], position[1]), max(box[4], position[2])}
	end
	surface.destroy_decoratives{area = {{box[1], box[2]}, {box[3] + 1, box[4] + 1}}}
	return box
end

script.on_event(defines.events.on_resource_depleted, function(event)
	local chance = setting("rso-depletion-vein-chance")
	local entity = event.entity
	if chance <= 0 or not (entity and entity.valid) then return end
	local surface = entity.surface
	local surfaceData = storage.surfaces[surface.index]
	if not (surfaceData and planet_info(surface)) then return end
	local name = entity.name
	local cfg = surfaceData.config and surfaceData.config[name]
	if not (cfg and cfg.type == "resource-ore") then return end

	storage.depletionRng = storage.depletionRng or game.create_random_generator(surfaceData.seed % 4294967296)
	local rng = storage.depletionRng
	if rng() >= chance then return end

	local p = entity.position
	local angle = rng() * pi * 2
	local d = C.depletion_vein_distance[1] + rng() * (C.depletion_vein_distance[2] - C.depletion_vein_distance[1])
	local pos = {x = floor(p.x + cos(angle) * d) + 0.5, y = floor(p.y + sin(angle) * d) + 0.5}
	local dist = distanceFromStartingAreas(surfaceData, pos.x / REGION_TILE_SIZE, pos.y / REGION_TILE_SIZE)
	local richness = cfg.richness * settings.startup["rso-global-richness-mult"].value
		* max(dist, 0.1) ^ settings.startup["rso-distance-exponent"].value * C.depletion_vein_richness
	local size = rng(C.depletion_vein_size[1], C.depletion_vein_size[2])
	local box = spawn_vein(surface, name, pos, size, richness, cfg.min_amount or C.min_amount, rng)
	if not box then return end

	count("depletion_veins")
	local chunk = {floor(pos.x / CHUNK_SIZE), floor(pos.y / CHUNK_SIZE)}
	local gps = string.format("[gps=%d,%d,%s]", floor(pos.x), floor(pos.y), surface.name)
	for _, force in pairs(game.forces) do
		if #force.players > 0 and force.is_chunk_charted(surface, chunk) then
			force.chart(surface, {{box[1], box[2]}, {box[3], box[4]}})
			force.print({"rso-message.new-vein", "[img=entity/" .. name .. "]", gps})
		end
	end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
	storage.surfaces[event.surface_index] = nil
	if storage.forecasts then storage.forecasts[event.surface_index] = nil end
	if storage.sites then storage.sites[event.surface_index] = nil end
	if storage.cells then storage.cells[event.surface_index] = nil end
	if storage.blocks then storage.blocks[event.surface_index] = nil end
end)

script.on_event(defines.events.on_surface_cleared, function(event)
	if storage.surfaces[event.surface_index] then
		storage.surfaces[event.surface_index].regions = {}
	end
	clear_forecasts(event.surface_index)
	if storage.sites then storage.sites[event.surface_index] = nil end
	if storage.cells then storage.cells[event.surface_index] = nil end
	if storage.blocks then storage.blocks[event.surface_index] = nil end
end)

--[[ COMMANDS ]]--

-- the commands rewrite the whole map: admins (or the server console) only
local function allowed(command)
	local player = command.player_index and game.get_player(command.player_index)
	if player and not player.admin then
		player.print("RSO: only admins can use /" .. command.name)
		return false
	end
	return true
end

local function skipEnemiesParameter(parameters)
	return parameters ~= nil and parameters.parameter == "noenemies"
end

local function regenerateCommand(parameters)
	if parameters and not allowed(parameters) then return end
	regenerate_everything(false, skipEnemiesParameter(parameters))
end

local function clearCommand(parameters)
	if parameters and not allowed(parameters) then return end
	regenerate_everything(true, skipEnemiesParameter(parameters))
end

local function regenerateSurfaceCommand(parameters)
	if not allowed(parameters) then return end
	local player = parameters.player_index and game.get_player(parameters.player_index)
	if not player then
		log("RSO: surface regenerate command used without player")
		return
	end
	if not planet_info(player.surface) then
		player.print("RSO does not generate resources on surface " .. player.surface.name)
		return
	end
	regenerateSurface(player.surface, false)
	player.print("Surface " .. player.surface.name .. " regenerated")
end

commands.add_command("rso-regenerate", "", regenerateCommand)
commands.add_command("rso-clear", "", clearCommand)
commands.add_command("rso-regenerate-surface", "", regenerateSurfaceCommand)

--[[ REMOTE INTERFACE ]]--

remote.add_interface("RSO", {
	-- remote.call("RSO", "regenerate")
	regenerate = function()
		regenerateCommand(nil)
	end,

	clear = function()
		clearCommand(nil)
	end,

	-- remote.call("RSO", "ignoreSurface", "name-of-surface"): no enemy bases, forecasts and field
	-- extras there (resources follow the map generator settings of the surface)
	ignoreSurface = function(surfaceName)
		if type(surfaceName) ~= "string" then
			log("RSO ignoreSurface interface: surfaceName should be a string")
			return
		end
		storage.ignoreSurfaceNames = storage.ignoreSurfaceNames or {}
		storage.ignoreSurfaceNames[surfaceName] = true
	end,

	regenConfig = function()
		for index in pairs(storage.surfaces) do
			local surface = game.surfaces[index]
			if surface then
				loadAndPrepareConfig(surface)
			end
		end
	end,

	disableChunkHandler = function()
		if not storage.disableEventHandler then
			script.on_event(defines.events.on_chunk_generated, nil)
		end
		storage.disableEventHandler = true
	end,

	generateChunk = function(event)
		localGenerateChunk(event)
	end,

	-- forgets the enemy regions of the surface (they are rolled again for new chunks)
	resetGeneration = function(surface)
		if surface == nil then
			return
		end
		updateSurfaceConfig(surface)
		storage.surfaces[surface.index].regions = {}
	end,

	isInStartingArea = function(surfaceIndex, tileX, tileY)
		return isInStartingArea(surfaceIndex, tileX, tileY)
	end,

	-- Geological survey (Ore Radar): marks for the force on its map the nearest field the force has
	-- not charted yet. Returns the marked position or nil.
	-- remote.call("RSO", "forecast", surface_index, force_index, {x = 0, y = 0})
	forecast = forecast,

	-- counters of the Reforged mechanics: veins, guards, mines, depletion_veins, forecasts
	stats = function()
		return storage.stats or {}
	end,

	-- per force: {[force index] = {veins = rich veins found (charted), guards = guard sites cleared}}
	force_stats = function()
		return storage.forceStats or {}
	end,
})
