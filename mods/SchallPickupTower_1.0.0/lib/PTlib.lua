local PTlib = {}

local showlog = false     -- Debug log message toggle
local showprint = false   -- Debug game print toggle

function PTlib.debuglog(msg)
  if showlog then log(msg) end
  return showlog
end

function PTlib.debugprint(msg)
  if showprint and game then game.print(msg) end
  return showprint
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

function PTlib.format_number_eng(n, unit)
  unit = unit or ""
  for _, v in pairs(metric_prefix) do
    if n >= v.value then
      return string.format(v.strformat, math.floor(n / v.div1)/v.div2), { "" , v.symbol, unit }
    end
  end
  return tostring(n), unit
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

function PTlib.box_area(centre, radius)
  local c = {centre.x or centre[1], centre.y or centre[2]}
  return {
    {c[1] - radius, c[2] - radius},
    {c[1] + radius, c[2] + radius}
  }
end


PTlib.PT_icon_layer = {icon = "__SchallPickupTower__/graphics/icons/pickup-tower.png", icon_size = 128, icon_mipmaps = 3}
PTlib.PT_tech_icon_layer = {icon = "__SchallPickupTower__/graphics/technology/pickup-tower.png", icon_size = 128}

local tier_layer = {
  [1] = {icon = "__SchallPickupTower__/graphics/icons/mk1.png", icon_size = 128, icon_mipmaps = 3},
  [2] = {icon = "__SchallPickupTower__/graphics/icons/mk2.png", icon_size = 128, icon_mipmaps = 3},
  [3] = {icon = "__SchallPickupTower__/graphics/icons/mk3.png", icon_size = 128, icon_mipmaps = 3},
  [4] = {icon = "__SchallPickupTower__/graphics/icons/mk4.png", icon_size = 128, icon_mipmaps = 3},
}

function PTlib.tier_icon_layer(tier)
  return tier_layer[tier]
end

function PTlib.PT_localised_description(range, interval, energy_usage, desc)
  desc = desc or "entity-description.Schall-pickup-tower"
  return { "", {desc}, {"description.Schall-pickup-range", range}, {"description.Schall-pickup-interval", interval, {"description.Schall-si-unit-symbol-second"}}, {"description.Schall-energy-consumption", PTlib.format_number_eng(energy_usage, {"si-unit-symbol-watt"})} }
end

function PTlib.create_flying_text_item(surface, position, itempt, amountadd, source)
  local sign = ""
  local counts = source.get_item_count(itempt.name)
  local text
  if amountadd > 0 then
    sign = "+"
  end
  -- if counts > 0 then
    text = "description.Schall-flying-text-item"
  -- else
  --   text = "description.Schall-flying-text-item-deplete"
  -- end
  surface.create_entity{ name = "flying-text", position = position, text = {text, itempt.localised_name, sign, amountadd, counts} }
end



return PTlib