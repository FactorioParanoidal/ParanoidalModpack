local sounds = require ("__base__.prototypes.entity.sounds")
local sizes = require("warheads")
local generateAppearance = require("appearance-util")
local weapontype_sanitise = require("__Warheads__.prototypes.weapontype-sanitise")

local function combineAppearances(weapontypeGeneral, weaponAppearance, warheadWeapon)

  local icons = table.deepcopy(weaponAppearance.icons)


  if(weapontypeGeneral.image_base_shift) then
    local icon_shift = weapontypeGeneral.image_base_shift or {0, 0}
    for _,i in pairs(icons) do
      i.shift = i.shift or {0, 0}
      i.shift[1] = i.shift[1]+icon_shift[1]
      i.shift[2] = i.shift[2]+icon_shift[2]
    end
  end

  if(not weapontypeGeneral.ignore_warhead_image)then
    local core_icon_shift = weapontypeGeneral.image_warhead_shift or {10, -4}
    for _,i in pairs(table.deepcopy(warheadWeapon.icons)) do
      if(not i.special) then
        i.shift = i.shift or {0, 0}
        i.shift[1] = i.shift[1]+core_icon_shift[1]
        i.shift[2] = i.shift[2]+core_icon_shift[2]
        i.scale = i.scale or 1
        i.scale = i.scale/3
      end
      table.insert(icons, i)
    end
  end

  local pictures = table.deepcopy(weaponAppearance.pictures)


  if(weapontypeGeneral.image_base_shift) then
    local icon_shift = {weapontypeGeneral.image_base_shift[1]*0.01875, weapontypeGeneral.image_base_shift[2]*0.01875}
    for _,i in pairs(pictures) do
      i.shift = i.shift or {0, 0}
      i.shift[1] = i.shift[1]+icon_shift[1]
      i.shift[2] = i.shift[2]+icon_shift[2]
    end
  end

  local core_shift = {0.1875, -0.075}
  if(weapontypeGeneral.image_warhead_shift) then
    core_shift = {weapontypeGeneral.image_warhead_shift[1]*0.01875, weapontypeGeneral.image_warhead_shift[2]*0.01875}
  end
  for _,i in pairs(table.deepcopy(warheadWeapon.pictures)) do
    i.shift = i.shift or {0, 0}
    i.scale = i.scale or 1
    if not i.special then
      i.shift[1] = i.shift[1]+core_shift[1]
      i.shift[2] = i.shift[2]+core_shift[2]
      i.scale = i.scale*2/3.0
    end
    table.insert(pictures, i)
  end


  return {icons = icons, pictures = pictures}
end





