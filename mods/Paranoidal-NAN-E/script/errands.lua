-- Her own errands, now and then, while the engineer stands about in a quiet spot: she checks an idle machine and says
-- what is wrong with it (technical debt), rummages in a wreck or a ruin's chest (memory cards turn up there), or just
-- looks round the base. Half a minute at most; she drops it when he walks off or enemies come near.
local shared = require("shared")
local speech = require("script.speech")
local chatter = require("script.chatter")
local memory = require("script.memory")

local errands = {}

local minute = 3600
local gaps = {often = {3, 5}, rare = {5, 9}, silent = {6, 10}}  -- minutes between errands
local scan_radius = 40
local errand_ticks = 45 * 60
local leash = 40                 -- he walks farther than that from her: she comes back

local machine_types = {"assembling-machine", "furnace", "mining-drill", "lab"}
local S = defines.entity_status
-- Status -> locale key of [nan-e-debt] and how much it matters.
local debt =
{
  [S.not_plugged_in_electric_network] = {"not_plugged", 5},
  [S.no_power] = {"no_power", 5},
  [S.no_recipe] = {"no_recipe", 4},
  [S.no_minable_resources] = {"no_minable_resources", 4},
  [S.no_fuel] = {"no_fuel", 3},
  [S.missing_required_fluid] = {"missing_fluid", 3},
  [S.fluid_ingredient_shortage] = {"missing_fluid", 2},
  [S.no_input_fluid] = {"missing_fluid", 2},
  [S.low_power] = {"low_power", 2},
  [S.full_output] = {"full_output", 2},
  [S.no_research_in_progress] = {"no_research", 2},
  [S.item_ingredient_shortage] = {"no_ingredients", 1},
  [S.no_ingredients] = {"no_ingredients", 1},
  [S.missing_science_packs] = {"missing_science", 1}
}
errands.debt_keys = {"not_plugged", "no_power", "no_recipe", "no_minable_resources", "no_fuel", "missing_fluid",
  "low_power", "full_output", "no_research", "no_ingredients", "missing_science"}

