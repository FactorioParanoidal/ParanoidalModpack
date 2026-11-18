-- What Д-ОК flags as a foreign contaminant, where he stands to scrub it, and what each stroke of his brush does to it.
--
-- Kinds (target.kind):
--   decor   decoratives on a paved tile (grass, grit, and the muddy prints of script/tracks.lua); by tile
--   item    items lying on the floor: sucked into his bin
--   corpse  remains and remnants (corpse, rail-remnants): scrubbed away
--   wreck   small wreck debris (a name with "wreck"; containers only when empty): broken down, a part at a time
--   player  a dirty engineer on the paving (script/droid.lua chases him)
-- Entities need not be on the paving, only next to it: he scrubs from the floor.
local shared = require("shared")
local paving = require("script.paving")
local reactions = require("script.reactions")

local contaminants = {}

local geometry = shared.graphics[settings.startup[shared.settings.graphics].value] or shared.graphics.own
-- He parks this far from what he scrubs: his lowered brush meets the floor there.
contaminants.stand_off = geometry.brush_reach

local entity_types = {"item-entity", "corpse", "rail-remnants", "simple-entity", "simple-entity-with-owner", "container"}
local kind_of_type =
{
  ["item-entity"] = "item",
  ["corpse"] = "corpse",
  ["rail-remnants"] = "corpse",
  ["simple-entity"] = "wreck",
  ["simple-entity-with-owner"] = "wreck",
  ["container"] = "wreck"
}

-- Wreck debris by name: the crash site's and AAI's wrecks, whoever placed them; never the invisible mining targets of
-- the BnL start, nor anything without "wreck" in its name (the ship itself, the BnL compartments, rocks, chests).
local wreck_names = {}
local is_wreck_name = function(name)
  local known = wreck_names[name]
  if known == nil then
    known = name:find("wreck", 1, true) ~= nil and name:find("paranoidal-shipwreck-mining-", 1, true) ~= 1
    wreck_names[name] = known
  end
  return known
end

contaminants.tile_key = function(x, y)
  return x .. "," .. y
end

local entity_key = function(entity)
  local position = entity.position
  return entity.name .. "@" .. position.x .. "," .. position.y
end

-- Where a target is, for distances: a tile's centre, an entity's position.
contaminants.anchor = function(target)
  if target.kind == "decor" then
    return {x = target.x + 0.5, y = target.y + 0.5}
  end
  return {x = target.x, y = target.y}
end

-- The scanner's reading, as in the film: a percentage of "foreign contaminant".
contaminants.reading = function(target)
  local kind = target.kind
  if kind == "decor" then
    if target.prints then
      return 60 + (target.x * 7 + target.y * 13) % 33
    end
    return 8 + (target.x * 5 + target.y * 11) % 30
  elseif kind == "item" then
    return 25
  elseif kind == "corpse" then
    return 64
  elseif kind == "wreck" then
    return 87
  end
  return target.reading or 100
end

local box_of = function(entity)
  local box = entity.bounding_box
  local lt, rb = box.left_top, box.right_bottom
  return lt.x, lt.y, rb.x, rb.y
end

-- The four places he could stand to scrub an entity (or a tile): off the middle of each side, facing it.
local approach_points = function(target)
  local x1, y1, x2, y2
  if target.kind == "decor" then
    local cx, cy = target.x + 0.5, target.y + 0.5
    x1, y1, x2, y2 = cx, cy, cx, cy
  else
    local entity = target.entity
    if not (entity and entity.valid) then return {} end
    x1, y1, x2, y2 = box_of(entity)
  end
  local cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
  local d = contaminants.stand_off
  return
  {
    {stand = {x = x2 + d, y = cy}, brush = {x = x2, y = cy}},
    {stand = {x = x1 - d, y = cy}, brush = {x = x1, y = cy}},
    {stand = {x = cx, y = y2 + d}, brush = {x = cx, y = y2}},
    {stand = {x = cx, y = y1 - d}, brush = {x = cx, y = y1}}
  }
end

-- Cheap check at scan time: is there paving on any side to scrub it from?
local next_to_paving = function(surface, target)
  if target.kind == "decor" then return true end
  for _, point in pairs(approach_points(target)) do
    local stand = point.stand
    if paving.is_paved(surface.get_tile(stand.x, stand.y).name) then
      return true
    end
  end
  return false
