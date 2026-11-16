-- Her research branch: parts of reject robots of the Repair Ward. Lamp (L-T), paint trail home (VN-GO), vacuum
-- (VAQ-M), umbrella against lightning (BRL-A, with paranoidal-rain), defibrillator (D-FIB).
local shared = require("shared")
local state = require("script.state")
local speech = require("script.speech")
local chatter = require("script.chatter")

local abilities = {}

local T = shared.tech
local minute = 3600
local look = settings.startup[shared.settings.look].value
local L = shared.looks[look] or shared.looks.own

local trail_step = 6             -- tiles between paint marks
local trail_life = 30 * minute
local trail_max = 300            -- render objects per player (two a mark)
local base_radius = 32           -- no building of his this close: he is away from the base
local vacuum_radius = 6
local defib_cooldown = 30 * 60
local defib_range = 14
local paint = {{0.95, 0.35, 0.55}, {0.35, 0.75, 0.95}, {0.95, 0.85, 0.3}, {0.5, 0.9, 0.45}, {0.75, 0.5, 0.95}}

local building_types = {"assembling-machine", "furnace", "mining-drill", "electric-pole", "container", "transport-belt",
  "inserter", "lab", "boiler", "generator", "pipe", "wall", "ammo-turret", "electric-turret", "radar", "roboport",
  "solar-panel", "accumulator", "lamp", "offshore-pump", "storage-tank", "rocket-silo", "beacon", "splitter",
  "underground-belt"}

abilities.researched = function(force, name)
  local tech = force.technologies[name]
  return tech and tech.researched or false
end

local destroy = function(object)
  if object and object.valid then
    object.destroy()
  end
end

abilities.clear = function(data)
  destroy(data.lamp)
  data.lamp = nil
  destroy(data.umbrella)
  data.umbrella = nil
  if data.rod and data.rod.valid then
    data.rod.destroy()
  end
  data.rod = nil
end

-- Is it raining on that surface (paranoidal-rain)? Asked once per 5 s per surface.
local raining = function(surface_index)
  if not remote.interfaces["paranoidal-rain"] then return false end
  local record = state.s.rain[surface_index]
  if not record or game.tick - record.checked >= 300 then
    record = {checked = game.tick, raining = remote.call("paranoidal-rain", "is_raining", surface_index) == true}
    state.s.rain[surface_index] = record
  end
  return record.raining
end
abilities.raining = raining

local paved = function(surface, position)
  local tile = surface.get_tile(position.x, position.y)
  return tile.valid and tile.prototype.mineable_properties.minable
end

local update_lamp = function(data, player, unit, tick)
  if not abilities.researched(player.force, T.lamp) then return end
  if not (data.lamp and data.lamp.valid) then
    data.lamp = rendering.draw_light
    {
      sprite = "utility/light_medium",
      target = unit,
      surface = unit.surface,
      scale = 2.4,
      intensity = 0.85,
      minimum_darkness = 0.25,
      color = {1, 0.93, 0.78}
    }
  end
  -- A reject part: now and then it flickers.
  if data.flicker_until then
    if tick >= data.flicker_until then
      data.flicker_until = nil
      data.lamp.visible = true
    end
  elseif math.random() < 0.01 then
    data.flicker_until = tick + 15
    data.lamp.visible = false
  end
end

local away_from_base = function(player, char)
  return char.surface.count_entities_filtered{position = char.position, radius = base_radius, force = player.force,
    type = building_types, limit = 1} == 0
end

local update_trail = function(data, player, unit)
  if not abilities.researched(player.force, T.trail) then return end
  local char = player.character
  local trail = data.trail
  if not away_from_base(player, char) then
    trail.last = nil
    trail.away = nil
    return
  end
  local p = unit.position
  if trail.last and trail.last.surface == unit.surface_index then
    local dx, dy = p.x - trail.last.x, p.y - trail.last.y
    if dx * dx + dy * dy < trail_step * trail_step then return end
  end
  if not trail.away then
    trail.away = true
    chatter.occasion(data, player, "trail-start", {"nan-e.trail-start"}, "happy", 30 * minute)
  end
  trail.last = {x = p.x, y = p.y, surface = unit.surface_index}
  trail.colour = (trail.colour or 0) % #paint + 1
  local colour = paint[trail.colour]
  local objects = trail.objects
  objects[#objects + 1] = rendering.draw_circle{color = colour, radius = 0.22, filled = true, target = {x = p.x, y = p.y},
    surface = unit.surface, players = {player}, draw_on_ground = true, time_to_live = trail_life}
  objects[#objects + 1] = rendering.draw_circle{color = colour, radius = 1.5, filled = true, target = {x = p.x, y = p.y},
    surface = unit.surface, players = {player}, render_mode = "chart", time_to_live = trail_life}
  while #objects > trail_max do
    destroy(table.remove(objects, 1))
  end
  if math.random() < 0.2 then
    speech.sound(data, shared.sounds.spray, true)
  end