local distance = function(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  return math.sqrt(dx * dx + dy * dy)
end

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

-- The machines round the engineer and what is wrong with them; kept for the window's summary.
errands.scan = function(data, player, char)
  local counts, candidates = {}, {}
  local found = char.surface.find_entities_filtered{position = char.position, radius = scan_radius,
    force = player.force, type = machine_types, limit = 400}
  for _, entity in pairs(found) do
    local entry = debt[entity.status]
    if entry and not entity.to_be_deconstructed() then
      counts[entry[1]] = (counts[entry[1]] or 0) + 1
      for _ = 1, entry[2] do
        candidates[#candidates + 1] = {entity = entity, key = entry[1]}
      end
    end
  end
  data.scan = {tick = game.tick, counts = counts, machines = #found}
  return candidates
end

local quiet_spot = function(player, char)
  if player.vehicle or player.walking_state.walking then return false end
  return not char.surface.find_nearest_enemy{position = char.position, max_distance = 30, force = player.force}
end

local begin = function(data, kind, target, position, radius)
  data.task = {kind = kind, target = target, position = position, deadline = game.tick + errand_ticks, phase = "go"}
  data.moving = nil
  data.unit.commandable.set_command(go_to(position, radius))
end

local start_inspect = function(data, player, candidates)
  local choice = candidates[math.random(#candidates)]
  local entity = choice.entity
  local box = entity.prototype.collision_box
  local size = math.max(box.right_bottom.x - box.left_top.x, box.right_bottom.y - box.left_top.y)
  begin(data, "inspect", entity, entity.position, size / 2 + 1)
  data.task.key = choice.key
  chatter.occasion(data, player, "debt-go", {"nan-e.debt-go"}, "neutral", 15 * minute)
  return true
end

local start_search = function(data, player, char)
  local candidates = {}
  for _, entity in pairs(char.surface.find_entities_filtered{position = char.position, radius = scan_radius,
    type = {"simple-entity", "simple-entity-with-owner", "container"}, limit = 200}) do
    if entity.name ~= shared.husk and (string.find(entity.name, "wreck", 1, true)
      or (entity.type == "container" and entity.force ~= player.force and not entity.force.get_friend(player.force))) then
      candidates[#candidates + 1] = entity
    end
  end
  if #candidates == 0 then return false end
  local target = candidates[math.random(#candidates)]
  begin(data, "search", target, target.position, 2)
  chatter.occasion(data, player, "search-go", {"nan-e.search-go"}, "neutral", 20 * minute)
  return true
end

local start_wander = function(data, player, char)
  local around = char.surface.find_entities_filtered{position = char.position, radius = 30, force = player.force,
    type = machine_types, limit = 50}
  if #around == 0 then return false end
  local target = around[math.random(#around)]
  begin(data, "wander", nil, target.position, 3)
  return true
end

-- When she is free near him: perhaps an errand. Returns whether one started.
errands.maybe_start = function(data, player, char)
  if game.tick < (data.next_errand or 0) then return false end
  local mode = chatter.mode(player)
  local gap = gaps[mode] or gaps.rare
  data.next_errand = game.tick + math.random(gap[1] * 60, gap[2] * 60) * 60
  if not player.mod_settings[shared.settings.errands].value then return false end
  if not quiet_spot(player, char) then return false end
  local candidates = errands.scan(data, player, char)
  local roll = math.random()
  if roll < 0.55 and chatter.allowed(data, player) then
    if #candidates > 0 then
      return start_inspect(data, player, candidates)
    end
    chatter.occasion(data, player, "debt-none", {"nan-e.debt-none"}, "surprised", 60 * minute)
    return false
  elseif roll < 0.85 then
    return start_search(data, player, char)
  end
  return start_wander(data, player, char)
end

-- Started from the outside (the remote interface): "inspect", "search" or "wander".
errands.force_start = function(data, player, kind)
  local char = player.character
  if not (char and data.unit and data.unit.valid) then return false end
  if kind == "inspect" then
    local candidates = errands.scan(data, player, char)
    return #candidates > 0 and start_inspect(data, player, candidates)
  elseif kind == "search" then
    return start_search(data, player, char)
  end
  return start_wander(data, player, char)
end

local finish = function(data)
  data.task = nil
  data.moving = nil
end

local give_card = function(data, player, char)
  if player.insert{name = shared.card, count = 1} == 0 then
    char.surface.spill_item_stack{position = char.position, stack = {name = shared.card, count = 1}}
  end
  speech.sound(data, shared.sounds.card)
  speech.say(data, {"nan-e.search-found"}, {mood = "happy", silent = true})
end

-- Every 30 ticks while she is on an errand.
errands.update = function(data, player, char)
  local task = data.task
  local unit = data.unit
  if distance(unit.position, char.position) > leash or game.tick > task.deadline
    or (task.phase ~= "back" and not quiet_spot(player, char) and player.walking_state.walking) then
    if task.carrying then
      give_card(data, player, char)
    end
    finish(data)
    return
  end
  if task.phase == "go" then
    if task.target and not task.target.valid then
      finish(data)
      return
    end
    local reach = task.kind == "inspect" and 4 or 3
    if distance(unit.position, task.position) <= reach then
      task.phase = "look"
      task.until_tick = game.tick + (task.kind == "search" and 180 or 120)
      unit.commandable.set_command{type = defines.command.stop, ticks_to_wait = 200, distraction = defines.distraction.none}
      if task.kind == "search" then
        speech.sound(data, shared.sounds.vacuum, true)
      end
    end
  elseif task.phase == "look" then
    if game.tick < task.until_tick then return end
    if task.kind == "inspect" then
      if task.target.valid and chatter.allowed(data, player) then
        speech.say(data, {"nan-e-debt." .. task.key .. "-" .. math.random(2), "[entity=" .. task.target.name .. "]"},
          {mood = "stern", ticks = 540})
      end
      finish(data)
    elseif task.kind == "search" then
      if memory.search_card(player.force) then
        task.carrying = true
        task.phase = "back"
        unit.commandable.set_command(go_to(char.position, 2))
      else
        chatter.occasion(data, player, "search-nothing", {"nan-e.search-nothing-" .. math.random(3)}, "neutral", 10 * minute)
        finish(data)
      end
    else
      if math.random() < 0.3 then
        chatter.occasion(data, player, "wander", {"nan-e.wander-" .. math.random(3)}, "neutral", 15 * minute)
      end
      finish(data)
    end
  elseif task.phase == "back" then
    if distance(unit.position, char.position) <= 4 then
      give_card(data, player, char)
      finish(data)
    else
      unit.commandable.set_command(go_to(char.position, 2))
    end
  end
end

return errands
