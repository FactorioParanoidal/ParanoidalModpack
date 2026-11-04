-- The infected blob: picks the outermost mining outpost, falls on it with a huge splash and infects the drills nearest.
local infection = require("script.infection")
local shared = require("shared")
local util = require("util")
local config = require("script.config")
local outbreak = require("script.outbreak")

local arrival = {}

-- When, where and how hard it lands are map settings (config.lua): the first arrival, the retry delay, the technology it
-- waits for, the range of enemy evolution it lands somewhere in, the outpost's distance, size and radius, and how many
-- drills it infects. It lands once per map, on the side of the base away from the replicators' citadel.
local minute = 60 * 60
local target_force = "player"
local impact_radius = 6
local fall_ticks = 100
local fall_height = 70
local blob_size = 6
local splash_distance = {3, 9}
local splash_size = 16
local splat_hold = 60 * 60
local splat_fade = 30 * 60

-- Somewhere in the range of the settings, picked once and again only if the range changes, so it isn't known in advance.
local function evolution_threshold(state)
  local least, most = config.get("arrival-min-evolution"), config.get("arrival-max-evolution")
  if least > most then least, most = most, least end
  if not (state.threshold and state.threshold_range == least .. "-" .. most) then
    state.threshold = math.random(least, most)
    state.threshold_range = least .. "-" .. most
  end
  return state.threshold / 100
end

local function position_of(value)
  if type(value) ~= "table" then return nil end
  local x, y = value.x or value[1], value.y or value[2]
  if not (x and y) then return nil end
  return {x = x, y = y}
end

-- Which way the replicators' citadel (robotarmy-citadel) is from the player's base, so it can land on the other side.
-- "wait" while the citadel is being sited, so it doesn't land where the citadel is about to be. Nothing if there's no
-- citadel, it's on another surface, or the setting is off.
local function replicators(surface)
  if not config.get("avoid-replicators") then return nil end
  local interface = remote.interfaces["robotarmy-citadel"]
  if not (interface and interface.status) then return nil end
  local ok, status = pcall(remote.call, "robotarmy-citadel", "status")
  if not (ok and type(status) == "table") then return nil end
  if status.phase == "warned" or status.phase == "siting" then return "wait" end
  local citadel_surface = game.surfaces["nauvis"] or game.get_surface(1)
  if not citadel_surface or citadel_surface.index ~= surface.index then return nil end
  local at = position_of(status.core_position) or position_of(status.center)
  if not at then return nil end
  local base = position_of(status.base) or game.forces[target_force].get_spawn_position(surface)
  local dx, dy = at.x - base.x, at.y - base.y
  local length = math.sqrt(dx * dx + dy * dy)
  if length < 1 then return nil end
  return {x = dx / length, y = dy / length}
end

-- The best outpost on one surface: see find_outpost.
local function best_on(surface, force, away, best)
  local min_drills, radius = config.get("min-outpost-drills"), config.get("outpost-radius")
  local min_distance = config.get("min-outpost-distance") ^ 2
  local spawn = force.get_spawn_position(surface)
  for _, drill in pairs(surface.find_entities_filtered{type = "mining-drill", force = force}) do
    local dx, dy = drill.position.x - spawn.x, drill.position.y - spawn.y
    local distance = dx * dx + dy * dy
    -- How far round towards the citadel it is: anything below 0 is on the far side, where only the distance counts.
    local side = away and (dx * away.x + dy * away.y) / math.max(math.sqrt(distance), 1) or -1
    if side < 0 then side = -1 end
    local better = not best.drill or side < best.side or (side == best.side and distance > best.distance)
    if distance >= min_distance and better and infection.can_infect(drill, true) then
      local nearby = surface.count_entities_filtered{position = drill.position, radius = radius, type = "mining-drill", force = force}
      if nearby >= min_drills then
        best.drill, best.side, best.distance = drill, side, distance
      end
    end
  end
end

