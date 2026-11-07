-- Stage 5 (ПР-077 concept, act I): the first rocket a force launches tears the sky over the silo. A violet rift opens
-- where the rocket went up, with flashes and thunder; AUTO speaks about directive A113; a fragment of the bridge of the
-- Axiom-7 falls out of the rift next to the silo (a wreck with a space platform starter pack inside); the rift closes.
-- Players near the silo watch it in a short cutscene (they may skip it). Home stays quiet: no demons (user 2026-11-07:
-- demons only in warp sectors); no victory screen (user: not now).
-- storage.rift_done[force index] = true once the scene played for the force (in a save from before this version: the
-- next launch); storage.rifts[id] = a running scene; storage.rift_last[force index] = what the last scene left (tests).
local shared = require("shared")

local M = {}

local HEIGHT = 14 -- tiles north of the silo where the rift opens
local LENGTH = 16 -- full length of the tear
local SEGMENTS = 12
local OPEN = 120 -- ticks of opening
local FALL_START, FALL = 300, 90 -- the fragment falls out of the rift and lands
local CLOSE_START, CLOSE = 600, 120
local ENDS = 760
local LANDING_MIN, LANDING_MAX = 22, 34 -- tiles from the silo
local CAMERA_RADIUS = 500 -- players farther away only hear it and read the chat
local STARTER = "space-platform-starter-pack"
local COLOR_AUTO = {r = 0.55, g = 0.8, b = 1}
local LAYERS = { -- half-width, colour of the tear (outer glow, body, core)
	{width = 2.6, color = {r = 0.32, g = 0.05, b = 0.55, a = 0.55}},
	{width = 1.4, color = {r = 0.62, g = 0.22, b = 0.95, a = 0.8}},
	{width = 0.45, color = {r = 1, g = 0.85, b = 1, a = 0.95}},
}

local function scenes()
	storage.rifts = storage.rifts or {}
	return storage.rifts
end

local function say(force, key, ...)
	force.print({"", "[color=acid]", {"paranoidal-warp.auto"}, "[/color] ", {key, ...}}, {color = COLOR_AUTO})
end

local function destroy(object)
	if object and object.valid then object.destroy() end
end

local function in_sandbox(silo)
	return silo.surface.name:find("^bpsb%-lab%-") ~= nil or silo.force.name:find("^bpsb%-sb%-") ~= nil
end