end

-- Whether the bot fits at a point: all of it on paved floor, clear of buildings and trains (other units move off).
local fits = function(surface, point)
  local half = shared.bot_size
  for x = math.floor(point.x - half), math.floor(point.x + half - 0.001) do
    for y = math.floor(point.y - half), math.floor(point.y + half - 0.001) do
      if not paving.is_paved(surface.get_tile(x, y).name) then
        return false
      end
    end
  end
  local area = {{point.x - half, point.y - half}, {point.x + half, point.y + half}}
  for _, entity in pairs(surface.find_entities_filtered{area = area, collision_mask = {"player", "train"}}) do
    if entity.type ~= "unit" and entity.type ~= "character" then
      return false
    end
  end
  return true
end

-- Where to stand and where his brush lands, on the nearest side he fits.
contaminants.approach = function(surface, target, from)
  local best, best_distance
  for _, point in pairs(approach_points(target)) do
    local dx, dy = point.stand.x - from.x, point.stand.y - from.y
    local away = dx * dx + dy * dy
    if (not best_distance or away < best_distance) and fits(surface, point.stand) then
      best, best_distance = point, away
    end
  end
  return best
end

-- Whether the target is still dirty: the tile still has decoratives, the entity is still there (and a wreck chest is
-- still empty: he doesn't go through anyone's things).
contaminants.still_there = function(surface, target)
  local kind = target.kind
  if kind == "decor" then
    return surface.find_decoratives_filtered{position = {target.x, target.y}, limit = 1}[1] ~= nil and
      paving.is_paved(surface.get_tile(target.x, target.y).name)
  end
  local entity = target.entity
  if not (entity and entity.valid) then return false end
  if kind == "wreck" and entity.type == "container" then
    local inventory = entity.get_inventory(defines.inventory.chest)
    if inventory and not inventory.is_empty() then return false end
  end
  return true
end

