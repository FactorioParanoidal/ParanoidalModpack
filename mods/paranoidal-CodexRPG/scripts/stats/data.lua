-- Base statistics for the RPG window ("base journal").
--
-- Nothing here polls the game every tick. There are three kinds of work:
-- 1. Counters bumped from events: deaths, kills, research, rockets, hand crafting, building of a few
--    milestone entity types (filtered events) and player movement (the engine raises it only when a
--    player steps onto another tile).
-- 2. A snapshot of the whole base, built only when a player opens a statistics page and the last
--    snapshot is older than a minute. The snapshot job spends a fixed number of engine calls per tick
--    (BUDGET), usually finishes within a second and then unregisters on_tick.
-- 3. Once per save, when this version is installed: milestones reached earlier are found in the
--    engine statistics and their time is estimated from the statistics history.
--
-- Everything the window shows lives in storage, so multiplayer clients stay in sync.
local fmt = require("scripts.stats.fmt")

local M = {}

local BUDGET = 1000            -- engine calls per tick while a snapshot job runs
M.FRESH = 60 * 60              -- a snapshot younger than this (ticks) is shown as is
local PLANET = "nauvis"        -- map statistics (chunks, power, pollution) are for this surface
local VERSION = 3              -- storage layout

---------------------------------------------------------------------------------------------
-- Prototype caches. Pure functions of the prototypes, identical on every client.

local P = {}

-- Helper entities of other mods that a player never sees: hidden or not selectable (power interfaces
-- of production modes, the line losses of Electric Resistance and the like).
local function visible_entity(name)
	local t = P.visible
	if not t then t = {} P.visible = t end
	local v = t[name]
	if v == nil then
		local proto = prototypes.entity[name]
		v = proto ~= nil and not proto.hidden and proto.selectable_in_game
		t[name] = v
	end
	return v
end

local function etype(name)
	local t = P.etype
	if not t then t = {} P.etype = t end
	local v = t[name]
	if v == nil then
		local proto = prototypes.entity[name]
		v = proto and proto.type or false
		t[name] = v
	end
	return v
end
M.etype = etype