-- Vertices of the tear as a triangle strip: a jagged line, open by `open` (0..1), half-width scaled by `width`.
local function vertices(scene, half_width, open)
	local list = {}
	local c = scene.center
	for i = 0, SEGMENTS do
		local t = i / SEGMENTS
		local x = c.x + scene.jag[i + 1] * open
		local y = c.y + (t - 0.5) * LENGTH * open
		local w = math.max(0.03, half_width * open * math.sin(math.pi * t))
		list[#list + 1] = {x = x - w, y = y}
		list[#list + 1] = {x = x + w, y = y}
	end
	return list
end

local function shape(scene, open)
	for i, layer in ipairs(LAYERS) do
		local polygon = scene.tear[i]
		if polygon and polygon.valid then polygon.vertices = vertices(scene, layer.width, open) end
	end
	if scene.halo and scene.halo.valid then
		scene.halo.x_scale = 6 * open + 0.1
		scene.halo.y_scale = 12 * open + 0.1
	end
end

-- A lightning bolt out of the tear: a short jagged line that lives a few ticks.
local function bolt(scene)
	local c = scene.center
	local from = {x = c.x + (math.random() - 0.5) * 2, y = c.y + (math.random() - 0.5) * LENGTH * 0.8}
	local angle = math.random() * 2 * math.pi
	local ttl = math.random(6, 12)
	for _ = 1, 4 do
		angle = angle + (math.random() - 0.5) * 1.2
		local length = 1.2 + math.random() * 1.8
		local to = {x = from.x + math.cos(angle) * length, y = from.y + math.sin(angle) * length}
		rendering.draw_line({color = {r = 0.95, g = 0.8, b = 1, a = 1}, width = 2 + math.random(2), from = from, to = to,
			surface = scene.surface, time_to_live = ttl, render_layer = "air-object"})
		from = to
	end
end

local function flash(surface, center, strength)
	for _, step in ipairs({{0.6, 8}, {0.3, 20}, {0.12, 40}}) do
		local a = step[1] * strength
		rendering.draw_rectangle({color = {r = 0.75 * a, g = 0.5 * a, b = a, a = a}, filled = true,
			left_top = {center.x - 120, center.y - 80}, right_bottom = {center.x + 120, center.y + 80},
			surface = surface, time_to_live = step[2], render_layer = "cursor"})
	end
end

local function sound(surface, path)
	surface.play_sound({path = path})
end

-- Where the fragment lands: 22-34 tiles from the silo in a random direction, on free ground.
local function landing(silo)
	local surface, p = silo.surface, silo.position
	for _ = 1, 8 do
		local angle = math.random() * 2 * math.pi
		local distance = LANDING_MIN + math.random() * (LANDING_MAX - LANDING_MIN)
		local point = {x = p.x + math.cos(angle) * distance, y = p.y + math.sin(angle) * distance}
		local position = surface.find_non_colliding_position(shared.fragment, point, 8, 0.5)
		if position then return position end
	end
	return surface.find_non_colliding_position(shared.fragment, p, 60, 1)
		or {x = p.x + LANDING_MIN, y = p.y}
end

local function cutscene(scene, silo)
	local watchers = {}
	local mid = {x = (scene.center.x + scene.landing.x) / 2, y = (scene.center.y + scene.landing.y) / 2}
	for _, player in pairs(game.connected_players) do
		local p = player.position
		local character = player.character
		if player.surface == silo.surface and player.controller_type == defines.controllers.character
			and character and character.valid and not player.driving
			and (p.x - silo.position.x) ^ 2 + (p.y - silo.position.y) ^ 2 <= CAMERA_RADIUS ^ 2 then
			local ok = pcall(function()
				player.set_controller({type = defines.controllers.cutscene, final_transition_time = 60,
					waypoints = {
						{position = silo.position, transition_time = 60, time_to_wait = 60, zoom = 0.45},
						{position = scene.center, transition_time = 60, time_to_wait = 210, zoom = 0.35},
						{position = mid, transition_time = 60, time_to_wait = 210, zoom = 0.35},
					}})
			end)
			if ok then watchers[#watchers + 1] = player.index end
		end
	end
	return watchers
end

-- The first rocket of the force has gone up (on_rocket_launched: the rocket finished ascending).
function M.on_rocket_launched(event)
	local silo = event.rocket_silo
	if not (silo and silo.valid) or silo.surface.platform or in_sandbox(silo) then return end
	local force = silo.force
	storage.rift_done = storage.rift_done or {}
	if storage.rift_done[force.index] then return end
	storage.rift_done[force.index] = true

	local surface = silo.surface
	local center = {x = silo.position.x, y = silo.position.y - HEIGHT}
	local jag = {}
	for i = 0, SEGMENTS do
		local edge = (i == 0 or i == SEGMENTS) and 0.3 or 1
		jag[i + 1] = (math.random() - 0.5) * 2.4 * edge
	end
	local scene = {force = force, surface = surface, center = center, jag = jag, start = game.tick, tear = {},
		landing = landing(silo), silo = silo.position}
	for i, layer in ipairs(LAYERS) do
		scene.tear[i] = rendering.draw_polygon({color = layer.color, vertices = vertices(scene, layer.width, 0.05),
			surface = surface, render_layer = "air-object"})
	end
	scene.halo = rendering.draw_sprite({sprite = "utility/light_medium", target = center, surface = surface,
		x_scale = 0.1, y_scale = 0.1, tint = {r = 0.45, g = 0.12, b = 0.75, a = 0.6}, render_layer = "air-object"})
	scene.light = rendering.draw_light({sprite = "utility/light_medium", scale = 25, intensity = 1,
		color = {r = 0.7, g = 0.3, b = 1}, target = center, surface = surface})
	scene.watchers = cutscene(scene, silo)
	local scenes_ = scenes()
	scene.id = (storage.rift_next or 0) + 1
	storage.rift_next = scene.id
	scenes_[scene.id] = scene
	storage.rift_last = storage.rift_last or {}
	storage.rift_last[force.index] = {start = game.tick, watchers = scene.watchers, landing = scene.landing}

	flash(surface, center, 1)
	sound(surface, shared.rift_sound_open)
	sound(surface, shared.rift_sound_thunder)
	say(force, "paranoidal-warp.rift-open")
end

local function impact(scene)
	local surface = scene.surface
	local at = surface.find_non_colliding_position(shared.fragment, scene.landing, 12, 0.5) or scene.landing
	surface.create_entity({name = "massive-explosion", position = at})
	for _ = 1, 6 do
		surface.create_trivial_smoke({name = "smoke-fast",
			position = {x = at.x + (math.random() - 0.5) * 4, y = at.y + (math.random() - 0.5) * 4}})
	end
	sound(surface, shared.rift_sound_impact)
	local fragment = surface.create_entity({name = shared.fragment, position = at, force = scene.force,
		raise_built = true})
	local last = storage.rift_last and storage.rift_last[scene.force.index]
	if fragment then
		fragment.insert({name = STARTER, count = 1})
		if last then last.fragment = fragment end
	else
		surface.spill_item_stack({position = at, stack = {name = STARTER, count = 1}, enable_looted = true})
	end
	if last then last.landed = at end
	say(scene.force, "paranoidal-warp.rift-fragment",
		"[gps=" .. math.floor(at.x) .. "," .. math.floor(at.y) .. "," .. surface.name .. "]")
end

local function fall(scene, elapsed)
	local t = (elapsed - FALL_START) / FALL
	local c, l = scene.center, scene.landing
	local p = {x = c.x + (l.x - c.x) * t, y = c.y + (l.y - c.y) * t - math.sin(math.pi * t) * 6}
	if not (scene.falling and scene.falling.valid) then
		local sprite = helpers.is_valid_sprite_path(shared.fragment) and shared.fragment or "utility/light_medium"
		scene.falling = rendering.draw_sprite({sprite = sprite, target = p, surface = scene.surface,
			render_layer = "air-object"})
		scene.falling_light = rendering.draw_light({sprite = "utility/light_medium", scale = 4, intensity = 0.9,
			color = {r = 1, g = 0.55, b = 0.2}, target = p, surface = scene.surface})
	end
	scene.falling.target = p
	scene.falling.x_scale = 0.4 + 0.6 * t
	scene.falling.y_scale = 0.4 + 0.6 * t
	scene.falling.orientation = t * 0.35
	if scene.falling_light.valid then scene.falling_light.target = p end
	if elapsed % 3 == 0 then scene.surface.create_trivial_smoke({name = "fire-smoke", position = p}) end
end

local function finish(scene)
	for _, polygon in pairs(scene.tear) do destroy(polygon) end
	destroy(scene.halo)
	destroy(scene.light)
	destroy(scene.falling)
	destroy(scene.falling_light)
	local last = storage.rift_last and storage.rift_last[scene.force.index]
	if last then last.finished = game.tick end
	if scene.force.valid then say(scene.force, "paranoidal-warp.rift-closed") end
	scenes()[scene.id] = nil
end

-- Every tick while a scene runs.
function M.tick()
	local list = storage.rifts
	if not (list and next(list)) then return end
	for _, scene in pairs(list) do
		local elapsed = game.tick - scene.start
		if not (scene.surface.valid and scene.force.valid) then
			finish(scene)
		else
			if elapsed <= OPEN and elapsed % 4 == 0 then
				shape(scene, math.min(1, elapsed / OPEN))
			elseif elapsed >= CLOSE_START and elapsed <= CLOSE_START + CLOSE and elapsed % 4 == 0 then
				shape(scene, math.max(0.02, 1 - (elapsed - CLOSE_START) / CLOSE))
			end
			if elapsed < CLOSE_START + CLOSE / 2 then
				if elapsed % 15 == 0 then bolt(scene) end
				if elapsed % 90 == 45 then sound(scene.surface, shared.rift_sound_thunder) end
				local core = scene.tear[#scene.tear]
				if core and core.valid and elapsed % 6 == 0 then
					local a = 0.7 + 0.3 * math.random()
					core.color = {r = a, g = 0.85 * a, b = a, a = a}
				end
			end
			if elapsed == 150 then say(scene.force, "paranoidal-warp.rift-a113") end
			if elapsed >= FALL_START and elapsed < FALL_START + FALL then fall(scene, elapsed) end
			if elapsed == FALL_START + FALL then
				destroy(scene.falling)
				destroy(scene.falling_light)
				flash(scene.surface, scene.landing, 0.5)
				impact(scene)
			end
			if elapsed >= ENDS then finish(scene) end
		end
	end
end

-- For automated tests (remote interface).
function M.status(force_index)
	local last = storage.rift_last and storage.rift_last[force_index]
	local active = 0
	for _, scene in pairs(storage.rifts or {}) do
		if scene.force.valid and scene.force.index == force_index then active = active + 1 end
	end
	local fragment = last and last.fragment
	return {done = storage.rift_done and storage.rift_done[force_index] or false, active = active,
		start = last and last.start, finished = last and last.finished, watchers = last and last.watchers,
		landed = last and last.landed,
		fragment = fragment and fragment.valid and {name = fragment.name, position = fragment.position,
			starter = fragment.get_item_count(STARTER)} or nil}
end

return M
