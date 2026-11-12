-- Blueprint wires of the bushings (0.2.0). The bushing poles are hidden and not blueprintable, so a blueprint or a
-- copy-paste keeps their copper wires in the transformer's tags: the offset and name of every pole (or other
-- transformer) of the same blueprint that a bushing was wired to. When the transformer is built from it, the wires
-- come back to the poles standing there; poles still to be built get theirs when they are built. A rotated or flipped
-- blueprint is recognised: of the 8 variants the one under which most recorded poles or their ghosts are found is used.
local S = require("shared")

local M = {}
local copper = defines.wire_connector_id.pole_copper
local PLAYER = defines.wire_origin.player
local KEEP = 36000 -- a pending wire waits 10 min for its pole

local function key(x, y)
  return string.format("%d:%d", math.floor(x * 4 + 0.5), math.floor(y * 4 + 0.5))
end

-- variant 1 is the blueprint as it was made; 2-4 rotate by 90 degrees, 5-8 are the same flipped
local function transform(v, x, y)
  if v > 4 then x = -x end
  for _ = 1, (v - 1) % 4 do x, y = -y, x end
  return x, y
end

local function owner_of_bushing(pole)
  local b = storage.bush and storage.bush[pole.unit_number]
  return b and storage.tr[b.u], b and b.s
end

-- tags for one transformer: list of { s = "i"|"o", x, y, n = pole name } and for a wire to another transformer's bushing
-- { s, x, y, n = transformer name, t = "i"|"o" }; only targets that are in the same blueprint (index_of) are kept
function M.record(m, index_of)
  local out = {}
  local e = m.e
  if not (e and e.valid) then return out end
  local pos = e.position
  for side, pole in pairs({ i = m.pin, o = m.pout }) do
    local c = pole and pole.valid and pole.get_wire_connector(copper, false)
    if c then
      for _, w in ipairs(c.real_connections) do
        local o = w.target.owner
        if o.valid and o ~= m.ain and o ~= m.aout then
          if o.name == S.POLE_IN or o.name == S.POLE_OUT then
            local other, oside = owner_of_bushing(o)
            if other and other.e.valid and index_of[other.e.unit_number] then
              local op = other.e.position
              out[#out + 1] = { s = side, x = op.x - pos.x, y = op.y - pos.y, n = other.e.name, t = oside }
            end
          elseif o.unit_number and index_of[o.unit_number] then
            local op = o.position
            out[#out + 1] = { s = side, x = op.x - pos.x, y = op.y - pos.y, n = o.name }
          end
        end
      end
    end
  end
  return out
end

-- the wire connector a recorded wire goes to at (x, y): a built pole, or a bushing of a built transformer
local function target_con(surface, x, y, w)
  local ent = surface.find_entity(w.n, { x, y })
  if not ent then return nil end
  if w.t then
    local o = storage.tr[ent.unit_number]
    local p = o and (w.t == "i" and o.pin or o.pout)
    return p and p.valid and p.get_wire_connector(copper, true) or nil
  end
  return ent.get_wire_connector(copper, true)
end

local function ghost_at(surface, x, y, name)
  for _, g in ipairs(surface.find_entities_filtered({ ghost_name = name, position = { x, y }, radius = 0.1 })) do
    if g.valid then return g end
  end
  return nil
end

local function connect(m, side, con)
  local pole = side == "i" and m.pin or m.pout
  if not (pole and pole.valid and con and con.valid) then return false end
  return pole.get_wire_connector(copper, true).connect_to(con, false, PLAYER)
end

local function add_pending(surface, x, y, entry)
  local s = storage.pending[surface.index]
  if not s then
    s = {}
    storage.pending[surface.index] = s
  end
  local k = key(x, y)
  local l = s[k]
  if not l then
    l = {}
    s[k] = l
  end
  entry.tick = game.tick
  l[#l + 1] = entry
end

-- a transformer was built with recorded wires
function M.restore(m, wires)
  local e = m.e
  if not (e and e.valid and type(wires) == "table" and #wires > 0) then return end
  local surface, pos = e.surface, e.position
  local best, best_n = 1, 0
  for v = 1, 8 do
    local n = 0
    for _, w in ipairs(wires) do
      if type(w) == "table" and type(w.x) == "number" and type(w.y) == "number" and type(w.n) == "string" then
        local x, y = transform(v, w.x, w.y)
        x, y = pos.x + x, pos.y + y
        if surface.find_entity(w.n, { x, y }) or ghost_at(surface, x, y, w.n) then n = n + 1 end
      end
    end
    if n > best_n then best, best_n = v, n end
  end
  if best_n == 0 then return end
  for _, w in ipairs(wires) do
    if type(w) == "table" and type(w.x) == "number" and type(w.y) == "number" and type(w.n) == "string"
      and (w.s == "i" or w.s == "o") and (w.t == nil or w.t == "i" or w.t == "o") then
      local x, y = transform(best, w.x, w.y)
      x, y = pos.x + x, pos.y + y
      local con = target_con(surface, x, y, w)
      if con then
        connect(m, w.s, con)
      elseif ghost_at(surface, x, y, w.n) then
        add_pending(surface, x, y, { u = m.unit, s = w.s, n = w.n, t = w.t })
      end
    end
  end
end

-- an entity was built where a recorded wire waits for it (a pole, or a transformer for bushing-to-bushing wires)
function M.on_built(entity)
  local s = storage.pending[entity.surface.index]
  if not s then return end
  local p = entity.position
  local k = key(p.x, p.y)
  local l = s[k]
  if not l then return end
  local keep = {}
  for _, w in ipairs(l) do
    local m = storage.tr[w.u]
    if m and m.e.valid and w.n == entity.name then
      local con
      if w.t then
        local o = storage.tr[entity.unit_number]
        local pole = o and (w.t == "i" and o.pin or o.pout)
        con = pole and pole.valid and pole.get_wire_connector(copper, true)
      else
        con = entity.get_wire_connector(copper, true)
      end
      if con then connect(m, w.s, con) end
    elseif m and m.e.valid then
      keep[#keep + 1] = w
    end
  end
  s[k] = (#keep > 0) and keep or nil
end

-- drop wires whose pole never came
function M.cleanup(t)
  for si, s in pairs(storage.pending) do
    for k, l in pairs(s) do
      local keep = {}
      for _, w in ipairs(l) do
        if t - (w.tick or 0) < KEEP and storage.tr[w.u] then keep[#keep + 1] = w end
      end
      s[k] = (#keep > 0) and keep or nil
    end
    if next(s) == nil then storage.pending[si] = nil end
  end
end

return M
