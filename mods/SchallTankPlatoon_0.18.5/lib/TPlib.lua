local TPlib = {}

local showmsg = false  -- Debug log message toggle

function TPlib.debuglog(msg)
  if showmsg then log(msg) end
  return showmsg
end

function TPlib.format_number_eng(n)
    if n >= 10^12 then
        return string.format("%.1fT", math.floor(n / 10^11)/10)
    elseif n >= 10^9 then
        return string.format("%.1fG", math.floor(n / 10^8)/10)
    elseif n >= 10^6 then
        return string.format("%.1fM", math.floor(n / 10^5)/10)
    elseif n >= 10^3 then
        return string.format("%.0fk", math.floor(n / 10^3))
    else
        return tostring(n)
    end
end

function TPlib.format_number(x, n)
  return string.format("%."..n.."f", x)
end

function TPlib.floor_float(x)
  return x>=0 and math.floor(x) or math.ceil(x)
end

function TPlib.round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function TPlib.round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x+0.5) else x = math.ceil(x-0.5) end
  return x / n
end

function TPlib.format_position(p)
  return string.format("%.0f,%.0f", p.x, p.y )
end

function TPlib.format_position_gps(p)
  return string.format("[gps=%.0f,%.0f]", p.x, p.y )
end

function TPlib.string_split(str, sep)
  local rt = {}
  string.gsub(str, "[^"..sep.."]+", function(w) table.insert(rt, w) end)
  return rt
end

function TPlib.check_set_value(entry, prop, val)
  if entry then
    if type(prop) == "table" then
      if #prop > 1 then
        TPlib.debuglog("  At lv "..#prop.. ": "..prop[1])
        return TPlib.check_set_value(entry[prop[1]], {table.unpack(prop,2)}, val)
      else
        TPlib.debuglog("    Set "..prop[1].. " = `"..tostring(val).."`")
        entry[prop[1]] = val
        return true
      end
    else
      TPlib.debuglog("    Set "..prop.. " = `"..tostring(val).."`")
      entry[prop] = val
      return true
    end
  else
    if type(prop) == "table" then
      log("Failed to set prop `"..prop[1].."` = `"..tostring(val).."`")
    else
      log("Failed to set prop `"..prop.."` = `"..tostring(val).."`")
    end
    return false
  end
end



local soft_limit = {75, 80, 90, 95, 98, 100}
local hard_limit = 100

-- function TPlib.aymptotic_100(x)
--   for _, v in pairs(soft_limit) do
--     if x<=v then
--       return math.ceil(x)
--     else
--       x = v + (x-v) * 0.5
--     end
--   end
--   return math.min(x, hard_limit)
-- end

function TPlib.aymptotic_100(base, add)
  local x = base + add
  for _, v in pairs(soft_limit) do
    if x <= v then
      return math.ceil(x)
    elseif base >= v then
      -- Skip checking if base is already higher than soft limit
    else
      x = v + (x-v) * 0.5
    end
  end
  return math.min(x, hard_limit)
end

function TPlib.resistances(base, add)
  local rt = {}
  local decbase, perbase
  local decadd, peradd
  for k, v in pairs(base) do
    decbase = v.decrease
    perbase = v.percent
    if add[k] then
      decadd = add[k].decrease
      peradd = add[k].percent
    else
      decadd = 0
      peradd = 0
    end
    if dec ~= 0 or per ~= 0 then
      table.insert(rt, { type = k, decrease = decbase+decadd, percent = TPlib.aymptotic_100(perbase, peradd) } )
    end
  end
  return rt
end

local mk1_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/mk1.png", icon_size = 128, icon_mipmaps = 3}
local mk2_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/mk2.png", icon_size = 128, icon_mipmaps = 3}
local mk3_icon_layer = {icon = "__SchallAlienTech__/graphics/icons/mk3.png", icon_size = 128, icon_mipmaps = 3}
local tier_layer = {
  [0] = nil,
  [1] = mk1_icon_layer,
  [2] = mk2_icon_layer,
  [3] = mk3_icon_layer,
}

function TPlib.tier_icon_layer(tier)
  return tier_layer[tier]
end

TPlib.tankeqp_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/tank-equipment.png", icon_size = 128, icon_mipmaps = 3}
TPlib.caliber_H1_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/H1.png", icon_size = 128, icon_mipmaps = 3}
TPlib.caliber_H2_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/H2.png", icon_size = 128, icon_mipmaps = 3}


local burner_smoke =
{
  {
    name = "tank-smoke",
    deviation = {0.25, 0.25},
    frequency = 50,
    position = {0, 1.5},
    starting_frame = 0,
    starting_frame_deviation = 60
  }
}

function TPlib.burner_nuclear(effectivity)
  return {
    fuel_category = "nuclear",
    effectivity = effectivity,
    fuel_inventory_size = 1,
    burnt_inventory_size = 1,
    smoke = burner_smoke
  }
end



return TPlib