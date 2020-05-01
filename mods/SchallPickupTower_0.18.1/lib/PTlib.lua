local PTlib = {}

local showmsg = false  -- Debug log message toggle

function PTlib.debuglog(msg)
  if showmsg then log(msg) end
  return showmsg
end



local metric_prefix = {
  { value = 10^24,  strformat = "%.1f", div1 = 10^23, div2 = 10,  symbol = {"si-prefix-symbol-yotta"} },
  { value = 10^21,  strformat = "%.1f", div1 = 10^20, div2 = 10,  symbol = {"si-prefix-symbol-zetta"} },
  { value = 10^18,  strformat = "%.1f", div1 = 10^17, div2 = 10,  symbol = {"si-prefix-symbol-exa"} },
  { value = 10^15,  strformat = "%.1f", div1 = 10^14, div2 = 10,  symbol = {"si-prefix-symbol-peta"} },
  { value = 10^12,  strformat = "%.1f", div1 = 10^11, div2 = 10,  symbol = {"si-prefix-symbol-tera"} },
  { value = 10^9,   strformat = "%.1f", div1 = 10^8,  div2 = 10,  symbol = {"si-prefix-symbol-giga"} },
  { value = 10^6,   strformat = "%.1f", div1 = 10^5,  div2 = 10,  symbol = {"si-prefix-symbol-mega"} },
  { value = 10^3,   strformat = "%.0f", div1 = 10^3,  div2 = 1,   symbol = {"si-prefix-symbol-kilo"} },
  -- { value = 1,      strformat = "%.0f", div1 = 1,     div2 = 1,   symbol = {} },
}

function PTlib.format_number_eng(n, indent)
  indent = indent or ""
  for _,v in pairs(metric_prefix) do
    if n >= v.value then
      return {"" , string.format(v.strformat..indent, math.floor(n / v.div1)/v.div2), v.symbol}
    end
  end
  return tostring(n)..indent
end

function PTlib.format_number(x, n)
  return string.format("%."..n.."f", x)
end

function PTlib.floor_float(x)
  return x>=0 and math.floor(x) or math.ceil(x)
end

function PTlib.round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function PTlib.round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x+0.5) else x = math.ceil(x-0.5) end
  return x / n
end

function PTlib.PT_localised_description(range, interval, energy_usage, desc)
  desc = desc or "entity-description.Schall-pickup-tower"
  return { "", {desc}, {"description.Schall-pickup-range", range}, {"description.Schall-pickup-interval", interval.." ", {"description.Schall-si-unit-symbol-second"}}, {"description.Schall-energy-consumption", PTlib.format_number_eng(energy_usage, " "), {"si-unit-symbol-watt"}} }
end



return PTlib