end

local update_vacuum = function(data, player, unit, char, tick)
  if tick < (data.next_vacuum or 0) then return end
  data.next_vacuum = tick + 60
  if not abilities.researched(player.force, T.vacuum) then return end
  local dx, dy = unit.position.x - char.position.x, unit.position.y - char.position.y
  if dx * dx + dy * dy > 100 then return end
  local surface = unit.surface
  local items = surface.find_entities_filtered{position = unit.position, radius = vacuum_radius, type = "item-entity", limit = 8}
  if #items == 0 then return end
  local dok = script.active_mods["Paranoidal-Droid-M-O"]
  local picked = false
  for _, item in pairs(items) do
    -- The paving is Д-ОК's (ПР-092).
    if not (dok and paved(surface, item.position)) then
      local stack = item.stack
      local count = stack.count
      local inserted = player.insert(stack)
      if inserted > 0 then
        picked = true
        if inserted >= count then
          item.destroy()
        else
          stack.count = count - inserted
        end
      else
        break
      end
    end
  end
  if picked then
    speech.sound(data, shared.sounds.vacuum, true)
    chatter.occasion(data, player, "vacuum", {"nan-e.vacuum"}, "happy", 20 * minute)
    -- A reject vacuum: now and then she sneezes and what lies round her rolls away.
    if math.random() < 0.02 then
      for _, item in pairs(surface.find_entities_filtered{position = unit.position, radius = 4, type = "item-entity", limit = 10}) do
        local p = item.position
        local spot = surface.find_non_colliding_position("item-on-ground", {x = p.x + math.random(-3, 3), y = p.y + math.random(-3, 3)}, 3, 0.5)
        if spot then
          item.teleport(spot)
        end
      end
      speech.sound(data, shared.sounds.sneeze, true)
      speech.say(data, {"nan-e.sneeze"}, {mood = "surprised", ticks = 180, silent = true})
    end
  end
end

local update_umbrella = function(data, player, unit)
  if not (remote.interfaces["paranoidal-rain"] and abilities.researched(player.force, T.umbrella)) then return end
  local rod = data.rod
  if not (rod and rod.valid) or rod.surface ~= unit.surface then
    if rod and rod.valid then
      rod.destroy()
    end
    rod = unit.surface.create_entity{name = shared.rod, position = unit.position, force = unit.force, raise_built = true}
    if rod then
      rod.destructible = false
    end
    data.rod = rod
  else
    rod.teleport(unit.position)
  end
  local wet = raining(unit.surface_index)
  if wet and not (data.umbrella and data.umbrella.valid) then
    data.umbrella = rendering.draw_sprite
    {
      sprite = shared.sprite.umbrella,
      target = {entity = unit, offset = L.umbrella_offset},
      surface = unit.surface,
      render_layer = "higher-object-under"
    }
    speech.sound(data, shared.sounds.umbrella, true)
  elseif not wet and data.umbrella then
    destroy(data.umbrella)
    data.umbrella = nil
  end
end

-- Night and rain: a line now and then.
local update_occasions = function(data, player, unit, tick)
  if tick < (data.next_occasion or 0) then return end
  data.next_occasion = tick + 300
  local surface = unit.surface
  local night = surface.darkness > 0.6
  if night and not data.night then
    local lamp = abilities.researched(player.force, T.lamp)
    chatter.occasion(data, player, "night", {lamp and "nan-e.night-lamp" or "nan-e.night-nolamp"}, lamp and "happy" or "worried", 40 * minute)
  end
  data.night = night
  local wet = raining(unit.surface_index)
  if wet and not data.wet then
    local umbrella = remote.interfaces["paranoidal-rain"] and abilities.researched(player.force, T.umbrella)
    chatter.occasion(data, player, "rain", {umbrella and "nan-e.rain-umbrella" or "nan-e.rain-none"}, "happy", 40 * minute)
  end
  data.wet = wet
  if player.vehicle and not data.in_vehicle and math.random() < 0.3 then
    chatter.occasion(data, player, "vehicle", {"nan-e.vehicle"}, "stern", 30 * minute)
  end
  data.in_vehicle = player.vehicle ~= nil
  if player.afk_time > 5 * minute and not data.afk then
    data.afk = true
    chatter.occasion(data, player, "afk", {"nan-e.afk"}, "sleepy", 30 * minute)
  elseif player.afk_time < 60 then
    data.afk = nil
  end
  if script.active_mods["Paranoidal-Droid-M-O"] and math.random() < 0.05 and prototypes.entity["droid-m-o"] then
    if surface.count_entities_filtered{position = unit.position, radius = 10, name = "droid-m-o", limit = 1} > 0 then
      chatter.occasion(data, player, "dok", {"nan-e.dok-" .. math.random(2)}, "happy", 30 * minute)
    end
  end
