-- Advice for a district: what keeps it out of the green zone and what the player can do.
-- Returns a list of { level = "ok"|"warn"|"bad", msg = LocalisedString }.
local S = require("shared")
local state = require("scripts.state")
local U = require("scripts.util")
local engine = require("scripts.engine")

local M = {}

local function mw(j_tick) return U.tpower(j_tick) end

-- nominal combinations of one or two transformers (J/tick) with a label
local COMBOS
local function combos()
  if COMBOS then return COMBOS end
  COMBOS = {}
  for i, a in ipairs(S.TIERS) do
    COMBOS[#COMBOS + 1] = { n = a.nominal / 60, label = { "", "Т-", a.key }, tiers = { i } }
    for j = i, #S.TIERS do
      local b = S.TIERS[j]
      COMBOS[#COMBOS + 1] = { n = (a.nominal + b.nominal) / 60, label = { "", "Т-", a.key, " + Т-", b.key }, tiers = { i, j } }
    end
  end
  table.sort(COMBOS, function(x, y) return x.n < y.n end)
  return COMBOS
end

local function spread(h)
  if not h or #h < 6 then return 0 end
  local lo, hi = math.huge, -math.huge
  for i = math.max(1, #h - 59), #h do
    local v = h[i]
    if v < lo then lo = v end
    if v > hi then hi = v end
  end
  return hi - lo
end

function M.zone_share(h, lo, hi)
  if not h or #h == 0 then return nil end
  local n, z = 0, 0
  for _, v in ipairs(h) do
    n = n + 1
    if v >= lo and v <= hi then z = z + 1 end
  end
  return z / n
end

function M.district(ds)
  local out = {}
  if not ds or not ds.N then return out end
  local tr = storage.tr
  local lead = tr[ds.lead]
  if not lead then return out end
  local name = engine.name_of(lead)
  local f = state.force(ds.force)
  local s = ds.status
  local L, N, lo, hi = ds.L, ds.N, ds.lo, ds.hi
  if s == "bypass" then
    out[#out + 1] = { level = "bad", msg = { "ppd-advice.bypass", name } }
  elseif s == "loop" then
    out[#out + 1] = { level = "bad", msg = { "ppd-advice.loop", name } }
  elseif s == "converter" then
    out[#out + 1] = { level = "bad", msg = { "ppd-advice.converter", name } }
  elseif s == "noinput" then
    out[#out + 1] = { level = "bad", msg = { "ppd-advice.noinput", name } }
  elseif s == "limit" then
    out[#out + 1] = { level = "bad", msg = { "ppd-advice.limit", name, mw(N * S.LIMIT) } }
  elseif s == "off_auto" then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.off-auto", name } }
  elseif s == "off_manual" then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.off-manual", name } }
  elseif s == "off_circuit" then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.off-circuit", name } }
  elseif s == "nowire_in" then
    out[#out + 1] = { level = "bad", msg = { "ppd-advice.nowire-in", name } }
  elseif s == "nowire_out" then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.nowire-out", name } }
  elseif s == "boost" then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.boost", name, mw(N * S.LIMIT) } }
  end
  if s == "under" or s == "over" or s == "idle" or s == "limit" then
    -- does any single or paired nominal fit this load?
    local fit
    for _, c in ipairs(combos()) do
      if L >= c.n * lo and L <= c.n * hi then
        fit = c
        break
      end
    end
    if s == "under" then
      out[#out + 1] = { level = "warn", msg = { "ppd-advice.under", name, mw(lo * N - L) } }
    elseif s == "over" then
      out[#out + 1] = { level = "warn", msg = { "ppd-advice.over", name, mw(L - hi * N) } }
    end
    if fit and math.abs(fit.n - N) > 1 then
      out[#out + 1] = { level = "warn", msg = { "ppd-advice.fit", name, mw(L), fit.label } }
    elseif not fit and L > 0 then
      -- the nearest nominal above: how much load to add
      local up
      for _, c in ipairs(combos()) do
        if c.n * lo > L then
          up = c
          break
        end
      end
      if up then
        out[#out + 1] = { level = "warn", msg = { "ppd-advice.no-fit", name, mw(L), mw(up.n * lo - L), up.label } }
      end
    end
    -- a tap (research) that puts this load into the zone, the nearest to the current one
    local tapmax = f.taps or 0
    if tapmax > 0 and N > 0 then
      local cur = ds.tap or 0
      local base = N / (1 + S.TAP_STEP * cur)
      local best
      for v = -tapmax, tapmax do
        local rr = L / (base * (1 + S.TAP_STEP * v))
        if v ~= cur and rr >= lo and rr <= hi and (not best or math.abs(v - cur) < math.abs(best - cur)) then best = v end
      end
      if best then
        out[#out + 1] = { level = "ok", msg = { "ppd-advice.tap", name, engine.tap_text(best) } }
      end
    end
    if s == "under" and f.has_bank and N > 0 then
      local B = S.TIERS[lead.tier].bonus * state.bonus_mult(f)
      if ds.r >= lo / (1 + B) then
        out[#out + 1] = { level = "ok", msg = { "ppd-advice.bank-yes", name, mw(lo * 1.01 * N - L) } }
      else
        out[#out + 1] = { level = "warn", msg = { "ppd-advice.bank-no", name, math.floor(lo / (1 + B) * 100 + 0.5) } }
      end
    end
  end
  local sp = spread(lead.h5)
  if sp > 0.3 and s ~= "off_manual" and s ~= "off_auto" then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.jumpy", name, math.floor(sp * 100 + 0.5) } }
  end
  if s == "zone" and ds.r > hi - 0.03 then
    out[#out + 1] = { level = "warn", msg = { "ppd-advice.near-top", name, math.floor(ds.r * 100 + 0.5) } }
  end
  for _, u in ipairs(ds.units or {}) do
    local m = tr[u]
    if m and m.reserve and f.has_auto and m.noin then
      out[#out + 1] = { level = "bad", msg = { "ppd-advice.reserve-noinput", name } }
      break
    end
  end
  return out
end

-- top consumers of a district network (5 s average), excluding hidden parts
function M.top_consumers(m, count)
  local pole = m.pout
  if not (pole and pole.valid) then return {} end
  local stats = pole.electric_network_statistics
  if not stats then return {} end
  local list = {}
  for name in pairs(stats.input_counts) do
    local v = stats.get_flow_count({ name = name, category = "input", precision_index = defines.flow_precision_index.five_seconds })
    if v > 0 then list[#list + 1] = { name = name, v = v } end
  end
  table.sort(list, function(a, b) return a.v > b.v end)
  local out = {}
  for i = 1, math.min(count, #list) do out[i] = list[i] end
  return out
end

return M
