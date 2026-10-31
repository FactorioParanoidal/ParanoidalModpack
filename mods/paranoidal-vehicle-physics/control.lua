-- Paranoidal Vehicle Physics: one control script for three former mods.
--   physics  — drift, tire marks, dust and sounds of driven cars (vehicle_physics 2.0.4, OwnlyMe);
--   snap     — the driving angle snaps to fixed angles (VehicleSnap 2.0.3, Zaflis);
--   shields  — hit effect when an equipment shield absorbs damage (Shield-FX 2.0.1, OwnlyMe).
-- Within a tick the parts run in the old mod order: snap, physics, shields.
-- on_tick is registered only while something needs it. The decision is derived from storage alone, so every
-- peer registers the same handlers in on_load. Local caches below hold only prototype/setting data.

local abs, floor, min, max, sin, sqrt, atan2, pi, random =
	math.abs, math.floor, math.min, math.max, math.sin, math.sqrt, math.atan2, math.pi, math.random

local SNAP_SETTING = "VehicleSnap_amount"
local SNAP_SHORTCUT = "VehicleSnap-shortcut"
local SNAP_INPUT = "VehicleSnap-toggle"
local SHIELD_SETTING = "SFX_alternate_effect"

-- Vehicles the drift physics leaves alone (hovercraft and raven mods of the original author).
local EXCLUSIONS = {
	["raven2-1"] = true,
	["raven2-2"] = true,
	["raven2-shadow"] = true,
	["hcraft-entity"] = true,
	["ecraft-entity"] = true,
	["mcraft-entity"] = true,
	["lcraft-entity"] = true,
	["hovercraft"] = true,
	["electric-hovercraft"] = true,
	["missile-hovercraft"] = true,
	["laser-hovercraft"] = true,
}

-- Odd rail angles used when snapping to 16 directions; 0.07405 is the measured rail wagon offset.
local RAIL = 0.07405
local RAIL_AXES = {RAIL, 0.25 - RAIL, 0.25 + RAIL, 0.5 - RAIL, 0.5 + RAIL, 0.75 - RAIL, 0.75 + RAIL, 1.0 - RAIL}

local ZERO = {x = 0, y = 0}

---------------------------------------------------------------------------------------------------
-- Prototype caches (identical on every peer)

local flycar_cache = {}
local function is_flycar(name)
	local flycar = flycar_cache[name]
	if flycar == nil then
		local mask = prototypes.entity[name].collision_mask
		flycar = not (mask and mask.layers and mask.layers["player"])
		flycar_cache[name] = flycar
	end
	return flycar
end

local friction_cache = {}
local function tile_friction(tile)
	local name = tile.name
	local friction = friction_cache[name]
	if friction == nil then
		friction = tile.prototype.vehicle_friction_modifier
		friction_cache[name] = friction
	end
	return friction
end

