-- Stage 3 on warp ships (user 2026-11-07): the comfort field and its dome, demons of the four sins while it is weak
-- (only in warp sectors; they stay when it recovers), the void shield against asteroids, the red alert.
-- storage.ships[platform index] = {platform, strength, field_state, progress, generator, pressure, wave, demons,
-- dome, box, shields, tiles, breach, hit, shield_said, alert}; storage.mined_tiles[surface index] = true.
local shared = require("shared")

local M = {}

local COST_PER_HP = 25000 -- J of shield energy per asteroid health point (medium asteroid 400 HP: 10 MJ)
local HEAL_COST = 50000 -- J per point of asteroid damage taken off a building
local NEAR_HULL = 4 -- tiles: an asteroid this close to the foundation bursts on the shield
local WAVE_PRESSURE = 30 -- pressure per wave; it grows by (1 - strength) x sector danger per second
local MAX_DEMONS = 40
local HOLD = 30 * 60 -- ticks a breach or an unshielded hit keeps the alert on
local SIREN = 5 * 60
local COLOR_AUTO = {r = 0.55, g = 0.8, b = 1}
local COLOR_BAD = {r = 1, g = 0.45, b = 0.4}

local foundations
local function foundation_names()
	if not foundations then
		foundations = {}
		for name, tile in pairs(prototypes.tile) do
			if tile.is_foundation then foundations[#foundations + 1] = name end
		end
	end
	return foundations
end

local function is_foundation(surface, position)
	local tile = surface.get_tile(position.x, position.y)
	if not (tile and tile.valid) then return false end
	for _, name in ipairs(foundation_names()) do
		if tile.name == name then return true end
	end
	return false
end

local function ships()
	storage.ships = storage.ships or {}
	return storage.ships
end

local function ship_of(platform)
	local list = ships()
	local ship = list[platform.index]
	if not ship then
		ship = {platform = platform, strength = 1, pressure = 0, wave = 0, demons = {}, shields = {}}
		list[platform.index] = ship
	end
	return ship
end

local function say(platform, key, ...)
	platform.force.print({"", "[color=acid]", {"paranoidal-warp.auto"}, "[/color] ", {key, platform.name, ...}},
		{color = COLOR_AUTO})
end

local function destroy_all(list)
	for _, object in pairs(list or {}) do
		if object.valid then object.destroy() end
	end
end

-- Field ----------------------------------------------------------------------------------------------------------

-- Strength 0..1: the generator's craft rate (it slows down without enough power). Outside warp sectors it sleeps.
local function measure(ship, platform, warp)
	local generator = platform.surface.find_entities_filtered({name = shared.field, limit = 1})[1]
	if not generator then
		ship.progress, ship.generator = nil, nil
		return nil
	end
	if not warp then
		generator.disabled_by_script = true
		ship.progress = nil
		return 1
	end
	if generator.disabled_by_script then generator.disabled_by_script = false end
	local progress = generator.products_finished + generator.crafting_progress
	local last, same = ship.progress, ship.generator == generator.unit_number
	ship.progress, ship.generator = progress, generator.unit_number
	if not (last and same) then -- no measurement yet: the machine's state
		local status = generator.status
		if status == defines.entity_status.working then return 1 end
		if status == defines.entity_status.low_power then return 0.5 end
		return 0
	end
	local per_second = generator.crafting_speed / prototypes.recipe[shared.field_recipe].energy
	local strength = (progress - last) / per_second
	if strength >= 0.97 then return 1 end
	return math.max(0, math.min(1, strength))
end

-- Box around the ship's buildings (for the dome); refreshed every 10 s in warp.
local function refresh_box(ship, platform)
	local x1, y1, x2, y2
	for _, entity in pairs(platform.surface.find_entities_filtered({force = platform.force})) do
		local p = entity.position
		x1, y1 = math.min(x1 or p.x, p.x), math.min(y1 or p.y, p.y)
		x2, y2 = math.max(x2 or p.x, p.x), math.max(y2 or p.y, p.y)
	end
	if not x1 then
		local hub = platform.hub
		local p = hub and hub.valid and hub.position or {x = 0, y = 0}
		x1, y1, x2, y2 = p.x, p.y, p.x, p.y
	end
	ship.box = {x1 = x1 - 3, y1 = y1 - 3, x2 = x2 + 3, y2 = y2 + 3, tick = game.tick}
end

local function crack_lines(surface, center, radius)
	local lines = {}
	local angle = math.random() * 2 * math.pi
	local from = {x = center.x + math.cos(angle) * radius, y = center.y + math.sin(angle) * radius}
	for _ = 1, 4 do
		angle = angle + (math.random() - 0.5) * 0.9
		local length = radius * (0.08 + math.random() * 0.1)
		local to = {x = from.x - math.cos(angle) * length, y = from.y - math.sin(angle) * length}
		lines[#lines + 1] = rendering.draw_line({color = {r = 1, g = 0.35, b = 0.85, a = 0.85}, width = 3, from = from,
			to = to, surface = surface, render_layer = "air-object"})
		from = to
	end
	return lines