-- One of the player's drills with at least so many others within the outpost's radius, no nearer to the spawn than the
-- setting allows. Of those on the far side of the base from the replicators, the furthest out; if there are none there,
-- the one most nearly on that side. Only on a surface where the biters have evolved enough, unless that's ignored.
local function find_outpost(ignore_evolution)
  local force = game.forces[target_force]
  if not force then return end
  local min_evolution = evolution_threshold(storage.arrival)
  local enemy = game.forces["enemy"]
  local best = {}
  for _, surface in pairs(game.surfaces) do
    if not surface.platform and (ignore_evolution or min_evolution <= 0 or (enemy and enemy.get_evolution_factor(surface) >= min_evolution)) then
      local away = replicators(surface)
      if away == "wait" and ignore_evolution then away = nil end
      if away ~= "wait" then best_on(surface, force, away, best) end
    end
  end
  return best.drill
end

local function announce(force, entity)
  force.print({"the-beast.arrived"}, {color = {r = 1, g = 0.2, b = 0.3}})
  for _, player in pairs(force.players) do
    if entity and entity.valid then
      player.add_custom_alert(entity, {type = "virtual", name = "signal-skull"}, {"the-beast.arrived"}, true)
    end
    player.play_sound{path = "utility/alert_destroyed"}
  end
end

local function draw_blob(surface, position, size, tint, layer)
  return rendering.draw_sprite
  {
    sprite = "beast-creep-patch", target = position, surface = surface, tint = tint, x_scale = size, y_scale = size,
    render_layer = layer
  }
end