local function combine(weapontype, warheadWeapon)
  local result = {}

  if(weapontype.override) then
    result =  weapontype.override(weapontype, warheadWeapon)
    if(warheadWeaponIgnore[weapontype.name .. warheadWeapon.appendName]) then
      result.valid = false
    end
    if(warheadOverrides[weapontype.name .. warheadWeapon.appendName]) then
      for _,override in pairs(warheadOverrides[weapontype.name .. warheadWeapon.appendName]) do
        override(result)
      end
    end
    return result
  end

  local item = {type = "item"}

  local name = weapontype.name .. warheadWeapon.appendName
  result.rawName = name
  if(warheadWeaponNameMap[weapontype.name .. warheadWeapon.appendName]) then
    name = warheadWeaponNameMap[name]
  end

  item.name = name
  item.order = weapontype.order .. warheadWeapon.appendOrder
  item.subgroup = weapontype.item.subgroup


  local weaponAppearance

  if weapontype.appearances[warheadWeapon.appendName] then
    weaponAppearance = generateAppearance(weapontype.appearances[warheadWeapon.appendName])
  else
    weaponAppearance = generateAppearance(weapontype.appearances["default"])
  end

  local appearance = combineAppearances(weapontype.appearance, weaponAppearance, warheadWeapon.appearance)
  item.icons = appearance.icons
  item.pictures = {layers = appearance.pictures}
  item.stack_size = math.min(weapontype.item.stack_size, warheadWeapon.item.stack_size_max)

  item.magazine_size = weapontype.item.magazine_size

  if (weapontype.item.reload_time) then
    item.reload_time = weapontype.item.reload_time*warheadWeapon.item.reload_time_modifier
  end
  if (weapontype.type == "projectile" or weapontype.type == "stream" or weapontype.type == "artillery" or weapontype.type == "bullet") then
    item.type = "ammo"
    item.ammo_type = {}
    item.ammo_type.range_modifier = weapontype.item.range_modifier * warheadWeapon.item.range_modifier
    item.ammo_type.cooldown_modifier = weapontype.item.cooldown_modifier * warheadWeapon.item.cooldown_modifier
    item.ammo_type.target_type = warheadWeapon.item.target_type or weapontype.item.target_type
    item.ammo_type.clamp_position = weapontype.item.clamp_position or warheadWeapon.item.clamp_position
    item.ammo_type.category = warheadWeapon.item.ammo_category or weapontype.item.ammo_category
    item.ammo_type.action = weapontype.item.action_creator(name, weapontype.item.range_modifier * warheadWeapon.item.range_modifier, warheadWeapon.projectile.action, warheadWeapon.projectile.final_action, warheadWeapon.projectile.created_action)
  elseif(weapontype.type == "land-mine") then
    item.place_result = name
  elseif(weapontype.type == "capsule") then
    item.type = "capsule"
    item.capsule_action = weapontype.item.action_creator(name, weapontype.item.range_modifier * warheadWeapon.item.range_modifier, warheadWeapon.projectile.action, warheadWeapon.projectile.final_action, warheadWeapon.projectile.created_action)
    item.radius_color = weapontype.item.radius_color or warheadWeapon.item.radius_color or weapontype.item.default_radius_color
  end

  item.localised_name = {"weapontype-name." .. weapontype.name, {"warhead-name." .. warheadWeapon.appendName}}
  item.localised_description = {"weapontype-description." .. weapontype.name, {"warhead-description." .. warheadWeapon.appendName}}
  result.item = item

  local recipe = {type = "recipe"}
  local warheadsUsed = 0
  recipe.name = name
  recipe.enabled = false
  recipe.order = weapontype.order .. warheadWeapon.appendOrder
  recipe.category = weapontype.recipe.category
  recipe.subgroup = weapontype.recipe.subgroup
  recipe.energy_required = weapontype.recipe.energy_required * warheadWeapon.recipe.energy_required_modifier
  recipe.crafting_machine_tint = warheadWeapon.recipe.crafting_machine_tint
  recipe.ingredients = table.deepcopy(weapontype.recipe.ingredients)
  if(warheadWeapon.recipe.build_up_ingredient) then
    recipe.ingredients = {}
    local buildUpName = weapontype.name .. warheadWeapon.recipe.build_up_ingredient.name
    if(warheadWeaponNameMap[buildUpName]) then
      buildUpName = warheadWeaponNameMap[buildUpName]
    end
    table.insert(recipe.ingredients, {name = buildUpName, amount = warheadWeapon.recipe.build_up_ingredient.amount})
  else
    table.insert(recipe.ingredients, {name = warheadWeapon.recipe.warhead_name, amount = weapontype.recipe.warhead_count})
    warheadsUsed = weapontype.recipe.warhead_count
  end
  for _,i in pairs(warheadWeapon.recipe.additional_ingedients) do
    table.insert(recipe.ingredients, i)
  end
  recipe.icons = appearance.icons
  recipe.results = {{type="item", name=name, amount = weapontype.recipe.result_count}}
  for _,r in pairs(weapontype.recipe.additional_results) do
    table.insert(recipe.results, r)
  end
  for _,r in pairs(warheadWeapon.recipe.additional_results) do
    table.insert(recipe.results, r)
  end

  if(warheadsUsed ~= 0 and warheadWeapon.recipe.warhead_count_per_item ~= 1) then
    local batch_size = 1
    for i = 1,warheadWeapon.recipe.warhead_count_per_item do
      if ((i*warheadsUsed) % warheadWeapon.recipe.warhead_count_per_item == 0) then
        batch_size = i
        break
      end
    end
    for _,i in pairs(recipe.ingredients) do
      if((i.name or i[1]) == warheadWeapon.recipe.warhead_name) then
        i.amount = (i.amount or i[2])*batch_size/warheadWeapon.recipe.warhead_count_per_item
        i[2] = nil
      else
        i.amount = (i.amount or i[2])*batch_size
        i[2] = nil
      end
    end
    for _,r in pairs(recipe.results) do
      r.amount = (r.amount or r[2])*batch_size
      r[2] = nil
    end
  end
  result.recipe = recipe

  if (weapontype.type == "projectile" or weapontype.type == "stream" or weapontype.type == "capsule" or weapontype.type == "artillery") then
    local projectile = {}
    if(weapontype.type == "stream")then
      projectile = table.deepcopy(weapontype.stream);
    end
    projectile.name = name
    projectile.order = weapontype.order .. warheadWeapon.appendOrder
    projectile.icons = appearance.icons

    if (weapontype.type == "projectile" or weapontype.type == "capsule")then
      projectile.type = "projectile"

      if weapontype.projectile.acceleration then
        projectile.acceleration = weapontype.projectile.acceleration * warheadWeapon.projectile.acceleration_modifier
      end
      projectile.animation = weapontype.projectile.animation
      projectile.direction_only = warheadWeapon.projectile.collisions and weapontype.projectile.direction_only
      projectile.height = weapontype.projectile.height
      projectile.light = weapontype.projectile.light
      if(weapontype.projectile.max_speed) then
        projectile.max_speed = weapontype.projectile.max_speed * warheadWeapon.projectile.max_speed_modifier
      end
      if(weapontype.projectile.piercing_damage) then
        projectile.piercing_damage = weapontype.projectile.piercing_damage * warheadWeapon.projectile.piercing_damage_modifier + warheadWeapon.projectile.piercing_damage_extra
      else
        projectile.piercing_damage = warheadWeapon.projectile.piercing_damage_extra
      end
      if not warheadWeapon.projectile.piercing then
        projectile.piercing_damage = 0
      end

      projectile.shadow = weapontype.projectile.shadow
      projectile.smoke = weapontype.projectile.smoke
      projectile.height_from_ground = weapontype.projectile.height
      projectile.collision_box = weapontype.projectile.collision_box


      if((not warheadWeapon.projectile.collisions) and (not weapontype.projectile.collide_anyway)) then
        projectile.collision_box = nil
      end
    elseif (weapontype.type == "artillery") then
      projectile.type = "artillery-projectile"

      projectile.chart_picture = warheadWeapon.projectile.chart_picture
      projectile.reveal_map = weapontype.projectile.reveal_map
      projectile.map_color = warheadWeapon.projectile.map_color or weapontype.projectile.map_color
    end
    projectile.action = warheadWeapon.projectile.action
    projectile.final_action = warheadWeapon.projectile.final_action
    projectile.created_effect = warheadWeapon.projectile.created_action
    projectile.picture = weapontype.projectile.picture
    projectile.shadow = weapontype.projectile.shadow
    projectile.localised_name = {"weapontype-name." .. weapontype.name, {"warhead-name." .. warheadWeapon.appendName}}
    projectile.localised_description = {"weapontype-description." .. weapontype.name, {"warhead-description." .. warheadWeapon.appendName}}

    if(weapontype.type == "stream")then
      projectile.action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          target_effects = {
            {
              type = "nested-result",
              action =projectile.action
            },
            {
              type = "nested-result",
              action =projectile.final_action
            }
          }
        }
      }

    end
    result.projectile = projectile
  elseif(weapontype.type == "land-mine") then
    local landmine = {}
    landmine.name = name
    landmine.order = weapontype.order .. warheadWeapon.appendOrder
    landmine.icons = item.icons
    landmine.type = "land-mine"
    landmine.ammo_category = (warheadWeapon.landmine or warheadWeapon.item).ammo_category or (warheadWeapon.land_mine or warheadWeapon.item).ammo_category
    landmine.trigger_radius = weapontype.land_mine.trigger_radius*warheadWeapon.land_mine.trigger_radius_modifier
    landmine.picture_safe = (weapontype.land_mine.pictures[warheadWeapon.appendName] or weapontype.land_mine.pictures["default"]).picture_safe
    landmine.picture_set = (weapontype.land_mine.pictures[warheadWeapon.appendName] or weapontype.land_mine.pictures["default"]).picture_set
    landmine.picture_set_enemy = (weapontype.land_mine.pictures[warheadWeapon.appendName] or weapontype.land_mine.pictures["default"]).picture_set_enemy
    landmine.max_health = weapontype.land_mine.max_health*warheadWeapon.land_mine.max_health_modifier
    landmine.selection_box = weapontype.land_mine.selection_box
    landmine.created_effect = warheadWeapon.land_mine.created_effect
    landmine.minable = table.deepcopy(weapontype.land_mine.minable)
    landmine.minable.result = item.name
    landmine.corpse = weapontype.land_mine.corpse
    landmine.collision_box = weapontype.land_mine.collision_box
    landmine.selection_box = weapontype.land_mine.selection_box
    landmine.damaged_trigger_effect = weapontype.land_mine.damaged_trigger_effect
    landmine.dying_explosion = (warheadWeapon.landmine or {}).dying_explosion or (weapontype.land_mine or {}).dying_explosion

    landmine.flags =
      {
        "placeable-player",
        "placeable-enemy",
        "player-creation",
        "placeable-off-grid",
        "not-on-map"
      }
    landmine.localised_name = {"weapontype-name." .. weapontype.name, {"warhead-name." .. warheadWeapon.appendName}}
    landmine.localised_description = {"weapontype-description." .. weapontype.name, {"warhead-description." .. warheadWeapon.appendName}}
    landmine.open_sound = sounds.machine_open
    landmine.close_sound = sounds.machine_close
    landmine.mined_sound = { filename = "__core__/sound/deconstruct-small.ogg" }
    landmine.action = warheadWeapon.land_mine.action
    result.landmine = landmine
  end
  result.valid = true
  if(warheadWeaponIgnore[weapontype.name .. warheadWeapon.appendName]) then
    result.valid = false
  end
  if(warheadOverrides[weapontype.name .. warheadWeapon.appendName]) then
    for _,override in pairs(warheadOverrides[weapontype.name .. warheadWeapon.appendName]) do
      override(result)
    end
  end
  return result
end






return combine




