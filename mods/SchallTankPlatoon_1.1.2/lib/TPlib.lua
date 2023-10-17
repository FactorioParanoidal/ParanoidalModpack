local TPlib = {}

local showlog = false     -- Debug log message toggle
local showprint = false   -- Debug game print toggle

function TPlib.debuglog(msg)
  if showlog then log(msg) end
  return showlog
end

function TPlib.debugprint(msg)
  if showprint and game then game.print(msg) end
  return showprint
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

function TPlib.vector_multiply(vector, scale)
  if not (vector and scale) then
    return vector
  end
  return {vector[1] * scale, vector[2] * scale}
end

function TPlib.table_multiply(t, scale)
  if not (t and scale) then
    return t
  end
  for k, v in pairs(t) do
    t[k] = v * scale
  end
  return t
end

function TPlib.table_recursive_multiply(t, scale)
  if not (t and scale) then
    return t
  end
  for k, v in pairs(t) do
    if type(v) == "table" then
      TPlib.table_recursive_multiply(v, scale)
    elseif type(v) == "number" then
      t[k] = v * scale
    end
  end
  return t
end

function TPlib.table_merge_unique(tables)
  -- Different from core util.merge, a siimple function NOT dealing with subtables.
  -- Will NOT override/replace earlier tables, but create a unique table.
  -- New entries are inserted at the end.
  local rt = {}
  local tdict = {}
  for i, tab in ipairs(tables) do
    for _, v in pairs(tab) do
      if not tdict[v] then
        table.insert(rt, v)
        tdict[v] = true
      end
    end
  end
  return rt
end

function TPlib.sprite_rescale_recursive(layer, linescale, animscale, spritesspec)
  if not layer or type(layer) ~= "table" then return nil end
  local spec = spritesspec or {}
  if layer.width then
    local isanim = layer.animation_speed or layer.frame_count
    layer.shift = TPlib.vector_multiply(layer.shift, linescale)
    if not spec.skipscale then
      layer.scale = (layer.scale or 1) * linescale * (spec.scalemul or 1)
    end
    if isanim and not spec.skipanimscale and not spec.constant_speed then
      layer.animation_speed = (layer.animation_speed or 1) * animscale
    end
    if layer.hr_version then
      layer.hr_version.shift = TPlib.vector_multiply(layer.hr_version.shift, linescale)
      if not spec.skipscale then
        layer.hr_version.scale = (layer.hr_version.scale or 1) * linescale * (spec.scalemul or 1)
      end
      if isanim and not spec.skipanimscale and not spec.constant_speed then
        layer.hr_version.animation_speed = (layer.hr_version.animation_speed or 1) * animscale
      end
    end
  else
    if layer.constant_speed then
      spec = table.deepcopy(spec)
      spec.skipanimscale = true
    end
    for k, v in pairs(layer) do
      if type(k) == "string" and k:match("_position$") then
        layer[k] = TPlib.vector_multiply(v, linescale)
      else
        TPlib.sprite_rescale_recursive(v, linescale, animscale, spec)
      end
    end
  end
  return layer
end

function TPlib.sprite_tint_recursive(layer, tint)
  if not layer or type(layer) ~= "table" then return nil end
  if layer.width then
    layer.tint = tint
    if layer.hr_version then
      layer.hr_version.tint = tint
    end
  else
    for k, v in pairs(layer) do
      TPlib.sprite_tint_recursive(v, tint)
    end
  end
  return layer
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

function TPlib.create_flying_text_item(surface, position, itempt, amountadd, source)
  local sign = ""
  local counts = source.get_item_count(itempt.name)
  local text
  if amountadd > 0 then
    sign = "+"
  end
  if counts == 0 then
    color = {r=1, g=0.14, b=0}
  end
  surface.create_entity{ name = "flying-text", position = position, color = color, text = {"description.Schall-flying-text-item", itempt.localised_name, sign, amountadd, counts} }
end

function TPlib.create_flying_text_insert_failed(surface, position, itempt)
  surface.create_entity{ name = "flying-text", position = position, text = {"description.Schall-flying-text-insert-failed", itempt.localised_name} }
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

TPlib.tankeqp_techicon_layer = {icon = "__SchallTankPlatoon__/graphics/technology/tank-equipment.png"}
TPlib.traineqp_techicon_layer = {icon = "__SchallTankPlatoon__/graphics/technology/train-equipment.png"}


TPlib.burner_tank_smoke =
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

function TPlib.energy_source(oript, category, spec, smoke)
  if not spec then return oript end
  local rt = table.deepcopy(oript)
  for k, v in pairs(spec) do
    rt[k] = v
  end
  if category == "nuclear" then
    rt.type = "burner"
    rt.fuel_category = category
    rt.fuel_inventory_size = 1
    rt.burnt_inventory_size = 1
    if smoke then rt.smoke = smoke end
  elseif category == "chemical" then
    rt.type = "burner"
    rt.fuel_category = category
    rt.fuel_inventory_size = rt.fuel_inventory_size or 1
    if smoke then rt.smoke = smoke end
  elseif category == "void" then
    rt = { type = "void" }
  end
  return rt
end

local function scale_volume(pt, scale)
  for _, v in pairs(pt) do
    if v.volume then v.volume = v.volume * scale end
  end
end

function TPlib.scale_sound_volume(pt, scale)
  if pt.variations then
    scale_volume(pt.variations, scale)
  else
    scale_volume(pt, scale)
  end
end



return TPlib