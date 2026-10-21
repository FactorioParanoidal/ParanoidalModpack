-- King's Turret Shields, Paranoidal fork: runtime of the shield generators (9.111.0).
--
-- A shield generator protects the eligible turrets of its force whose centre lies within RADIUS of
-- the generator centre. Its shield is one hidden electric-energy-interface under the building
-- (the "buffer"); the electric network recharges it without any Lua. The generator does not
-- protect itself.
--
-- The engine delivers only the hits that would kill a covered turret (damage filter: turret type
-- AND final health <= 0). Such a hit is intercepted: the generator pays the whole hull and the
-- turret survives. Every other hit is left to the engine and repaired later from the generator:
-- each covered turret is looked at by a tick schedule, every HOT ticks while it keeps being
-- damaged, the gap doubling up to IDLE ticks once it is not. Cost therefore follows the turrets
-- under fire and the hits that would kill, not the number of hits (stress save 2026-10-21:
-- ~418 hits per tick, of which ~12-36 would kill depending on the repair period).
--
-- Who pays for a turret inside several generators: the one with the highest cached charge
-- fraction. The cache (generator.est) is the buffer energy read at the generator's own look every
-- GEN_LOOK ticks and after every payment, so choosing costs no engine call; one read and one
-- write of the chosen buffer per payment (looks of one tick share one read/write per generator).
-- An emptied generator stops for BROKEN_TICKS; a payment it cannot make goes on to the next one.
--
-- Engine costs measured on 2.0.77 (bench 2026-10-21): an event to a handler that reads it ~7 us,
-- an entity property read/write 0.15-0.3 us, a health write that makes an entity fully healthy
-- ~5.7 us (hence turrets under fire are repaired to RECORD.top, just below their maximum, and
-- get the rest SUSTAIN ticks after the last damage).
local shared = require("kts_shared")

local cfg = shared.read(settings.startup)
local J_PER_HP = cfg.kj_per_hp * 1000
local MAX_LEVEL = cfg.research and cfg.max_level or 0
local RADIUS = cfg.radius
local R2 = RADIUS * RADIUS

local TECH_BASE, TECH_SIZE, TECH_RATE = shared.tech_base, shared.tech_size, shared.tech_rate
local TOOL, GEN, BUFFER_PREFIX = shared.tool, shared.generator, shared.buffer_prefix
local TURRET_TYPES = shared.turret_types
local BAR, STEPS = shared.bar_short, shared.bar_short_steps
local HIT, HIT_SMOKE = shared.hit_animation, shared.hit_smoke
local HIT_FRAMES, HIT_SPEED = shared.hit_frames, shared.hit_speed
local HIT_TICKS = math.floor(HIT_FRAMES / HIT_SPEED + 0.5) -- 30; 9 / 0.3 is 30.000000000000004
local UNPLUGGED = "utility/electricity_icon_unplugged"

local HOT = 3 -- ticks between looks at a turret damaged at its last look or just intercepted
local IDLE = 300 -- longest gap between two looks at an undamaged turret
local UNPAID = 60 -- longest gap between two looks at a damaged turret no generator can repair now
local SUSTAIN = 60 -- ticks after the last seen damage a turret is kept eps below its maximum
local GEN_LOOK = 30 -- ticks between two looks at a generator (cached charge, bar, power icon, dome)
local BROKEN_TICKS = 10 -- an emptied generator neither repairs nor intercepts for this many ticks
local MIN_SAVE = 1 -- health points; an intercept that cannot give back this much is not made
local EMPTY = 1 -- J; a buffer below this counts as empty
local SPREAD = 30 -- first looks at new records are spread over this many ticks
local LOW = 0.25 -- charge fraction below which the dome shows "low"
local FX_INTERVAL = 5 -- a turret gets at most one bubble update per this many ticks
local EXTEND_BEFORE = 10 -- a bubble is extended when fewer ticks than this are left

local ENTITY = defines.target_type.entity
local EAST, WEST, SOUTH = defines.direction.east, defines.direction.west, defines.direction.south
local KIND_PLAIN, KIND_FLUID, KIND_LASER = 1, 2, 3
local DOME_COLORS = {
	{r = 0.1, g = 0.35, b = 0.6, a = 0.6}, -- charged
	{r = 0.6, g = 0.4, b = 0.05, a = 0.6}, -- low
	{r = 0.6, g = 0.1, b = 0.1, a = 0.6}, -- empty or broken
	{r = 0.25, g = 0.25, b = 0.25, a = 0.5}, -- off (research)
}
local BAR_OFFSET = {0, 0.75}
local PLUG_OFFSET = {0, -0.4}

