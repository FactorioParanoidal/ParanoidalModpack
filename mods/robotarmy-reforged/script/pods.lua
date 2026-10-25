-- Drop pods. Loading: the "Load" button of a squad in the army window writes up to
-- shared.pod.capacity droids of the squad (rank prototype, quality, health share, kills, land mines)
-- into the tags of an empty drop pod in the player's cursor or inventory; the droids leave the map.
-- The squad must be within shared.pod.load_range tiles of the player; garrisons cannot be loaded.
--
-- Landing: a placed pod with a squad cannot be mined; after shared.pod.open_ticks it opens, the
-- droids appear around it as one squad that holds the landing site (until released or sent with
-- the tool), and the empty pod can be mined back. A pod destroyed before it opens loses its squad.
--
-- storage.pods[unit_number] = {entity, droids = {...}, open_tick}
-- storage.pod_prebuild[player_index] = {tags, tick}: tags of the pod in the cursor when the player
--   starts building it (fallback if the consumed item of the built event carries no tags)
local shared = require("lib.shared")
local state = require("script.state")
local Squad = require("script.squad")
local droids = require("script.droids")
local compat = require("script.compat")
local ranks = require("script.ranks")
local util = require("script.util")

local P = shared.pod
local pods = {}

local function is_empty_pod(stack)
  return stack and stack.valid_for_read and stack.name == P.item and stack.get_tag(P.tag) == nil
end

local function empty_pod_of(player)
  if is_empty_pod(player.cursor_stack) then return player.cursor_stack end
  local inventory = player.get_main_inventory()
  if not inventory then return nil end
  for i = 1, #inventory do
    if is_empty_pod(inventory[i]) then return inventory[i] end
  end
  return nil
end