end

-- Every 30 ticks while she is up.
abilities.update = function(data, player, char, tick)
  local unit = data.unit
  update_lamp(data, player, unit, tick)
  update_umbrella(data, player, unit)
  if char.surface == unit.surface then
    update_trail(data, player, unit)
    update_vacuum(data, player, unit, char, tick)
  end
  update_occasions(data, player, unit, tick)
end

local owner_of = function(entity)
  if entity.type == "character" then
    local player = entity.player
    return player and state.s.players[player.index]
  end
  for _, data in pairs(state.s.players) do
    if data.unit == entity then
      return data
    end
  end
  return nil
end

-- The defibrillator: someone hostile hurts him or her, she shocks it (and its pack) still for four seconds.
abilities.on_damaged = function(event)
  local cause = event.cause
  if not (cause and cause.valid and cause.type == "unit") then return end
  local victim = event.entity
  if not victim.valid then return end
  local data = owner_of(victim)
  if not data or data.status ~= "active" then return end
  local unit = data.unit
  local player = game.get_player(data.player_index)
  if not (player and unit and unit.valid) then return end
  -- The engineer badly hurt: a word of comfort, now and then.
  if victim.type == "character" and victim.health < victim.max_health * 0.3 then
    chatter.occasion(data, player, "hurt", {"nan-e.hurt"}, "worried", 5 * minute)
  end
  if not (victim.force.is_enemy(cause.force) and abilities.researched(player.force, T.defib)) then return end
  if game.tick < (data.defib_ready or 0) then return end
  if unit.surface ~= cause.surface then return end
  local dx, dy = unit.position.x - cause.position.x, unit.position.y - cause.position.y
  if dx * dx + dy * dy > defib_range * defib_range then return end
  data.defib_ready = game.tick + defib_cooldown
  speech.sound(data, shared.sounds.zap, true)
  if math.random() < 0.05 then
    unit.commandable.set_command{type = defines.command.stop, ticks_to_wait = 120, distraction = defines.distraction.none}
    speech.say(data, {"nan-e.defib-misfire"}, {mood = "surprised", ticks = 240, silent = true})
    return
  end
  local targets = {cause}
  for _, other in pairs(cause.surface.find_entities_filtered{position = cause.position, radius = 4, type = "unit", limit = 6}) do
    if other ~= cause and victim.force.is_enemy(other.force) then
      targets[#targets + 1] = other
    end
  end
  for _, target in pairs(targets) do
    cause.surface.create_entity{name = shared.sticker, position = target.position, target = target}
    local commandable = target.commandable
    if commandable then
      commandable.set_command{type = defines.command.stop, ticks_to_wait = 240, distraction = defines.distraction.none}
    end
    rendering.draw_line{color = {0.55, 0.85, 1}, width = 3, from = {entity = unit, offset = {0, -0.6}}, to = target,
      surface = unit.surface, time_to_live = 12}
    rendering.draw_light{sprite = "utility/light_small", target = target, surface = unit.surface, color = {0.55, 0.85, 1},
      intensity = 1, scale = 1.5, time_to_live = 12}
  end
  chatter.occasion(data, player, "defib", {"nan-e.defib-" .. math.random(3)}, "stern", 60 * 60)
end

-- paranoidal-rain's on_lightning_strike: her umbrella took a bolt. It hurts her a little.
abilities.on_strike = function(event)
  local attractor = event.attractor
  if not (attractor and attractor.valid and attractor.name == shared.rod) then return end
  for _, data in pairs(state.s.players) do
    if data.rod == attractor and data.unit and data.unit.valid then
      speech.sound(data, shared.sounds.zap, true)
      speech.say(data, {"nan-e.strike"}, {mood = "surprised", ticks = 240})
      data.unit.damage(data.unit.max_health * 0.12, "neutral", "electric")
      return
    end
  end
end

return abilities