local ceil, min, max = math.ceil, math.min, math.max

-- The only place that registers handlers (the bench build swaps this line for its profiler).
local on_event = script.on_event

local animated = settings.global["kts-animated-effect"].value

-- Storage layout of the generators. There is no migration: storage of any other layout (the
-- per-turret shields of 9.110.x) is dropped on configuration change, nothing is carried over.
local LAYOUT = 2

-- Bound storage tables (bind()).
local gens -- [generator unit_number] = generator record, see add_gen()
local turrets -- [turret unit_number] = turret record, see new_record()
local disabled -- [turret unit_number] = {turret = LuaEntity, icon = LuaRenderObject}
local levels -- [force index] = {on = bool, size = int, rate = int, name = buffer prototype}
local buckets -- [tick] = array of keys: turret unit_number, or -generator unit_number
local stats -- counters, see init_storage()

local ticking = false
local on_tick

local function bind()
	gens = storage.gens
	turrets = storage.turrets
	disabled = storage.disabled
	levels = storage.levels
	buckets = storage.buckets
	stats = storage.stats
end

---------------------------------------------------------------------------------------------------
-- Caches derived from prototypes and startup settings only (identical on every peer).
---------------------------------------------------------------------------------------------------
local stats_cache = {}
local function stats_of(lv)
	local s = stats_cache[lv.name]
	if not s then
		s = shared.stats(cfg, lv.size, lv.rate)
		stats_cache[lv.name] = s
	end
	return s
end

-- Only buildable player turrets: helpers such as the Bio Industries arboretum area (an
-- ammo-turret without player-creation) and hidden fakes are never protected.
local eligible_cache = {}
local function eligible(name)
	local v = eligible_cache[name]
	if v == nil then
		local p = prototypes.entity[name]
		v = p ~= nil and not p.hidden and p.has_flag("player-creation")
		eligible_cache[name] = v
	end
	return v
end

local kind_cache = {}
local function kind_of(turret)
	local name = turret.name
	local k = kind_cache[name]
	if not k then
		if turret.type == "fluid-turret" then
			k = KIND_FLUID
		elseif name == "laser-turret" then
			k = KIND_LASER
		else
			k = KIND_PLAIN
		end
		kind_cache[name] = k
	end
	return k
end