-- One scan cell: what in it is dirty and not yet known, skipped or claimed by another bot.
contaminants.scan_cell = function(data, surface, x1, y1, size, is_skipped, force)
  local keys = data.queue_keys
  local queue = data.queue
  for _, found in pairs(surface.find_decoratives_filtered{area = {{x1, y1}, {x1 + size, y1 + size}}}) do
    local position = found.position
    local key = contaminants.tile_key(position.x, position.y)
    if not keys[key] and not is_skipped(key) and paving.is_paved(surface.get_tile(position.x, position.y).name) then
      keys[key] = true
      local name = found.decorative.name
      queue[#queue + 1] =
      {
        kind = "decor",
        key = key,
        x = position.x,
        y = position.y,
        prints = (name == shared.footprints or name == shared.mud) or nil
      }
    end
  end
  for _, entity in pairs(surface.find_entities_filtered{area = {{x1, y1}, {x1 + size, y1 + size}}, type = entity_types}) do
    local kind = kind_of_type[entity.type]
    if kind == "wreck" and not (is_wreck_name(entity.name) and not force.is_enemy(entity.force)) then
      kind = nil
    end
    if kind then
      local key = entity_key(entity)
      if not keys[key] and not is_skipped(key) then
        local position = entity.position
        local target = {kind = kind, key = key, x = position.x, y = position.y, entity = entity}
        if contaminants.still_there(surface, target) and next_to_paving(surface, target) then
          keys[key] = true
          queue[#queue + 1] = target
        end
      end
    end
  end
end

-- ------------------------------------------------------------------ strokes

-- One decorative scrubbed off a tile, its bits flying if it has any (data-final-fixes.lua). Names are kept per tile:
-- decoratives of one kind on a tile merge.
local scrubbed_effects = {}
local scrub_off = function(surface, position, name)
  local effect = scrubbed_effects[name]
  if effect == nil then
    effect = prototypes.entity[shared.scrubbed .. name] and shared.scrubbed .. name or false
    scrubbed_effects[name] = effect
  end
  surface.destroy_decoratives{position = position, name = name, limit = 1}
  if effect then
    surface.create_entity{name = effect, position = {position[1] + 0.5, position[2] + 0.5}}
  end
end

local puff = function(surface, position)
  surface.create_entity{name = shared.dust, position = position}
end

-- How many strokes an entity takes, from its size: debris up to 16, remains 2 or 3.
local strokes_for = function(target)
  local entity = target.entity
  local x1, y1, x2, y2 = box_of(entity)
  local area = math.max(0.25, (x2 - x1) * (y2 - y1))
  if target.kind == "wreck" then
    return math.max(4, math.min(16, math.floor(area * 1.5 + 0.5)))
  end
  return area > 1 and 3 or 2
end

-- What a wreck breaks into: its mining products, weighted by their expected amounts. Cached per wreck name.
local wreck_parts = {}
local parts_of = function(entity)
  local name = entity.name
  local parts = wreck_parts[name]
  if parts then return parts end
  parts = {total = 0}
  local properties = entity.prototype.mineable_properties
  for _, product in pairs(properties and properties.products or {}) do
    if product.type == "item" and prototypes.item[product.name] then
      local amount = product.amount or ((product.amount_min or 0) + (product.amount_max or 0)) / 2
      local weight = amount * (product.probability or 1)
      if weight > 0 then
        parts[#parts + 1] = {name = product.name, weight = weight}
        parts.total = parts.total + weight
      end
    end
  end
  wreck_parts[name] = parts
  return parts
end

local pick_part = function(entity)
  local parts = parts_of(entity)
  if parts.total <= 0 then return end
  local roll = math.random() * parts.total
  for _, part in ipairs(parts) do
    roll = roll - part.weight
    if roll <= 0 then
      return part.name
    end
  end
  return parts[#parts].name
end

-- One stroke of his brush on a target. Returns "more" (keep scrubbing), "done" or "full" (his bin can't take it).
contaminants.stroke = function(data, target)
  local surface = data.bot.surface
  local kind = target.kind
  if kind == "decor" then
    local position = {target.x, target.y}
    local found = surface.find_decoratives_filtered{position = position, limit = 2}
    if found[1] then
      scrub_off(surface, position, found[1].decorative.name)
    end
    if found[2] then return "more" end
    if found[1] then
      puff(surface, {target.x + 0.5, target.y + 0.5})
    end
    return "done", found[1] ~= nil
  end

  local entity = target.entity
  if not (entity and entity.valid) then return "done" end

  if kind == "item" then
    local stack = entity.stack
    if not stack.valid_for_read then
      entity.destroy()
      return "done"
    end
    local count = stack.count
    local inserted = data.backpack.insert(stack)
    if inserted > 0 then
      reactions.say(data, shared.sounds.pickup, entity.position)
    end
    if inserted >= count then
      entity.destroy()
      return "done", not entity.valid
    end
    if inserted > 0 then
      stack.count = count - inserted
    end
    return "full"
  end

  if kind == "corpse" then
    target.needed = target.needed or strokes_for(target)
    target.strokes = (target.strokes or 0) + 1
    if target.strokes >= target.needed then
      local position = entity.position
      entity.destroy()
      puff(surface, position)
      return "done", not entity.valid
    end
    return "more"
  end

  if kind == "wreck" then
    if not contaminants.still_there(surface, target) then return "done" end
    target.needed = target.needed or strokes_for(target)
    target.strokes = (target.strokes or 0) + 1
    -- A part breaks off every other stroke: a few units of what the wreck is made of, never what mining it gives.
    if target.strokes % 2 == 0 then
      local part = pick_part(entity)
      if part then
        local inserted = data.backpack.insert{name = part, count = 1, quality = entity.quality.name}
        if inserted == 0 then
          target.strokes = target.strokes - 1
          return "full"
        end
        reactions.say(data, shared.sounds.clank, entity.position)
        reactions.label(surface, entity, {"", "[item=", part, "] +1"}, reactions.colours.note, 60, {0, -0.6})
      end
    end
    if target.strokes >= target.needed then
      local position = entity.position
      entity.destroy{raise_destroy = true}
      puff(surface, position)
      return "done", not entity.valid
    end
    -- The wreck's health bar shows how far along he is.
    local max_health = entity.max_health
    if max_health and max_health > 0 then
      entity.health = math.max(1, max_health * (1 - target.strokes / target.needed))
    end
    if target.strokes == 4 or target.strokes == 10 then
      reactions.say(data, shared.sounds.grumble)
    end
    return "more"
  end
  return "done"
end

return contaminants