-- Names of tiles with friction <= 0.9 ("hard surface"): one count call instead of reading every tile around.
local hard_tiles
local function hard_tile_names()
	if not hard_tiles then
		hard_tiles = {}
		for name, tile in pairs(prototypes.tile) do
			if tile.vehicle_friction_modifier <= 0.9 then hard_tiles[#hard_tiles + 1] = name end
		end
	end
	return hard_tiles
end

local dusty_cache = {}
local function is_dusty(name)
	local dusty = dusty_cache[name]
	if dusty == nil then
		dusty = (name:find("sand", 1, true) or name:find("desert", 1, true) or name:find("dirt", 1, true)) ~= nil
		dusty_cache[name] = dusty
	end
	return dusty
end

local alternate_shield = true
local function read_settings()
	alternate_shield = settings.global[SHIELD_SETTING].value
end

---------------------------------------------------------------------------------------------------
-- Geometry

local function projection(orientation, distance, position)
	position = position or ZERO
	distance = distance or 0 -- a character has no speed
	return {
		x = sin(orientation * 2 * pi) * distance + position.x,
		y = sin((orientation + 0.75) * 2 * pi) * distance + position.y,
	}
end

local function orientation_from_coords(x, y)
	return (atan2(x, y) / pi / 2 - 0.5) * -1
end

local function distance(a, b)
	local dx, dy = a.x - b.x, a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

local function wrap(change)
	if change < -0.5 then return change + 1 elseif change > 0.5 then return change - 1 end
	return change
end

---------------------------------------------------------------------------------------------------
-- Tick registration

local on_tick
local ticking = false

local function refresh_tick()
	local needed = (next(storage.cars) or next(storage.tanks) or next(storage.pending)
		or next(storage.snapping) or next(storage.shields)) ~= nil
	if needed ~= ticking then
		ticking = needed
		script.on_event(defines.events.on_tick, needed and on_tick or nil)
	end
end

---------------------------------------------------------------------------------------------------
-- Snap

local function snap_data(player)
	local data = storage.snap[player.index]
	if not data then
		data = {enabled = true, amount = player.mod_settings[SNAP_SETTING].value, ticks = 0, last = 0}
		storage.snap[player.index] = data
	end
	return data
end

-- Snapping runs for a connected player who sits in a car with snapping on.
local function recheck_snap(player)
	local data = snap_data(player)
	local vehicle = player.connected and player.vehicle
	if data.enabled and vehicle and vehicle.type == "car" then
		storage.snapping[player.index] = true
	else
		storage.snapping[player.index] = nil
	end
end

local function angle_dist(a, b)
	local d = abs(a - b)
	if d >= 1.0 then d = d - 1.0 end
	return d
end

local function snap_tick()
	local snap, snapping = storage.snap, storage.snapping
	for index in pairs(snapping) do
		local player = game.get_player(index)
		local data = snap[index]
		local vehicle = player and player.connected and data and data.enabled and player.vehicle
		if not vehicle then
			-- Keep the entry while the player only looks away (remote view, god mode of other mods).
			if not (player and player.connected and data and data.enabled)
				or player.controller_type == defines.controllers.character then
				snapping[index] = nil
			end
		else
			local driver = vehicle.get_driver()
			-- Only the driver steers; a passenger's own snap setting no longer turns the car.
			if (driver == player.character or driver == player) and abs(vehicle.speed) > 0.03 then
				local o = vehicle.orientation
				-- The player is turning: wait until the angle has been steady for a few updates.
				if abs(o - data.last) < 0.001 then
					if data.ticks > 1 then
						local amount = data.amount
						local target
						if amount == 16 then
							target = floor(o * 8.0 + 0.5) / 8.0
							local nearest = angle_dist(o, target)
							for i = 1, 8 do
								local d = angle_dist(o, RAIL_AXES[i])
								if d < nearest then
									nearest = d
									target = RAIL_AXES[i]
								end
							end
						else
							target = floor(o * amount + 0.5) / amount
						end
						o = (o * 4.0 + target) * 0.2 -- 80 % current, 20 % target
						vehicle.orientation = o
					else
						data.ticks = data.ticks + 1
					end
				else
					data.ticks = 0
				end
				data.last = o
			end
		end
	end
end

local function toggle_snap(event)
	local player = game.get_player(event.player_index)
	if not player then return end
	local data = snap_data(player)
	data.enabled = not data.enabled
	player.set_shortcut_toggled(SNAP_SHORTCUT, data.enabled)
	player.create_local_flying_text{
		text = data.enabled and {"description.VehicleSnap_enable"} or {"description.VehicleSnap_disable"},
		position = player.position,
	}
	recheck_snap(player)
	refresh_tick()
end

local function setup_player(player)
	local data = snap_data(player)
	data.amount = player.mod_settings[SNAP_SETTING].value
	player.set_shortcut_toggled(SNAP_SHORTCUT, data.enabled)
	recheck_snap(player)
end

---------------------------------------------------------------------------------------------------
-- Physics

local function forget_vehicle(unit)
	storage.cars[unit] = nil
	storage.tanks[unit] = nil
	storage.pending[unit] = nil
	storage.sound_tick[unit] = nil
end

-- A car joins the physics one tick after its driver enters (as in vehicle_physics); a tank only raises dust.
local function track_vehicle(entity, tick)
	if not (entity and entity.valid and entity.type == "car") or EXCLUSIONS[entity.name] then return end
	local unit = entity.unit_number
	if not entity.get_driver() then
		forget_vehicle(unit)
	elseif not storage.cars[unit] then
		if entity.name:find("tank", 1, true) then
			storage.tanks[unit] = entity
		else
			storage.pending[unit] = {entity = entity, tick = tick + 1}
		end
	end
end

local function start_car(entity)
	local position = entity.position
	local speed = entity.speed
	storage.cars[entity.unit_number] = {
		entity = entity,
		drift = speed ~= 0 and projection(entity.orientation, speed) or {x = 0, y = 0},
		position = position,
		last_pos = position,
		idle_ticks = 0,
		orientation = entity.orientation,
		last_speed = speed,
	}
end

local function make_tire_mark(surface, position, speed, unit, tick)
	if tile_friction(surface.get_tile(position.x, position.y)) > 0.9 then return end
	surface.create_entity{name = "drifting-tire-marks", position = position}
	local sound_tick = storage.sound_tick
	if (sound_tick[unit] or 0) + 12 < tick then
		sound_tick[unit] = tick
		surface.play_sound{
			path = "vehphy-squeel-" .. random(3),
			volume_modifier = max(0.4, min(0.8, abs(speed) ^ 0.4 * 1.2)) * 0.7,
			position = position,
		}
	end
end

local function tire_marks(surface, pos, last_pos, orientation, speed, unit, tick)
	local o1, o2 = (orientation + 0.4) % 1, (orientation + 0.6) % 1
	local temp_y = pos.y + 0.1
	local last_x, last_y = last_pos.x + 0.05, last_pos.y + 0.1
	local dist = distance(last_pos, pos)
	if dist > 0.35 then
		local a = {x = (pos.x + last_x * 2) / 3, y = (temp_y + last_y * 2) / 3}
		local b = {x = (pos.x * 2 + last_x) / 3, y = (temp_y * 2 + last_y) / 3}
		make_tire_mark(surface, projection(o1, 1.2, a), speed, unit, tick)
		make_tire_mark(surface, projection(o2, 1.2, a), speed, unit, tick)
		make_tire_mark(surface, projection(o1, 1.2, b), speed, unit, tick)
		make_tire_mark(surface, projection(o2, 1.2, b), speed, unit, tick)
	elseif dist > 0.2 then
		local a = {x = (pos.x + last_x) / 2, y = (temp_y + last_y + 0.1) / 2}
		make_tire_mark(surface, projection(o1, 1.2, a), speed, unit, tick)
		make_tire_mark(surface, projection(o2, 1.2, a), speed, unit, tick)
	end
	if dist > 0.05 then
		local a = {x = pos.x + 0.05, y = temp_y}
		make_tire_mark(surface, projection(o1, 1.2, a), speed, unit, tick)
		make_tire_mark(surface, projection(o2, 1.2, a), speed, unit, tick)
	end
end

local braking = defines.riding.acceleration.braking
local straight = defines.riding.direction.straight

local function tanks_tick(tick)
	local tanks = storage.tanks
	for unit, entity in pairs(tanks) do
		if entity.valid then
			local speed = abs(entity.speed)
			if (speed > 0.08 and tick % max(1, min(10, floor(2 / speed))) == 0)
				or (speed < 0.08 and tick % 5 == 1 and entity.riding_state.direction ~= straight) then
				local pos = entity.position
				local surface = entity.surface
				if is_dusty(surface.get_tile(pos.x, pos.y).name) then
					surface.create_trivial_smoke{name = "hover-smoke", position = {pos.x, pos.y + 0.04}}
				end
			end
		else
			forget_vehicle(unit)
		end
	end
end

local function car_step(unit, car, tick)
	local entity = car.entity
	local speed = entity.speed
	local original_speed = speed
	local flycar = is_flycar(entity.name)
	-- The engine stopped the car (collision): put it back where the physics had it.
	if speed == 0 and car.last_speed ~= 0 and not flycar then
		entity.teleport(car.last_pos or entity.position)
		car.position = car.last_pos
		car.drift = {x = 0, y = 0}
	end

	local pos = entity.position
	if speed == 0 then car.idle_ticks = car.idle_ticks + 1 else car.idle_ticks = 0 end

	if car.idle_ticks < 50 then
		local surface = entity.surface
		local movement_x = pos.x - car.position.x
		local movement_y = pos.y - car.position.y
		local old_drift = car.drift
		local is_braking = entity.riding_state.acceleration == braking
		local orientation = entity.orientation

		local mult = 0.865
		if flycar then
			mult = is_braking and 0.97 or 0.95
		elseif is_braking then
			mult = 0.95
		end
		local drift_x = movement_x * (1 - mult) + old_drift.x * mult
		local drift_y = movement_y * (1 - mult) + old_drift.y * mult

		local hard_ground = false
		local no_tire_marks = false
		-- A standing car needs no tile scan: the result only matters for braking/drift.
		if not flycar and speed ~= 0 then
			local names = hard_tile_names()
			hard_ground = #names > 0
				and surface.count_tiles_filtered{position = pos, radius = 1.5, name = names, limit = 1} > 0
			if hard_ground then
				local idle = car.idle_ticks
				mult = min(0.95, max(0, 0.6 + max(0, 0.7 - abs(speed)) * 0.5 - idle * 0.02))
				if is_braking then
					local drift_orientation = orientation_from_coords(old_drift.x, old_drift.y)
					local difference
					if speed >= 0 then
						difference = abs(drift_orientation - orientation)
					else
						difference = abs(drift_orientation - (orientation + 0.5) % 1)
					end
					if difference > 0.971 then
						if speed < 0 then
							speed = min(0, speed + 0.003)
						elseif speed > 0 then
							speed = max(0, speed - 0.003)
						end
						no_tire_marks = true
					elseif difference < 0.029 then
						speed = speed - 0.004 -- better than vanilla braking on asphalt
						no_tire_marks = true
					else
						mult = min(0.95, max(0, 0.6 + max(0, 0.7 - abs(speed)) * 0.5 - idle * 0.02 + abs(speed) * 0.45))
					end
				end
				drift_x = movement_x * (1 - mult) + old_drift.x * mult
				drift_y = movement_y * (1 - mult) + old_drift.y * mult
			end
		end

		if not is_braking then
			local manoeuvrability = max(0.4, 0.2 + 0.9 - abs(speed) / (flycar and 3 or 1.5))
			orientation = orientation - wrap(orientation - car.orientation) * (1 - manoeuvrability)
			entity.orientation = orientation
		elseif not flycar then
			local manoeuvrability = 0.3 - abs(speed) / 1.5
			if hard_ground then
				orientation = orientation + wrap(orientation - car.orientation) * (manoeuvrability / 4)
				entity.orientation = orientation
				if not no_tire_marks then
					tire_marks(surface, pos, car.last_pos, orientation, speed, unit, tick)
				end
			else
				orientation = orientation + wrap(orientation - car.orientation) * (manoeuvrability / 6)
				entity.orientation = orientation
				local sound_tick = storage.sound_tick
				if (sound_tick[unit] or 0) + 12 < tick then
					sound_tick[unit] = tick
					surface.play_sound{
						path = "vehphy-dirt",
						volume_modifier = max(0.2, min(0.8, abs(speed) ^ 0.4 * 1.2)) * 0.75,
						position = pos,
					}
				end
			end
		end
		car.orientation = orientation
		car.last_pos = pos

		if sqrt(drift_x * drift_x + drift_y * drift_y) > 0.001 then
			local new_pos = {x = car.position.x + drift_x, y = car.position.y + drift_y}
			local slide = distance(pos, new_pos) * 0.01
			if speed > 0 then
				speed = max(0, speed - slide)
			elseif speed < 0 then
				speed = min(0, speed + slide)
			end
			if not flycar and tick % 4 == 2 and not hard_ground then
				surface.create_trivial_smoke{name = "hover-smoke", position = pos}
			end
			entity.teleport(new_pos)
			car.drift = {x = drift_x, y = drift_y}
		else
			car.drift = {x = movement_x * 0.9 + drift_x * 0.1, y = movement_y * 0.9 + drift_y * 0.1}
		end

		-- Sliding sideways costs speed.
		local skew = orientation_from_coords(drift_x, drift_y) - orientation
		if skew > 0.7 then skew = skew - 1 elseif skew < -0.7 then skew = skew + 1 end
		speed = speed * (1 - max(0, abs(skew) - 0.1) / 5)
		if speed < original_speed - 0.003 then
			entity.speed = speed + 0.003
		end
	else
		car.drift = {x = 0, y = 0}
		car.last_pos = pos
	end
	car.position = entity.position
	car.last_speed = speed
end

local function cars_tick(tick)
	local cars = storage.cars
	for unit, car in pairs(cars) do
		if car.entity.valid then
			car_step(unit, car, tick)
		else
			forget_vehicle(unit)
		end
	end
end

local function pending_tick(tick)
	local pending = storage.pending
	for unit, entry in pairs(pending) do
		if tick >= entry.tick then
			pending[unit] = nil
			local entity = entry.entity
			-- The driver may have left during the wait.
			if entity.valid and entity.get_driver() and not storage.cars[unit] then start_car(entity) end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Shields

local function is_tank(entity)
	return entity.name:find("tank", 1, true) ~= nil
end

local function on_entity_damaged(event)
	-- The effect is shown only when the shield absorbed the whole hit (Shield-FX behaviour).
	if event.final_damage_amount > 0 then return end
	local entity = event.entity
	local kind = entity.type
	if kind ~= "character" and kind ~= "car" and kind ~= "spider-vehicle" then return end
	local grid = entity.grid
	if not grid then return end
	local shield = grid.shield
	-- Shield-FX also compared the shield with a threshold and with the damage; with the damage fully absorbed
	-- (zero) that comparison is always true, so only the live-owner check remains.
	if shield < 0.1 or shield == grid.max_shield or entity.health <= 0 then return end

	local tick = event.tick
	local surface = entity.surface
	local position = projection(entity.orientation, entity.speed, entity.position)
	local tank = kind == "car" and is_tank(entity)
	local effect = (tank or kind == "spider-vehicle") and "-big" or ""
	local unit = entity.unit_number
	local record = storage.shields[unit]
	if not record then
		record = {entity = entity}
		storage.shields[unit] = record
		refresh_tick()
	end

	if alternate_shield then
		if record.tick == nil or record.tick < tick - 5 then
			local previous = record.effect
			if previous and previous.valid then
				effect = effect .. "2"
				previous.destroy()
			end
			if kind == "car" then
				if tank then
					position.y = position.y - 0.4
					position.x = position.x - 0.16
				end
				position.y = position.y + 0.42
			elseif kind == "spider-vehicle" then
				position.y = position.y - 1.1
			else
				position.y = position.y - 0.2
			end
			record.effect = surface.create_entity{
				name = "shield-effect-alternate" .. effect,
				position = {position.x - 0.06, position.y - 0.5},
				force = "neutral",
			}
			record.tick = tick
		end
	else
		record.trail = true
		record.tick = tick
		if kind == "car" then
			position.y = position.y + 0.3
			if tank then
				position.y = position.y - 0.31
				position.x = position.x - 0.2
			end
		elseif kind == "spider-vehicle" then
			position.y = position.y - 1.1
		else
			position.y = position.y - 0.2
		end
		local smoke = {name = "shield-effect" .. effect, position = {position.x, position.y - 0.48}}
		surface.create_trivial_smoke(smoke)
		surface.create_trivial_smoke(smoke)
	end
end

-- The alternate effect follows its owner; the default effect leaves a short trail for 7 ticks.
local function shields_tick(tick)
	local shields = storage.shields
	for unit, record in pairs(shields) do
		local entity, effect = record.entity, record.effect
		local alive = entity.valid
		if alive and effect and effect.valid then
			local pos = projection(entity.orientation, entity.speed, entity.position)
			local kind = entity.type
			if kind == "car" then
				if is_tank(entity) then
					effect.teleport({pos.x - 0.22, pos.y - 0.48})
				else
					effect.teleport({pos.x - 0.06, pos.y - 0.08})
				end
			elseif kind == "spider-vehicle" then
				effect.teleport({pos.x, pos.y - 1.58})
			else
				effect.teleport({pos.x - 0.06, pos.y - 0.7})
			end
		elseif alive and not alternate_shield and record.trail and record.tick > tick - 7 then
			local pos = projection(entity.orientation, entity.speed, entity.position)
			local kind = entity.type
			local surface = entity.surface
			if kind == "car" then
				if is_tank(entity) then
					surface.create_trivial_smoke{name = "shield-effect-big", position = {pos.x - 0.2, pos.y - 0.5}}
				else
					surface.create_trivial_smoke{name = "shield-effect", position = {pos.x, pos.y - 0.18}}
				end
			elseif kind == "spider-vehicle" then
				surface.create_trivial_smoke{name = "shield-effect-big", position = {pos.x, pos.y - 1.7}}
			else
				surface.create_trivial_smoke{name = "shield-effect", position = {pos.x, pos.y - 0.8}}
			end
		else
			-- The owner is gone: do not leave its effect floating.
			if not alive and effect and effect.valid then effect.destroy() end
			shields[unit] = nil
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Events

on_tick = function(event)
	local tick = event.tick
	if tick % 2 == 0 and next(storage.snapping) then snap_tick() end -- VehicleSnap ran every 2nd tick
	if next(storage.tanks) then tanks_tick(tick) end
	if next(storage.cars) then cars_tick(tick) end
	if next(storage.pending) then pending_tick(tick) end
	if next(storage.shields) then shields_tick(tick) end
	refresh_tick()
end

local function init_storage()
	storage.cars = storage.cars or {}
	storage.tanks = storage.tanks or {}
	storage.pending = storage.pending or {}
	storage.sound_tick = storage.sound_tick or {}
	storage.snap = storage.snap or {}
	storage.snapping = storage.snapping or {}
	storage.shields = storage.shields or {}
	storage.version = 1
end

-- Rebuilds everything that can be derived from the game: players who already drive, snap settings, shortcuts.
local function rebuild()
	init_storage()
	read_settings()
	for unit, car in pairs(storage.cars) do
		if not car.entity.valid or EXCLUSIONS[car.entity.name] then forget_vehicle(unit) end
	end
	for unit, entity in pairs(storage.tanks) do
		if not entity.valid or EXCLUSIONS[entity.name] then forget_vehicle(unit) end
	end
	for _, player in pairs(game.players) do
		setup_player(player)
		local vehicle = player.vehicle
		if vehicle then track_vehicle(vehicle, game.tick) end
	end
	refresh_tick()
end

script.on_init(rebuild)
script.on_configuration_changed(rebuild)
script.on_load(function()
	read_settings()
	refresh_tick()
end)

script.on_event(defines.events.on_player_driving_changed_state, function(event)
	local player = game.get_player(event.player_index)
	if player then recheck_snap(player) end
	track_vehicle(event.entity, event.tick)
	refresh_tick()
end)

local function recheck_event(event)
	local player = game.get_player(event.player_index)
	if player then
		recheck_snap(player)
		refresh_tick()
	end
end
script.on_event({
	defines.events.on_player_changed_surface,
	defines.events.on_player_died,
	defines.events.on_player_joined_game,
	defines.events.on_player_left_game,
	defines.events.on_player_controller_changed,
}, recheck_event)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if player then setup_player(player) end
end)

script.on_event(defines.events.on_player_removed, function(event)
	storage.snap[event.player_index] = nil
	storage.snapping[event.player_index] = nil
	refresh_tick()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == SNAP_SETTING then
		local player = event.player_index and game.get_player(event.player_index)
		if player then snap_data(player).amount = player.mod_settings[SNAP_SETTING].value end
	elseif event.setting == SHIELD_SETTING then
		read_settings()
	end
end)

script.on_event(SNAP_INPUT, toggle_snap)
script.on_event(defines.events.on_lua_shortcut, function(event)
	if event.prototype_name == SNAP_SHORTCUT then toggle_snap(event) end
end)

script.on_event(defines.events.on_entity_damaged, on_entity_damaged,
	{{filter = "vehicle"}, {filter = "type", type = "character"}})