local names_list
local function buffer_names()
	if not names_list then
		names_list = {}
		for size = 0, MAX_LEVEL do
			for rate = 0, MAX_LEVEL do
				names_list[#names_list + 1] = shared.buffer_name(size, rate)
			end
		end
	end
	return names_list
end

---------------------------------------------------------------------------------------------------
-- Research levels per force (stored: game state is not readable in on_load).
---------------------------------------------------------------------------------------------------
local function completed(tech)
	if not tech then
		return 0
	end
	local done = tech.researched and tech.level or tech.level - 1
	if done < 0 then
		return 0
	elseif done > MAX_LEVEL then
		return MAX_LEVEL
	end
	return done
end

local function compute_level(force)
	local on, size, rate
	if cfg.research then
		local techs = force.technologies
		local base = techs[TECH_BASE]
		on = base ~= nil and base.researched
		size, rate = completed(techs[TECH_SIZE]), completed(techs[TECH_RATE])
	else
		on = force.name ~= "enemy" and force.name ~= "neutral"
		size, rate = 0, 0
	end
	return {on = on, size = size, rate = rate, name = shared.buffer_name(size, rate)}
end

local function level(force_index)
	local lv = levels[force_index]
	if not lv then
		lv = compute_level(game.forces[force_index])
		levels[force_index] = lv
	end
	return lv
end

---------------------------------------------------------------------------------------------------
-- Tick schedule.
---------------------------------------------------------------------------------------------------
local function set_ticking(on)
	if on ~= ticking then
		ticking = on
		on_event(defines.events.on_tick, on and on_tick or nil)
	end
end

-- key: turret unit_number, or -unit_number of a generator. tick is always in the future.
local function schedule(key, tick)
	local list = buckets[tick]
	if list then
		list[#list + 1] = key
	else
		buckets[tick] = {key}
	end
	if not ticking then
		set_ticking(true)
	end
end

local function look_at(t, tick)
	t.due = tick
	schedule(t.unit, tick)
end

-- Damage seen or intercepted: the next look comes within HOT ticks.
local function hot(t, tick)
	t.period = HOT
	local due = tick + HOT
	if not t.due or t.due > due then
		look_at(t, due)
	end
end

---------------------------------------------------------------------------------------------------
-- Payments. choose() picks the covering generator with the highest cached charge fraction;
-- take() pays from it through a per-call cache (one buffer read and one write per generator,
-- written by flush()).
---------------------------------------------------------------------------------------------------
local cache_e, cache_list = {}, {}

local function choose(t, tick)
	local list = t.gens
	local best, best_r
	for i = 1, #list do
		local g = gens[list[i]]
		if g and g.on and g.broken < tick then
			local r = g.est / g.cap
			if not best or r > best_r then
				best, best_r = g, r
			end
		end
	end
	return best
end

local function take(g, hp, tick)
	local e = cache_e[g]
	if not e then
		local buf = g.buf
		if not buf.valid then
			g.broken = tick + BROKEN_TICKS -- the generator look builds a new buffer
			return 0
		end
		e = buf.energy
		cache_list[#cache_list + 1] = g
	end
	local need = hp * J_PER_HP
	if e >= need then
		e = e - need
		cache_e[g], g.est, g.paid = e, e, g.paid + need
		return hp
	end
	cache_e[g], g.est, g.paid = 0, 0, g.paid + e
	g.broken = tick + BROKEN_TICKS
	stats.broken = stats.broken + 1
	return e / J_PER_HP
end

-- take() checked every listed buffer in the same call, and nothing in between destroys buffers.
local function flush()
	for i = #cache_list, 1, -1 do
		local g = cache_list[i]
		g.buf.energy = cache_e[g]
		cache_e[g] = nil
		cache_list[i] = nil
	end
end

-- Pays up to hp health points for turret record t; returns the points paid.
-- At most one attempt per covering generator: take() marks a generator that cannot pay in full
-- as broken, so choose() moves on; the bound keeps the loop finite whatever take() does.
local function pay(t, hp, tick)
	local paid, n = 0, 0
	for _ = 1, #t.gens do
		local g = choose(t, tick)
		if not g then
			break
		end
		n = n + 1
		local want = hp - paid
		local got = take(g, want, tick)
		paid = paid + got
		if got >= want then
			break
		end
	end
	if n > 1 then
		stats.fallback = stats.fallback + 1
	end
	return paid
end

---------------------------------------------------------------------------------------------------
-- Turret records and coverage. t.gens: units of the covering generators by distance (then unit).
---------------------------------------------------------------------------------------------------
local function set_limits(t, turret)
	local max_health = turret.max_health
	t.max = max_health
	t.eps = max(0.01, max_health * 1e-6)
	t.top = max_health - t.eps
end

local function new_record(turret, tick)
	local p = turret.position
	local unit = turret.unit_number
	local t = {
		unit = unit, turret = turret, surface = turret.surface_index, x = p.x, y = p.y, force = turret.force_index,
		gens = {}, kind = kind_of(turret), seen = -SUSTAIN - 1, period = HOT, vis = 0, fx_exp = 0,
	}
	set_limits(t, turret)
	turrets[unit] = t
	look_at(t, tick + 1 + unit % SPREAD)
	return t
end

local function dist2(g, t)
	local dx, dy = g.x - t.x, g.y - t.y
	return dx * dx + dy * dy
end

local function link(t, g)
	if g.members[t.unit] then
		return
	end
	local list = t.gens
	local d = dist2(g, t)
	local i = #list
	while i >= 1 do
		local o = gens[list[i]]
		local od = dist2(o, t)
		if od < d or (od == d and o.unit < g.unit) then
			break
		end
		list[i + 1] = list[i]
		i = i - 1
	end
	list[i + 1] = g.unit
	g.members[t.unit] = true
	g.count = g.count + 1
end

local function unlink(t, unit)
	local list = t.gens
	for i = 1, #list do
		if list[i] == unit then
			table.remove(list, i)
			return
		end
	end
end

-- Removes the record; a turret kept eps below its maximum gets it back.
local function drop(t)
	turrets[t.unit] = nil
	t.due = nil
	local list = t.gens
	for i = 1, #list do
		local g = gens[list[i]]
		if g and g.members[t.unit] then
			g.members[t.unit] = nil
			g.count = g.count - 1
		end
	end
	t.gens = {}
	local turret = t.turret
	if turret.valid then
		local h = turret.health
		if h < t.max and t.max - h <= 1.5 * t.eps then
			turret.health = t.max
		end
	end
	local fx = t.fx
	if fx and fx.valid then
		fx.destroy()
	end
end

-- A turret that is eligible, not switched off and inside at least one generator of its force gets
-- a record. Generators are few, so they are looked up in Lua.
local function cover_turret(turret, tick)
	local unit = turret.unit_number
	local t = turrets[unit]
	if t or disabled[unit] or not eligible(turret.name) then
		return t
	end
	local p = turret.position
	local s, f = turret.surface_index, turret.force_index
	local found
	for _, g in pairs(gens) do
		if g.surface == s and g.force == f then
			local dx, dy = g.x - p.x, g.y - p.y
			if dx * dx + dy * dy <= R2 then
				found = found or {}
				found[#found + 1] = g
			end
		end
	end
	if not found then
		return nil
	end
	t = new_record(turret, tick)
	for i = 1, #found do
		link(t, found[i])
	end
	return t
end

local function cover_gen(g, tick)
	local found = g.entity.surface.find_entities_filtered({
		position = {g.x, g.y}, radius = RADIUS + 0.01, type = TURRET_TYPES, force = g.force,
	})
	for i = 1, #found do
		local turret = found[i]
		local unit = turret.unit_number
		if not disabled[unit] and eligible(turret.name) then
			local p = turret.position
			local dx, dy = g.x - p.x, g.y - p.y
			if dx * dx + dy * dy <= R2 then
				link(turrets[unit] or new_record(turret, tick), g)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Generators.
---------------------------------------------------------------------------------------------------
local function destroy_render(o)
	if o and o.valid then
		o.destroy()
	end
end

-- Creates, replaces or removes the hidden buffer for the force level. energy: carried energy
-- (nil = keep the current buffer energy).
local function set_level(g, lv, energy)
	local buf = g.buf
	local old_valid = buf ~= nil and buf.valid
	if not lv.on then
		if old_valid then
			buf.destroy()
		end
		g.buf, g.name, g.on, g.cap, g.est = nil, nil, false, 0, 0
		return
	end
	if g.on and g.name == lv.name and old_valid then
		return
	end
	if energy == nil then
		energy = old_valid and buf.energy or 0
	end
	local new = g.entity.surface.create_entity({
		name = lv.name, position = {g.x, g.y}, force = g.force, create_build_effect_smoke = false,
	})
	if not new then
		return
	end
	new.destructible = false
	if old_valid then
		buf.destroy()
	end
	local st = stats_of(lv)
	energy = min(max(energy, 0), st.buffer)
	if energy > 0 then
		new.energy = energy
	end
	g.buf, g.name, g.on, g.cap, g.est = new, lv.name, true, st.buffer, energy
end

local function add_gen(entity, energy, tick)
	local unit = entity.unit_number
	local g = gens[unit]
	if g then
		return g
	end
	local p = entity.position
	g = {
		unit = unit, entity = entity, surface = entity.surface_index, x = p.x, y = p.y, force = entity.force_index,
		members = {}, count = 0, on = false, cap = 0, est = 0, paid = 0, last = -1, broken = -1, step = -1,
	}
	gens[unit] = g
	script.register_on_object_destroyed(entity)
	set_level(g, level(g.force), energy or 0)
	g.dome = rendering.draw_circle({
		color = DOME_COLORS[g.on and 1 or 4], radius = RADIUS, width = 2, filled = false, target = entity,
		surface = g.surface, draw_on_ground = true, only_in_alt_mode = true,
	})
	g.band = g.on and 1 or 4
	cover_gen(g, tick)
	g.due = tick + 1
	schedule(-unit, g.due)
	return g
end

local function remove_gen(unit)
	local g = gens[unit]
	if not g then
		return
	end
	gens[unit] = nil
	g.due = nil
	local buf = g.buf
	if buf and buf.valid then
		buf.destroy()
	end
	destroy_render(g.dome)
	destroy_render(g.bar)
	destroy_render(g.plug)
	for tu in pairs(g.members) do
		local t = turrets[tu]
		if t then
			unlink(t, unit)
			if #t.gens == 0 then
				drop(t)
			end
		end
	end
	g.members, g.count = {}, 0
end

-- Generator look: cached charge, charge bar, "no power" icon, dome colour.
local function look_gen(g, tick)
	g.due = nil
	local entity = g.entity
	if not entity.valid then
		return -- on_object_destroyed removes the record
	end
	if not g.on then
		return -- research reversed; relevel() schedules the next look
	end
	local buf = g.buf
	if not buf.valid then
		g.on = false
		set_level(g, level(g.force), 0)
		buf = g.buf
		if not buf then
			return
		end
	end
	local energy = buf.energy
	local cap = g.cap
	g.est = energy
	local step = 0
	if energy >= EMPTY then
		step = min(STEPS, max(1, ceil(energy * STEPS / cap - 1e-9)))
	end
	if step ~= g.step then
		local bar = g.bar
		if bar and bar.valid then
			bar.sprite = BAR .. step
		else
			g.bar = rendering.draw_sprite({
				sprite = BAR .. step, target = {entity = entity, offset = BAR_OFFSET}, surface = g.surface,
			})
		end
		g.step = step
	end
	-- Not full and not more than the payments since the last look explain: no recharge.
	local unplugged = g.last >= 0 and energy < cap - EMPTY and energy <= g.last - g.paid + EMPTY
	if unplugged ~= (g.plug ~= nil) then
		if unplugged then
			g.plug = rendering.draw_sprite({
				sprite = UNPLUGGED, target = {entity = entity, offset = PLUG_OFFSET}, surface = g.surface,
				x_scale = 0.5, y_scale = 0.5, render_layer = "entity-info-icon",
			})
		else
			destroy_render(g.plug)
			g.plug = nil
		end
	end
	local band = (g.broken >= tick or energy < EMPTY) and 3 or (energy < LOW * cap and 2 or 1)
	if band ~= g.band then
		local dome = g.dome
		if dome and dome.valid then
			dome.color = DOME_COLORS[band]
		end
		g.band = band
	end
	g.last, g.paid = energy, 0
	g.due = tick + GEN_LOOK
	schedule(-g.unit, g.due)
end

---------------------------------------------------------------------------------------------------
-- Turret look: repair from the generators.
---------------------------------------------------------------------------------------------------
local function look_turret(t, tick)
	t.due = nil
	local turret = t.turret
	if not turret.valid then
		drop(t) -- removed by any means; nothing else tracks covered turrets
		return
	end
	stats.looks = stats.looks + 1
	local h = turret.health
	local lost = t.max - h
	local eps = t.eps
	if lost > 1.5 * eps then
		t.seen = tick
		local paid = pay(t, t.top - h, tick)
		if paid > 0 then
			turret.health = h + paid
			stats.repairs = stats.repairs + 1
			stats.repaired_hp = stats.repaired_hp + paid
			t.period = HOT
		else
			-- Empty, broken or switched off generators: look less often until one can pay.
			t.period = min(UNPAID, t.period * 2)
		end
	else
		if lost > 0.5 * eps and tick - t.seen > SUSTAIN then
			local paid = pay(t, lost, tick)
			if paid > 0 then
				turret.health = h + paid
				stats.giveback = stats.giveback + 1
			end
		end
		t.period = min(IDLE, t.period * 2)
	end
	look_at(t, tick + t.period)
end

on_tick = function(event)
	local tick = event.tick
	local list = buckets[tick]
	if list then
		buckets[tick] = nil
		local later
		for i = 1, #list do
			local key = list[i]
			if key > 0 then
				local t = turrets[key]
				if t and t.due == tick then
					look_turret(t, tick)
				end
			else
				local g = gens[-key]
				if g and g.due == tick then
					later = later or {}
					later[#later + 1] = g
				end
			end
		end
		flush()
		if later then
			for i = 1, #later do
				look_gen(later[i], tick)
			end
		end
	end
	if next(buckets) == nil then
		set_ticking(false)
	end
end

---------------------------------------------------------------------------------------------------
-- Intercepting a hit that would kill a covered turret: the hot path.
---------------------------------------------------------------------------------------------------
-- The bubble is one render object per turret. Under continued interception it is not drawn again:
-- shortly before it ends its time to live is extended, and it keeps looping.
local function hit_effect(t, turret, tick)
	t.vis = tick + FX_INTERVAL
	if not animated then
		local p = turret.position
		turret.surface.create_trivial_smoke({name = HIT_SMOKE, position = {p.x, p.y - 0.48}})
		return
	end
	local left = t.fx_exp - tick
	if left >= EXTEND_BEFORE then
		return
	end
	local fx = t.fx
	if left > 0 and fx and fx.valid then
		fx.time_to_live = HIT_TICKS
	else
		local dx, dy = -0.06, -0.38
		local kind = t.kind
		if kind == KIND_LASER then
			dx, dy = -0.04, -0.54
		elseif kind == KIND_FLUID then
			-- The flamethrower head is off-centre; the effect goes to its end, as in 1.1.
			local d = turret.direction
			if d == EAST then
				dx = -0.56
			elseif d == SOUTH then
				dy = -0.88
			elseif d == WEST then
				dx = 0.44
			else
				dy = 0.12
			end
		end
		-- Animation frames follow the game tick; the offset makes the bubble start at frame 0.
		t.fx = rendering.draw_animation({
			animation = HIT, target = {entity = turret, offset = {dx, dy}}, surface = turret.surface_index,
			time_to_live = HIT_TICKS, animation_speed = HIT_SPEED,
			animation_offset = -(tick * HIT_SPEED) % HIT_FRAMES + 0.001, render_layer = "wires",
		})
	end
	t.fx_exp = tick + HIT_TICKS
end

-- The engine has already applied the hit: the turret has 0 health and dies after the handlers
-- unless one gives health back. The generator pays the whole hull up to t.top (it also covers the
-- not yet repaired damage of earlier hits).
local function on_lethal(event)
	local turret = event.entity
	if not turret.valid then
		return -- destroyed by an earlier handler of another mod
	end
	local t = turrets[turret.unit_number]
	if not t then
		return
	end
	local tick = event.tick
	local paid = pay(t, t.top, tick)
	flush()
	if paid < MIN_SAVE then
		stats.lost = stats.lost + 1
		return
	end
	turret.health = paid
	stats.saved = stats.saved + 1
	if paid < t.top then
		stats.partial = stats.partial + 1
	end
	t.seen = tick
	hot(t, tick)
	if tick >= t.vis then
		hit_effect(t, turret, tick)
	end
end

---------------------------------------------------------------------------------------------------
-- Switching turrets out of the protection and back (shortcut tool).
---------------------------------------------------------------------------------------------------
local function off_icon(turret)
	return rendering.draw_sprite({
		sprite = UNPLUGGED, target = {entity = turret, offset = {0.7, -0.8}}, surface = turret.surface_index,
		x_scale = 0.18, y_scale = 0.18, render_layer = "entity-info-icon",
	})
end

local function disable(turret)
	local unit = turret.unit_number
	if disabled[unit] then
		return
	end
	local t = turrets[unit]
	if t then
		drop(t)
	end
	disabled[unit] = {turret = turret, icon = off_icon(turret)}
	script.register_on_object_destroyed(turret)
end

local function enable(turret, tick)
	local unit = turret.unit_number
	local entry = disabled[unit]
	if not entry then
		return
	end
	destroy_render(entry.icon)
	disabled[unit] = nil
	cover_turret(turret, tick)
end

local function on_selected(event, on)
	if event.item ~= TOOL then
		return
	end
	local entities = event.entities
	for i = 1, #entities do
		local turret = entities[i]
		if turret.valid then
			if on then
				enable(turret, event.tick)
			else
				disable(turret)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Building, replacing, moving.
---------------------------------------------------------------------------------------------------
-- Off state of a turret destroyed by a script, for a replacement built at the same place in the
-- same tick (HeroTurrets promotes a turret by destroy + create).
local function stash(turret, tick)
	local unit = turret.unit_number
	local t = turrets[unit]
	if t then
		drop(t)
	end
	local entry = disabled[unit]
	if not entry then
		return
	end
	destroy_render(entry.icon)
	disabled[unit] = nil
	local carry = storage.carry
	if carry.tick ~= tick then
		carry = {tick = tick}
		storage.carry = carry
	end
	local p = turret.position
	carry[#carry + 1] = {surface = turret.surface_index, x = p.x, y = p.y, off = true}
end

local function take_carried(turret, tick)
	local carry = storage.carry
	if carry.tick ~= tick then
		return nil
	end
	local p = turret.position
	local surface = turret.surface_index
	for i = #carry, 1, -1 do
		local c = carry[i]
		if c.surface == surface and c.x == p.x and c.y == p.y then
			table.remove(carry, i)
			return c
		end
	end
	return nil
end

local function built_turret(turret, tick, carried)
	if carried and carried.off then
		disable(turret)
		return
	end
	cover_turret(turret, tick)
end

local function on_built(event)
	local entity = event.entity
	if not (entity and entity.valid) then
		return
	end
	if entity.name == GEN then
		add_gen(entity, 0, event.tick)
	else
		built_turret(entity, event.tick, nil)
	end
end

local function on_script_built(event)
	local entity = event.entity
	if not (entity and entity.valid) then
		return
	end
	if entity.name == GEN then
		add_gen(entity, 0, event.tick)
	else
		built_turret(entity, event.tick, take_carried(entity, event.tick))
	end
end

local function on_script_destroy(event)
	local entity = event.entity
	if not (entity and entity.valid) then
		return
	end
	if entity.name == GEN then
		remove_gen(entity.unit_number)
	else
		stash(entity, event.tick)
	end
end

local function on_cloned(event)
	local clone = event.destination
	if not clone.valid then
		return
	end
	local name = clone.name
	if clone.type == "electric-energy-interface" then
		-- A buffer copied by an area clone has no owner; the cloned generator gets its own.
		if name:sub(1, #BUFFER_PREFIX) == BUFFER_PREFIX then
			clone.destroy()
		end
		return
	end
	local source = event.source
	if name == GEN then
		local energy = 0
		if source.valid then
			local g = gens[source.unit_number]
			if g and g.buf and g.buf.valid then
				energy = g.buf.energy
			end
		end
		add_gen(clone, energy, event.tick)
		return
	end
	built_turret(clone, event.tick, {off = source.valid and disabled[source.unit_number] ~= nil})
end

local function on_teleported(event)
	local entity = event.entity
	if not entity.valid then
		return
	end
	local unit = entity.unit_number
	if entity.name == GEN then
		local g = gens[unit]
		local energy = g and g.buf and g.buf.valid and g.buf.energy or 0
		remove_gen(unit)
		add_gen(entity, energy, event.tick)
		return
	end
	local t = turrets[unit]
	if t then
		drop(t)
	end
	cover_turret(entity, event.tick)
end

local function on_object_destroyed(event)
	if event.type ~= ENTITY then
		return
	end
	local unit = event.useful_id
	if gens[unit] then
		remove_gen(unit)
	end
	disabled[unit] = nil
end

---------------------------------------------------------------------------------------------------
-- Research and forces.
---------------------------------------------------------------------------------------------------
local function relevel(force)
	local fi = force.index
	local old = levels[fi]
	local lv = compute_level(force)
	levels[fi] = lv
	if old and old.on == lv.on and old.name == lv.name then
		return
	end
	local tick = game.tick
	for _, g in pairs(gens) do
		if g.force == fi then
			local was = g.on
			set_level(g, lv, nil)
			if g.on and not was then
				g.last, g.paid = -1, 0
				g.due = tick + 1
				schedule(-g.unit, g.due)
			elseif not g.on then
				destroy_render(g.bar)
				destroy_render(g.plug)
				g.bar, g.plug, g.step = nil, nil, -1
				local dome = g.dome
				if dome and dome.valid then
					dome.color = DOME_COLORS[4]
				end
				g.band = 4
			end
		end
	end
end

local function on_research(event)
	local name = event.research.name
	if name == TECH_BASE or name == TECH_SIZE or name == TECH_RATE then
		relevel(event.research.force)
	end
end

local function on_force_changed(event)
	relevel(event.force)
end

---------------------------------------------------------------------------------------------------
-- Rebuild everything (configuration change, /kts-rebuild, forces merged).
---------------------------------------------------------------------------------------------------
local function full_rescan()
	local tick = game.tick
	for unit, entry in pairs(disabled) do
		if not entry.turret.valid then
			disabled[unit] = nil
		end
	end
	for _, t in pairs(turrets) do
		drop(t) -- gives back the eps, removes the bubble
	end
	local energy_of = {}
	for unit, g in pairs(gens) do
		if g.buf and g.buf.valid then
			energy_of[unit] = g.buf.energy
		end
		destroy_render(g.dome)
		destroy_render(g.bar)
		destroy_render(g.plug)
	end
	storage.gens, storage.turrets, storage.buckets = {}, {}, {}
	for fi in pairs(storage.levels) do
		storage.levels[fi] = nil
	end
	bind()
	-- Every buffer is rebuilt from its generator; this also removes ownerless ones.
	local names = buffer_names()
	for _, surface in pairs(game.surfaces) do
		local found = surface.find_entities_filtered({type = "electric-energy-interface", name = names})
		for i = 1, #found do
			found[i].destroy()
		end
	end
	for _, force in pairs(game.forces) do
		levels[force.index] = compute_level(force)
	end
	for _, surface in pairs(game.surfaces) do
		local found = surface.find_entities_filtered({name = GEN})
		for i = 1, #found do
			local e = found[i]
			add_gen(e, energy_of[e.unit_number] or 0, tick)
		end
	end
	if next(buckets) == nil then
		set_ticking(false)
	end
end

---------------------------------------------------------------------------------------------------
-- Lifecycle.
---------------------------------------------------------------------------------------------------
local STAT_KEYS = {"saved", "partial", "lost", "looks", "repairs", "repaired_hp", "giveback", "fallback", "broken"}

local function init_storage()
	storage.gens = storage.gens or {}
	storage.turrets = storage.turrets or {}
	storage.disabled = storage.disabled or {}
	storage.levels = storage.levels or {}
	storage.buckets = storage.buckets or {}
	storage.carry = storage.carry or {tick = -1}
	storage.stats = storage.stats or {}
	for _, k in ipairs(STAT_KEYS) do
		storage.stats[k] = storage.stats[k] or 0
	end
	bind()
end

-- Storage of another layout (9.110.x per-turret shields) is dropped together with the render
-- objects of this mod, so that such a save loads without errors. Not a migration: nothing is kept.
local function drop_foreign_layout()
	if storage.version == LAYOUT then
		return
	end
	for k in pairs(storage) do
		storage[k] = nil
	end
	rendering.clear(script.mod_name)
	storage.version = LAYOUT
end

script.on_init(function()
	init_storage()
	storage.version = LAYOUT
	full_rescan()
end)

script.on_load(function()
	bind()
	if storage.version == LAYOUT and next(buckets) ~= nil then
		set_ticking(true)
	end
end)

script.on_configuration_changed(function()
	drop_foreign_layout()
	init_storage()
	full_rescan()
end)

on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "kts-animated-effect" then
		animated = settings.global["kts-animated-effect"].value
	end
end)

local lethal_filter, built_filter = {}, {}
for _, t in ipairs(TURRET_TYPES) do
	lethal_filter[#lethal_filter + 1] = {filter = "type", type = t}
	lethal_filter[#lethal_filter + 1] = {filter = "final-health", comparison = "<=", value = 0, mode = "and"}
	built_filter[#built_filter + 1] = {filter = "type", type = t}
end
built_filter[#built_filter + 1] = {filter = "name", name = GEN}
local clone_filter = {{filter = "type", type = "electric-energy-interface"}}
for _, f in ipairs(built_filter) do
	clone_filter[#clone_filter + 1] = f
end

on_event(defines.events.on_entity_damaged, on_lethal, lethal_filter)
on_event(defines.events.on_built_entity, on_built, built_filter)
on_event(defines.events.on_robot_built_entity, on_built, built_filter)
on_event(defines.events.script_raised_built, on_script_built, built_filter)
on_event(defines.events.script_raised_revive, on_script_built, built_filter)
on_event(defines.events.script_raised_destroy, on_script_destroy, built_filter)
on_event(defines.events.script_raised_teleported, on_teleported, built_filter)
on_event(defines.events.on_entity_cloned, on_cloned, clone_filter)
on_event(defines.events.on_object_destroyed, on_object_destroyed)
on_event(defines.events.on_player_selected_area, function(event) on_selected(event, false) end)
on_event(defines.events.on_player_alt_selected_area, function(event) on_selected(event, true) end)
on_event(defines.events.on_research_finished, on_research)
on_event(defines.events.on_research_reversed, on_research)
on_event(defines.events.on_technology_effects_reset, on_force_changed)
on_event(defines.events.on_force_reset, on_force_changed)
on_event(defines.events.on_forces_merged, function() full_rescan() end)
on_event(defines.events.on_force_created, function(event)
	levels[event.force.index] = compute_level(event.force)
end)

---------------------------------------------------------------------------------------------------
-- Commands and the remote interface.
---------------------------------------------------------------------------------------------------
local function fmt(x)
	return string.format("%.1f", x)
end

local function counts(force_index)
	local n_gens, n_turrets, energy = 0, 0, 0
	for _, g in pairs(gens) do
		if not force_index or g.force == force_index then
			n_gens = n_gens + 1
			energy = energy + g.est
		end
	end
	for _, t in pairs(turrets) do
		if not force_index or t.force == force_index then
			n_turrets = n_turrets + 1
		end
	end
	return n_gens, n_turrets, energy
end

commands.add_command("kts-stats", {"kts.command-stats"}, function(command)
	local player = command.player_index and game.get_player(command.player_index)
	local force = player and player.force or game.forces.player
	local print = player and player.print or game.print
	local lv = level(force.index)
	if not lv.on then
		print({"kts.stats-off"})
		return
	end
	local st = stats_of(lv)
	local n_gens, n_turrets, energy = counts(force.index)
	print({
		"kts.stats", fmt(st.hp), fmt(st.hps), fmt(st.drain / 1000), fmt(st.recharge / 1000), RADIUS,
		n_gens, n_turrets, fmt(energy / J_PER_HP), lv.size, lv.rate, stats.saved, stats.repairs,
	})
end)

commands.add_command("kts-rebuild", {"kts.command-rebuild"}, function(command)
	local player = command.player_index and game.get_player(command.player_index)
	if player and not player.admin then
		player.print({"kts.admin-only"})
		return
	end
	full_rescan()
	local n_gens, n_turrets = counts(nil)
	game.print({"kts.rebuilt", n_gens, n_turrets})
end)

remote.add_interface("kts-shields", {
	-- Counters since the map started using generators, plus current record counts.
	stats = function()
		local out = {}
		if stats then
			for k, v in pairs(stats) do
				out[k] = v
			end
			out.generators, out.turrets = counts(nil)
		end
		return out
	end,
})
