--[[ RSO Reforged (Resource Spawner Overhaul, Paranoidal fork) — control stage.

Resources and enemy bases are placed by the map generator from the noise expressions of
prototypes/noise.lua. This file reads the same expressions (LuaSurface.calculate_tile_properties)
to know the field sites and adds what the map generator cannot:

* when the chunk holding the centre of a field is generated: an old mine ruin
  (AbandonedRuins-paranoidal) by a rich far field, the sites of rich veins and guard bases for
  the achievement counters;
* geological survey forecasts (Ore Radar) with the grade of the field;
* new veins under depleted ore, charting of new fields, regeneration commands.
]]--

local util = require("util")
local C = require("config")
local loadResourceConfig = require("resourceconfigs.mainconfig")

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
local GUARD_RADIUS = C.enemy_radius_max + 8 -- around the centre of a guarded field

-- planets with RSO expressions: {prefix, region, resources = {index -> name}, enemies = {names}}
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

-- Flat key of an integer position (|x|, |y| < 2^21).
local function tile_key(x, y)
	return (x + 2097152) * 4194304 + (y + 2097152)
end

local function chunk_key(x, y)
	return tile_key(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
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

local CONFIG_ENV = {
	has = function(name)
		local prototype = prototypes.entity[name]
		return prototype ~= nil and prototype.autoplace_specification ~= nil
	end,
	mods = script.active_mods,
	setting = function(name) return settings.startup[name].value end,
}

local function isIgnoredSurface(surface)
	return storage.ignoreSurfaceNames and storage.ignoreSurfaceNames[surface.name]
end

local function planet_info(surface)
	local planet = surface.planet
	return planet and not isIgnoredSurface(surface) and PLANETS[planet.name] or nil
end

-- size of a cell of the field grid on the surface (the "RSO fields" frequency of its map settings)
local function cell_size(surface, info)
	local surfaceData = storage.surfaces[surface.index]
	if not surfaceData.cell then
		local name = info.prefix .. "G"
		surfaceData.cell = surface.calculate_tile_properties({name}, {{0, 0}})[name][1]
	end
	return surfaceData.cell
end

--[[ FIELD SITES ]]--

-- Sites of the noise generator, cached per cell: storage.cells[surface index][cell key] =
-- {x, y, name, liquid, radius, estimate, grade, vein, core, guard, partner};
-- storage.blocks[surface index][block key] = true once a block is read. The values are those of
-- the expressions, the same on every peer.
local SITE_PROPERTIES = {"kind", "valid", "liq", "rad", "estimate", "grade", "veinon", "coretiles", "multi", "partner",
	"e_guard", "form"}

local function query_cells(surface, info, G, wanted)
	local p = info.prefix
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
	local props = {}
	for i, name in ipairs(SITE_PROPERTIES) do props[i] = p .. name end
	local d = surface.calculate_tile_properties(props, centres)
	local function v(name, i)
		local values = d[p .. name]
		return values and values[i] or 0
	end
	for i, c in ipairs(on) do
		local name = info.resources[floor(v("kind", i) + 0.5)]
		if v("valid", i) > 0 and name then
			local ore = v("liq", i) == 0
			cells[tile_key(c[1], c[2])] = {
				x = centres[i][1], y = centres[i][2], name = name, liquid = not ore, radius = v("rad", i),
				estimate = v("estimate", i), grade = v("grade", i), vein = ore and v("veinon", i) > 0,
				core = ore and v("coretiles", i) >= C.infinite_core_tiles, guard = v("e_guard", i) > 0,
				partner = v("multi", i) > 0 and info.resources[floor(v("partner", i) + 0.5)] or nil,
				form = info.forms and info.forms[floor(v("form", i) + 0.5)] or nil,
			}
		end
	end
end

local function block_of(c)
	return floor((c + BLOCK / 2) / BLOCK)
end

-- sites of the cells ci1..ci2 x cj1..cj2 (read by blocks)
local function sites_in(surface, info, G, ci1, cj1, ci2, cj2)
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
				query_cells(surface, info, G, wanted)
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

-- Sites of rich veins and guard bases, for the per-force counters read by achievements (remote
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

-- the chunk holding the centre of a field is generated: counters of a rich vein and of a guard
-- base, a mine ruin by a rich far field. A regeneration (command) adds nothing again.
local function field_extras(surface, surfaceData, site)
	if storage.regenerating then return end
	if site.vein then
		count("veins")
		add_site(surface, "vein", site.x, site.y)
	end
	if site.guard then
		count("guards")
		add_site(surface, "guard", site.x, site.y)
	end
	if not (site.vein or site.core) then return end

	local mineChance = setting("rso-mine-ruin-chance")
	local iface = remote.interfaces[RUINS]
	local dist = distanceFromStartingAreas(surfaceData, site.x / REGION_TILE_SIZE, site.y / REGION_TILE_SIZE)
	if mineChance <= 0 or not (iface and iface.spawn_mine) or dist < C.mine_min_distance then return end
	local rng = rng_for_reg_pos(surface.index, {x = site.x, y = site.y})
	if rng() >= mineChance then return end
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
	if DEBUG then debug("Mine ruin " .. size .. " by the field at " .. site.x .. "," .. site.y) end
	if remote.call(RUINS, "spawn_mine", surface.index, {x = x, y = y}, size) then count("mines") end
end

local function generate_chunk(surface, c_x, c_y)
	local surfaceData = storage.surfaces[surface.index]
	local info = surfaceData and planet_info(surface)
	if not info then return end
	local G = cell_size(surface, info)
	for _, site in ipairs(sites_in(surface, info, G, floor(c_x / G), floor(c_y / G),
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
	for _, name in ipairs(info.resources) do
		names[#names + 1] = name
		if prototypes.entity["infinite-" .. name] then names[#names + 1] = "infinite-" .. name end
	end
	return names
end

-- clears RSO resources and enemy bases (not with noEnemies) outside the starting areas; the map
-- generator places them again unless clearOnly
local function regenerateSurface(surface, clearOnly, noEnemies)
	local surfaceData = storage.surfaces[surface.index]
	local info = surfaceData and planet_info(surface)
	if not info then return end
	local resources = resource_names(info)
	local enemies = noEnemies and {} or info.enemies
	local names = {}
	for _, name in ipairs(resources) do names[#names + 1] = name end
	for _, name in ipairs(enemies) do names[#names + 1] = name end
	local chunks = {}
	for chunk in surface.get_chunks() do
		local x, y = chunk.x * CHUNK_SIZE, chunk.y * CHUNK_SIZE
		if not isInStartingArea(surface.index, x, y) then
			chunks[#chunks + 1] = {chunk.x, chunk.y}
			local area = {{x, y}, {x + CHUNK_SIZE, y + CHUNK_SIZE}}
			for _, entity in pairs(surface.find_entities_filtered{area = area, name = names}) do entity.destroy() end
			if #enemies > 0 then
				for _, entity in pairs(surface.find_entities_filtered{area = area, type = "unit", force = "enemy"}) do entity.destroy() end
			end
		end
	end
	if not clearOnly and #chunks > 0 then
		surface.regenerate_entity(names, chunks)
		storage.regenerating = true
		for _, chunk in ipairs(chunks) do
			generate_chunk(surface, chunk[1] * CHUNK_SIZE, chunk[2] * CHUNK_SIZE)
		end
		storage.regenerating = nil
	end
	log(clearOnly and "RSO: clear done on " .. surface.name or "RSO: regeneration done on " .. surface.name)
end

local function regenerate_everything(clearOnly, noEnemies)
	for index in pairs(storage.surfaces) do
		local surface = game.surfaces[index]
		if surface then
			regenerateSurface(surface, clearOnly, noEnemies)
		end
	end
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

-- surface data: map seed, starting areas, resource configs (new veins), cached cell size
local function updateSurfaceConfig(surface)
	local old = storage.surfaces[surface.index] or {}
	local startingAreas = old.startingAreas
	if not startingAreas then
		startingAreas = {}
		for _, startingPoint in pairs(surface.map_gen_settings.starting_points or {}) do
			table.insert(startingAreas, {x = startingPoint.x, y = startingPoint.y})
		end
	end
	local planet = surface.planet
	storage.surfaces[surface.index] = {
		seed = surface.map_gen_settings.seed,
		startingAreas = startingAreas,
		starting_area_size = C.starting_area_size * (surface.map_gen_settings.starting_area or 1),
		config = planet and loadResourceConfig(CONFIG_ENV)[planet.name] or {},
	}
end

local function updateConfig()
	storage.surfaces = storage.surfaces or {}
	for _, surface in pairs(game.surfaces) do
		updateSurfaceConfig(surface)
	end
	for index in pairs(storage.surfaces) do
		if not game.get_surface(index) then storage.surfaces[index] = nil end
	end
	-- data of older versions (scripted resources and enemy bases)
	storage.regions, storage.useBobEntity, storage.mapSeedOverride, storage.disableStartingArea = nil, nil, nil, nil
	storage.skipEnemies = nil
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

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if not storage.surfaces[player.surface.index] then
		updateSurfaceConfig(player.surface)
	end
	checkForUnusedResources(player)
end)

script.on_event(defines.events.on_surface_created, function(event)
	updateSurfaceConfig(game.surfaces[event.surface_index])
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

-- grade of a field: name of the locale key and the label colour
local function grade_of(site)
	if site.grade < C.grade_poor then return "poor", {0.75, 0.75, 0.75} end
	if site.grade < C.grade_rich then return "normal", {1, 0.85, 0.4} end
	return "rich", {1, 0.55, 0.2}
end

-- "~350k, rich, crescent, a rich vein, guarded" as a localised string
local function description(site)
	local grade = grade_of(site)
	local text = {"", amount_text(site.estimate), ", ", {"rso-message.grade-" .. grade}}
	if site.form then
		text[#text + 1] = ", "
		text[#text + 1] = {"rso-message.form-" .. site.form}
	end
	for _, flag in ipairs({"vein", "core", "guard"}) do
		if site[flag] then
			text[#text + 1] = ", "
			text[#text + 1] = {"rso-message.flag-" .. flag}
		end
	end
	return text
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
	local G = cell_size(surface, info)
	local ci, cj = floor(position.x / G), floor(position.y / G)
	local best, bestD, bestKey = nil, nil, nil
	for _, site in ipairs(sites_in(surface, info, G, ci - FORECAST_CELLS, cj - FORECAST_CELLS, ci + FORECAST_CELLS, cj + FORECAST_CELLS)) do
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
	local _, colour = grade_of(best)
	local text = description(best)
	local label = rendering.draw_text{
		text = {"", icon, " ", text},
		surface = surface, target = {x, y}, color = colour, forces = {force},
		render_mode = "chart", scale = 1.5, scale_with_zoom = true, use_rich_text = true,
		alignment = "center", vertical_alignment = "middle",
	}
	marks[bestKey] = marks[bestKey] or {}
	marks[bestKey][force_index] = label
	count("forecasts")
	force.print({"rso-message.forecast", icon, string.format("[gps=%d,%d,%s]", x, y, surface.name), text})
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

-- the last nest of a guard base killed by a force clears the site for it
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	local sites = storage.sites and storage.sites[entity.surface.index]
	if not sites then return end
	local p = entity.position
	local cx, cy = floor(p.x / CHUNK_SIZE), floor(p.y / CHUNK_SIZE)
	local reach = ceil(GUARD_RADIUS / CHUNK_SIZE)
	for dx = -reach, reach do
		for dy = -reach, reach do
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
	surface.destroy_decoratives{area = {{box[1] - 2, box[2] - 2}, {box[3] + 3, box[4] + 3}}}
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
	regenerateSurface(player.surface, false, skipEnemiesParameter(parameters))
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

	-- remote.call("RSO", "ignoreSurface", "name-of-surface"): no forecasts and field extras there
	-- (resources and bases follow the map generator settings of the surface)
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
				updateSurfaceConfig(surface)
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

	-- forgets the cached sites of the surface (they are read again)
	resetGeneration = function(surface)
		if surface == nil then
			return
		end
		updateSurfaceConfig(surface)
		if storage.cells then storage.cells[surface.index] = nil end
		if storage.blocks then storage.blocks[surface.index] = nil end
	end,

	isInStartingArea = function(surfaceIndex, tileX, tileY)
		return isInStartingArea(surfaceIndex, tileX, tileY)
	end,

	-- Geological survey (Ore Radar): marks for the force on its map the nearest field the force has
	-- not charted yet, with its grade. Returns the marked position or nil.
	-- remote.call("RSO", "forecast", surface_index, force_index, {x = 0, y = 0})
	forecast = forecast,

	-- counters of the Reforged mechanics: veins, guards, mines, depletion_veins, forecasts
	stats = function()
		return storage.stats or {}
	end,

	-- per force: {[force index] = {veins = rich veins found (charted), guards = guard bases cleared}}
	force_stats = function()
		return storage.forceStats or {}
	end,
})
