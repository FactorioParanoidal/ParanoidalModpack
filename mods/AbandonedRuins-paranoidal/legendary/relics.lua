-- Runtime of relic buildings (rewards of legendary ruins). Relics whose effect needs a script
-- are registered when built; the rest are plain prototypes (see prototypes/relics.lua).
local F = require("legendary.feats")

local R = {}

R.PREFIX = "pd-relic-"

-- Relics with scripted effects: interval in ticks (0 = event driven only).
R.SCRIPTED = {
  ["pd-relic-minelayer"] = 600,
  ["pd-relic-forerunner-gate"] = 0,
  ["pd-relic-time-anchor"] = 0,
  ["pd-relic-themis-scales"] = 300,
  ["pd-relic-champion-banner"] = 120,
  ["pd-relic-healing-spring"] = 60,
  ["pd-relic-hammer"] = 1800,
  ["pd-relic-rescue-beacon"] = 3600,
  ["pd-relic-star-telescope"] = 36000,
  ["pd-relic-funeral-bell"] = 0,
  ["pd-relic-eternal-spring"] = 60,
}

function R.names()
  local list = {}
  for name in pairs(R.SCRIPTED) do list[#list + 1] = name end
  table.sort(list)
  return list
end

local function state()
  local L = storage.legend
  L.relics = L.relics or {}
  L.relic_reg = L.relic_reg or {}
  L.anchor_ready = L.anchor_ready or {}
  return L
end

function R.on_built(entity)
  if not (entity and entity.valid and R.SCRIPTED[entity.name]) then return end
  local L = state()
  local id = entity.unit_number
  L.relics[id] = { entity = entity, name = entity.name, force = entity.force.index, born = game.tick }
  local reg = script.register_on_object_destroyed(entity)
  L.relic_reg[reg] = id
  if entity.name == "pd-relic-star-telescope" then R.telescope(entity, true) end
end

-- Any relic built (scripted or not) is reported to other mods.
function R.count_built(entity)
  F.force(entity.force, "relic-built", { member = entity.name })
end

function R.on_died(entity)
  if entity and entity.valid and entity.name:sub(1, #R.PREFIX) == R.PREFIX then
    F.force(entity.force, "relic-died", { member = entity.name })
  end
  if entity.name == "pd-relic-rescue-beacon" then L.relics[id].next_drop = game.tick + 60 * 60 * 30 end
end

function R.on_object_destroyed(event)
  local L = storage.legend
  local id = L and L.relic_reg and L.relic_reg[event.registration_number]
  if not id then return false end
  L.relic_reg[event.registration_number] = nil
  L.relics[id] = nil
  return true
end

local function of_force(name, force_index, surface_index)
  local out = {}
  local L = storage.legend
  for _, r in pairs(L and L.relics or {}) do
    if r.name == name and r.force == force_index and r.entity.valid
      and (surface_index == nil or r.entity.surface_index == surface_index) then
      out[#out + 1] = r.entity
    end
  end
  table.sort(out, function(a, b) return a.unit_number < b.unit_number end)
  return out
end

-- Minelayer: plants land mines from its inventory around itself, and makes one itself every minute.
local MINES = { "land-mine", "bob-poison-mine", "bob-slowdown-mine", "bob-distractor-mine" }
local function minelayer(r)
  local e = r.entity
  local surface = e.surface
  local count = surface.count_entities_filtered({ position = e.position, radius = 14, type = "land-mine", force = e.force })
  if count >= 24 then return end
  local inv = e.get_inventory(defines.inventory.chest)
  local name, quality = nil, nil
  for _, mine in ipairs(MINES) do
    if prototypes.item[mine] and inv.get_item_count(mine) > 0 then
      for _, content in pairs(inv.get_contents()) do
        if content.name == mine then quality = content.quality break end
      end
      inv.remove({ name = mine, count = 1, quality = quality })
      name = mine
      break
    end
  end
  r.cycles = (r.cycles or 0) + 1
  if not name and r.cycles % 6 == 0 then name, quality = "land-mine", nil end
  if not name then return end
  for _ = 1, 12 do
    local a, d = math.random() * 2 * math.pi, 5 + math.random() * 9
    local pos = { x = e.position.x + math.cos(a) * d, y = e.position.y + math.sin(a) * d }
    if surface.can_place_entity({ name = name, position = pos, force = e.force }) then
      surface.create_entity({ name = name, position = pos, force = e.force, quality = quality, raise_built = true })
      return
    end
  end
end

-- Scales of Themis: k+1 items of defect grade -k become one standard item.
local function scales(r)
  local inv = r.entity.get_inventory(defines.inventory.chest)
  for _, content in pairs(inv.get_contents()) do
    local grade = tonumber((content.quality or ""):match("^ic%-defect%-([1-5])$"))
    if grade then
      local need = grade + 1
      local batches = math.floor(content.count / need)
      if batches > 0 and inv.can_insert({ name = content.name, count = 1 }) then
        local removed = inv.remove({ name = content.name, count = batches * need, quality = content.quality })
        local made = math.floor(removed / need)
        local rest = removed - made * need
        if made > 0 then
          inv.insert({ name = content.name, count = made })
          F.force(r.entity.force, "themis", { member = r.name, amount = made * need })
        end
        if rest > 0 then inv.insert({ name = content.name, count = rest, quality = content.quality }) end
      end
    end
  end
end

local REPAIR_TYPES = { "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret", "turret", "wall", "gate" }
local function banner(r)
  local e = r.entity
  for _, t in pairs(e.surface.find_entities_filtered({ position = e.position, radius = 24, force = e.force, type = REPAIR_TYPES })) do
    if t.valid and t.health and t.health < t.max_health then
      t.health = math.min(t.max_health, t.health + t.max_health * 0.03)
    end
  end
end

local function spring(r)
  local e = r.entity
  for _, c in pairs(e.surface.find_entities_filtered({ position = e.position, radius = 12, type = "character" })) do
    if c.valid and c.health and not e.force.is_enemy(c.force) and c.health < c.max_health then
      c.health = math.min(c.max_health, c.health + 25)
    end
  end
end

local function hammer(r)
  local e = r.entity
  if e.get_item_count("artillery-shell") < 5 and prototypes.item["artillery-shell"] then
    e.insert({ name = "artillery-shell", count = 1 })
  end
end

local POD_GOODS = {
  { "iron-plate", 50, 150 }, { "copper-plate", 50, 150 }, { "steel-plate", 10, 40 },
  { "electronic-circuit", 10, 40 }, { "iron-gear-wheel", 20, 60 }, { "firearm-magazine", 20, 60 },
  { "piercing-rounds-magazine", 10, 30 }, { "repair-pack", 10, 30 }, { "raw-fish", 5, 15 },
  { "coal", 50, 150 }, { "stone-brick", 50, 100 }, { "engine-unit", 2, 8 }, { "explosives", 10, 30 },
}
local function rescue(r)
  if game.tick < (r.next_drop or 0) then return end
  r.next_drop = game.tick + 60 * 60 * 30
  local e = r.entity
  local surface = e.surface
  local pos = surface.find_non_colliding_position("crash-site-chest-1", {
    x = e.position.x + math.random(-6, 6), y = e.position.y + math.random(-6, 6) }, 10, 0.5)
  if not pos then return end
  local pod = surface.create_entity({ name = "crash-site-chest-1", position = pos, force = "neutral" })
  if not pod then return end
  for _ = 1, 4 do
    local g = POD_GOODS[math.random(#POD_GOODS)]
    if prototypes.item[g[1]] then pod.insert({ name = g[1], count = math.random(g[2], g[3]) }) end
  end
  surface.create_entity({ name = "big-explosion", position = pos })
  e.force.print({ "pd-legendary-relic.rescue-drop", string.format("[gps=%d,%d,%s]", math.floor(pos.x), math.floor(pos.y), surface.name) })
end

local function eternal_spring(r)
  if prototypes.fluid["crude-oil"] then r.entity.insert_fluid({ name = "crude-oil", amount = 1200 }) end
end

-- Star telescope: shows the owner force every legendary ruin of its surface.
function R.telescope(entity, announce)
  local L = storage.legend
  local count, new = 0, 0
  for _, site in pairs(L.sites) do
    if site.surface == entity.surface_index and site.state ~= "waiting" and site.state ~= "lost" then
      count = count + 1
      local force = entity.force
      local tag = site.tags[force.index]
      local known = (tag and tag.valid) or (site.tag_wait and site.tag_wait[force.index])
      if not site.found[force.index] and not known then
        new = new + 1
        site.tag_wait = site.tag_wait or {}
        site.tag_wait[force.index] = site.state == "dormant" and "signal-lock" or "signal-unlock"
        force.chart(entity.surface, {
          { site.x - site.half - 32, site.y - site.half - 32 }, { site.x + site.half + 32, site.y + site.half + 32 } })
      end
    end
  end
  if announce or new > 0 then entity.force.print({ "pd-legendary-relic.telescope", count }) end
end

local HANDLERS = {
  ["pd-relic-minelayer"] = minelayer,
  ["pd-relic-themis-scales"] = scales,
  ["pd-relic-champion-banner"] = banner,
  ["pd-relic-healing-spring"] = spring,
  ["pd-relic-hammer"] = hammer,
  ["pd-relic-rescue-beacon"] = rescue,
  ["pd-relic-star-telescope"] = function(r) R.telescope(r.entity) end,
  ["pd-relic-eternal-spring"] = eternal_spring,
}

function R.on_tick(tick)
  local L = storage.legend
  if not (L and L.relics) or tick % 60 ~= 0 then return end
  for id, r in pairs(L.relics) do
    if not r.entity.valid then
      L.relics[id] = nil
    else
      local interval = R.SCRIPTED[r.name]
      local handler = HANDLERS[r.name]
      if handler and interval > 0 and (tick - r.born) % interval < 60 and tick ~= r.born then handler(r) end
    end
  end
end

-- Forerunner gates: stepping on one sends the player to the next gate of the force (ring order).
function R.on_player_changed_position(player)
  local L = storage.legend
  if not (L and L.relics) or not next(L.relics) then return end
  local char = player.character
  if not (char and char.valid) then return end
  local gates = of_force("pd-relic-forerunner-gate", player.force.index, player.surface_index)
  if #gates < 2 then return end
  L.gate_cooldown = L.gate_cooldown or {}
  local pos = char.position
  for i, gate in ipairs(gates) do
    local gp = gate.position
    if math.abs(gp.x - pos.x) < 0.9 and math.abs(gp.y - pos.y) < 0.9 then
      local last = L.gate_cooldown[player.index]
      if last and game.tick - last < 120 then return end
      local target = gates[i % #gates + 1]
      local dest = { x = target.position.x, y = target.position.y + 1.6 }
      local mover = player.vehicle or char
      dest = target.surface.find_non_colliding_position(mover.name, dest, 4, 0.5) or dest
      L.gate_cooldown[player.index] = game.tick
      mover.teleport(dest)
      target.surface.create_entity({ name = "spark-explosion", position = dest })
      F.player(player, "gate", { member = "pd-relic-forerunner-gate" })
      return
    end
  end
end

-- Time anchor: on death the character's belongings are pulled into the force's anchor.
local CHARACTER_INVENTORIES = { "character_main", "character_guns", "character_ammo", "character_armor", "character_trash" }
function R.on_pre_player_died(player)
  local char = player.character
  if not (char and char.valid) then return end
  local L = storage.legend
  if not (L and L.relics) then return end
  local anchors = of_force("pd-relic-time-anchor", player.force.index, nil)
  if #anchors == 0 then return end
  L.anchor_ready = L.anchor_ready or {}
  local ready = L.anchor_ready[player.force.index] or 0
  if game.tick < ready then
    player.print({ "pd-legendary-relic.anchor-charging", math.ceil((ready - game.tick) / 3600) })
    return
  end
  local anchor = anchors[1]
  for _, a in ipairs(anchors) do
    if a.surface_index == char.surface_index then anchor = a break end
  end
  local store = anchor.get_inventory(defines.inventory.chest)
  local moved = 0
  for _, inv_name in ipairs(CHARACTER_INVENTORIES) do
    local inv = char.get_inventory(defines.inventory[inv_name])
    if inv then
      for i = 1, #inv do
        local stack = inv[i]
        if stack.valid_for_read then
          local slot = store.find_empty_stack()
          if not slot then break end
          if slot.transfer_stack(stack) then moved = moved + 1 end
        end
      end
    end
  end
  if moved > 0 then
    L.anchor_ready[player.force.index] = game.tick + 60 * 60 * 20
    F.player(player, "anchor", { member = "pd-relic-time-anchor" })
    player.force.print({ "pd-legendary-relic.anchor-saved", player.name,
      string.format("[gps=%d,%d,%s]", math.floor(anchor.position.x), math.floor(anchor.position.y), anchor.surface.name) })
  end
end

-- Funeral bell: a respawned player appears next to the force's bell on the same surface.
function R.on_player_respawned(player)
  local bells = of_force("pd-relic-funeral-bell", player.force.index, player.surface_index)
  local bell = bells[1]
  local char = player.character
  if not (bell and char and char.valid) then return end
  local dest = bell.surface.find_non_colliding_position(char.name, { x = bell.position.x, y = bell.position.y + 2 }, 8, 0.5)
  if dest then
    player.teleport(dest, bell.surface)
    player.print({ "pd-legendary-relic.bell" })
    F.player(player, "bell", { member = "pd-relic-funeral-bell" })
  end
end

return R
