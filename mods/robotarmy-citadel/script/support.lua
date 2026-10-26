-- Support work of the citadel, each a short look on the heartbeat:
--   repair   one repair dock per look heals the droids on its plaza and the buildings of one chunk
--            (its own or a neighbour, in turn)
--   cull     the truce does not stop the citadel from clearing its surroundings: every one to two
--            minutes it destroys a few biter nests and worms within the clearing radius of the city
--   jam      the jammers hide the city from the player maps once a minute
local S = require("lib.shared")
local U = require("script.util")
local P = require("script.production")
local forces = require("script.forces")

local SUP = {}

local HEAL_UNITS = 0.25
local HEAL_BUILDINGS = 0.1
local REPAIR_TYPES = {"wall", "gate", "electric-turret", "simple-entity-with-owner", "electric-energy-interface",
  "electric-pole", "accumulator", "radar", "lamp"}
local CULL_KILLS = 5
local CULL_CHUNKS = 32
local JAM_MAX = 6

local function heal(e, share)
  local max = e.max_health
  local h = e.health
  if h and max and h < max then e.health = math.min(max, h + max * share) end
end

function SUP.repair(c, surface)
  if (c.alive["repair-dock"] or 0) == 0 then return end
  local n = #c.order
  local i = c.dock_cursor or 0
  local m
  for _ = 1, n do
    i = i % n + 1
    local o = c.modules[c.order[i]]
    if o and o.type == "repair-dock" and o.built and not o.ruined then
      m = o
      break
    end
  end
  c.dock_cursor = i
  if not m then return end
  for _, e in pairs(surface.find_entities_filtered({position = P.muster_of(m), radius = 40, force = S.force,
    type = "unit", limit = 80})) do
    heal(e, HEAL_UNITS)
  end
  m.repair_i = (m.repair_i or 0) % 5 + 1
  local d = m.repair_i == 1 and {0, 0} or U.NEIGHBOURS4[m.repair_i - 1]
  local x, y = m.x + d[1], m.y + d[2]
  if c.modules[U.key(x, y)] then
    for _, e in pairs(surface.find_entities_filtered({area = U.area(x, y), force = S.force, type = REPAIR_TYPES})) do
      heal(e, HEAL_BUILDINGS)
    end
  end
end

--- Destroys a few nests and worms of the truce forces around the city (no evolution: they are
--- removed by script, not killed).
function SUP.cull(c, cfg, surface)
  local b = c.bbox
  local truce = forces.truce_names()
  if not b or #truce == 0 then return end
  local r = cfg.clear_radius
  local x1, y1 = b[1] - r, b[2] - r
  local w, h = b[3] + r - x1 + 1, b[4] + r - y1 + 1
  local total = w * h
  local i = c.cull_cursor or 0
  local killed = 0
  for _ = 1, math.min(total, CULL_CHUNKS) do
    i = i % total
    local cx, cy = x1 + i % w, y1 + math.floor(i / w)
    i = i + 1
    for _, e in pairs(surface.find_entities_filtered({area = U.area(cx, cy), force = truce,
      type = {"unit-spawner", "turret"}, limit = CULL_KILLS - killed})) do
      surface.create_entity({name = "big-explosion", position = e.position})
      e.destroy({raise_destroy = true})
      killed = killed + 1
    end
    if killed >= CULL_KILLS then break end
  end
  c.cull_cursor = i
end

--- Uncharts the city (and a ring around it) for every player force.
function SUP.jam(c, surface)
  local j = c.alive.jammer or 0
  local b = c.bbox
  if j == 0 or not b then return end
  local r = math.min(JAM_MAX, 1 + j + (c.alive.relay or 0))
  for _, force in pairs(forces.players()) do
    for x = b[1] - r, b[3] + r do
      for y = b[2] - r, b[4] + r do
        local chunk = {x, y}
        if force.is_chunk_charted(surface, chunk) then force.unchart_chunk(chunk, surface) end
      end
    end
  end
end

return SUP
