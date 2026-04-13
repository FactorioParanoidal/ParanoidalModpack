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
  { value = 10^30,  strformat = "%.1f", div1 = 10^29, div2 = 10,  symbol = {"si-prefix-symbol-quetta"} },
  { value = 10^27,  strformat = "%.1f", div1 = 10^26, div2 = 10,  symbol = {"si-prefix-symbol-ronna"} },
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

function PTlib.counts_add(t, k, amtadd, processzero)
  if processzero or amtadd > 0 then
    t[k] = (t[k] or 0) + amtadd
  end
end

function PTlib.contain_negative(t, k)
  return t[k] and t[k] < 0
end


function PTlib.counts_2D_add(t, k1, k2, amtadd, processzero)
  if not t[k1] then t[k1] = {} end
  if processzero or amtadd > 0 then
    t[k1][k2] = (t[k1][k2] or 0) + amtadd
  end
end

function PTlib.compare_value_desc(a, b)
  return a.value > b.value
end

function PTlib.compare_value_asc(a, b)
  return a.value < b.value
end

function PTlib.pairs_sorted(t, f)
  local a = {}
  for k, v in pairs(t) do
    table.insert(a, { key = k, value = v })
  end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i].key, a[i].value
    end
  end
  return iter
end

function PTlib.pairs_2D_sorted(t, f)
  local a = {}
  for k1, v1 in pairs(t) do
    for k2, v in pairs(v1) do
      table.insert(a, { key1 = k1, key2 = k2, value = v })
    end
  end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return {a[i].key1, a[i].key2, a[i].value}
    end
  end
  return iter
end


PTlib.PT_icon_layer = {icon = "__SchallPickupTower__/graphics/icons/pickup-tower.png", icon_size = 128, icon_mipmaps = 3}
PTlib.PT_tech_icon_layer = {icon = "__SchallPickupTower__/graphics/technology/pickup-tower.png", icon_size = 256, icon_mipmaps = 4}

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
  return { "",
    {desc}, {"description.Schall-pickup-range", tostring(range)},
    {"description.Schall-pickup-interval", {"time-symbol-seconds", tostring(interval)}},
    {"description.Schall-energy-consumption", PTlib.format_number_eng(energy_usage, {"si-unit-symbol-watt"})}
  }
end


function PTlib.text_quality_or_normal(quality)
  -- Output "normal" for normal, or "quality" for <> normal
  if quality == "normal" then
    return quality
  else
    return "quality"
  end
end

function PTlib.richtext_item(name, quality)
  if script.active_mods["quality"] then
    return "[item="..name..",quality="..quality.."]"
  else
    return "[item="..name.."]"
  end
end

function PTlib.create_flying_text_item_force(surface, position, itempt, quality, amountadd, inv, force)
  local sign = ""
  -- local inv = source.get_main_inventory()
  if not inv then return end
  local counts = inv.get_item_count({name = itempt.name, quality = quality})
  -- local counts = player.get_item_count(itempt.name)
  local text
  if amountadd > 0 then
    sign = "+"
  end
  local chgtext = sign .. tostring(amountadd)
  if counts == 0 then
    color = {r=1, g=0.14, b=0}
  else
    color = nil
  end
  local localetext = "show-diff-"..PTlib.text_quality_or_normal(quality)
  local itemRT = PTlib.richtext_item(itempt.name, quality)
  local qualityLOC = prototypes.quality[quality].localised_name
  for _, player in pairs(force.connected_players) do 
    player.create_local_flying_text{position = position, color = color, text = {localetext, chgtext, itemRT, counts, itempt.localised_name, qualityLOC}, speed = 10 }
  end
end

function PTlib.filter_allow(unlimitedmode, t, k)
  return unlimitedmode or PTlib.contain_negative(t, k)
end

function PTlib.filter_update(unlimitedmode, t, k, chg)
  if not unlimitedmode then
    PTlib.counts_add(t, k, chg)
  end
end



return PTlib