--[[
Nearby Ammo Count (Paranoidal fork).

Every turret near a connected player gets at most one persistent render object.
Objects are updated in place only when the shown value, colour or set of viewers
changes; turrets nobody should see have no object at all.

Work is spread over ticks: each tick refreshes a slice of the tracked turrets so
that every turret is refreshed once per update period. The turret search around
a player runs only when the player moved, changed surface, forces changed, or
after RESCAN_MAX_AGE ticks; turrets built nearby are added through build events.

All mutable state lives in `storage`; module locals hold only values derived
from settings and prototypes, so they are identical on every client.
]]

local RADIUS = 100
local RADIUS_SQ = RADIUS * RADIUS
local RESCAN_CHECK_TICKS = 30
local RESCAN_MAX_AGE = 300
local RESCAN_MOVE_SQ = 16 * 16

local SETTING_PREFIX = "nearby-ammo-"
local SETTING_ONLY_DEFICIT = "nearby-ammo-only-deficit"
local SETTING_DEFICIT_PERCENT = "nearby-ammo-deficit-percent"

local TURRET_INV = defines.inventory.turret_ammo
local ICON_SPRITE = "ammo-icon-white"
local ICON_LAYER = "entity-info-icon-above"
local TEXT_SCALE = 2.5

local LEVEL_CRITICAL, LEVEL_LOW, LEVEL_NORMAL = 1, 2, 3

-- Derived from runtime-global settings (see read_settings).
local disp_mode = "magazine"
local text_mode = true
local period = 15
local level_color = {}
local level_hidden = {}
local colorbase_r, colorbase_g, colorbase_b, colorbase_a
local norm_r, norm_g, norm_b, norm_a
local crit_r, crit_g, crit_b, crit_a

-- Derived from prototypes.
local limit_cache, mag_size_cache = {}, {}

local function turret_limit(name)
	local x = limit_cache[name]
	if x == nil then
		x = prototypes.entity[name].automated_ammo_count or 0
		if x < 1 then x = 1 end
		limit_cache[name] = x
	end
	return x
end

local function mag_size(name)
	local x = mag_size_cache[name]
	if x == nil then
		x = prototypes.item[name].magazine_size or 1
		mag_size_cache[name] = x
	end
	return x
end

local function read_settings()
	local g = settings.global
	disp_mode = g["nearby-ammo-display-mode"].value
	text_mode = disp_mode == "shot" or disp_mode == "magazine"

	local ups = g["nearby-ammo-update-per-second"].value
	period = math.max(1, math.floor(60 / ups))

	local norm = g["nearby-ammo-color-normal"].value
	local low = g["nearby-ammo-color-low"].value
	local crit = g["nearby-ammo-color-critical"].value
	level_color[LEVEL_CRITICAL], level_color[LEVEL_LOW], level_color[LEVEL_NORMAL] = crit, low, norm
	for level, color in pairs(level_color) do
		level_hidden[level] = (color.a or 1) <= 0
	end

	colorbase_r, colorbase_g, colorbase_b, colorbase_a = low.r, low.g, low.b, low.a
	norm_r, norm_g, norm_b, norm_a = norm.r - low.r, norm.g - low.g, norm.b - low.b, norm.a - low.a
	crit_r, crit_g, crit_b, crit_a = crit.r - low.r, crit.g - low.g, crit.b - low.b, crit.a - low.a
end

-- Per-user filter: false = show every tracked turret, number = fraction of the
-- inserter fill limit (automated_ammo_count) below which the counter is shown.
local function player_factor(player)
	local s = player.mod_settings
	if not s[SETTING_ONLY_DEFICIT].value then return false end
	return s[SETTING_DEFICIT_PERCENT].value / 100
end

---------------------------------------------------------------------------
-- State

local function reset_state()
	rendering.clear(script.mod_name)
	storage.turrets = {} -- [unit_number] = record
	storage.list = {}    -- array of unit_number, round-robin order
	storage.pos = {}     -- [unit_number] = index in list
	storage.cursor = 1
	storage.players = {} -- [player_index] = scan state
end

local function ensure_state()
	if not storage.list then reset_state() end
end

local function destroy_objects()
	rendering.clear(script.mod_name)
	for _, rec in pairs(storage.turrets) do
		rec.obj, rec.value, rec.level = nil, nil, nil
		rec.viewers = {}
	end
end

