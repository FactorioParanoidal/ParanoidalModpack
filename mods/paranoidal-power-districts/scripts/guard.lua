-- Border guard for newly built poles:
-- 1) automatic wires to a transformer's bushings are removed (the player connects them by hand);
-- 2) if the new pole joined the input and the output network of a guarded transformer, its wires are
--    rebuilt nearest first and the wire that would join them is not restored.
local S = require("shared")
local engine = require("scripts.engine")

local M = {}
local copper = defines.wire_connector_id.pole_copper

local function say(player, pole, text)
  if player and player.valid then
    player.create_local_flying_text({ text = text, position = pole.position, surface = pole.surface, color = { 1, 0.85, 0.36 } })
  end
end

function M.on_pole_built(pole, player)
  local name = pole.name
  if name == S.POLE_IN or name == S.POLE_OUT or name == S.POLE_ALT then return end
  local st = storage
  if next(st.tr) == nil then return end
  local con = pole.get_wire_connector(copper, false)
  if not con then return end
  local conns = con.real_connections
  if #conns == 0 then return end
  local cut_hidden = false
  for _, c in ipairs(conns) do
    local owner = c.target.owner
    local oname = owner.name
    if oname == S.POLE_IN or oname == S.POLE_OUT then
      con.disconnect_from(c.target, c.origin)
      cut_hidden = true
    end
  end
  if cut_hidden then
    say(player, pole, { "ppd-flying.manual-wire" })
    conns = con.real_connections
  end
  if st.guarded == 0 or #conns < 2 then return end
  local merged = pole.electric_network_id
  if not merged then return end
  local hit = false
  for _, m in pairs(st.tr) do
    if m.guard and m.pout and m.pout.valid and m.pout.electric_network_id == merged
      and m.pin and m.pin.valid and m.pin.electric_network_id == merged then
      hit = true
      break
    end
  end
  if not hit then return end
  -- take the pole out of all networks and read the neighbours' own networks
  local targets = {}
  local pp = pole.position
  for i, c in ipairs(conns) do
    local o = c.target.owner.position
    targets[i] = { con = c.target, origin = c.origin, d = (o.x - pp.x) ^ 2 + (o.y - pp.y) ^ 2 }
  end
  for _, x in ipairs(targets) do con.disconnect_from(x.con, x.origin) end
  local nets = {}
  for _, x in ipairs(targets) do
    x.id = x.con.owner.electric_network_id
    if x.id then nets[x.id] = true end
  end
  local forbid = {}
  for _, m in pairs(st.tr) do
    if m.guard and m.pin and m.pin.valid and m.pout and m.pout.valid then
      local a, b = m.pin.electric_network_id, m.pout.electric_network_id
      if a and b and a ~= b and nets[a] and nets[b] then
        forbid[a] = forbid[a] or {}
        forbid[b] = forbid[b] or {}
        forbid[a][b] = m
        forbid[b][a] = m
      end
    end
  end
  table.sort(targets, function(x, y) return x.d < y.d end)
  local joined = {}
  local blocked
  for _, x in ipairs(targets) do
    local ok = true
    local f = x.id and forbid[x.id]
    if f then
      for j in pairs(joined) do
        if f[j] then
          ok = false
          blocked = f[j]
          break
        end
      end
    end
    if ok then
      con.connect_to(x.con, false, x.origin)
      if x.id then joined[x.id] = true end
    end
  end
  if blocked then
    say(player, pole, { "ppd-flying.border", engine.name_of(blocked) })
  end
end

return M
