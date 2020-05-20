local TPlib = require("__SchallTankPlatoon__.lib.TPlib")
local cfg1 = require("config.config-1")



local TPpt = {}


-- Vehicle Grid
local function read_grid_values(setting, defw, defh)
  if setting then
    return string.match(setting.value, "(%d+)x(%d+)")
  else
    return defw, defh
  end
end

TPpt.VEH_base_grid = {
  [0] = {read_grid_values(settings.startup["tankplatoon-tank-t0-grid"], 5, 4)},
  [1] = {read_grid_values(settings.startup["tankplatoon-tank-t1-grid"], 7, 7)},
  [2] = {read_grid_values(settings.startup["tankplatoon-tank-t2-grid"], 10, 10)},
  [3] = {read_grid_values(settings.startup["alientech-tank-t3-grid"], 12, 14)},
}

function TPpt.VEH_grid_width(tier, size_add)
  return math.max(TPpt.VEH_base_grid[tier][1] + size_add, 0)
end

function TPpt.VEH_grid_height(tier, size_add)
  return math.max(TPpt.VEH_base_grid[tier][2] + size_add, 0)
end


-- Transport Group
TPpt.subgroup_vehmil = {
  [0] = "transport",
  [1] = "transport",
  [2] = "transport",
  [3] = "transport"
}

if mods["SchallTransportGroup"] then
  TPpt.subgroup_vehmil = {
    [0] = "vehicles-military",
    [1] = "vehicles-military",
    [2] = "vehicles-military",
    [3] = "vehicles-military"
  }
  if settings.startup["tankplatoon-tiered-military-vehicles-subgroups"].value then
    for k,v in pairs(TPpt.subgroup_vehmil) do
      if k>0 then TPpt.subgroup_vehmil[k] = v.."-"..k end
    end
  end
end


TPpt.tank_icon_path = {
  ["ori"] = "__base__/graphics/icons/tank.png",
  ["tint"] = "__SchallTankPlatoon__/graphics/icons/tank-to-tint.png",
}


function TPpt.tank_base_icon_layer(spec)
  return {icon = TPpt.tank_icon_path[spec.icon_base], icon_size = 64, icon_mipmaps = 4, tint = spec.tint}
end

function TPpt.VEH_icons(spec, tier)
  return {
    TPpt.tank_base_icon_layer(spec),
    TPlib.tier_icon_layer(tier)
  }
end

function TPpt.VEH_name(name, tier)
  return name .. cfg1.tier_suffix[tier]
end

function TPpt.VEH_name_table_replace(name, rt)
  for _, v in pairs(rt) do
    if v[1]:match("^__VEH__") then
      local tier = tonumber(v[1]:match("^__VEH__(%d+)__"))
      v[1] = TPpt.VEH_name(name, tier)
    end
  end
end

function TPpt.VEH_item(spec, tier)
  local entyname = TPpt.VEH_name(spec.name, tier)
  return
  {
    type = "item-with-entity-data",
    name = entyname,
    icons = TPpt.VEH_icons(spec, tier),
    subgroup = TPpt.subgroup_vehmil[tier],
    order = "b[personal-transport]-" .. spec.subcat .. tier,
    place_result = entyname,
    equipment_grid = entyname .. "-equipment-grid",
    stack_size = 1
  }
end

function TPpt.VEH_entity(spec, tier)
  local enty = table.deepcopy(data.raw.car.tank)
  local entyname = TPpt.VEH_name(spec.name, tier)
  enty.hide_resistances = cfg1.hide_resistances
  enty.name = entyname
  enty.icons = TPpt.VEH_icons(spec, tier)
  enty.minable = {mining_time = spec.mining_time, result = entyname}
  enty.max_health = spec.base_health * cfg1.tier_health_mul[tier]
  enty.resistances = TPlib.resistances(spec.base_resistances, cfg1.resistances_add[tier])
  enty.collision_box = {{-0.9*spec.scale, -1.3*spec.scale}, {0.9*spec.scale, 1.3*spec.scale}}
  enty.selection_box = {{-0.9*spec.scale, -1.3*spec.scale}, {0.9*spec.scale, 1.3*spec.scale}}
  enty.drawing_box = {{-1.8*spec.scale, -1.8*spec.scale}, {1.8*spec.scale, 1.5*spec.scale}}
  enty.effectivity = spec.effectivity
  enty.burner.fuel_inventory_size = spec.burner_fuel_inventory_size
  if tier >= 3 then
    enty.burner = TPlib.burner_nuclear(spec.burner_effectivity)
  else
    enty.burner.effectivity = spec.burner_effectivity
  end
  enty.braking_power = spec.base_braking_power * cfg1.tier_power_mul[tier] .. "kW"
  enty.consumption = spec.base_consumption * cfg1.tier_power_mul[tier] .. "kW"
  enty.terrain_friction_modifier = spec.terrain_friction_modifier
  enty.weight = spec.weight * cfg1.tier_weight_mul[tier]
  enty.turret_rotation_speed = spec.turret_rotation_speed
  enty.rotation_speed = spec.rotation_speed
  enty.inventory_size = spec.base_inventory_size + cfg1.tier_inventory_size_add[tier]
  enty.guns = spec.guns[tier]
  enty.equipment_grid = entyname.."-equipment-grid"
  for _, layer in pairs(enty.animation.layers) do
    layer.tint = spec.tint
    layer.scale = spec.scale
    if (layer.hr_version) then
      layer.hr_version.tint = spec.tint
      layer.hr_version.scale = 0.5*spec.scale
    end
  end
  for _, layer in pairs(enty.turret_animation.layers) do
    layer.scale = spec.scale
    if (layer.hr_version) then
      layer.hr_version.scale = 0.5*spec.scale
    end
  end
  return enty
end

function TPpt.VEH_recipe(spec, tier)
  local rcp = table.deepcopy(spec.recipe_specs[tier])
  local entyname = TPpt.VEH_name(spec.name, tier)
  rcp.type = "recipe"
  rcp.name = entyname
  if rcp.normal then
    rcp.normal.enabled = rcp.normal.enabled or false
    rcp.normal.result = entyname
    TPpt.VEH_name_table_replace(spec.name, rcp.normal.ingredients)
    rcp.expensive.enabled = rcp.expensive.enabled or false
    rcp.expensive.result = entyname
    TPpt.VEH_name_table_replace(spec.name, rcp.expensive.ingredients)
  else
    rcp.enabled = rcp.enabled or false
    rcp.result = entyname
    TPpt.VEH_name_table_replace(spec.name, rcp.ingredients)
  end
  return rcp
end

function TPpt.VEH_grid(spec, tier)
  local entyname = TPpt.VEH_name(spec.name, tier)
  return
  {
    type = "equipment-grid",
    name = entyname.."-equipment-grid",
    width = TPpt.VEH_grid_width(tier, spec.grid.width_add or 0),
    height = TPpt.VEH_grid_height(tier, spec.grid.height_add or 0),
    equipment_categories = spec.grid.equipment_categories
  }
end



return TPpt