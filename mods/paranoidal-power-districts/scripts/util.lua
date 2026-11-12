-- Formatting helpers (LocalisedString) and small utilities.
local U = {}

local floor, abs = math.floor, math.abs

-- number with `digits` decimals, locale decimal separator, trailing zero dropped
function U.num(x, digits)
  digits = digits or 1
  local neg = x < 0
  x = abs(x)
  local m = 10 ^ digits
  local v = floor(x * m + 0.5)
  local whole = floor(v / m)
  local frac = v - whole * m
  local s = tostring(whole)
  if #s > 3 then s = s:reverse():gsub("(%d%d%d)", "%1 "):reverse():gsub("^ ", "") end
  if digits > 0 and frac ~= 0 then
    return { "", neg and "−" or "", s, { "ppd-unit.dec" }, string.format("%0" .. digits .. "d", frac) }
  end
  return { "", neg and "−" or "", s }
end

-- power from W
function U.power(w)
  local a = abs(w)
  if a >= 1e9 then return { "", U.num(w / 1e9, 2), " ", { "ppd-unit.gw" } } end
  if a >= 1e6 or a == 0 then return { "", U.num(w / 1e6, 1), " ", { "ppd-unit.mw" } } end
  return { "", U.num(w / 1e3, 0), " ", { "ppd-unit.kw" } }
end

-- power from J/tick
function U.tpower(j) return U.power(j * 60) end

function U.energy(j)
  local a = abs(j)
  if a >= 1e12 then return { "", U.num(j / 1e12, 2), " ", { "ppd-unit.tj" } } end
  if a >= 1e9 then return { "", U.num(j / 1e9, 1), " ", { "ppd-unit.gj" } } end
  return { "", U.num(j / 1e6, 0), " ", { "ppd-unit.mj" } }
end

function U.pct(r) return { "", tostring(floor(r * 100 + 0.5)), " %" } end

function U.signed_pct(b)
  return { "", "+", U.num(b * 100, 1), " %" }
end

function U.minutes(ticks)
  local m = floor(ticks / 3600)
  if m >= 120 then return { "ppd-unit.hours", floor(m / 60) } end
  return { "ppd-unit.minutes", m }
end

function U.clock(tick)
  local s = floor(tick / 60)
  return string.format("%d:%02d:%02d", floor(s / 3600), floor(s / 60) % 60, s % 60)
end

function U.color_rich(c)
  return string.format("%.2f,%.2f,%.2f", c.r, c.g, c.b)
end

function U.clamp(x, a, b)
  if x < a then return a elseif x > b then return b end
  return x
end

-- remove value from array (order not kept)
function U.remove_value(t, v)
  for i = #t, 1, -1 do
    if t[i] == v then
      t[i] = t[#t]
      t[#t] = nil
      return true
    end
  end
  return false
end

return U
