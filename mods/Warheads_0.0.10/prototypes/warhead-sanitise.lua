local sizes = require("warheads").sizes
local generateAppearance = require("appearance-util")

local function sanitseWarhead(key, warhead)
  local result = {}
  result.warhead = {}
  result.weapons = {}

  local appearance = generateAppearance(warhead)


  result.size = warhead.size
  result.preciseSize = warhead.preciseSize
  if(not result.preciseSize) then
    result.preciseSize = sizes[warhead.size]
  end

  if(result.preciseSize and not result.size) then
    local tmpSizeBestDiff = 100
    for s,i in pairs(sizes) do
      if(i > result.preciseSize  and math.abs(result.preciseSize - i)<tmpSizeBestDiff) then
        tmpSizeBestDiff = math.abs(result.preciseSize - i)
        result.size = s
      end
    end
  end
  result.warhead.item = {}

  result.warhead.item.type = "item"
  result.warhead.item.name = key
  result.warhead.item.order = warhead.order or warhead.appendOrder
  result.warhead.item.subgroup = result.size .. "-warheads"
  result.warhead.item.stack_size = warhead.stack_size
  result.warhead.item.pictures = {layers = appearance.pictures}
  result.warhead.item.icons = appearance.icons


  result.warhead.recipe = {}

  result.warhead.recipe.category = warhead.recipe_category or "crafting"
  result.warhead.recipe.type = "recipe"
  result.warhead.recipe.name = key
  result.warhead.recipe.enabled = false
  result.warhead.recipe.energy_required = warhead.energy_required
  result.warhead.recipe.ingredients = warhead.ingredients
  result.warhead.recipe.results = {{type="item", name=key, amount = warhead.recipe_result_count or 1}}

  if warhead.tint then
    result.warhead.recipe.crafting_machine_tint = warhead.tint
  end

  local explosions
  if warhead.explosions then
    explosions = warhead.explosions
  else
    explosions = {{appendName = "", appendOrder = "", effect = warhead.effect, final_effect = warhead.final_effect, created_effect = warhead.created_effect ,
      action = warhead.action, final_action = warhead.final_action, created_action = warhead.created_action}}
  end
  local prevExplosionName = nil
  for _,explosion in pairs(explosions) do
    local weapon = {}
    weapon.appendName = warhead.appendName .. explosion.appendName
    weapon.appendOrder = warhead.appendOrder .. explosion.appendOrder

    local expAppearance = generateAppearance(explosion)
    if(expAppearance.icons[1]) then
      weapon.appearance = expAppearance
    else
      weapon.appearance = appearance
    end

    weapon.item = {}

    weapon.item.stack_size_max = explosion.stack_size_max or warhead.stack_size_max or warhead.stack_size

    weapon.item.reload_time_modifier = explosion.reload_time_modifier or warhead.reload_time_modifier or 1

    weapon.item.cooldown_modifier = explosion.cooldown_modifier or warhead.cooldown_modifier or 1

    weapon.item.range_modifier = explosion.range_modifier or warhead.range_modifier or 1

    weapon.item.radius_color = explosion.radius_color or warhead.radius_color

    if(explosion.clamp_position ~= nil) then
      weapon.item.clamp_position = explosion.clamp_position
    elseif(warhead.clamp_position ~= nil) then
      weapon.item.clamp_position = warhead.clamp_position
    end
    weapon.item.target_type = explosion.target_type or warhead.target_type

    weapon.item.ammo_category = warhead.ammo_category

    weapon.recipe = {}
    weapon.recipe.warhead_count_per_item = warhead.warhead_count_per_item or 1

    weapon.recipe.energy_required_modifier = explosion.energy_required_modifier or warhead.energy_required_modifier or 1
    weapon.recipe.crafting_machine_tint = explosion.weapon_creation_tint or warhead.weapon_creation_tint
    weapon.recipe.warhead_name = key
    weapon.recipe.additional_ingedients = {}
    if(explosion.additional_ingedients) then
      for _,ingredient in pairs(explosion.additional_ingedients) do
        table.insert(weapon.recipe.additional_ingedients, ingredient)
      end
    end
    if(explosion.additional_ingedient) then
      table.insert(weapon.recipe.additional_ingedients, {name = explosion.additional_ingedient, amount = explosion.ingredient_count or 1})
    end

    if(prevExplosionName == nil) then
      if(warhead.additional_ingedients) then
        for _,ingredient in pairs(warhead.additional_ingedients) do
          table.insert(weapon.recipe.additional_ingedients, ingredient)
        end
      end
      if(warhead.additional_ingedient) then
        table.insert(weapon.recipe.additional_ingedients, {name = warhead.additional_ingedient, amount = warhead.ingredient_count or 1})
      end
    end

    if(warhead.progressiveRecipe) then
      if(prevExplosionName ~= nil) then
        weapon.recipe.build_up_ingredient = {name = prevExplosionName, amount = explosion.built_up_ingredient_amount or 1}
      end
      if(warhead.progressiveRecipe == "from-first")then
        if(prevExplosionName == nil) then
          prevExplosionName = warhead.appendName .. explosion.appendName
        end
      elseif (warhead.progressiveRecipe == "building-up")then
        prevExplosionName = warhead.appendName .. explosion.appendName
      end
    end
    weapon.recipe.additional_results = explosion.additional_results or warhead.additional_results or {}


    weapon.projectile = {}

    if(explosion.chart_picture) then
      if(type(explosion.chart_picture)=="table") then
        weapon.projectile.chart_picture = explosion.chart_picture
      else
        weapon.projectile.chart_picture = {
          filename = explosion.chart_picture,
          flags = { "icon" },
          frame_count = 1,
          width = 64,
          height = 64,
          priority = "high",
          scale = 0.25
        }
      end
    elseif(warhead.chart_picture) then
      if(type(explosion.chart_picture)=="table") then
        weapon.projectile.chart_picture = warhead.chart_picture
      else
        weapon.projectile.chart_picture = {
          filename = warhead.chart_picture,
          flags = { "icon" },
          frame_count = 1,
          width = 64,
          height = 64,
          priority = "high",
          scale = 0.25
        }
      end
    end
    if not weapon.projectile.chart_picture then
      if explosion.chart_tint or weapon.chart_tint then
        weapon.projectile.chart_picture = {
          filename = "__Warheads__/graphics/artillery/artillery-map.png",
          flags = { "icon" },
          frame_count = 1,
          width = 64,
          height = 64,
          priority = "high",
          scale = 0.25,
          tint = explosion.chart_tint or weapon.chart_tint
        }
      else
        weapon.projectile.chart_picture = {
          filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
          flags = { "icon" },
          frame_count = 1,
          width = 64,
          height = 64,
          priority = "high",
          scale = 0.25
        }
      end
    end
    weapon.projectile.collisions = true
    if(explosion.collisions ~= nil) then
      weapon.projectile.collisions = explosion.collisions
    elseif(warhead.collisions ~= nil) then
      weapon.projectile.collisions = warhead.collisions
    end


    weapon.projectile.piercing = weapon.projectile.collisions
    if(explosion.piercing ~= nil) then
      weapon.projectile.piercing = explosion.piercing
    elseif(warhead.piercing ~= nil) then
      weapon.projectile.piercing = warhead.piercing
    end
    weapon.projectile.piercing_damage_extra = explosion.piercing_damage_extra or weapon.piercing_damage_extra or 0
    weapon.projectile.piercing_damage_modifier = explosion.piercing_damage_modifier or weapon.piercing_damage_modifier or 1
    weapon.projectile.acceleration_modifier = explosion.acceleration_modifier or weapon.acceleration_modifier or 1
    weapon.projectile.max_speed_modifier = explosion.max_speed_modifier or weapon.max_speed_modifier or 1
    if explosion.action or explosion.effect then
      weapon.projectile.action = explosion.action or {type = "direct", action_delivery = {type = "instant", target_effects = explosion.effect}}
    end
    if explosion.final_action or explosion.final_effect then
      weapon.projectile.final_action = explosion.final_action or {type = "direct", action_delivery = {type = "instant", target_effects = explosion.final_effect}}
    end
    if explosion.created_action or explosion.created_effect then
      weapon.projectile.created_action = explosion.created_action or {type = "direct", action_delivery = {type = "instant", target_effects = explosion.created_effect}}
    end
    weapon.projectile.ammo_category = warhead.ammo_category
    weapon.projectile.map_color = warhead.map_color

    weapon.land_mine = {}
    weapon.land_mine.trigger_radius_modifier = explosion.trigger_radius_modifier or warhead.trigger_radius_modifier or 1
    weapon.land_mine.max_health_modifier = explosion.max_health_modifier or warhead.max_health_modifier or 1

    weapon.land_mine.action = explosion.final_action or {type = "direct", action_delivery = {type = "instant", target_effects = explosion.final_effect}}
    weapon.land_mine.created_action = explosion.created_action or {type = "direct", action_delivery = {type = "instant", target_effects = explosion.created_effect}}
    weapon.land_mine.ammo_category = warhead.ammo_category
    weapon.land_mine.dying_explosion = explosion.dying_explosion or warhead.dying_explosion
    table.insert(result.weapons, weapon)
  end
  return result
end








return sanitseWarhead
