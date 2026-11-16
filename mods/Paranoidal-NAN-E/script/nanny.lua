-- НЯН-Я herself: one per engineer. She is a unit of her player's force that hovers over buildings (only water stops
-- her), keeps a few tiles from him, catches up when left far behind, waits outside other surfaces (factories) and,
-- knocked out, becomes a switched-off husk that wakes up when repaired. Errands, abilities and her memory live in their own files.
local shared = require("shared")
local state = require("script.state")
local speech = require("script.speech")
local chatter = require("script.chatter")
local errands = require("script.errands")
local abilities = require("script.abilities")
local memory = require("script.memory")

local nanny = {}

local minute = 3600
local catch_up_distance = 64        -- tiles: farther than that she takes the vents
local surface_wait = 2 * minute     -- on another surface that long, she follows (factories never)
local boot_ticks = 150              -- a new one boots up this long after she is placed
local alert_interval = 600

nanny.get = function(player_index)
  return state.s.players[player_index]
end

local new_data = function(player)
  return
  {
    player_index = player.index,
    status = "offline",
    journal = {},
    said = {},
    trail = {objects = {}},
    next_chatter = game.tick + 5 * minute,
    next_errand = game.tick + 3 * minute,
    created = game.tick
  }
end

nanny.data_for = function(player)
  local data = state.s.players[player.index]
  if not data then
    data = new_data(player)
    state.s.players[player.index] = data
  end
  return data
end

-- Any switched-off husk on record, by entity.
local husk_record = function(entity)
  return entity and entity.valid and entity.unit_number and state.s.husks[entity.unit_number]
end

-- quality: carried over from her (and back to her when she wakes up), as from the item she was placed from.
nanny.spawn_husk = function(surface, position, force, kind, owner, health_ratio, quality)
  local spot = surface.find_non_colliding_position(shared.husk, position, 12, 0.5) or position
  local husk = surface.create_entity{name = shared.husk, position = spot, force = force, quality = quality,
    create_build_effect_smoke = false}
  if not husk then return nil end
  husk.health = math.max(1, husk.max_health * (health_ratio or 0))
  husk.destructible = false
  state.s.husks[husk.unit_number] = {entity = husk, kind = kind, owner = owner, boot_tick = kind == "new" and game.tick + boot_ticks or nil}
  return husk
end

local forget_husk = function(husk)
  if husk and husk.valid and husk.unit_number then
    state.s.husks[husk.unit_number] = nil
  end
end

-- She wakes up next to the husk (which goes) for that player.
nanny.activate = function(player, husk, kind)
  local data = nanny.data_for(player)
  if data.unit and data.unit.valid then return false end
  local surface, position = husk.surface, husk.position
  local health_ratio = husk.health / husk.max_health
  local spot = surface.find_non_colliding_position(shared.unit, position, 10, 0.5) or position
  local unit = surface.create_entity{name = shared.unit, position = spot, force = player.force, quality = husk.quality,
    create_build_effect_smoke = false}
  if not unit then return false end
  if kind == "revived" then
    unit.health = unit.max_health * math.max(0.5, health_ratio)
  end
  player.remove_alert{type = defines.alert_type.custom, icon = {type = "item", name = shared.item}}
  forget_husk(husk)
  husk.destroy()
  if data.husk and data.husk.valid and data.husk ~= husk then
    forget_husk(data.husk)
    data.husk.destroy()
  end
  data.husk = nil
  data.unit = unit
  data.quality = unit.quality.name
  data.status = "active"
  data.task = nil
  memory.unlock_first(player.force)
  speech.sound(data, shared.sounds.boot)
  local line = kind == "revived" and "boot-revived" or (data.met and "boot-new" or "boot-first")
  speech.say(data, {"nan-e." .. line}, {mood = kind == "revived" and "happy" or "sleepy", ticks = 480, silent = true})
  if kind == "first" and state.s.axiom6.state == "placed" and not data.axiom6_told then
    -- The one found at the Axiom-6: her cards are in the liner's hold.
    data.axiom6_told = true
    data.axiom6_tip = game.tick + 1200
  end
  if not data.met then
    data.met = true
    data.first_tip = game.tick + 600
    if nanny.on_first_meeting then
      nanny.on_first_meeting(player)
    end
  end
  return true