local function add_watch(unit, entity, player_index)
	local turrets = storage.turrets
	local rec = turrets[unit]
	if not rec then
		rec = {
			entity = entity,
			surface = entity.surface_index,
			limit = turret_limit(entity.name),
			watchers = {},
			nwatch = 0,
			viewers = {},
		}
		turrets[unit] = rec
		local list = storage.list
		list[#list + 1] = unit
		storage.pos[unit] = #list
	end
	if not rec.watchers[player_index] then
		rec.watchers[player_index] = true
		rec.nwatch = rec.nwatch + 1
	end
end

local function remove_record(unit)
	local rec = storage.turrets[unit]
	if not rec then return end
	if rec.obj then rec.obj.destroy() end
	storage.turrets[unit] = nil

	local list, pos = storage.list, storage.pos
	local i, last = pos[unit], #list
	local moved = list[last]
	list[i] = moved
	pos[moved] = i
	list[last] = nil
	pos[unit] = nil
end

local function remove_watch(unit, player_index)
	local rec = storage.turrets[unit]
	if not (rec and rec.watchers[player_index]) then return end
	rec.watchers[player_index] = nil
	rec.nwatch = rec.nwatch - 1
	if rec.nwatch <= 0 then remove_record(unit) end
end

local function drop_player(player_index)
	local ps = storage.players[player_index]
	if not ps then return end
	for unit in pairs(ps.set) do
		remove_watch(unit, player_index)
	end
	storage.players[player_index] = nil
end

-- Forces whose turrets this player may see: own force and forces that
-- consider the player's force a friend (same rule as the original mod).
local function visible_forces(player_force)
	local result = {player_force}
	local own = player_force.index
	for _, f in pairs(game.forces) do
		if f.index ~= own and f.get_friend(player_force) then
			result[#result + 1] = f
		end
	end
	return result
end

local function scan_player(ps, player, tick)
	local position = player.position
	local found = player.surface.find_entities_filtered{
		type = "ammo-turret",
		position = position,
		radius = RADIUS,
		force = visible_forces(player.force),
	}
	local pi = ps.index
	local old, new = ps.set, {}
	for i = 1, #found do
		local t = found[i]
		local unit = t.unit_number
		new[unit] = true
		if not old[unit] then add_watch(unit, t, pi) end
	end
	for unit in pairs(old) do
		if not new[unit] then remove_watch(unit, pi) end
	end
	ps.set = new
	ps.surface = player.surface_index
	ps.x, ps.y = position.x, position.y
	ps.tick = tick
end

local function check_players(tick)
	local states = storage.players
	for pi in pairs(states) do
		local p = game.get_player(pi)
		if not (p and p.connected) then drop_player(pi) end
	end
	for _, p in pairs(game.connected_players) do
		local pi = p.index
		local ps = states[pi]
		if not ps then
			ps = {index = pi, factor = player_factor(p), set = {}}
			states[pi] = ps
		end
		local rescan = not ps.tick
			or ps.surface ~= p.surface_index
			or tick - ps.tick >= RESCAN_MAX_AGE
		if not rescan then
			local pos = p.position
			local dx, dy = pos.x - ps.x, pos.y - ps.y
			rescan = dx * dx + dy * dy >= RESCAN_MOVE_SQ
		end
		if rescan then scan_player(ps, p, tick) end
	end
end

local function mark_all_for_rescan()
	for _, ps in pairs(storage.players) do ps.tick = nil end
end

---------------------------------------------------------------------------
-- Per-turret refresh

local function clear_viewers(viewers)
	for i = #viewers, 1, -1 do viewers[i] = nil end
end

local function hide(rec)
	if rec.obj then
		rec.obj.destroy()
		rec.obj = nil
	end
	rec.value, rec.level = nil, nil
	clear_viewers(rec.viewers)
end

-- Returns true when the record was removed (the list slot now holds another unit).
local function refresh(unit)
	local rec = storage.turrets[unit]
	local e = rec.entity
	if not e.valid then
		remove_record(unit)
		return true
	end

	local m, value
	if disp_mode == "shot" then
		local inv = e.get_inventory(TURRET_INV)
		m, value = 0, 0
		if inv then
			for j = 1, #inv do
				local s = inv[j]
				if s.valid_for_read then
					local c = s.count
					m = m + c
					value = value + mag_size(s.name) * (c - 1) + s.ammo
				end
			end
		end
	else
		m = e.get_item_count()
		value = m
	end

	local limit = rec.limit
	local level
	if text_mode then
		level = (m <= 1 and LEVEL_CRITICAL) or (m < limit and LEVEL_LOW) or LEVEL_NORMAL
		if level_hidden[level] then hide(rec) return false end
	elseif m >= limit then
		hide(rec)
		return false
	end

	local viewers = rec.viewers
	local players = storage.players
	local nv, viewers_changed = 0, false
	for pi in pairs(rec.watchers) do
		local ps = players[pi]
		if ps then
			local f = ps.factor
			if m == 0 or not f or m < limit * f then
				nv = nv + 1
				if viewers[nv] ~= pi then
					viewers[nv] = pi
					viewers_changed = true
				end
			end
		end
	end
	if nv == 0 then hide(rec) return false end
	for i = #viewers, nv + 1, -1 do
		viewers[i] = nil
		viewers_changed = true
	end

	local obj = rec.obj
	local value_changed = rec.value ~= value
	if obj and (value_changed or viewers_changed or rec.level ~= level) and not obj.valid then
		obj = nil
	end

	if text_mode then
		local color = level_color[level]
		if not obj then
			rec.obj = rendering.draw_text{
				text = value,
				surface = rec.surface,
				target = e,
				color = color,
				players = viewers,
				only_in_alt_mode = true,
				scale = TEXT_SCALE,
				scale_with_zoom = true,
				alignment = "center",
			}
		else
			if value_changed then obj.text = value end
			if rec.level ~= level then obj.color = color end
			if viewers_changed then obj.players = viewers end
		end
		rec.value, rec.level = value, level
		return false
	end

	-- Icon modes: m < limit here.
	if obj and not value_changed then
		if viewers_changed then obj.players = viewers end
		return false
	end
	local r = m / limit
	local scale = disp_mode == "scaled-icon" and 1 / (1 + r) or 1
	local k, tint = r * 2, nil
	if k < 1 then
		k = 1 - k
		tint = {colorbase_r + k * crit_r, colorbase_g + k * crit_g, colorbase_b + k * crit_b, (colorbase_a + crit_a) * (k / 2)}
	else
		k = k - 1
		tint = {colorbase_r + k * norm_r, colorbase_g + k * norm_g, colorbase_b + k * norm_b, (colorbase_a + norm_a) * (1 - k) / 2}
	end
	if not obj then
		rec.obj = rendering.draw_sprite{
			sprite = ICON_SPRITE,
			surface = rec.surface,
			target = e,
			tint = tint,
			x_scale = scale,
			y_scale = scale,
			players = viewers,
			render_layer = ICON_LAYER,
			use_target_orientation = false,
		}
	else
		obj.color = tint
		obj.x_scale = scale
		obj.y_scale = scale
		if viewers_changed then obj.players = viewers end
	end
	rec.value, rec.level = value, nil
	return false
end

---------------------------------------------------------------------------
-- Events

local function on_tick(event)
	ensure_state()
	local tick = event.tick
	if tick % RESCAN_CHECK_TICKS == 0 then check_players(tick) end

	local list = storage.list
	local n = #list
	if n == 0 then return end
	local c = storage.cursor
	for _ = 1, math.ceil(n / period) do
		local size = #list
		if size == 0 then break end
		if c > size then c = 1 end
		if not refresh(list[c]) then c = c + 1 end
	end
	storage.cursor = c
end

local function on_turret_built(event)
	local entity = event.entity or event.destination
	if not (entity and entity.valid) then return end
	ensure_state()
	local surface_index = entity.surface_index
	local pos = entity.position
	local unit = entity.unit_number
	local force = entity.force
	for pi, ps in pairs(storage.players) do
		if ps.tick and ps.surface == surface_index and not ps.set[unit] then
			local dx, dy = pos.x - ps.x, pos.y - ps.y
			if dx * dx + dy * dy <= RADIUS_SQ then
				local p = game.get_player(pi)
				local pf = p and p.force
				if pf and (force.index == pf.index or force.get_friend(pf)) then
					ps.set[unit] = true
					add_watch(unit, entity, pi)
				end
			end
		end
	end
end

local function on_setting_changed(event)
	local name = event.setting
	if not name or name:sub(1, #SETTING_PREFIX) ~= SETTING_PREFIX then return end
	ensure_state()
	if event.setting_type == "runtime-per-user" then
		local ps = event.player_index and storage.players[event.player_index]
		local p = ps and game.get_player(event.player_index)
		if p then ps.factor = player_factor(p) end
	else
		read_settings()
		destroy_objects()
	end
end

local function on_player_gone(event)
	ensure_state()
	drop_player(event.player_index)
end

local function on_forces_changed()
	ensure_state()
	mark_all_for_rescan()
end

local function on_player_changed_force(event)
	ensure_state()
	local ps = storage.players[event.player_index]
	if ps then ps.tick = nil end
end

script.on_init(function()
	read_settings()
	reset_state()
end)

script.on_load(read_settings)

script.on_configuration_changed(function()
	read_settings()
	limit_cache, mag_size_cache = {}, {}
	reset_state()
end)

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_setting_changed)
script.on_event(defines.events.on_player_left_game, on_player_gone)
script.on_event(defines.events.on_player_removed, on_player_gone)
script.on_event(defines.events.on_player_changed_force, on_player_changed_force)
script.on_event(defines.events.on_force_friends_changed, on_forces_changed)
script.on_event(defines.events.on_forces_merged, on_forces_changed)

local turret_filter = {{filter = "type", type = "ammo-turret"}}
script.on_event(defines.events.on_built_entity, on_turret_built, turret_filter)
script.on_event(defines.events.on_robot_built_entity, on_turret_built, turret_filter)
script.on_event(defines.events.script_raised_built, on_turret_built, turret_filter)
script.on_event(defines.events.script_raised_revive, on_turret_built, turret_filter)
script.on_event(defines.events.on_entity_cloned, on_turret_built, turret_filter)
