local TPlib = require("lib.TPlib")
local cfg1 = require("config.config-1")



local dr = data.raw
local drc = dr.car
local drsv = dr["spider-vehicle"]
local drr = dr.recipe
local drg = dr.gun
local dri = dr.item
local dra = dr.ammo
local drbe = dr["battery-equipment"]
local drp = dr.projectile



-- Hide vehicle resistances
local hide_resistances = cfg1.hide_resistances
if not hide_resistances then
  TPlib.check_set_value(drc.car, "hide_resistances", hide_resistances)
  TPlib.check_set_value(drc.tank, "hide_resistances", hide_resistances)
  TPlib.check_set_value(drsv.spidertron, "hide_resistances", hide_resistances)
end


-- Hide vanilla tank recipe
if not settings.startup["tankplatoon-tank-to-recipe-keep"].value then
  drr.tank.enabled = false
end


-- Chemical Recipes for Chemical Weapons
if settings.startup["tankplatoon-chemical-weapon-chemical-recipes"].value then
  TPlib.check_set_value(drr["poison-capsule"], "category", "chemistry")
  TPlib.check_set_value(drr["poison-capsule"], "ingredients",
  {
    {type="item", name="electronic-circuit", amount=1},
    {type="item", name="coal", amount=10},
    {type="fluid", name="sulfuric-acid", amount=50}
  })
  TPlib.check_set_value(drr["Schall-poison-bomb"], "category", "chemistry")
  TPlib.check_set_value(drr["Schall-poison-bomb"], "ingredients",
  {
    {type="item", name="rocket", amount=2},
    {type="item", name="electronic-circuit", amount=2},
    {type="item", name="coal", amount=60},
    {type="fluid", name="sulfuric-acid", amount=300}
  })
end


-- Change vanilla icons matching the series
if settings.startup["tankplatoon-vehicle-battery-enable"].value then
  TPlib.check_set_value(dri["battery-equipment"], "icons", { {icon = "__SchallTankPlatoon__/graphics/icons/battery-equipment.png", icon_size = 64, icon_mipmaps = 4} })
  TPlib.check_set_value(dri["battery-mk2-equipment"], "icons", { {icon = "__SchallTankPlatoon__/graphics/icons/battery-mk2-equipment.png", icon_size = 64, icon_mipmaps = 4} })
  TPlib.check_set_value(drbe["battery-equipment"], "sprite", { filename = "__SchallTankPlatoon__/graphics/equipment/battery-equipment.png", width = 32, height = 64, priority = "medium" })
  TPlib.check_set_value(drbe["battery-mk2-equipment"], "sprite", { filename = "__SchallTankPlatoon__/graphics/equipment/battery-mk2-equipment.png", width = 32, height = 64, priority = "medium" })
end


-- Gun changes to vanilla
TPlib.check_set_value(drg["tank-flamethrower"], {"attack_parameters", "range"}, 15) --9
TPlib.check_set_value(drg["tank-cannon"], {"attack_parameters", "range"}, 27) -- 25
TPlib.check_set_value(drg["tank-cannon"], {"attack_parameters", "min_range"}, 5)
TPlib.check_set_value(drg["tank-cannon"], {"attack_parameters", "damage_modifier"}, 1.5) --1
TPlib.check_set_value(drg["tank-machine-gun"], {"attack_parameters", "damage_modifier"}, 1.5) --1


-- Ammo changes to vanilla
local ft_ammo_type2 = dra["flamethrower-ammo"].ammo_type[2]
if TPlib.check_set_value(ft_ammo_type2, "consumption_modifier", 1) then --1.125
  TPlib.check_set_value(ft_ammo_type2, {"action", "action_delivery", "max_length"}, 15) --9
  if settings.startup["tankplatoon-tank-flamethrower-fire-stream-incendiary"].value then
    TPlib.check_set_value(ft_ammo_type2, {"action", "action_delivery", "stream"}, "handheld-flamethrower-fire-stream") --"tank-flamethrower-fire-stream"
  end
end

-- Have min_range like their non-uranium shells
TPlib.check_set_value(dra["uranium-cannon-shell"], {"ammo_type", "action", "action_delivery", "min_range"}, 5)
TPlib.check_set_value(dra["explosive-uranium-cannon-shell"], {"ammo_type", "action", "action_delivery", "min_range"}, 5)

-- Have max_range matching the tank cannon
TPlib.check_set_value(dra["cannon-shell"], {"ammo_type", "action", "action_delivery", "max_range"}, 27)
TPlib.check_set_value(dra["explosive-cannon-shell"], {"ammo_type", "action", "action_delivery", "max_range"}, 27)
TPlib.check_set_value(dra["uranium-cannon-shell"], {"ammo_type", "action", "action_delivery", "max_range"}, 27)
TPlib.check_set_value(dra["explosive-uranium-cannon-shell"], {"ammo_type", "action", "action_delivery", "max_range"}, 27)

TPlib.check_set_value(dra["artillery-shell"], "order", "h[artillery]-a[basic]") --"d[explosive-cannon-shell]-d[artillery]"
TPlib.check_set_value(dra["atomic-bomb"], "order", "d[rocket-launcher]-n[atomic-bomb]") --"d[rocket-launcher]-c[atomic-bomb]"