--- LocalisedString of many parts (at most 20 parameters per level).
local function join(parts)
  if #parts <= 19 then
    local out = {""}
    for i = 1, #parts do out[i + 1] = parts[i] end
    return out
  end
  local out, chunk = {""}, {}
  for i = 1, #parts do
    chunk[#chunk + 1] = parts[i]
    if #chunk == 19 then
      out[#out + 1] = join(chunk)
      chunk = {}
    end
  end
  if #chunk > 0 then out[#out + 1] = join(chunk) end
  return join({table.unpack(out, 2)})
end

--- Item tooltip: the droid kinds in the pod, how many of each and how many veterans.
local function describe(list)
  local counts, veterans, order = {}, {}, {}
  for _, d in pairs(list) do
    local kind = droids.kind[d.name] or d.name
    if not counts[kind] then order[#order + 1] = kind end
    counts[kind] = (counts[kind] or 0) + 1
    if (droids.rank[d.name] or 0) > 0 then veterans[kind] = (veterans[kind] or 0) + 1 end
  end
  local lines = {}
  for _, kind in pairs(order) do
    local icon = prototypes.item[kind] and ("[item=" .. kind .. "]") or ""
    lines[#lines + 1] = {"robotarmy-pod.line", icon, {"entity-name." .. kind}, counts[kind], veterans[kind] or 0}
  end
  return {"robotarmy-pod.description", #list, join(lines)}
end

--- Loads up to P.capacity droids of `squad` (veterans first) into `stack`, an empty drop pod.
--- Returns the number of droids loaded.
function pods.load(squad, stack)
  if not is_empty_pod(stack) or squad.deleted then return 0 end
  local members = {}
  for _, member in pairs(squad.members) do
    if member.valid then members[#members + 1] = member end
  end
  table.sort(members, function(a, b)
    local ra, rb = droids.rank[a.name] or 0, droids.rank[b.name] or 0
    if ra ~= rb then return ra > rb end
    return a.unit_number < b.unit_number
  end)
  local count = math.min(#members, P.capacity)
  if count == 0 then return 0 end
  local list = {}
  for i = 1, count do
    local member = members[i]
    local unit_number = member.unit_number
    list[i] = {
      name = member.name,
      quality = member.quality.name,
      health = member.health / member.max_health,
      kills = storage.kills[unit_number],
      mines = storage.mines[unit_number],
    }
  end
  stack.set_tag(P.tag, list)
  stack.custom_description = describe(list)
  for i = 1, count do
    local member = members[i]
    local unit_number = member.unit_number
    Squad.remove(squad, unit_number, true) -- quietly: loading is not losing the squad
    storage.units[unit_number] = nil
    storage.kills[unit_number] = nil
    storage.mines[unit_number] = nil
    storage.mine_tick[unit_number] = nil
    member.destroy({raise_destroy = true})
  end
  return count
end

--- The "Load" button: checks and messages for the player.
function pods.player_load(player, squad)
  local function say(text) player.create_local_flying_text({text = text, create_at_cursor = true}) end
  if squad.station or squad.mode == Squad.MODE.guard then
    say({"robotarmy-gui.pod-garrison"})
    return
  end
  local character = player.character
  local surface_index = character and character.surface_index or player.surface_index
  local position = character and character.position or player.position
  if squad.surface_index ~= surface_index or util.distance(squad.pos, position) > P.load_range then
    say({"robotarmy-gui.pod-too-far", P.load_range})
    return
  end
  local stack = empty_pod_of(player)
  if not stack then
    say({"robotarmy-gui.pod-none"})
    return
  end
  local left = squad.size
  local count = pods.load(squad, stack)
  say({"robotarmy-gui.pod-loaded", count, math.max(0, left - count)})
end

--- A pod is on the ground; `tags` are the tags of the item it was placed from.
function pods.placed(entity, tags)
  local list = tags and tags[P.tag]
  if type(list) ~= "table" or #list == 0 then return end -- an empty pod is only a container
  entity.minable_flag = false
  script.register_on_object_destroyed(entity)
  storage.pods[entity.unit_number] = {entity = entity, droids = list, open_tick = game.tick + P.open_ticks}
end

--- on_pre_build: remember the tags of a pod about to be placed from the cursor.
function pods.on_pre_build(event)
  local player = game.get_player(event.player_index)
  local stack = player and player.cursor_stack
  if stack and stack.valid_for_read and stack.name == P.item then
    storage.pod_prebuild[event.player_index] = {tags = stack.tags, tick = event.tick}
  end
end

function pods.on_built(event)
  local entity = event.entity or event.destination
  local tags
  local consumed = event.consumed_items
  if consumed and consumed.valid then
    for i = 1, #consumed do
      local stack = consumed[i]
      if stack.valid_for_read and stack.name == P.item then
        tags = stack.tags
        break
      end
    end
  end
  local stack = event.stack
  if not tags and stack and stack.valid_for_read and stack.name == P.item then
    tags = stack.tags
  end
  local index = event.player_index
  local pre = index and storage.pod_prebuild[index]
  if index then storage.pod_prebuild[index] = nil end
  if not (tags and tags[P.tag]) and pre and pre.tick == event.tick then tags = pre.tags end
  pods.placed(entity, tags)
end

local function droid_name(name)
  if droids.is_droid[name] then return name end
  local kind = type(name) == "string" and name:gsub("%-rank%-%d+$", "")
  return kind and droids.is_droid[kind] and kind or nil -- the rank prototype is gone: its kind
end

local function open(record)
  local pod = record.entity
  local surface, force = pod.surface, pod.force
  local fd = state.force_data(force)
  local squad
  local landed = 0
  for _, d in pairs(record.droids) do
    local name = droid_name(d.name)
    local quality = type(d.quality) == "string" and prototypes.quality[d.quality] and d.quality or "normal"
    local position = name and surface.find_non_colliding_position(name, pod.position, 15, 0.5)
    local droid = position and surface.create_entity({name = name, position = position, force = force, quality = quality})
    if droid then
      droid.health = math.max(1, droid.max_health * (tonumber(d.health) or 1))
      local unit_number = droid.unit_number
      storage.kills[unit_number] = tonumber(d.kills)
      storage.mines[unit_number] = tonumber(d.mines)
      state.track_unit(droid)
      if compat.unit_control then
        compat.unit_spawned(droid, pod)
      else
        if not squad then
          squad = Squad.create(fd, droid)
          squad.hold = true
          squad.hold_pos = util.copy_position(pod.position)
        end
        Squad.add(squad, droid)
      end
      ranks.mark(droid)
      script.raise_script_built({entity = droid})
      landed = landed + 1
    end
  end
  pod.minable_flag = true
  if squad then
    squad.order.dirty = true
    util.squad_message(force, {"robotarmy-message.pod-landed", squad.id, landed, util.gps(pod.position, surface)})
  end
end

--- Pods that are due open; destroyed ones lose their squad.
function pods.on_nth_tick(tick)
  for unit_number, record in pairs(storage.pods) do
    if not record.entity.valid then
      storage.pods[unit_number] = nil
    elseif tick >= record.open_tick then
      storage.pods[unit_number] = nil
      open(record)
    end
  end
end

--- Places a pod from an item stack (remote interface: scenarios and tests).
function pods.place_from_stack(stack, surface, position, force)
  if not (stack and stack.valid_for_read and stack.name == P.item) then return nil end
  local entity = surface.create_entity({name = P.entity, position = position, force = force})
  if not entity then return nil end
  pods.placed(entity, stack.tags)
  stack.clear()
  return entity
end

return pods