-- Labs that only take module parts (Bob's module lab): the processors and cases are also spent in
-- module recipes, so they would inflate "science per minute". They are not counted as science.
local MODULE_LABS = {["lab-module"] = true}

-- Science packs: everything the research labs accept.
local function lab_inputs()
	if P.lab_inputs then return P.lab_inputs end
	local set, list = {}, {}
	for lab_name, lab in pairs(prototypes.get_entity_filtered({{filter = "type", type = "lab"}})) do
		for _, name in pairs(MODULE_LABS[lab_name] and {} or lab.lab_inputs or {}) do
			if not set[name] and prototypes.item[name] then set[name] = true list[#list + 1] = name end
		end
	end
	table.sort(list)
	P.lab_inputs = list
	return list
end

local function packset()
	if P.packset then return P.packset end
	local set = {}
	for _, name in ipairs(lab_inputs()) do set[name] = true end
	P.packset = set
	return set
end

-- Census order: the five defect grades from the mildest, then positive tiers upwards.
-- Display order: from the best tier down to the worst defect.
local function qualities()
	if P.qorder then return P.qorder, P.qdisplay, P.qdefect end
	local defects, positive = {}, {}
	local qdefect = {}
	for name, q in pairs(prototypes.quality) do
		local grade = name:match("^ic%-defect%-(%d)$")
		if grade then
			defects[#defects + 1] = {name = name, grade = tonumber(grade)}
			qdefect[name] = true
		elseif name ~= "normal" and not q.hidden then
			positive[#positive + 1] = {name = name, level = q.level}
		end
	end
	table.sort(defects, function(a, b) return a.grade < b.grade end)
	table.sort(positive, function(a, b)
		if a.level ~= b.level then return a.level < b.level end
		return a.name < b.name
	end)
	local order, display, early = {}, {}, {"normal"}
	for _, d in ipairs(defects) do order[#order + 1] = d.name early[#early + 1] = d.name end
	for _, q in ipairs(positive) do order[#order + 1] = q.name end
	for i = #positive, 1, -1 do display[#display + 1] = positive[i].name end
	display[#display + 1] = "normal"
	for _, d in ipairs(defects) do display[#display + 1] = d.name end
	P.qorder, P.qdisplay, P.qdefect, P.qearly = order, display, qdefect, early
	P.qpositive = {}
	for _, q in ipairs(positive) do P.qpositive[q.name] = true end
	return order, display, qdefect
end

-- Qualities the first buildings and packs of a game come in: normal and the defects.
local function early_qualities()
	qualities()
	return P.qearly
end

local function sorted_names(proto_table, keep)
	local list = {}
	for name, proto in pairs(proto_table) do
		if keep(proto) then list[#list + 1] = name end
	end
	table.sort(list)
	return list
end

local function tech_names()
	P.techs = P.techs or sorted_names(prototypes.technology, function(t) return not t.hidden end)
	return P.techs
end

-- Science pack names of every technology (from the prototype; research cost multipliers do not
-- change the kinds of packs).
local function tech_packs(name)
	local t = P.tech_packs
	if not t then t = {} P.tech_packs = t end
	local v = t[name]
	if not v then
		v = {}
		local proto = prototypes.technology[name]
		for _, ing in pairs(proto and proto.research_unit_ingredients or {}) do v[#v + 1] = ing.name end
		t[name] = v
	end
	return v
end

local function recipe_names()
	P.recipes = P.recipes or sorted_names(prototypes.recipe, function(r)
		return not r.hidden and not r.is_parameter
	end)
	return P.recipes
end

-- Items and fluids that come out of resource entities (ores, stone, coal, crude oil...).
local function resource_products()
	if P.resources then return P.resources end
	local set = {}
	for _, res in pairs(prototypes.get_entity_filtered({{filter = "type", type = "resource"}})) do
		local mp = res.mineable_properties
		for _, product in pairs(mp and mp.products or {}) do
			if product.name then set[product.name] = product.type or "item" end
		end
	end
	P.resources = set
	return set
end

local function ammo_items()
	if P.ammo then return P.ammo end
	local set = {}
	for name in pairs(prototypes.get_item_filtered({{filter = "type", type = "ammo"}})) do set[name] = true end
	P.ammo = set
	return set
end

-- ic-more-qualities: items that can be defective (finished and not exempt).
local function defectable()
	if P.defectable then return P.defectable end
	local set = {}
	local md = prototypes.mod_data["ic-defects-classification"]
	if md and md.data then
		local no = md.data.no_defect or {}
		for name in pairs(md.data.finished or {}) do
			if not no[name] then set[name] = true end
		end
	end
	P.defectable = set
	return set
end

---------------------------------------------------------------------------------------------
-- Forces and storage

local function is_sandbox(name)
	return name:sub(1, 8) == "bpsb-sb-"
end

-- Forces of players: the "player" force and any force that has players.
function M.player_force(force)
	if not (force and force.valid) then return false end
	if is_sandbox(force.name) then return false end
	return force.name == "player" or #force.players > 0
end

local function planet()
	return game.surfaces[PLANET]
end

-- Surfaces whose production counts for the base (Blueprint Sandboxes labs are left out).
local function base_surfaces()
	local list = {}
	for _, surface in pairs(game.surfaces) do
		if surface.name:sub(1, 9) ~= "bpsb-lab-" then list[#list + 1] = surface.index end
	end
	table.sort(list)
	return list
end

---------------------------------------------------------------------------------------------
-- Statistics history

-- Precisions of the engine statistics: 300 samples over the span (ticks).
local SPANS = {
	{"five_seconds", 300}, {"one_minute", 3600}, {"ten_minutes", 36000}, {"one_hour", 216000},
	{"ten_hours", 2160000}, {"fifty_hours", 10800000}, {"two_hundred_fifty_hours", 54000000},
	{"one_thousand_hours", 216000000},
}

-- The finest precision that still covers the whole game, and the width of one sample in ticks.
local function precision_for(age)
	for _, p in ipairs(SPANS) do
		if p[2] >= age then return defines.flow_precision_index[p[1]], p[2] / 300 end
	end
	local last = SPANS[#SPANS]
	return defines.flow_precision_index[last[1]], last[2] / 300
end

-- probes: list of {LuaFlowStatistics, FlowStatisticsID}. Returns the estimated tick of the first
-- sample (oldest first) where any probe counted something, and the sample width; nil if none.
-- Sample i covers the ticks (now - i*w, now - (i-1)*w] (checked in the engine).
-- from_tick: the thing is known to have happened after it, so a finer precision is enough.
local function first_seen(probes, category, from_tick)
	if #probes == 0 then return nil end
	local now = game.tick
	local prec, w = precision_for(now - (from_tick or 0))
	for i = math.min(300, math.ceil(now / w)), 1, -1 do
		for _, pr in ipairs(probes) do
			if pr[1].get_flow_count({name = pr[2], category = category, precision_index = prec,
				sample_index = i, count = true}) > 0 then
				return math.max(0, math.floor(now - (i - 0.5) * w)), w
			end
		end
	end
	return nil
end

---------------------------------------------------------------------------------------------
-- Milestones

-- Built entity types that mark a milestone the first time a force builds one.
local BUILD_MILESTONES = {
	["mining-drill"] = "drill",
	["lab"] = "lab",
	["generator"] = "generator",
	["burner-generator"] = "generator",
	["ammo-turret"] = "turret",
	["radar"] = "radar",
	["car"] = "car",
	["solar-panel"] = "solar",
	["locomotive"] = "locomotive",
	["train-stop"] = "station",
	["electric-turret"] = "laser",
	["roboport"] = "roboport",
	["beacon"] = "beacon",
	["reactor"] = "reactor",
	["artillery-turret"] = "artillery",
	["rocket-silo"] = "silo",
}
M.BUILD_MILESTONES = BUILD_MILESTONES

-- Paranoidal buildings that mark a milestone by name. Their types are added to the event filters;
-- other entities of these types cost the handler one table lookup.
local NAME_MILESTONES = {
	["ic-refine-workshop"] = "workshop",
	["ic-control-post"] = "post",
	["recycler"] = "recycler", ["recycler-1"] = "recycler", ["recycler-2"] = "recycler", ["recycler-3"] = "recycler",
	["factory-1"] = "factory", ["factory-2"] = "factory", ["factory-3"] = "factory", ["factory-4"] = "factory",
	["space-factory-1"] = "factory", ["space-factory-2"] = "factory", ["space-factory-3"] = "factory",
	["spidertron"] = "spider",
}
local NAME_TYPES = {"furnace", "container", "storage-tank", "spider-vehicle"}

-- Things made for the first time. Checked every 10 minutes and when the statistics are counted; the
-- time comes from the statistics graphs, to a couple of seconds.
local PRODUCE = {
	{id = "crushed", items_match = "^angels%-ore%d+%-crushed$", icon = "[item=angels-ore1-crushed]"},
	{id = "basic-board", items = {"bob-basic-circuit-board"}},
	{id = "steel", items = {"steel-plate"}},
	{id = "molten", fluids_match = "^angels%-liquid%-molten%-", icon = "[fluid=angels-liquid-molten-iron]"},
	{id = "green-circuit", items = {"electronic-circuit"}},
	{id = "oil", fluids = {"crude-oil"}},
	{id = "plastic", items = {"plastic-bar"}},
	{id = "sulfuric", fluids = {"sulfuric-acid"}},
	{id = "aluminium", items = {"bob-aluminium-plate"}},
	{id = "battery", items = {"battery"}},
	{id = "red-circuit", items = {"advanced-circuit"}},
	{id = "titanium", items = {"bob-titanium-plate"}},
	{id = "silicon", items = {"bob-silicon-wafer"}},
	{id = "quality-module", items = {"quality-module"}},
	{id = "blue-circuit", items = {"processing-unit"}},
	{id = "uranium", items = {"uranium-235"}},
}

-- Quality tiers with a milestone of their own ("q:<name>"), found when the statistics are counted.
local QUALITY_MS = {"uncommon", "rare", "epic", "legendary", "legendary-t5", "extreme"}
local QUALITY_ID = {}
for _, q in ipairs(QUALITY_MS) do QUALITY_ID[q] = "q:" .. q end
local QUALITY_CANDIDATES = 12 -- items probed in the graphs for the time of a quality milestone

local RUIN_MS = {ruin = true, legend = true, ["legend-won"] = true}

-- Fixed milestones in their usual order of appearance. Science pack milestones ("pack:<item>")
-- come on top of these.
M.MILESTONE_ORDER = {"drill", "generator", "crushed", "lab", "turret", "basic-board", "workshop", "death", "radar",
	"steel", "ruin", "nest", "worm", "molten", "post", "green-circuit", "quality10", "car", "oil", "plastic", "sulfuric",
	"recycler", "solar", "aluminium", "locomotive", "station", "battery", "laser", "red-circuit", "factory",
	"roboport", "titanium", "silicon", "quality-module", "q:uncommon", "q:rare", "beacon", "q:epic", "blue-circuit",
	"legend", "uranium", "reactor", "legend-won", "q:legendary", "artillery", "spider", "silo", "rocket",
	"q:legendary-t5", "q:extreme"}

-- PRODUCE with the names that exist in this game, and the icon of each of these milestones.
local function produce_defs()
	if P.produce then return P.produce end
	local list, icons = {}, {}
	for _, def in ipairs(PRODUCE) do
		local names, fluid = {}, (def.fluids or def.fluids_match) and true or false
		local protos = fluid and prototypes.fluid or prototypes.item
		local pattern = def.items_match or def.fluids_match
		if pattern then
			for name, proto in pairs(protos) do
				if name:match(pattern) and not proto.hidden then names[#names + 1] = name end
			end
			table.sort(names)
		else
			for _, name in ipairs(def.items or def.fluids) do
				if protos[name] then names[#names + 1] = name end
			end
		end
		if #names > 0 then
			list[#list + 1] = {id = def.id, names = names, fluid = fluid}
			icons[def.id] = def.icon or ((fluid and "[fluid=" or "[item=") .. names[1] .. "]")
		end
	end
	P.produce, P.produce_icons = list, icons
	return list
end

-- Rich text icon of a milestone, if it has one of its own.
function M.milestone_icon(id)
	produce_defs()
	return P.produce_icons[id]
end

-- Whether a milestone can happen in this game (its items, buildings, research and mods exist).
function M.milestone_available(id)
	local q = id:match("^q:(.+)$")
	if q then return prototypes.quality[q] ~= nil end
	if id:match("^pack:") then return true end
	if id == "quality10" then return prototypes.technology["ic-defect-control-10"] ~= nil end
	if RUIN_MS[id] then
		local iface = remote.interfaces["AbandonedRuins-paranoidal"]
		return iface ~= nil and iface.get_force_summary ~= nil
	end
	produce_defs()
	for _, def in ipairs(PRODUCE) do
		if def.id == id then return P.produce_icons[id] ~= nil end
	end
	local named = false
	for name, mid in pairs(NAME_MILESTONES) do
		if mid == id then
			named = true
			if prototypes.entity[name] then return true end
		end
	end
	return not named
end

-- Base status: the highest step whose condition is met. Step 1 needs nothing.
M.STATUS = {
	{},
	{packs = {"logistic-science-pack"}},
	{packs = {"chemical-science-pack"}},
	{packs = {"production-science-pack", "utility-science-pack"}},
	{rocket = true},
	{packs = {"space-science-pack"}},
}
-- Science packs worth a line in the "still ahead" list.
M.KEY_PACKS = {"automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack",
	"production-science-pack", "utility-science-pack", "space-science-pack"}

function M.build_filters()
	local list = {}
	local types = {}
	for t in pairs(BUILD_MILESTONES) do types[t] = true end
	for _, t in ipairs(NAME_TYPES) do types[t] = true end
	for t in pairs(types) do list[#list + 1] = {filter = "type", type = t} end
	table.sort(list, function(a, b) return a.type < b.type end)
	return list
end

-- Only reactors that burn nuclear fuel make the "reactor" milestone (Bob's burner reactors do not).
local function nuclear(proto)
	local burner = proto and proto.burner_prototype
	return burner and burner.fuel_categories and burner.fuel_categories["nuclear"] and true or false
end

local function milestone_of(proto)
	local id = proto and (NAME_MILESTONES[proto.name] or BUILD_MILESTONES[proto.type])
	if id == "reactor" and not nuclear(proto) then return nil end
	return id
end

local announce -- set by the window module: function(force, id, record)
function M.set_announcer(fn) announce = fn end

local function force_record(s, index)
	local f = s.forces[index]
	if not f then
		f = {milestones = {}, kills_by = {}}
		s.forces[index] = f
	end
	return f
end

local function mark(f, id, record)
	if f.milestones[id] then return false end
	f.milestones[id] = record
	return true
end

-- Marks the milestones this force reached before they were tracked (old saves).
local function backfill_force(s, force)
	local f = force_record(s, force.index)
	for _, si in ipairs(base_surfaces()) do
		for name, count in pairs(force.get_entity_build_count_statistics(si).input_counts) do
			local id = count > 0 and etype(name) and milestone_of(prototypes.entity[name])
			if id then mark(f, id, {before = true, entity = name}) end
		end
		for name, count in pairs(force.get_kill_count_statistics(si).input_counts) do
			if count > 0 then
				local t = etype(name)
				if t == "unit-spawner" then mark(f, "nest", {before = true})
				elseif t == "turret" then mark(f, "worm", {before = true}) end
			end
		end
	end
	for name, tech in pairs(force.technologies) do
		if tech.researched then
			for _, ing in pairs(tech.research_unit_ingredients) do
				mark(f, "pack:" .. ing.name, {before = true})
			end
			if name == "ic-defect-control-10" then mark(f, "quality10", {before = true}) end
		end
	end
	if force.rockets_launched > 0 then mark(f, "rocket", {before = true}) end
	local deaths = storage.personalxp and storage.personalxp.Death or {}
	for _, player in pairs(force.players) do
		if (deaths[player.name] or 0) > 0 then mark(f, "death", {before = true}) break end
	end
end

-- Estimated time of a milestone reached before it was tracked: when the engine statistics first
-- counted the thing behind it. Sets rec.est (tick) and rec.res (sample width), or rec.upto (it
-- happened no later than this tick) when the history does not tell.
local function estimate(s, force, id, rec)
	local probes = {}
	local pack = id:match("^pack:(.+)$")
	-- packs: the first ones consumed by labs; deaths: characters lost; the rest: built or killed
	local category = (pack or id == "death") and "output" or "input"
	for _, si in ipairs(base_surfaces()) do
		if pack then
			local st = force.get_item_production_statistics(si)
			if (st.output_counts[pack] or 0) > 0 then
				for _, q in ipairs(early_qualities()) do probes[#probes + 1] = {st, {name = pack, quality = q}} end
			end
		elseif rec.entity then
			local st = force.get_entity_build_count_statistics(si)
			if (st.input_counts[rec.entity] or 0) > 0 then
				for _, q in ipairs(early_qualities()) do probes[#probes + 1] = {st, {name = rec.entity, quality = q}} end
			end
		elseif id == "death" then
			local st = force.get_kill_count_statistics(si)
			if (st.output_counts["character"] or 0) > 0 then probes[#probes + 1] = {st, "character"} end
		elseif id == "nest" or id == "worm" then
			local want = id == "nest" and "unit-spawner" or "turret"
			local st = force.get_kill_count_statistics(si)
			for name, c in pairs(st.input_counts) do
				if c > 0 and etype(name) == want then probes[#probes + 1] = {st, name} end
			end
		elseif id == "quality10" then
			-- research time is not kept; green science needs this research, so the first green pack
			-- made is the latest it could have happened
			local st = force.get_item_production_statistics(si)
			if (st.input_counts["logistic-science-pack"] or 0) > 0 then
				for _, q in ipairs(early_qualities()) do
					probes[#probes + 1] = {st, {name = "logistic-science-pack", quality = q}}
				end
			end
		end
	end
	local t, w = first_seen(probes, category)
	if not t then
		rec.upto = s.since
	elseif id == "quality10" then
		rec.upto = t
	else
		rec.est, rec.res = t, w
	end
end

local function backfill_estimates(s, force)
	local f = force_record(s, force.index)
	local ids = {}
	for id, rec in pairs(f.milestones) do
		if rec.before and not rec.est and not rec.upto then ids[#ids + 1] = id end
	end
	table.sort(ids)
	for _, id in ipairs(ids) do estimate(s, force, id, f.milestones[id]) end
end

-- Bounding box and count of generated chunks on the planet, counted once for old saves.
local function backfill_world(s)
	local surface = planet()
	s.world = {generated = 0}
	if not surface then return end
	local w = s.world
	for chunk in surface.get_chunks() do
		if surface.is_chunk_generated(chunk) then
			w.generated = w.generated + 1
			local x, y = chunk.x, chunk.y
			if not w.x1 then w.x1, w.x2, w.y1, w.y2 = x, x, y, y
			else
				if x < w.x1 then w.x1 = x elseif x > w.x2 then w.x2 = x end
				if y < w.y1 then w.y1 = y elseif y > w.y2 then w.y2 = y end
			end
		end
	end
end

local function planet_index()
	local surface = planet()
	return surface and surface.index or 0
end

local poll_force -- first products and ruins, defined with the snapshot job: function(s, force, backfill)

-- Older storage layouts. Runs from on_configuration_changed and, because a save loaded with the same
-- mod version does not necessarily raise it, also lazily from the first event that needs storage.
local function migrate(s)
	if (s.version or 1) < 2 then
		-- 2: more milestone types, estimated times instead of "earlier", movement counters
		s.since_move = game.tick
		s.planet = planet_index()
		for _, force in pairs(game.forces) do
			if M.player_force(force) then
				backfill_force(s, force)
				backfill_estimates(s, force)
			end
		end
	end
	if (s.version or 1) < 3 then
		-- 3: Paranoidal milestones (buildings by name, first products, quality tiers, ruins)
		s.since3 = game.tick
		for _, force in pairs(game.forces) do
			if M.player_force(force) then
				backfill_force(s, force)
				backfill_estimates(s, force)
				poll_force(s, force, true)
			end
		end
	end
	s.version = VERSION
end

-- Storage root. Created lazily from events (never from on_load).
-- new_game: chunks that already exist at on_init still raise on_chunk_generated afterwards (seen in
-- the engine), so a new map is counted from events only; an old save is counted once here.
function M.root(new_game)
	local s = storage.rpg_stats
	if s then
		if s.version ~= VERSION then migrate(s) end
		return s
	end
	s = {version = VERSION, since = game.tick, since_move = game.tick, since3 = game.tick, forces = {},
		players = {}, world = {generated = 0}, depleted = 0, planet = planet_index()}
	storage.rpg_stats = s
	if not new_game then backfill_world(s) end
	for _, force in pairs(game.forces) do
		if M.player_force(force) then
			backfill_force(s, force)
			backfill_estimates(s, force)
			if not new_game then poll_force(s, force, true) end
		end
	end
	return s
end

-- A new map starts at tick 0; a save the mod is added to does not (its chunks raise no events).
function M.on_init()
	M.root(game.tick == 0)
end

function M.on_configuration_changed()
	M.root()
end

function M.force(force_index)
	return force_record(M.root(), force_index)
end

function M.player(player_index)
	local s = M.root()
	local p = s.players[player_index]
	if not p then
		p = {tab = "char", stats_tab = "passport", art = 1, zoom = 0.25, deaths_by = {}, crafted = 0,
			crafted_items = {}, trees = 0, rocks = 0}
		s.players[player_index] = p
	end
	if not p.walk then p.walk, p.drive, p.rail, p.far = 0, 0, 0, 0 end
	return p
end

function M.on_player_removed(player_index)
	local s = storage.rpg_stats
	if s then s.players[player_index] = nil end
end

local function reach(force, id, player, entity_name)
	local f = M.force(force.index)
	local record = {tick = game.tick, player = player and player.valid and player.name or nil, entity = entity_name}
	if mark(f, id, record) and announce then announce(force, id, record) end
end
M.reach = reach

-- Tick a milestone record stands for (exact, estimated or the upper bound), for sorting.
function M.record_tick(rec)
	return rec.tick or rec.est or rec.upto or 0
end

---------------------------------------------------------------------------------------------
-- Event counters

function M.on_built(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local id = NAME_MILESTONES[entity.name] or BUILD_MILESTONES[entity.type]
	if not id then return end
	local force = entity.force
	local f = storage.rpg_stats and storage.rpg_stats.forces[force.index]
	if f and f.milestones[id] then return end -- the usual case: one table lookup
	if not M.player_force(force) then return end
	if id == "reactor" and not nuclear(entity.prototype) then return end
	local player = event.player_index and game.get_player(event.player_index)
	reach(force, id, player, entity.name)
end

local KILL_CAUSE = {
	["ammo-turret"] = "ammo_turret",
	["electric-turret"] = "electric_turret",
	["fluid-turret"] = "fluid_turret",
	["artillery-turret"] = "artillery",
	["artillery-wagon"] = "artillery",
	["character"] = "character",
	["car"] = "vehicle",
	["spider-vehicle"] = "vehicle",
	["locomotive"] = "train",
	["cargo-wagon"] = "train",
	["fluid-wagon"] = "train",
	["combat-robot"] = "robot",
	["land-mine"] = "mine",
}
M.KILL_CAUSES = {"ammo_turret", "electric_turret", "fluid_turret", "artillery", "character",
	"vehicle", "robot", "mine", "train", "other", "none"}

local ENEMY_TYPES = {["unit"] = true, ["unit-spawner"] = true, ["turret"] = true}

-- From the existing on_entity_died handler (already filtered to these entity types).
function M.on_enemy_died(event)
	local entity, force = event.entity, event.force
	if not (force and entity and entity.valid and ENEMY_TYPES[entity.type]) then return end
	if not storage.rpg_stats or not M.player_force(force) then return end
	local victim = entity.force
	if victim == force or force.get_friend(victim) then return end
	local f = force_record(storage.rpg_stats, force.index)
	local cause = event.cause
	local cat = "none"
	if cause and cause.valid then cat = KILL_CAUSE[cause.type] or "other" end
	f.kills_by[cat] = (f.kills_by[cat] or 0) + 1
	local id = (entity.type == "unit-spawner" and "nest") or (entity.type == "turret" and "worm") or nil
	if id and not f.milestones[id] then
		local player = cause and cause.valid and cause.type == "character" and cause.player or nil
		reach(force, id, player)
	end
end

local TRAINS = {["locomotive"] = true, ["cargo-wagon"] = true, ["fluid-wagon"] = true, ["artillery-wagon"] = true}
M.DEATH_CAUSES = {"enemy", "train", "vehicle", "friendly", "other"}

function M.on_player_died(player, cause)
	if not (player and player.valid) then return end
	local p = M.player(player.index)
	local cat = "other"
	if cause and cause.valid then
		local t = cause.type
		if TRAINS[t] then cat = "train"
		elseif cause.force == player.force or player.force.get_friend(cause.force) then
			cat = (t == "car" or t == "spider-vehicle") and "vehicle" or "friendly"
		elseif t == "car" or t == "spider-vehicle" then cat = "vehicle"
		else cat = "enemy" end
	end
	p.deaths_by[cat] = (p.deaths_by[cat] or 0) + 1
	if M.player_force(player.force) then reach(player.force, "death", player) end
end

-- The player stepped onto another tile. Only the body counts (physical controller), so remote view
-- and the map do not add distance. Jumps of 8 tiles and more (teleports, respawn) are skipped.
function M.on_moved(event)
	local s = storage.rpg_stats
	if not s then return end
	if s.version ~= VERSION then s = M.root() end
	local player = game.get_player(event.player_index)
	if not (player and player.physical_controller_type == defines.controllers.character) then return end
	local p = s.players[player.index]
	if not (p and p.walk) then p = M.player(player.index) end
	local pos, si = player.physical_position, player.physical_surface_index
	local x, y = pos.x, pos.y
	if p.lx and p.ls == si then
		local dx, dy = x - p.lx, y - p.ly
		local d2 = dx * dx + dy * dy
		if d2 < 64 then
			local d = math.sqrt(d2)
			local vehicle = player.physical_vehicle
			if not vehicle then p.walk = p.walk + d
			elseif TRAINS[vehicle.type] then p.rail = p.rail + d
			else p.drive = p.drive + d end
		end
	end
	p.lx, p.ly, p.ls = x, y, si
	if si == s.planet then
		local spawn = player.force.get_spawn_position(si)
		local sx, sy = x - spawn.x, y - spawn.y
		local d2 = sx * sx + sy * sy
		if d2 > p.far * p.far then p.far = math.sqrt(d2) end
	end
end

function M.on_research_finished(event)
	if event.by_script then return end
	local tech = event.research
	local force = tech.force
	if not M.player_force(force) then return end
	local f = M.force(force.index)
	for _, ing in pairs(tech.research_unit_ingredients) do
		if not f.milestones["pack:" .. ing.name] then reach(force, "pack:" .. ing.name) end
	end
	if tech.name == "ic-defect-control-10" then reach(force, "quality10") end
end

function M.on_rocket_launched(force)
	if M.player_force(force) and not M.force(force.index).milestones.rocket then reach(force, "rocket") end
end

function M.on_crafted(event)
	local stack = event.item_stack
	if not (stack and stack.valid_for_read) then return end
	local p = M.player(event.player_index)
	local n = stack.count
	p.crafted = p.crafted + n
	p.crafted_items[stack.name] = (p.crafted_items[stack.name] or 0) + n
end

function M.on_nature_mined(player, entity_type)
	local p = M.player(player.index)
	if entity_type == "tree" then p.trees = p.trees + 1 else p.rocks = p.rocks + 1 end
end

function M.on_resource_depleted()
	local s = storage.rpg_stats
	if s then s.depleted = s.depleted + 1 end
end

function M.on_chunk_generated(event)
	local s = storage.rpg_stats
	if not s or event.surface.name ~= PLANET then return end
	local w = s.world
	local x, y = event.position.x, event.position.y
	w.generated = w.generated + 1
	if not w.x1 then w.x1, w.x2, w.y1, w.y2 = x, x, y, y
	else
		if x < w.x1 then w.x1 = x elseif x > w.x2 then w.x2 = x end
		if y < w.y1 then w.y1 = y elseif y > w.y2 then w.y2 = y end
	end
end

function M.on_surface_cleared(surface_index)
	local s = storage.rpg_stats
	local surface = game.surfaces[surface_index]
	if s and surface and surface.name == PLANET then s.world = {generated = 0} end
end

---------------------------------------------------------------------------------------------
-- Snapshot job

local on_done -- set by the window module: function(force_index)
function M.set_done_handler(fn) on_done = fn end

local tick_handler

local function add(t, k, v) t[k] = (t[k] or 0) + v end

local function top(map, n, keep)
	local list = {}
	for name, count in pairs(map) do
		if count > 0 and (not keep or keep(name)) then list[#list + 1] = {name, count} end
	end
	table.sort(list, function(a, b)
		if a[2] ~= b[2] then return a[2] > b[2] end
		return a[1] < b[1]
	end)
	for i = #list, n + 1, -1 do list[i] = nil end
	return list
end

local PHASES = {"flows", "census", "tech", "recipes", "sweep", "rates", "peak", "finish"}

local STEP = {}

-- One surface per tick: item, fluid, build and kill statistics.
function STEP.flows(job, force)
	local si = job.surfaces[job.i]
	if not si then return true end
	local a = job.acc
	if game.surfaces[si] then
		local ammo = ammo_items()
		local st = force.get_item_production_statistics(si)
		for name, c in pairs(st.input_counts) do
			if c > 0 then
				add(a.items_in, name, c)
				local n = #a.cq_n + 1
				a.cq_s[n], a.cq_n[n], a.cq_c[n] = si, name, c
			end
		end
		local packs = packset()
		for name, c in pairs(st.output_counts) do
			a.items_out = a.items_out + c
			if ammo[name] then a.ammo_used = a.ammo_used + c end
			if packs[name] and c > 0 then a.pack_out[#a.pack_out + 1] = {si, name} end
		end
		st = force.get_fluid_production_statistics(si)
		for name, c in pairs(st.input_counts) do a.fluids_made = a.fluids_made + c add(a.fluids_in, name, c) end
		for _, c in pairs(st.output_counts) do a.fluids_used = a.fluids_used + c end
		st = force.get_entity_build_count_statistics(si)
		for name, c in pairs(st.input_counts) do add(a.built, name, c) end
		for name, c in pairs(st.output_counts) do add(a.mined, name, c) end
		st = force.get_kill_count_statistics(si)
		for name, c in pairs(st.input_counts) do add(a.killed, name, c) end
		for name, c in pairs(st.output_counts) do add(a.lost, name, c) end
	end
	job.i = job.i + 1
	return job.i > #job.surfaces
end

-- Quality split of production. The total of an item is known; quality counts are read from the
-- mildest defect upwards and the item is done as soon as they add up to the total, so most
-- items cost one or two calls.
function STEP.census(job, force)
	local a = job.acc
	local order, _, qdefect = qualities()
	local can_defect = defectable()
	local packs = packset()
	local reached = M.force(force.index).milestones
	local ops, si_cached, st = 0, nil, nil
	while ops < BUDGET do
		local i = job.i
		local name = a.cq_n[i]
		if not name then return true end
		local si, total = a.cq_s[i], a.cq_c[i]
		if si ~= si_cached then st = force.get_item_production_statistics(si) si_cached = si ops = ops + 1 end
		local pq = packs[name] and (a.pack_q[name] or {}) or nil
		if pq then a.pack_q[name] = pq end
		local normal = st.get_input_count(name)
		ops = ops + 1
		add(a.q, "normal", normal)
		if pq and normal > 0 then pq.normal = true end
		local rest = total - normal
		local defects = 0
		if rest > 0 then
			for _, q in ipairs(order) do
				local c = st.get_input_count({name = name, quality = q})
				ops = ops + 1
				if c > 0 then
					add(a.q, q, c)
					if qdefect[q] then defects = defects + c end
					if pq then pq[q] = true end
					local qid = QUALITY_ID[q]
					if qid and not reached[qid] then
						local list = a.qms[q] or {}
						a.qms[q] = list
						if #list < QUALITY_CANDIDATES then list[#list + 1] = {si, name} end
					end
					rest = rest - c
					if rest <= 0 then break end
				end
			end
		end
		if can_defect[name] then
			a.defectable = a.defectable + total
			a.defects = a.defects + defects
		end
		job.i = i + 1
	end
	return false
end

-- Technologies: researched share, the most expensive one, and progress on the packs reached.
function STEP.tech(job, force)
	local names = tech_names()
	local techs = force.technologies
	local a = job.acc
	local reached = job.packs
	local ops = 0
	while ops < BUDGET do
		local name = names[job.i]
		if not name then return true end
		local t = techs[name]
		ops = ops + 3
		if t then
			local researched = t.researched
			if researched or t.enabled then
				a.tech_total = a.tech_total + 1
				local open = true
				for _, pack in ipairs(tech_packs(name)) do
					if not reached[pack] then open = false break end
				end
				if open then
					a.tier_total = a.tier_total + 1
					if researched then a.tier_done = a.tier_done + 1 end
				end
			end
			if researched then
				a.tech_done = a.tech_done + 1
				local cost = t.research_unit_count * #tech_packs(name)
				ops = ops + 1
				if cost > a.tech_top_cost then a.tech_top_cost, a.tech_top = cost, name end
			end
		end
		job.i = job.i + 1
	end
	return false
end

function STEP.recipes(job, force)
	local names = recipe_names()
	local recipes = force.recipes
	local a = job.acc
	local ops = 0
	while ops < BUDGET do
		local name = names[job.i]
		if not name then return true end
		local r = recipes[name]
		if r and r.enabled then a.recipes = a.recipes + 1 end
		ops = ops + 2
		job.i = job.i + 1
	end
	return false
end

local P5 -- flow precision for "now"
local function read_network(a, pole)
	local es = pole.electric_network_statistics
	P5 = P5 or defines.flow_precision_index.five_seconds
	local H1 = defines.flow_precision_index.one_hour
	local ops, produced, now_total, sources = 2, 0, 0, {}
	for name in pairs(es.output_counts) do
		local now = es.get_flow_count({name = name, category = "output", precision_index = P5})
		local hour = es.get_flow_count({name = name, category = "output", precision_index = H1})
		add(a.power_now, name, now)
		add(a.power_hour, name, hour)
		produced = produced + now + hour
		now_total = now_total + now
		sources[#sources + 1] = name
		ops = ops + 2
	end
	for name in pairs(es.input_counts) do
		add(a.power_use, name, es.get_flow_count({name = name, category = "input", precision_index = P5}))
		ops = ops + 1
	end
	if produced > 0 then
		a.networks = a.networks + 1
		a.nets[#a.nets + 1] = {pole = pole, now = now_total, sources = sources}
	end
	return ops
end

-- Planet chunks row by row: charted chunks, the farthest one, chunks with our poles, and electric
-- networks found through the poles of the same row.
function STEP.sweep(job, force)
	local surface = planet()
	local w = storage.rpg_stats.world
	if not (surface and w.x1) then return true end
	local a = job.acc
	if not job.y then
		job.y = w.y1
		local spawn = force.get_spawn_position(surface)
		job.sx, job.sy = math.floor(spawn.x / 32), math.floor(spawn.y / 32)
		job.seen = {}
	end
	local x1, x2 = w.x1, w.x2
	local ops = 0
	while ops < BUDGET do
		local y = job.y
		if y > w.y2 then return true end
		local dy2 = (y - job.sy) ^ 2
		local pos = {0, y}
		for x = x1, x2 do
			pos[1] = x
			if force.is_chunk_charted(surface, pos) then
				a.charted = a.charted + 1
				local d2 = (x - job.sx) ^ 2 + dy2
				if d2 > a.far2 then a.far2 = d2 end
			end
		end
		ops = ops + 2 * (x2 - x1 + 1)
		local poles = surface.find_entities_filtered({
			area = {{x1 * 32, y * 32}, {(x2 + 1) * 32, (y + 1) * 32}},
			type = "electric-pole", force = force})
		ops = ops + 1 + #poles
		local seen = job.seen
		local row = {}
		for _, pole in pairs(poles) do
			local pp = pole.position
			local cx = math.floor(pp.x / 32)
			if math.floor(pp.y / 32) == y and not row[cx] then row[cx] = true a.footprint = a.footprint + 1 end
			local id = pole.electric_network_id
			if id and not seen[id] then
				seen[id] = true
				ops = ops + read_network(a, pole)
			end
		end
		job.y = y + 1
	end
	return false
end

-- Per-minute rates: science packs consumed over the last hour, pollution now.
function STEP.rates(job, force)
	local a = job.acc
	if not job.rates_ready then
		job.rates_ready = true
		for _, entry in ipairs(a.pack_out) do
			for q in pairs(a.pack_q[entry[2]] or {normal = true}) do a.rq[#a.rq + 1] = {entry[1], entry[2], q} end
		end
		local surface = planet()
		if surface then
			for name in pairs(game.get_pollution_statistics(surface).input_counts) do
				a.rq[#a.rq + 1] = {0, name}
			end
		end
	end
	local H1, M1 = defines.flow_precision_index.one_hour, defines.flow_precision_index.one_minute
	local ops, si_cached, st = 0, nil, nil
	while ops < BUDGET do
		local q = a.rq[job.i]
		if not q then return true end
		local si = q[1]
		if si == 0 then
			if si_cached ~= 0 then st = game.get_pollution_statistics(planet()) si_cached = 0 end
			a.pollution_now = a.pollution_now + st.get_flow_count({name = q[2], category = "input", precision_index = M1})
		else
			if si ~= si_cached then st = force.get_item_production_statistics(si) si_cached = si end
			add(a.spm, q[2], st.get_flow_count({name = {name = q[2], quality = q[3]}, category = "output", precision_index = H1}))
		end
		ops = ops + 2
		job.i = job.i + 1
	end
	return false
end

-- Peak power over the last ten hours: the eight biggest networks, sample by sample.
function STEP.peak(job, force)
	local a = job.acc
	if not job.pk then
		table.sort(a.nets, function(x, y) return x.now > y.now end)
		job.pk = {}
		for i = 1, math.min(8, #a.nets) do job.pk[i] = a.nets[i] end
		job.n, job.k = 1, 1
	end
	local H10 = defines.flow_precision_index.ten_hours
	local ops = 0
	while ops < BUDGET do
		local net = job.pk[job.n]
		if not net then return true end
		local src = net.sources[job.k]
		if not (src and net.pole.valid) then
			job.n, job.k = job.n + 1, 1
		else
			local es = net.pole.electric_network_statistics
			local peak = a.peak
			for i = 1, 300 do
				peak[i] = (peak[i] or 0) + es.get_flow_count({name = src, category = "output", precision_index = H10, sample_index = i})
			end
			ops = ops + 301
			job.k = job.k + 1
		end
	end
	return false
end

-- Net count of standing entities by type: built minus mined minus lost, never below zero.
local function standing(a)
	local by_type, by_name = {}, {}
	for name, built in pairs(a.built) do
		local n = built - (a.mined[name] or 0) - (a.lost[name] or 0)
		if n > 0 then
			by_name[name] = n
			local t = etype(name)
			if t then add(by_type, t, n) end
		end
	end
	return by_type, by_name
end

local function sum_types(by_type, list)
	local n = 0
	for _, t in ipairs(list) do n = n + (by_type[t] or 0) end
	return n
end

local function ruins_summary(force)
	local iface = remote.interfaces["AbandonedRuins-paranoidal"]
	if not (iface and iface.get_force_summary) then return nil end
	local ok, res = pcall(remote.call, "AbandonedRuins-paranoidal", "get_force_summary", force.index)
	return ok and type(res) == "table" and res or nil
end

local function workshop_counters(force)
	local iface = remote.interfaces["ic-more-qualities"]
	if not (iface and iface.get_counters) then return nil end
	local ok, res = pcall(remote.call, "ic-more-qualities", "get_counters", force.index)
	return ok and type(res) == "table" and res or nil
end

-- Where a first product shows up in the statistics: normal everywhere, defects for finished items.
local function produce_probes(force, def)
	local probes = {}
	local can_defect = defectable()
	local _, _, qdefect = qualities()
	for _, si in ipairs(base_surfaces()) do
		if def.fluid then
			local st = force.get_fluid_production_statistics(si)
			for _, name in ipairs(def.names) do
				if st.get_input_count(name) > 0 then probes[#probes + 1] = {st, name} end
			end
		else
			local st = force.get_item_production_statistics(si)
			for _, name in ipairs(def.names) do
				local id = {name = name, quality = "normal"}
				if st.get_input_count(id) > 0 then probes[#probes + 1] = {st, id} end
				if can_defect[name] then
					for q in pairs(qdefect) do
						id = {name = name, quality = q}
						if st.get_input_count(id) > 0 then probes[#probes + 1] = {st, id} end
					end
				end
			end
		end
	end
	return probes
end

-- First products and ruins of a force. backfill: the save is being updated, so what is found now
-- happened earlier; it gets an estimated time and no chat message.
poll_force = function(s, force, backfill)
	local f = force_record(s, force.index)
	s.polled = s.polled or {}
	local prev = s.polled[force.index]
	for _, def in ipairs(produce_defs()) do
		if not f.milestones[def.id] then
			local probes = produce_probes(force, def)
			if #probes > 0 then
				local t, w = first_seen(probes, "input", (not backfill) and prev or nil)
				local rec
				if backfill then rec = t and {before = true, est = t, res = w} or {before = true, upto = game.tick}
				elseif t and w <= 600 then rec = {tick = t}
				elseif t then rec = {est = t, res = w}
				else rec = {upto = game.tick} end
				if mark(f, def.id, rec) and announce and not backfill then announce(force, def.id, rec) end
			end
		end
	end
	if not (f.milestones.ruin and f.milestones.legend and f.milestones["legend-won"]) then
		local ru = ruins_summary(force)
		if ru then
			local from = prev or s.since3 or s.since or 0
			local function put(id, tick, happened)
				if not happened or f.milestones[id] then return end
				local rec
				if tick then rec = {tick = tick}
				elseif backfill then rec = {upto = game.tick}
				else rec = {est = math.floor((from + game.tick) / 2), res = game.tick - from} end
				local old = backfill or (rec.tick ~= nil and rec.tick < (s.since3 or 0))
				if old then rec.before = true end
				if mark(f, id, rec) and announce and not old then announce(force, id, rec) end
			end
			put("ruin", ru.first_found, (ru.found_types or 0) > 0)
			put("legend", ru.legendary_first_found, (ru.legendary_found or 0) > 0)
			put("legend-won", ru.legendary_first_solved, (ru.legendary_solved or 0) > 0)
		end
	end
	s.polled[force.index] = game.tick
end

-- Every 10 minutes (on_nth_tick): first products and ruins of every team, a few dozen reads.
function M.on_poll()
	local s = storage.rpg_stats
	if not s then return end
	if s.version ~= VERSION then s = M.root() end
	for _, force in pairs(game.forces) do
		if M.player_force(force) then poll_force(s, force, false) end
	end
end

-- Status of the base from the milestones of the force (see M.STATUS).
local function status_of(f, force)
	local function met(step)
		if step.rocket then return f.milestones.rocket ~= nil or force.rockets_launched > 0 end
		if not step.packs then return true end
		for _, pack in ipairs(step.packs) do
			if f.milestones["pack:" .. pack] then return true end
		end
		return false
	end
	local status = 1
	for i, step in ipairs(M.STATUS) do
		if met(step) then status = i end
	end
	return status
end
M.status_of = status_of

function STEP.finish(job, force)
	local a = job.acc
	local f = M.force(force.index)
	local sn = {tick = game.tick}

	-- production
	local made = 0
	for _, c in pairs(a.items_in) do made = made + c end
	sn.items_made, sn.items_used = made, a.items_out
	sn.fluids_made, sn.fluids_used = a.fluids_made, a.fluids_used
	local built, mined = 0, 0
	for _, c in pairs(a.built) do built = built + c end
	for _, c in pairs(a.mined) do mined = mined + c end
	sn.built, sn.mined = built, mined
	sn.rockets = force.rockets_launched
	local resources = resource_products()
	sn.top_items = top(a.items_in, 5, function(name) return not resources[name] end)

	-- science
	local science, total_science = {}, 0
	for _, name in ipairs(lab_inputs()) do
		local c = a.items_in[name]
		if c and c > 0 then science[#science + 1] = {name, c, a.spm[name] or 0} total_science = total_science + c end
	end
	table.sort(science, function(x, y) return x[2] > y[2] end)
	local spm = 0
	for _, v in pairs(a.spm) do spm = spm + v end
	sn.science, sn.science_total, sn.spm = science, total_science, spm
	sn.tech_done, sn.tech_total, sn.tech_top = a.tech_done, a.tech_total, a.tech_top
	sn.tier_done, sn.tier_total = a.tier_done, a.tier_total
	sn.recipes = a.recipes
	local current = force.current_research
	if current then sn.research, sn.research_progress = current.name, force.research_progress end

	-- standing buildings
	local by_type, by_name = standing(a)
	sn.belts_m = by_type["transport-belt"] or 0
	sn.pipes_m = by_type["pipe"] or 0
	sn.machines = sum_types(by_type, {"assembling-machine", "furnace"})
	sn.walls = sum_types(by_type, {"wall", "gate"})
	sn.turrets = sum_types(by_type, {"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret"})
	sn.chests = sum_types(by_type, {"container", "logistic-container"})
	sn.radars = by_type["radar"] or 0
	sn.rails = sum_types(by_type, {"straight-rail", "half-diagonal-rail", "curved-rail-a", "curved-rail-b",
		"elevated-straight-rail", "elevated-half-diagonal-rail", "elevated-curved-rail-a", "elevated-curved-rail-b",
		"legacy-straight-rail", "legacy-curved-rail"})
	sn.poles = by_type["electric-pole"] or 0
	sn.top_buildings = top(by_name, 5, visible_entity)

	-- logistics
	local lr, lf, cr, cf, nets = 0, 0, 0, 0, 0
	for _, list in pairs(force.logistic_networks or {}) do
		for _, net in pairs(list) do
			nets = nets + 1
			lr, lf = lr + net.all_logistic_robots, lf + net.available_logistic_robots
			cr, cf = cr + net.all_construction_robots, cf + net.available_construction_robots
		end
	end
	sn.robots = {logistic = lr, logistic_free = lf, construction = cr, construction_free = cf, networks = nets}
	local trains = game.train_manager.get_trains({force = force})
	local locos, wagons = 0, 0
	for _, train in pairs(trains) do
		local l = train.locomotives
		local nl = #l.front_movers + #l.back_movers
		locos = locos + nl
		wagons = wagons + #train.carriages - nl
	end
	sn.trains = {trains = #trains, locomotives = locos, wagons = wagons,
		stops = #game.train_manager.get_train_stops({force = force})}

	-- power (electric flow counts are energy per tick; x60 gives watts)
	local now, hour, peak = 0, 0, 0
	for _, v in pairs(a.power_now) do now = now + v end
	for _, v in pairs(a.power_hour) do hour = hour + v end
	for i = 1, 300 do if (a.peak[i] or 0) > peak then peak = a.peak[i] end end
	sn.power = {now = now * 60, hour = hour * 60, peak = math.max(peak, now) * 60, networks = a.networks,
		sources = {}, consumers = {}}
	for _, entry in ipairs(top(a.power_now, 5, visible_entity)) do
		sn.power.sources[#sn.power.sources + 1] = {entry[1], entry[2] * 60}
	end
	for _, entry in ipairs(top(a.power_use, 3, visible_entity)) do
		sn.power.consumers[#sn.power.consumers + 1] = {entry[1], entry[2] * 60}
	end

	-- world
	sn.charted = a.charted
	sn.generated = storage.rpg_stats.world.generated
	sn.far_m = math.sqrt(a.far2) * 32
	sn.footprint = a.footprint
	sn.ruins = ruins_summary(force)
	sn.depleted = storage.rpg_stats.depleted
	local ore, fluid_res = {}, 0
	for name, kind in pairs(resources) do
		if kind == "fluid" then fluid_res = fluid_res + (a.fluids_in[name] or 0)
		elseif (a.items_in[name] or 0) > 0 then ore[name] = a.items_in[name] end
	end
	local ore_total = 0
	for _, c in pairs(ore) do ore_total = ore_total + c end
	sn.ore_total, sn.fluid_resources, sn.top_ores = ore_total, fluid_res, top(ore, 4)
	sn.fish = prototypes.item["raw-fish"] and (a.items_in["raw-fish"] or 0) or nil
	sn.wood = prototypes.item["wood"] and (a.items_in["wood"] or 0) or nil
	local surface = planet()
	if surface then
		sn.day = {time = surface.daytime, days = math.floor(game.tick / math.max(1, surface.ticks_per_day)),
			frozen = surface.freeze_daytime or nil}
	end

	-- war
	local units, spawners, worms = 0, 0, 0
	local enemies = {}
	for name, c in pairs(a.killed) do
		local t = etype(name)
		if t == "unit" then units = units + c enemies[name] = c
		elseif t == "unit-spawner" then spawners = spawners + c enemies[name] = c
		elseif t == "turret" then worms = worms + c enemies[name] = c end
	end
	sn.kills = {units = units, spawners = spawners, worms = worms}
	sn.top_killed = top(enemies, 6)
	sn.ammo_used = a.ammo_used
	local lost = 0
	for _, c in pairs(a.lost) do lost = lost + c end
	sn.lost, sn.top_lost = lost, top(a.lost, 5, visible_entity)
	if surface then
		local enemy = game.forces.enemy
		sn.evolution = {
			total = enemy.get_evolution_factor(surface),
			time = enemy.get_evolution_factor_by_time(surface),
			pollution = enemy.get_evolution_factor_by_pollution(surface),
			spawners = enemy.get_evolution_factor_by_killing_spawners(surface),
			-- map evolution off: only scripts move it, in Paranoidal research_evolution_factor
			by_research = (not game.map_settings.enemy_evolution.enabled) and script.active_mods["research_evolution_factor"] ~= nil,
		}
		local ps = game.get_pollution_statistics(surface)
		local emitted, absorbed = 0, 0
		for _, c in pairs(ps.input_counts) do emitted = emitted + c end
		for _, c in pairs(ps.output_counts) do absorbed = absorbed + c end
		sn.pollution = {emitted = emitted, absorbed = absorbed, now = a.pollution_now, top = top(ps.input_counts, 3)}
	end

	-- quality
	local _, display = qualities()
	local qlist, positive, best = {}, 0, nil
	for _, name in ipairs(display) do
		local c = a.q[name] or 0
		if c > 0 then
			qlist[#qlist + 1] = {name, c}
			if P.qpositive[name] then
				positive = positive + c
				best = best or {name, c}
			end
		end
	end
	sn.quality = {list = qlist, positive = positive, best = best, defects = a.defects,
		defectable = a.defectable, workshop = workshop_counters(force)}
	local level = 0
	for i = 1, 10 do
		local t = force.technologies["ic-defect-control-" .. i]
		if t and t.researched then level = i end
	end
	sn.quality.control = force.technologies["ic-defect-control-1"] and level or nil

	-- milestones found by this count: quality tiers (time from the graphs) and first products
	local since3 = storage.rpg_stats.since3 or 0
	for _, q in ipairs(QUALITY_MS) do
		local list, id = a.qms[q], QUALITY_ID[q]
		if list and not f.milestones[id] then
			local probes = {}
			for _, e in ipairs(list) do
				probes[#probes + 1] = {force.get_item_production_statistics(e[1]), {name = e[2], quality = q}}
			end
			local t, w = first_seen(probes, "input")
			local rec = t and {est = t, res = w} or {upto = game.tick}
			local old = (rec.est or rec.upto) < since3
			if old then rec.before = true end
			if mark(f, id, rec) and announce and not old then announce(force, id, rec) end
		end
	end
	poll_force(storage.rpg_stats, force, false)

	-- status
	sn.status = status_of(f, force)

	f.snapshot = sn
	return true
end

local function new_job(force)
	local packs = {["automation-science-pack"] = true}
	local f = M.force(force.index)
	for id in pairs(f.milestones) do
		local pack = id:match("^pack:(.+)$")
		if pack then packs[pack] = true end
	end
	return {
		force = force.index, phase = 1, i = 1, surfaces = base_surfaces(), packs = packs,
		acc = {
			items_in = {}, items_out = 0, ammo_used = 0, fluids_made = 0, fluids_used = 0, fluids_in = {},
			built = {}, mined = {}, killed = {}, lost = {},
			cq_s = {}, cq_n = {}, cq_c = {},
			q = {}, defects = 0, defectable = 0, rq = {}, spm = {}, pollution_now = 0, pack_out = {}, pack_q = {}, qms = {},
			tech_total = 0, tech_done = 0, tech_top_cost = 0, tier_total = 0, tier_done = 0,
			recipes = 0,
			charted = 0, far2 = 0, footprint = 0,
			power_now = {}, power_hour = {}, power_use = {}, networks = 0, nets = {}, peak = {},
		},
	}
end

local function register()
	script.on_event(defines.events.on_tick, tick_handler)
end

local function unregister()
	script.on_event(defines.events.on_tick, nil)
end

tick_handler = function()
	local s = storage.rpg_stats
	local job = s and s.job
	if not job then unregister() return end
	local force = game.forces[job.force]
	local done_force
	if not (force and force.valid) then
		s.job = nil
	else
		local name = PHASES[job.phase]
		if STEP[name](job, force) then
			job.phase = job.phase + 1
			job.i = 1
			if job.phase > #PHASES then
				s.job = nil
				done_force = force.index
			end
		end
	end
	if not s.job then
		local queue = s.queue or {}
		while #queue > 0 and not s.job do
			local nf = game.forces[table.remove(queue, 1)]
			if nf and nf.valid then s.job = new_job(nf) end
		end
		if not s.job then unregister() end
	end
	if done_force and on_done then on_done(done_force) end
end

function M.busy(force_index)
	local s = storage.rpg_stats
	if not s then return false end
	if s.job and s.job.force == force_index then return true end
	for _, fi in ipairs(s.queue or {}) do if fi == force_index then return true end end
	return false
end

-- Starts a snapshot unless one is fresh or already being built. Returns true when started or queued.
function M.request(force, forced)
	if not M.player_force(force) then return false end
	local s = M.root()
	if M.busy(force.index) then return true end
	local f = force_record(s, force.index)
	if not forced and f.snapshot and game.tick - f.snapshot.tick < M.FRESH then return false end
	if s.job then
		s.queue = s.queue or {}
		s.queue[#s.queue + 1] = force.index
	else
		s.job = new_job(force)
		register()
	end
	return true
end

function M.on_load()
	local s = storage.rpg_stats
	if s and s.job then register() end
end

-- For other mods and diagnostics: the last snapshot of a force, or nil.
function M.get_snapshot(force_index)
	local s = storage.rpg_stats
	local f = s and s.forces[force_index]
	return f and f.snapshot
end

M.fmt = fmt
return M