-- A huge blob drops out of the sky onto the outpost, with a shadow growing under it.
local function launch_blob(surface, position)
  local light = rendering.draw_light
  {
    sprite = "utility/light_medium", target = position, surface = surface, color = {r = 1, g = 0.05, b = 0.3},
    intensity = 1, scale = blob_size * 1.5
  }
  storage.arrival.blobs[#storage.arrival.blobs + 1] =
  {
    surface = surface, position = position, start = game.tick, light = light,
    shadow = draw_blob(surface, position, 1, {r = 0, g = 0, b = 0, a = 0.5}, "decals"),
    body = draw_blob(surface, position, blob_size, {r = 0.45, g = 0.04, b = 0.15}, "air-object"),
    core = draw_blob(surface, position, blob_size * 0.5, {r = 0.9, g = 0.2, b = 0.35, a = 0.8}, "air-object")
  }
end

-- Lands the blob on the drill's outpost.
function arrival.arrive(drill)
  storage.arrival.arrived = true
  storage.arrival.last_arrival = game.tick
  storage.arrival.target_force = drill.force
  launch_blob(drill.surface, drill.position)
end

local function splash(surface, position)
  local count = 28
  for i = 1, count do
    local angle = (i + math.random() * 0.8) / count * 2 * math.pi
    local distance = splash_distance[1] + math.random() * (splash_distance[2] - splash_distance[1])
    surface.create_entity
    {
      name = "beast-splash", position = position, source_position = position, force = "the-beast",
      target_position = {x = position.x + math.cos(angle) * distance, y = position.y + math.sin(angle) * distance}
    }
  end
  surface.create_entity{name = "beast-splash-explosion-huge", position = position}
  for _ = 1, 12 do
    surface.create_trivial_smoke{name = "beast-spores", position = {x = position.x + math.random() * 8 - 4, y = position.y + math.random() * 8 - 4}}
  end
  for _, size in pairs{splash_size, splash_size * 0.6} do
    local splats = storage.arrival.splats
    splats[#splats + 1] = {patch = draw_blob(surface, position, size, shared.creep_tint, "decals"), start = game.tick}
  end
end

-- Soaks away slowly, so that it never just vanishes while you're looking at it.
local function fade_splats()
  local splats = storage.arrival.splats
  for i = #splats, 1, -1 do
    local splat = splats[i]
    local left = 1 - (game.tick - splat.start - splat_hold) / splat_fade
    if left <= 0 or not splat.patch.valid then
      splat.patch.destroy()
      table.remove(splats, i)
    elseif left < 1 then
      local tint = shared.creep_tint
      splat.patch.color = {r = tint.r * left, g = tint.g * left, b = tint.b * left, a = tint.a * left}
    end
  end
end

local function impact(surface, position)
  splash(surface, position)
  local away = replicators(surface)
  outbreak.begin(surface, position, type(away) == "table" and away or nil)
  local force = storage.arrival.target_force
  if not (force and force.valid) then force = game.forces[target_force] end
  local drills = surface.find_entities_filtered{position = position, radius = impact_radius, type = "mining-drill", force = force}
  table.sort(drills, function(a, b) return util.distance(a.position, position) < util.distance(b.position, position) end)
  for i = 1, math.min(#drills, config.get("first-infected-drills")) do
    infection.infect(drills[i], true)
  end
  announce(force, drills[1])
end

local function fall(blob)
  if not blob.surface.valid then return false end
  local t = (game.tick - blob.start) / fall_ticks
  if t >= 1 then
    for _, key in pairs{"shadow", "body", "core", "light"} do blob[key].destroy() end
    impact(blob.surface, blob.position)
    return false
  end
  local position = blob.position
  local lifted = {x = position.x, y = position.y - fall_height * (1 - t * t)}
  blob.body.target = lifted
  blob.core.target = lifted
  blob.light.target = lifted
  local shadow_size = blob_size * (0.3 + 0.9 * t)
  blob.shadow.x_scale = shadow_size
  blob.shadow.y_scale = shadow_size
  blob.surface.create_trivial_smoke{name = "beast-spores", position = lifted}
  return true
end

local function on_tick()
  local blobs = storage.arrival.blobs
  for i = #blobs, 1, -1 do
    if not fall(blobs[i]) then table.remove(blobs, i) end
  end
end

-- The technology it waits for, if any. A name that doesn't exist is said once and then not waited for, rather than
-- quietly keeping it away for good.
local function technology_ready(state)
  local name = config.get("arrival-technology")
  if name == "" then return true end
  local technology = game.forces[target_force].technologies[name]
  if technology then return technology.researched end
  if state.warned_technology ~= name then
    state.warned_technology = name
    game.print({"the-beast.unknown-technology", name})
  end
  return true
end

local function check_arrival()
  if not config.get("auto-arrival") then return end
  local state = storage.arrival
  -- Once per map: there are no further landings.
  if state.arrived or game.tick < state.next_check then return end
  if game.tick < state.start_tick + config.get("first-arrival-minutes") * minute then return end
  if not game.forces[target_force] or not technology_ready(state) then return end
  state.next_check = game.tick + config.get("retry-minutes") * minute
  local drill = find_outpost()
  if drill then arrival.arrive(drill) end
end

local function setup()
  -- The first arrival counts from when the mod was added, so adding it to a game well under way isn't an instant landing.
  storage.arrival = storage.arrival or {next_check = 0, start_tick = game.tick}
  storage.arrival.start_tick = storage.arrival.start_tick or game.tick
  storage.arrival.blobs = storage.arrival.blobs or {}
  storage.arrival.splats = storage.arrival.splats or {}
  storage.arrival.pods = nil
end

arrival.on_init = setup
arrival.on_configuration_changed = setup

arrival.on_nth_tick =
{
  [1] = on_tick,
  [10] = fade_splats,
  [600] = check_arrival
}

arrival.add_commands = function()
  commands.add_command("beast-arrive", {"the-beast.arrive-command-help"}, function(command)
    local player = command.player_index and game.get_player(command.player_index)
    if player and not player.admin then return end
    if not arrival.can_arrive() then
      if player then player.print({"the-beast.already"}) end
      return
    end
    local drill = find_outpost(true)
    if drill then
      arrival.arrive(drill)
    elseif player then
      player.print({"the-beast.no-outpost"})
    end
  end)
end

arrival.find_outpost = find_outpost

-- Not while one is falling or an outbreak is going on.
function arrival.can_arrive()
  return not outbreak.active() and #storage.arrival.blobs == 0
end

return arrival