end

-- The dome over a ship in warp with a field generator; cracks: one per 8 % of missing strength.
local function update_dome(ship, platform, warp)
	local dome = ship.dome
	if not (warp and ship.generator) then
		if dome then
			destroy_all({dome.circle, dome.fill})
			for _, crack in pairs(dome.cracks) do destroy_all(crack) end
			ship.dome = nil
		end
		return
	end
	if not ship.box or game.tick - ship.box.tick >= 600 then refresh_box(ship, platform) end
	local box = ship.box
	local center = {x = (box.x1 + box.x2) / 2, y = (box.y1 + box.y2) / 2}
	local radius = math.sqrt((box.x2 - box.x1) ^ 2 + (box.y2 - box.y1) ^ 2) / 2 + 2
	if dome and (dome.radius ~= radius or dome.center.x ~= center.x or dome.center.y ~= center.y) then
		destroy_all({dome.circle, dome.fill})
		for _, crack in pairs(dome.cracks) do destroy_all(crack) end
		dome = nil
	end
	if not dome then
		local surface = platform.surface
		dome = {center = center, radius = radius, cracks = {},
			circle = rendering.draw_circle({color = {r = 0.35, g = 0.7, b = 1, a = 0.35}, radius = radius, width = 4,
				filled = false, target = center, surface = surface, render_layer = "air-object"}),
			fill = rendering.draw_circle({color = {r = 0.05, g = 0.12, b = 0.2, a = 0.08}, radius = radius, filled = true,
				target = center, surface = surface, render_layer = "air-object"})}
		ship.dome = dome
	end
	local wanted = math.floor((1 - ship.strength) * 12 + 0.5)
	while #dome.cracks < wanted do
		dome.cracks[#dome.cracks + 1] = crack_lines(platform.surface, dome.center, dome.radius)
	end
	while #dome.cracks > wanted do
		destroy_all(table.remove(dome.cracks))
	end
end

local function update_field(ship, platform, sector)
	local warp = sector ~= nil
	local strength = measure(ship, platform, warp)
	local state
	if strength == nil then
		strength = warp and 0 or 1
		state = warp and "none" or "home"
	elseif not warp then
		state = "home"
	elseif strength >= 0.97 then
		state = "ok"
	else
		state = "weak"
	end
	ship.strength = strength
	if state ~= ship.field_state then
		if state == "none" then
			say(platform, "paranoidal-warp.field-none")
		elseif state == "weak" then
			say(platform, "paranoidal-warp.field-weak", math.floor(strength * 100))
		elseif state == "ok" and ship.field_state ~= nil and ship.field_state ~= "home" then
			say(platform, "paranoidal-warp.field-restored")
		end
		ship.field_state = state
	end
	update_dome(ship, platform, warp)
end

-- Demons -------------------------------------------------------------------------------------------------------

local function count_demons(ship)
	local n = 0
	for id, demon in pairs(ship.demons) do
		if demon.valid then n = n + 1 else ship.demons[id] = nil end
	end
	return n
end

-- Attack the ship around one of its buildings (any building, the hub if there is nothing else).
local function hunt(demon, platform)
	local surface = platform.surface
	local targets = surface.find_entities_filtered({force = platform.force, position = demon.position, radius = 40})
	local target = #targets > 0 and targets[math.random(#targets)] or platform.hub
	if not (target and target.valid) then return end
	pcall(function()
		demon.commandable.set_command({type = defines.command.attack_area, destination = target.position, radius = 12,
			distraction = defines.distraction.by_anything})
	end)
end

local function place(ship, platform, name)
	local surface = platform.surface
	local box = ship.box
	for _ = 1, 12 do
		local point = {x = box.x1 + math.random() * (box.x2 - box.x1), y = box.y1 + math.random() * (box.y2 - box.y1)}
		local position = surface.find_non_colliding_position(name, point, 6, 0.5)
		if position and is_foundation(surface, position)
			and surface.count_entities_filtered({type = "character", position = position, radius = 6}) == 0 then
			return position
		end
	end
	return nil
end

local function spawn_wave(ship, platform, sector)
	ship.wave = ship.wave + 1
	local sin = shared.sins[math.random(#shared.sins)]
	local size = math.min(2 + ship.wave, 12) * sin.group
	if not ship.box then refresh_box(ship, platform) end
	local made = 0
	for _ = 1, size do
		if count_demons(ship) >= MAX_DEMONS then break end
		local roll, tier = math.random() / sector.danger, 1
		if ship.wave >= 6 and roll < 0.15 then tier = 3 elseif ship.wave >= 3 and roll < 0.5 then tier = 2 end
		local name = shared.demon(sin, tier)
		local position = prototypes.entity[name] and place(ship, platform, name)
		if position then
			local demon = platform.surface.create_entity({name = name, position = position, force = "enemy"})
			if demon then
				ship.demons[demon.unit_number] = demon
				hunt(demon, platform)
				made = made + 1
			end
		end
	end
	if made > 0 then say(platform, "paranoidal-warp.demons-" .. sin.id, made) end
end

local function update_demons(ship, platform, sector)
	if sector and ship.strength < 0.97 then
		ship.pressure = ship.pressure + (1 - ship.strength) * sector.danger
		if ship.pressure >= WAVE_PRESSURE then
			ship.pressure = ship.pressure - WAVE_PRESSURE
			spawn_wave(ship, platform, sector)
		end
	else
		ship.pressure = math.max(0, ship.pressure - 1)
		if game.tick % 3600 < 60 and ship.wave > 0 then ship.wave = ship.wave - 1 end
	end
	-- Demons stay aboard until killed (user 2026-11-07); every 10 s the idle ones look for a new target.
	if game.tick % 600 < 60 then
		for _, demon in pairs(ship.demons) do
			if demon.valid and not demon.commandable.has_command then hunt(demon, platform) end
		end
	end
end

-- Shield -------------------------------------------------------------------------------------------------------

local function shield_energy(ship)
	local total = 0
	for i = #ship.shields, 1, -1 do
		local shield = ship.shields[i]
		if shield.valid then total = total + shield.energy else table.remove(ship.shields, i) end
	end
	return total
end

local function drain(ship, amount)
	for _, shield in ipairs(ship.shields) do
		if amount <= 0 then return end
		local take = math.min(shield.energy, amount)
		shield.energy = shield.energy - take
		amount = amount - take
	end
end

local function flash(surface, position, radius)
	rendering.draw_circle({color = {r = 0.5, g = 0.75, b = 1, a = 0.7}, radius = radius, width = 3, filled = false,
		target = position, surface = surface, time_to_live = 12, render_layer = "air-object"})
	rendering.draw_circle({color = {r = 0.3, g = 0.5, b = 1, a = 0.35}, radius = radius * 0.7, filled = true,
		target = position, surface = surface, time_to_live = 8, render_layer = "air-object"})
end

-- Every 5 ticks: asteroids near the hull of a ship with charged shields burst on the shield.
function M.shield_scan()
	for _, ship in pairs(ships()) do
		local platform = ship.platform
		if platform.valid and #ship.shields > 0 then
			local energy = shield_energy(ship)
			local surface = platform.surface
			local names = foundation_names()
			for _, asteroid in pairs(surface.find_entities_filtered({type = "asteroid"})) do
				if asteroid.valid and surface.count_tiles_filtered({position = asteroid.position, radius = NEAR_HULL,
					name = names, limit = 1}) > 0 then
					local cost = asteroid.health * COST_PER_HP
					if energy < cost then
						if not ship.shield_said then
							ship.shield_said = true
							say(platform, "paranoidal-warp.shield-empty")
						end
						break
					end
					drain(ship, cost)
					energy = energy - cost
					flash(surface, asteroid.position, math.max(1.5, asteroid.get_radius() + 1))
					asteroid.destroy()
				end
			end
		end
	end
end

-- An asteroid hit on a building: the shield takes it off while it has energy, otherwise it counts for the alert.
function M.on_damaged(event)
	local cause, entity = event.cause, event.entity
	if not (cause and cause.valid and cause.type == "asteroid" and entity.valid) then return end
	local platform = entity.surface.platform
	if not platform then return end
	local ship = ship_of(platform)
	local cost = event.final_damage_amount * HEAL_COST
	if event.final_health > 0 and #ship.shields > 0 and shield_energy(ship) >= cost then
		drain(ship, cost)
		entity.health = entity.health + event.final_damage_amount
		flash(entity.surface, entity.position, 2)
	else
		ship.hit = game.tick
	end
end

function M.on_tile_mined(event)
	storage.mined_tiles = storage.mined_tiles or {}
	storage.mined_tiles[event.surface_index] = true
end

-- Alert --------------------------------------------------------------------------------------------------------

local function update_breach(ship, platform)
	local surface = platform.surface
	local count = surface.count_tiles_filtered({name = foundation_names()})
	local mined = storage.mined_tiles and storage.mined_tiles[surface.index]
	if ship.tiles and count < ship.tiles and not mined then
		ship.breach = game.tick
		say(platform, "paranoidal-warp.breach", ship.tiles - count)
	end
	ship.tiles = count
	if storage.mined_tiles then storage.mined_tiles[surface.index] = nil end
end

local function alert_reasons(ship)
	local reasons = {}
	if count_demons(ship) > 0 then reasons[#reasons + 1] = "demons" end
	if ship.breach and game.tick - ship.breach < HOLD then reasons[#reasons + 1] = "breach" end
	if ship.hit and game.tick - ship.hit < HOLD then reasons[#reasons + 1] = "hit" end
	return reasons
end

local function update_alert(ship, platform)
	local reasons = alert_reasons(ship)
	local alert = ship.alert
	if #reasons == 0 then
		if alert then
			destroy_all({alert.rect, alert.light})
			ship.alert = nil
			say(platform, "paranoidal-warp.alert-off")
		end
		return
	end
	if not ship.box or game.tick - ship.box.tick >= 600 then refresh_box(ship, platform) end
	local box = ship.box
	if not alert then
		local surface = platform.surface
		local hub = platform.hub
		alert = {said = {}, siren = 0,
			rect = rendering.draw_rectangle({color = {r = 0.35, g = 0, b = 0, a = 0.2}, filled = true,
				left_top = {box.x1, box.y1}, right_bottom = {box.x2, box.y2}, surface = surface, render_layer = "air-object"}),
			light = hub and hub.valid and rendering.draw_light({sprite = "utility/light_medium", scale = 30, intensity = 0.8,
				color = {r = 1, g = 0.1, b = 0.1}, target = hub, surface = surface}) or nil}
		ship.alert = alert
	else
		alert.rect.left_top = {box.x1, box.y1}
		alert.rect.right_bottom = {box.x2, box.y2}
	end
	for _, reason in ipairs(reasons) do
		if not alert.said[reason] then
			alert.said[reason] = true
			say(platform, "paranoidal-warp.alert-" .. reason)
		end
	end
	if game.tick >= alert.siren then
		alert.siren = game.tick + SIREN
		local hub = platform.hub
		platform.surface.play_sound({path = shared.alert_sound,
			position = hub and hub.valid and hub.position or {(box.x1 + box.x2) / 2, (box.y1 + box.y2) / 2}})
	end
end

-- Cycles -------------------------------------------------------------------------------------------------------

-- Every second: every platform with a hub.
function M.update()
	local seen = {}
	for _, force in pairs(game.forces) do
		for _, platform in pairs(force.platforms) do
			if platform.valid and platform.surface and platform.hub and platform.hub.valid then
				seen[platform.index] = true
				local ship = ship_of(platform)
				ship.platform = platform
				ship.shields = platform.surface.find_entities_filtered({name = shared.shield})
				if ship.shield_said then
					local capacity = 0
					for _, shield in pairs(ship.shields) do capacity = capacity + shield.electric_buffer_size end
					if shield_energy(ship) >= 0.5 * capacity then ship.shield_said = false end
				end
				local sector = shared.sector_of_platform(platform)
				update_field(ship, platform, sector)
				update_demons(ship, platform, sector)
				update_breach(ship, platform)
				update_alert(ship, platform)
			end
		end
	end
	for index, ship in pairs(ships()) do
		if not seen[index] then
			if ship.dome then
				destroy_all({ship.dome.circle, ship.dome.fill})
				for _, crack in pairs(ship.dome.cracks) do destroy_all(crack) end
			end
			if ship.alert then destroy_all({ship.alert.rect, ship.alert.light}) end
			ships()[index] = nil
		end
	end
end

-- Every 10 ticks: the dome shimmers, the alert pulses.
function M.animate()
	local t = game.tick / 60
	for _, ship in pairs(ships()) do
		local dome = ship.dome
		if dome and dome.circle.valid then
			local a = 0.28 + 0.1 * math.sin(t * 1.7) * (0.5 + ship.strength / 2)
			dome.circle.color = {r = 0.35, g = 0.7, b = 1, a = a * (0.4 + 0.6 * ship.strength)}
		end
		local alert = ship.alert
		if alert and alert.rect.valid then
			alert.rect.color = {r = 0.35, g = 0, b = 0, a = 0.12 + 0.12 * (0.5 + 0.5 * math.sin(t * 4))}
		end
	end
end

-- For the drive: a warning when the ship jumps into a sector without a comfort field.
function M.has_field(platform)
	return platform.surface.count_entities_filtered({name = shared.field, limit = 1}) > 0
end

-- For automated tests (remote interface).
function M.status(index)
	local ship = ships()[index]
	if not ship then return nil end
	local reasons = alert_reasons(ship)
	return {strength = ship.strength, field_state = ship.field_state, pressure = ship.pressure, wave = ship.wave,
		demons = count_demons(ship), alert = ship.alert ~= nil, reasons = reasons, shield = shield_energy(ship),
		dome = ship.dome ~= nil, cracks = ship.dome and #ship.dome.cracks or 0, tiles = ship.tiles}
end

return M