end

-- She is down: a husk where she fell, repaired she comes back with all her memory.
nanny.on_unit_died = function(event)
  local unit = event.entity
  for _, data in pairs(state.s.players) do
    if data.unit == unit then
      local player = game.get_player(data.player_index)
      speech.clear(data)
      abilities.clear(data)
      data.unit = nil
      data.status = "offline"
      data.task = nil
      if player then
        data.husk = nanny.spawn_husk(unit.surface, unit.position, unit.force, "knocked", data.player_index, 0, unit.quality)
        speech.say(data, {"nan-e.offline"}, {mood = "sleepy"})
        player.play_sound{path = shared.sounds.shutdown, position = unit.position}
        data.next_alert = 0
      end
      return
    end
  end
end

local remove_render = function(object)
  if object and object.valid then
    object.destroy()
  end
end

nanny.remove = function(player_index)
  local data = state.s.players[player_index]
  if not data then return end
  speech.clear(data)
  abilities.clear(data)
  for _, object in pairs(data.trail.objects) do
    remove_render(object)
  end
  if data.unit and data.unit.valid then
    data.unit.destroy()
  end
  if data.husk and data.husk.valid then
    forget_husk(data.husk)
    data.husk.destroy()
  end
  state.s.players[player_index] = nil
end

local distance = function(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return math.sqrt(dx * dx + dy * dy)
end
nanny.distance = distance

local go_to = function(destination, radius)
  return
  {
    type = defines.command.go_to_location,
    destination = destination,
    radius = radius or 1,
    distraction = defines.distraction.none,
    pathfind_flags = {prefer_straight_paths = true}
  }
end
nanny.go_to = go_to

nanny.stop = function(data, ticks)
  local unit = data.unit
  if unit and unit.valid then
    unit.commandable.set_command{type = defines.command.stop, ticks_to_wait = ticks or 60, distraction = defines.distraction.none}
  end
end

-- Next to him, a little behind on her side.
local spot_near = function(data, char, gap)
  local p, q = char.position, data.unit.position
  local dx, dy = q.x - p.x, q.y - p.y
  local d = math.sqrt(dx * dx + dy * dy)
  if d < 0.01 then
    dx, dy, d = 1, 1, math.sqrt(2)
  end
  return {x = p.x + dx / d * gap, y = p.y + dy / d * gap}
end

nanny.teleport_near = function(data, char, gap)
  local unit = data.unit
  local target = spot_near(data, char, gap or 3)
  local spot = char.surface.find_non_colliding_position(shared.unit, target, 8, 0.5)
  if not spot then return false end
  if unit.surface ~= char.surface then
    -- Units don't change surfaces by teleport: a new body with the same health takes over.
    local health = unit.health
    local new = char.surface.create_entity{name = shared.unit, position = spot, force = unit.force, quality = unit.quality,
      create_build_effect_smoke = false}
    if not new then return false end
    new.health = health
    speech.clear(data)
    abilities.clear(data)
    unit.destroy()
    data.unit = new
  else
    unit.teleport(spot)
  end
  nanny.stop(data, 30)
  return true
end

local is_factory = function(surface)
  return string.find(surface.name, "factory-floor", 1, true) ~= nil
end

-- Following, waiting and catching up; returns whether she is free (near him, on his surface) for anything else.
local follow = function(data, player, char)
  local unit = data.unit
  if unit.surface ~= char.surface then
    data.task = nil
    if not data.away_since then
      data.away_since = game.tick
      chatter.occasion(data, player, "wait-surface", {"nan-e.wait-surface"}, "neutral", 10 * minute)
    elseif game.tick - data.away_since > surface_wait and not is_factory(char.surface) then
      if nanny.teleport_near(data, char) then
        data.away_since = nil
        chatter.occasion(data, player, "catch-up", {"nan-e.catch-up-" .. math.random(3)}, "happy", 5 * minute)
      end
    end
    return false
  end
  if data.away_since then
    data.away_since = nil
    chatter.occasion(data, player, "back-surface", {"nan-e.back-surface"}, "happy", 10 * minute)
  end
  local d = distance(unit.position, char.position)
  local vehicle = player.vehicle
  if d > catch_up_distance then
    data.task = nil
    -- Not while he speeds along in a car or a train: she catches up when he stops.
    if vehicle and math.abs(vehicle.speed or 0) > 0.05 then return false end
    if nanny.teleport_near(data, char) then
      chatter.occasion(data, player, "catch-up", {"nan-e.catch-up-" .. math.random(3)}, "happy", 5 * minute)
    end
    return false
  end
  if data.task then
    return false
  end
  local gap = player.mod_settings[shared.settings.distance].value
  if d > gap + 1.5 then
    unit.commandable.set_command(go_to(spot_near(data, char, gap), 1))
    data.moving = true
    return d < gap + 6
  elseif data.moving then
    data.moving = nil
    nanny.stop(data, 120)
  end
  return true
end

-- Every 30 ticks for every nanny.
nanny.update = function(event)
  local tick = event.tick
  for player_index, data in pairs(state.s.players) do
    local player = game.get_player(player_index)
    if not player then
      nanny.remove(player_index)
    elseif data.status == "active" then
      local unit = data.unit
      if not (unit and unit.valid) then
        -- Gone without dying (another mod, a cleared surface): she crawls back as a husk to her engineer.
        data.unit = nil
        data.status = "offline"
        abilities.clear(data)
        local char = player.character
        if char then
          data.husk = nanny.spawn_husk(char.surface, char.position, player.force, "knocked", player_index, 0, data.quality)
          speech.say(data, {"nan-e.crawled"}, {mood = "worried"})
        end
      elseif player.connected then
        local char = player.character
        if char and char.valid then
          local free = follow(data, player, char)
          if data.task then
            errands.update(data, player, char)
          elseif free then
            if not errands.maybe_start(data, player, char) and not data.moving then
              chatter.think(data, player)
            end
          end
          if data.unit and data.unit.valid then
            abilities.update(data, player, char, tick)
          end
          if data.first_tip and tick >= data.first_tip then
            data.first_tip = nil
            speech.say(data, {"nan-e.first-tip"}, {mood = "happy"})
          elseif data.axiom6_tip and tick >= data.axiom6_tip then
            data.axiom6_tip = nil
            speech.say(data, {"nan-e.card-axiom6"}, {mood = "worried"})
          end
        end
      end
    end
  end
end

-- Every 60 ticks: husks booting up, repaired or lost; alerts for switched-off ones.
nanny.poll_husks = function(event)
  local tick = event.tick
  for id, record in pairs(state.s.husks) do
    local husk = record.entity
    if not (husk and husk.valid) then
      state.s.husks[id] = nil
    elseif record.kind == "new" then
      if tick >= record.boot_tick then
        local player = record.owner and game.get_player(record.owner)
        if player then
          nanny.activate(player, husk, "new")
        end
      end
    elseif husk.health >= husk.max_health - 0.5 then
      local player = record.kind == "knocked" and record.owner and game.get_player(record.owner)
      if record.kind == "found" then
        -- Whoever repaired her, or the next engineer of that force who has no nanny yet.
        local candidates = {}
        if record.repairer then
          candidates[1] = game.get_player(record.repairer)
        end
        for _, other in pairs(husk.force.connected_players) do
          candidates[#candidates + 1] = other
        end
        for _, candidate in pairs(candidates) do
          local data = candidate and state.s.players[candidate.index]
          if candidate and not (data and (data.status == "active" or (data.husk and data.husk.valid))) then
            player = candidate
            break
          end
        end
        if not player and record.repairer and not record.told then
          record.told = true
          local repairer = game.get_player(record.repairer)
          if repairer then
            repairer.print({"", "[item=" .. shared.item .. "] ", {"nan-e.found-busy"}}, {color = {1, 0.82, 0.9}})
          end
        end
      end
      if player then
        nanny.activate(player, husk, record.kind == "knocked" and "revived" or "first")
      end
    end
  end
  -- Her player's alert while she is switched off; a lost husk crawls back to him.
  for player_index, data in pairs(state.s.players) do
    if data.status == "offline" and data.met then
      local player = game.get_player(player_index)
      if player and player.connected then
        if not (data.husk and data.husk.valid) then
          local char = player.character
          if char then
            data.husk = nanny.spawn_husk(char.surface, char.position, player.force, "knocked", player_index, 0, data.quality)
            speech.say(data, {"nan-e.crawled"}, {mood = "worried"})
          end
        elseif tick >= (data.next_alert or 0) then
          data.next_alert = tick + alert_interval
          player.add_custom_alert(data.husk, {type = "item", name = shared.item}, {"nan-e.offline-alert"}, true)
        end
      end
    end
  end
end

-- A new one placed from the item: she boots up for whoever placed her, if he has no nanny yet.
nanny.on_built = function(event)
  local husk = event.entity
  if not (husk and husk.valid and husk.name == shared.husk) then return end
  local player = event.player_index and game.get_player(event.player_index)
  if not player then
    -- Built by a robot or a script: switched off, waiting for a repair like the one at the Axiom-6.
    husk.destructible = false
    state.s.husks[husk.unit_number] = {entity = husk, kind = "found"}
    return
  end
  local data = state.s.players[player.index]
  if data and (data.status == "active" or (data.husk and data.husk.valid)) then
    player.print({"", "[item=" .. shared.item .. "] ", {"nan-e.already-have"}}, {color = {1, 0.82, 0.9}})
    local quality = husk.quality and husk.quality.name or "normal"
    if player.insert{name = shared.item, count = 1, quality = quality} == 0 then
      husk.surface.spill_item_stack{position = husk.position, stack = {name = shared.item, count = 1, quality = quality}}
    end
    husk.destroy()
    return
  end
  husk.health = husk.max_health
  husk.destructible = false
  state.s.husks[husk.unit_number] = {entity = husk, kind = "new", owner = player.index, boot_tick = game.tick + boot_ticks}
  data = nanny.data_for(player)
  data.husk = husk
  data.status = "boot"
end

nanny.on_player_repaired = function(event)
  local record = husk_record(event.entity)
  if record then
    record.repairer = event.player_index
  end
end

-- "Come here": she drops her errand.
nanny.call = function(player)
  local data = state.s.players[player.index]
  if not (data and data.unit and data.unit.valid) then return end
  data.task = nil
  data.next_errand = game.tick + 5 * minute
  local char = player.character
  if char and data.unit.surface == char.surface then
    data.unit.commandable.set_command(go_to(char.position, 2))
    data.moving = true
  end
  speech.say(data, {"nan-e.call"}, {mood = "happy", ticks = 120})
end

nanny.toggle_quiet = function(player)
  local data = state.s.players[player.index]
  if not data then return end
  if data.quiet_until and game.tick < data.quiet_until then
    data.quiet_until = nil
    speech.say(data, {"nan-e.quiet-off"}, {mood = "happy", ticks = 180})
  else
    data.quiet_until = game.tick + 60 * minute
    speech.say(data, {"nan-e.quiet-on"}, {mood = "sleepy", ticks = 180})
  end
end

return nanny