-- Poison capsule colour
if settings.startup["tankplatoon-ammo-colour-rearrange"].value then
  TPlib.check_set_value(dra["rocket"], "icons", { {icon = "__SchallTankPlatoon__/graphics/icons/basic-rocket.png", icon_size = 64, icon_mipmaps = 4} })
  TPlib.check_set_value(dr["capsule"]["poison-capsule"], "icon", "__SchallTankPlatoon__/graphics/icons/poison-capsule.png")
  if TPlib.check_set_value(dr["projectile"]["poison-capsule"], {"animation", "filename"}, "__SchallTankPlatoon__/graphics/entity/poison-capsule/poison-capsule.png") then
    dr["projectile"]["poison-capsule"].animation = 
    {
      filename = "__SchallTankPlatoon__/graphics/entity/poison-capsule/poison-capsule.png",
      frame_count = 16,
      line_length = 8,
      animation_speed = 0.250,
      width = 29,
      height = 29,
      shift = util.by_pixel(1, 0.5),
      priority = "high",
      hr_version =
      {
        filename = "__SchallTankPlatoon__/graphics/entity/poison-capsule/hr-poison-capsule.png",
        frame_count = 16,
        line_length = 8,
        animation_speed = 0.250,
        width = 58,
        height = 59,
        shift = util.by_pixel(1, 0.5),
        priority = "high",
        scale = 0.5
      }
    }
  end
  TPlib.check_set_value(dr["smoke-with-trigger"]["poison-cloud-visual-dummy"], "color", {r=0.4, g=0.4, b=0, a=0.322})  --{r = 0.014, g = 0.358, b = 0.395, a = 0.322}
  TPlib.check_set_value(dr["trivial-smoke"]["poison-capsule-smoke"], "color", {r=1, g=1, b=0, a=0.690})  --{r = 0.239, g = 0.875, b = 0.992, a = 0.690}
  TPlib.check_set_value(dr["trivial-smoke"]["poison-capsule-particle-smoke"], "color", {r=1, g=1, b=0, a=0.690})  --{r = 0.239, g = 0.875, b = 0.992, a = 0.690}
end


-- Poison cloud colour
if settings.startup["tankplatoon-ammo-colour-rearrange"].value then
  TPlib.check_set_value(dr["smoke-with-trigger"]["poison-cloud"], "color", {r=0.992, g=0.9, b=0.239, a=0.690}) --{r = 0.239, g = 0.875, b = 0.992, a = 0.690}
end


-- Stone wall resistances
local stone_wall = dr.wall["stone-wall"]
if stone_wall then
  local existentry = false
  local percentresistance = 70
  for _,v in pairs(stone_wall.resistances) do
    if v.type:match("electric") then existentry = true end
    if v.type:match("laser") then percentresistance = v.percent end
  end
  if not existentry then
    table.insert(stone_wall.resistances, {type="electric", percent=percentresistance})
  end
end

local stone_gate = dr.gate["gate"]
if stone_gate then
  local existentry = false
  local percentresistance = 70
  for _,v in pairs(stone_gate.resistances) do
    if v.type:match("electric") then existentry = true end
    if v.type:match("laser") then percentresistance = v.percent end
  end
  if not existentry then
    table.insert(stone_gate.resistances, {type="electric", percent=percentresistance})
  end
end


-- Equipment
local drad = dr["active-defense-equipment"]
local PLD = drad["personal-laser-defense-equipment"]
TPlib.check_set_value(drad["discharge-defense-equipment"], "automatic", settings.startup["tankplatoon-discharge-defense-equipment-automatic"].value)
if TPlib.check_set_value(PLD, {"attack_parameters", "ammo_type", "energy_consumption"}, settings.startup["tankplatoon-personal-laser-defense-equipment-energy-consumption"].value) then  --"50kJ"
  local PLD_shot_energy = util.parse_energy(settings.startup["tankplatoon-personal-laser-defense-equipment-energy-consumption"].value)
  local PLD_buffer = util.parse_energy(PLD.energy_source.buffer_capacity)
  if PLD_shot_energy > PLD_buffer then
    PLD.energy_source.buffer_capacity = (PLD_shot_energy * 1.1) .. "J"
    TPlib.debuglog("PLD Buffer set to "..PLD.energy_source.buffer_capacity)
  end
else
  log("Error finding energy consumption of personal-laser-defense-equipment, changes skipped.")
end


-- Item Group
TPlib.check_set_value(dr["item-subgroup"]["science-pack"], "order", "z") --"g"


-- Projectile Collision Box
-- local cannon_ap_collision_box = cfg1.collision_box_ori
-- local cannon_he_collision_box = cfg1.collision_box_ori
local cannon_force_condition = settings.startup["tankplatoon-tank-cannon-force-condition"].value

-- TPlib.check_set_value(drp["cannon-projectile"], "collision_box", cannon_ap_collision_box)
-- TPlib.check_set_value(drp["uranium-cannon-projectile"], "collision_box", cannon_ap_collision_box)
-- TPlib.check_set_value(drp["explosive-cannon-projectile"], "collision_box", cannon_he_collision_box)
-- TPlib.check_set_value(drp["explosive-uranium-cannon-projectile"], "collision_box", cannon_he_collision_box)

TPlib.check_set_value(drp["cannon-projectile"], "force_condition", cannon_force_condition)
TPlib.check_set_value(drp["uranium-cannon-projectile"], "force_condition", cannon_force_condition)
TPlib.check_set_value(drp["explosive-cannon-projectile"], "force_condition", cannon_force_condition)
TPlib.check_set_value(drp["explosive-uranium-cannon-projectile"], "force_condition", cannon_force_condition)


-- Spidertron Equipment Categories
if mods.base and mods.base >= "1.0.0" then
  local grid = dr["equipment-grid"]["spidertron-equipment-grid"]
  if not grid then
    log("WARNING!  Vanilla Spidertron equipment grid removed.  Settings not applied.")
  else
    grid.equipment_categories = TPlib.table_merge_unique{grid.equipment_categories, cfg1.category_spider_base}
    TPlib.debuglog("==== Spidertron equipment_categories ====")
    for k, v in pairs(grid.equipment_categories) do
      TPlib.debuglog("  " .. k .. ": " .. v)
    end
  end
end
