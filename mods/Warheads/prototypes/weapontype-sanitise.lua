local util = require("warheads")



local function sanitseWeapontype(weapontype)
  local item = weapontype.item or {}

  local result = {}
  result.type = weapontype.type -- projectile, artillery, land-mine, bullet, capsule, other...

  result.name = weapontype.baseName
  result.order = weapontype.baseOrder or weapontype.item.order

  result.size = {}
  result.size.max = weapontype.size or weapontype.max_size
  result.size.min = weapontype.min_size
  if (type(result.size.max)=="string") then
    result.size.max = util.sizes[result.size.max]
  else
    result.size.max = result.size.max or util.sizes["all"]
  end
  if (type(result.size.min)=="string") then
    result.size.min = util.sizes[result.size.min]
  else
    result.size.min = result.size.min or util.sizes["none"]
  end
  if(weapontype.override) then
    result.override = weapontype.override
    return result
  end

  local appearance_fallbacks_tmp = table.deepcopy(weapontype.appearance_fallbacks) or {}

  if(weapontype.appearance_fallback) then
    table.insert(appearance_fallbacks_tmp, weapontype.appearance_fallback)
  end
  local appearance_fallbacks = {weapontype}
  for _,f in pairs(appearance_fallbacks_tmp) do
    if(weaponTypes[f]) then
      table.insert(appearance_fallbacks, weaponTypes[f])
    end
  end

  result.appearance = {}
  result.appearance.image_base_shift = weapontype.image_base_shift
  result.appearance.image_warhead_shift = weapontype.image_warhead_shift
  result.appearance.ignore_warhead_image = weapontype.ignore_warhead_image

  result.appearances = {}

  if(weapontype.icon) then
    if not result.appearances["default"] then
      result.appearances["default"] = {}
    end
    if not result.appearances["default"].icons then
      result.appearances["default"].icons = {weapontype.icon}
    end
  end
  if(weapontype.picture) then
    if not result.appearances["default"] then
      result.appearances["default"] = {}
    end
    if not result.appearances["default"].pictures then
      result.appearances["default"].pictures = {weapontype.picture}
    end
  end
  if(weapontype.light) then
    if not result.appearances["default"] then
      result.appearances["default"] = {}
    end
    if not result.appearances["default"].lights then
      result.appearances["default"].lights = {weapontype.light}
    end
  end

  for _,fallback in pairs(appearance_fallbacks) do
    local startContents = table.deepcopy(result.appearances)
    if (fallback.icons) then
      for w, e in pairs(fallback.icons) do
        local index = w
        if type(w) == "number" then
          index = "default"
        end
        if(not startContents[w]) then
          if not result.appearances[index] then
            result.appearances[index] = {}
          end
          if not result.appearances[index].icons then
            result.appearances[index].icons = {}
          end
          if(type(e) == "table" and e.filename == nil and e.icon == nil) then
            for _,i in pairs(e) do
              table.insert(result.appearances[index].icons, i)
            end
          else
            table.insert(result.appearances[index].icons, e)
          end
        end
      end
    end
    if (fallback.pictures) then
      for w, e in pairs(fallback.pictures) do
        local index = w
        if type(w) == "number" then
          index = "default"
        end
        if(not startContents[w]) then
          if not result.appearances[index] then
            result.appearances[index] = {}
          end
          if not result.appearances[index].pictures then
            result.appearances[index].pictures = {}
          end
          if(type(e) == "table" and e.filename == nil and e.icon == nil) then
            for _,p in pairs(e) do
              table.insert(result.appearances[index].pictures, p)
            end
          else
            table.insert(result.appearances[index].pictures, e)
          end
        end
      end
    end
    if (fallback.lights) then
      for w, e in pairs(fallback.lights) do
        local index = w
        if type(w) == "number" then
          index = "default"
        end
        if(not startContents[w]) then
          if not result.appearances[index] then
            result.appearances[index] = {}
          end
          if not result.appearances[index].lights then
            result.appearances[index].lights = {}
          end
          if(type(e) == "table" and e.filename == nil and e.icon == nil) then
            for _,l in pairs(e) do
              table.insert(result.appearances[index].lights, l)
            end
          else
            table.insert(result.appearances[index].lights, e)
          end
        end
      end
    end
  end

  for w, m in pairs(result.appearances) do
    if (weapontype.addon_icons) then
      if not m.icons then
        m.icons = {}
      end
      for _,i in pairs(weapontype.addon_icons) do
        table.insert(m.icons, i)
      end
    end
    if (weapontype.addon_icon) then
      if not m.icons then
        m.icons = {}
      end
      table.insert(m.icons, weapontype.addon_icon)
    end

    if (weapontype.addon_pictures) then
      if not m.pictures then
        m.pictures = {}
      end
      for _,p in pairs(weapontype.addon_pictures) do
        table.insert(m.pictures, p)
      end
    end
    if (weapontype.addon_picture) then
      if not m.pictures then
        m.pictures = {}
      end
      table.insert(m.pictures, weapontype.addon_picture)
    end

    if (weapontype.addon_lights) then
      if not m.lights then
        m.lights = {}
      end
      for _,l in pairs(weapontype.addon_lights) do
        table.insert(m.lights, l)
      end
    end
    if (weapontype.addon_light) then
      if not m.lights then
        m.lights = {}
      end
      table.insert(m.pictures, weapontype.addon_light)
    end
  end

  if not result.appearances["default"] then
    result.appearances["default"] = {}
  end
  if (result.appearances["default"].icons == nil) then
    if(item.icon) then
      result.appearances["default"].icons = {{icon = item.icon, icon_size = item.icon_size}}
    else
      result.appearances["default"].icons = item.icons
    end
  end

  result.item = {}
  result.item.subgroup = weapontype.subgroup or item.subgroup
  result.item.stack_size = weapontype.stack_size or item.stack_size or 200

  result.item.magazine_size = weapontype.magazine_size or item.magazine_size or 1
  result.item.reload_time = weapontype.reload_time or item.reload_time or 0

  result.item.radius_color = weapontype.radius_color

  result.item.default_radius_color = weapontype.default_radius_color or item.radius_color

  result.item.target_type = weapontype.target_type
  if(item.ammo_type and not result.item.target_type) then result.item.target_type = item.ammo_type.target_type end
  result.item.target_type = result.item.target_type or "entity"

  result.item.range_modifier = weapontype.range_modifier
  if(item.ammo_type and not result.item.range_modifier) then result.item.range_modifier = item.ammo_type.range_modifier end
  result.item.range_modifier = result.item.range_modifier or 1

  result.item.cooldown_modifier = weapontype.cooldown_modifier
  if(item.ammo_type and not result.item.cooldown_modifier) then result.item.cooldown_modifier = item.ammo_type.cooldown_modifier end
  result.item.cooldown_modifier = result.item.cooldown_modifier or 1

  result.item.clamp_position = weapontype.clamp_position
  if(item.ammo_type and (result.item.clamp_position == nil)) then result.item.clamp_position = item.ammo_type.clamp_position end

  result.item.action_creator = weapontype.action_creator

  result.item.ammo_category = weapontype.ammo_category
  if(item.ammo_type and (result.item.ammo_category == nil)) then result.item.ammo_category = item.ammo_type.category end

  -- default action creators
  if not result.item.action_creator then
    if result.type == "projectile" or result.type == "artillery" then
      result.item.action_creator = function (projectile, range_mult, target_action, final_action, source_action)
        local a = table.deepcopy(item.ammo_type.action)
        local to_use = nil
        for _,act in pairs(a) do
          local action = act
          if(a.action_delivery)then
            action = a
          end
          if(action.action_delivery.projectile) then
            to_use = action.action_delivery
          else
            for _,del in pairs(action.action_delivery) do
              if (type(del) == "table" and del.projectile) then
                to_use = del
              end
            end
          end
          if(to_use) then
            break
          end
        end
        if(not to_use) then
          log("ERROR: Cannot find projectile field")
          log("NAME: " .. item.name)
          local ERROR_No_projectile_field_on_item____PLEASE_REPORT_AS_BUG_ON_MOD_PAGE = nil
          log(ERROR_No_projectile_field_on_item____PLEASE_REPORT_AS_BUG_ON_MOD_PAGE.a)
        end
        to_use.projectile = projectile
        if(to_use.max_range) then
          to_use.max_range = range_mult * to_use.max_range
        end
        if source_action then
          if not to_use.source_effects then
            to_use.source_effects = {}
          end
          table.insert(to_use.source_effects, {type = "nested-result", action = source_action})
        end
        return a
      end
    elseif result.type == "stream" then
      result.item.action_creator = function (stream, range_mult, target_action, final_action, source_action)
        local a = table.deepcopy(item.ammo_type.action)
        local to_use = nil

        for _,act in pairs(a) do
          local action = act
          if(a.action_delivery)then
            action = a
          end
          if(action.action_delivery.stream) then
            to_use = action.action_delivery
          else
            for _,del in pairs(action.action_delivery) do
              if (del.stream) then
                to_use = del
              end
            end
          end
          if(to_use) then
            break
          end
        end
        if(not to_use) then
          log("ERROR: Cannot find stream field")
          log("NAME: " .. item.name)
          local ERROR_No_projectile_field_on_item____PLEASE_REPORT_AS_BUG_ON_MOD_PAGE = nil
          log(ERROR_No_projectile_field_on_item____PLEASE_REPORT_AS_BUG_ON_MOD_PAGE.a)
        end
        to_use.stream = stream
        if source_action then
          if not to_use.source_effects then
            to_use.source_effects = {}
          end
          table.insert(to_use.source_effects, {type = "nested-result", action = source_action})
        end
        return a
      end
    elseif result.type == "land-mine" then
      result.item.action_creator = function (projectile, range_mult, target_action, final_action, source_action)
        local a = table.deepcopy(item.action)
        if source_action then
          if not a.action_delivery.source_effects then
            a.action_delivery.source_effects = {}
          end
          table.insert(a.action_delivery.source_effects, {type = "nested-result", action = source_action})
        end
        if final_action then
          if not a.action_delivery.target_effects then
            a.action_delivery.target_effects = {}
          end
          table.insert(a.action_delivery.target_effects, {type = "nested-result", action = final_action})
        end
        if target_action then
          if not a.action_delivery.target_effects then
            a.action_delivery.target_effects = {}
          end
          table.insert(a.action_delivery.target_effects, {type = "nested-result", action = target_action})
        end
        return a
      end
    elseif result.type == "bullet" then
      result.item.action_creator = function (projectile, range_mult, target_action, final_action, source_action)
        local a = table.deepcopy(item.ammo_type.action)
        local to_use = nil

        for _,act in pairs(a) do
          local action = act
          if(a.action_delivery)then
            action = a
          end
          if(action.action_delivery.type) then
            to_use = action.action_delivery
          else
            for _,del in pairs(action.action_delivery) do
              if (del.type == "instant") then
                to_use = del
              end
            end
          end
          if(to_use) then
            break
          end
        end
        if(not to_use) then
          log("ERROR: Cannot find target_action field")
          log("NAME: " .. item.name)
          local ERROR_No_target_action_field_on_item____PLEASE_REPORT_AS_BUG_ON_MOD_PAGE = nil
          log(ERROR_No_target_action_field_on_item____PLEASE_REPORT_AS_BUG_ON_MOD_PAGE.a)
        end

        if target_action then
          if not to_use.target_effects then
            to_use.target_effects = {}
          end
          table.insert(to_use.target_effects, {type = "nested-result", action = target_action})
        end
        if final_action then
          if not to_use.target_effects then
            to_use.target_effects = {}
          end
          table.insert(to_use.target_effects, {type = "nested-result", action = final_action})
        end
        if source_action then
          if not to_use.source_effects then
            to_use.source_effects = {}
          end
          table.insert(to_use.source_effects, {type = "nested-result", action = source_action})
        end
        return a

      end

    elseif result.type == "capsule" then
      --should work on grenades... not sure about much else
      result.item.action_creator = function (projectile, range_mult, target_action, final_action, source_action)
        local a = table.deepcopy(item.capsule_action)
        a.attack_parameters.range = a.attack_parameters.range*range_mult
        if source_action then
          if not a.attack_parameters.ammo_type.action[2].action_delivery.source_effects then
            a.attack_parameters.ammo_type.action[2].action_delivery.source_effects = {}
          end
          table.insert(to_use.source_effects, {type = "nested-result", action = source_action})
        end
        a.attack_parameters.ammo_type.action[1].action_delivery.projectile = projectile
        return a

      end

    end
  end

  result.weapontype = weapontype

  result.recipe = {}
  result.recipe.result_count = weapontype.result_count or 1
  result.recipe.additional_results = weapontype.additional_results or {}

  result.recipe.ingredients = {{name = weapontype.base_item, amount = 1}}
  if(weapontype.extra_ingredients) then
    for _,i in pairs(weapontype.extra_ingredients) do
      table.insert(result.recipe.ingredients, i)
    end
  end
  result.recipe.energy_required = weapontype.energy_required
  result.recipe.category = weapontype.recipe_category
  result.recipe.subgroup = weapontype.recipe_subgroup
  result.recipe.hide_from_player_crafting = weapontype.hide_from_player_crafting
  result.recipe.warhead_count = weapontype.warhead_count or result.item.magazine_size

  result.land_mine = {}
  result.land_mine.corpse = weapontype.land_mine_corpse  or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).corpse
  result.land_mine.trigger_radius = weapontype.trigger_radius  or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).trigger_radius
  result.land_mine.max_health = weapontype.land_mine_max_health or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).max_health
  result.land_mine.damaged_trigger_effect = weapontype.land_mine_damaged_trigger_effect or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).damaged_trigger_effect
  result.land_mine.selection_box = weapontype.land_mine_selection_box or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).selection_box
  result.land_mine.collision_box = weapontype.land_mine_collision_box or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).collision_box
  result.land_mine.dying_explosion = weapontype.land_mine_dying_explosion or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).dying_explosion

  result.land_mine.pictures = weapontype.land_mine_pictures
  if not result.land_mine.pictures then
    result.land_mine.pictures = {}
  end
  if not result.land_mine.pictures["default"] then
    result.land_mine.pictures["default"] = {
      picture_safe = (weapontype.landmine or data.raw["land-mine"]["land-mine"]).picture_safe,
      picture_set = (weapontype.landmine or data.raw["land-mine"]["land-mine"]).picture_set,
      picture_set_enemy = (weapontype.landmine or data.raw["land-mine"]["land-mine"]).picture_set_enemy
    }
  end
  result.land_mine.minable = {
    mining_time = weapontype.land_mine_mining_time or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).minable.mining_time,
    mining_particle = weapontype.land_mine_mining_particle or (weapontype.landmine or data.raw["land-mine"]["land-mine"]).mining_particle
  }

  --TODO: do this nicely
  if(weapontype.stream) then
    result.stream = weapontype.stream
    weapontype.projectile = weapontype.projectile or weapontype.stream
  end
  result.projectile = {}
  if weapontype.projectile then
    result.projectile.acceleration = weapontype.projectile_acceleration or weapontype.projectile.acceleration
    result.projectile.picture = weapontype.projectile_picture or weapontype.animation or weapontype.projectile.picture or weapontype.projectile.animation
    result.projectile.shadow = weapontype.projectile_shadow  or weapontype.projectile.shadow
    result.projectile.smoke = weapontype.projectile_smoke  or weapontype.projectile.smoke
    result.projectile.light = weapontype.projectile_light  or weapontype.projectile.light
    result.projectile.animation = weapontype.projectile_animation or weapontype.picture or weapontype.projectile.animation or weapontype.projectile.picture
    result.projectile.max_speed = weapontype.max_speed  or weapontype.projectile.max_speed
    result.projectile.collision_box = weapontype.collision_box or weapontype.projectile.collision_box
    result.projectile.force_condition = weapontype.force_condition or weapontype.projectile.force_condition

    result.projectile.height = weapontype.height or weapontype.height_from_ground or weapontype.projectile.height or weapontype.projectile.height_from_ground

    result.projectile.direction_only = weapontype.direction_only
    result.projectile.collide_anyway = weapontype.collide_anyway

    if(weapontype.direction_only == nil) then
      result.projectile.direction_only =  weapontype.projectile.direction_only
    end
    result.projectile.turn_speed = weapontype.turn_speed or weapontype.projectile.turn_speed

    result.projectile.reveal_map = weapontype.reveal_map
    if(result.projectile.reveal_map == nil) then
      result.projectile.reveal_map =  weapontype.projectile.reveal_map
    end
    if(result.projectile.reveal_map == nil) then
      result.projectile.reveal_map =  true
    end
    result.projectile.map_color = weapontype.map_color or weapontype.projectile.map_color
  else
    result.projectile.acceleration = weapontype.projectile_acceleration
    result.projectile.picture = weapontype.projectile_picture
    result.projectile.shadow = weapontype.projectile_shadow
    result.projectile.smoke = weapontype.projectile_smoke
    result.projectile.light = weapontype.projectile_light
    result.projectile.animation = weapontype.projectile_animation
    result.projectile.max_speed = weapontype.max_speed
    result.projectile.collision_box = weapontype.collision_box or {{0, 0}, {0, 0}}

    result.projectile.height = weapontype.height or weapontype.height_from_ground

    result.projectile.direction_only = weapontype.direction_only
    result.projectile.collide_anyway = weapontype.collide_anyway

    result.projectile.turn_speed = weapontype.turn_speed

    result.projectile.reveal_map = weapontype.reveal_map

    result.projectile.map_color = weapontype.map_color
  end

  return result
end






return sanitseWeapontype



