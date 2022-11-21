local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

require("__Warheads__.prototypes.warheads")

table.insert(data.raw.technology["basic-atomic-weapons"].effects,
  {
    type = "unlock-recipe",
    recipe = "nuclear-test-site"
  })
table.insert(data.raw.technology["fusion-weapons"].effects,
  {
    type = "unlock-recipe",
    recipe = "fusion-test-site"
  })
local warheads_to_add = require("data-nukes-building-warheads")


for _,w in pairs(warheads_to_add) do
  if  data.raw.item[w.warhead] then
    local warhead = warheads[w.warhead]
    local explosion
    if(w.explosion) then
      explosion = warhead.explosions[w.explosion]
    else
      explosion = {appendOrder = "", appendName = ""}
    end
    local recipe = {
      type = "recipe",
      name = "detonation" .. warhead.appendName .. explosion.appendName .. w.label,
      category = "nuclear-detonation",
      enabled = true,
      hide_from_player_crafting = true,
      hide_from_stats = true,
      energy_required = w.energy,
      ingredients =
      {
        {w.warhead, 1}
      },
      result = "detonation" .. warhead.appendName .. explosion.appendName .. w.label,
    }
    if(w.fusion) then
      recipe.category = "fusion-detonation"
    end
    if warhead.additional_ingedients then
      for _,i in pairs(warhead.additional_ingedients) do
        table.insert(recipe.ingredients, i)
      end
    end
    if explosion.additional_ingedients then
      for _,i in pairs(explosion.additional_ingedients) do
        table.insert(recipe.ingredients, i)
      end
    end
    local item = {
      type = "item",
      name = "detonation" .. warhead.appendName .. explosion.appendName .. w.label,
      icon = w.icon or "__True-Nukes__/graphics/15kiloton-detonation.png",
      icon_size = 64, icon_mipmaps = 1,
      subgroup = "TN-atomic-detonation",
      order = "a[nuke]" ..warhead.appendOrder .. explosion.appendOrder .. w.label,
      stack_size = 1
    }

    data:extend{recipe, item}
  end
end








data:extend{
  {
    type = "recipe-category",
    name = "nuclear-detonation"
  },
  {
    type = "recipe-category",
    name = "fusion-detonation"
  },
  {
    name = "TN-atomic-detonation",
    type = "item-subgroup",
    group = "combat",
    order = "z1[TN-atomic-detonation]"
  }
}



data:extend{
  {
    type = "recipe",
    name = "nuclear-test-site",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"steel-plate", 200},
      {"concrete", 200},
      {"advanced-circuit", 25},
      {"accumulator", 5}
    },
    result = "nuclear-test-site"
  },
  {
    type = "recipe",
    name = "fusion-test-site",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"steel-plate", 2000},
      {"refined-concrete", 2000},
      {"processing-unit", 25},
      {"accumulator", 50}
    },
    result = "fusion-test-site"
  },
  {
    type = "item",
    name = "nuclear-test-site",
    icon = "__True-Nukes__/graphics/nuclear-test-building.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = "defensive-structure",
    order = "e[nuke]-a[nuclear-test-site]",
    place_result = "nuclear-test-site",
    stack_size = 1
  },
  {
    type = "item",
    name = "fusion-test-site",
    icon = "__True-Nukes__/graphics/fusion-test-building.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = "defensive-structure",
    order = "e[nuke]-b[fusion-test-site]",
    place_result = "fusion-test-site",
    stack_size = 1
  },
  {
    type = "furnace",
    name = "nuclear-test-site",
    is_military_target = true,
    icon = "__True-Nukes__/graphics/nuclear-test-building.png",
    icon_size = 64, icon_mipmaps = 1,
    source_inventory_size = 1,
    result_inventory_size = 1,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 10, result = "nuclear-test-site"},
    max_health = 5000,
    corpse = "assembling-machine-1-remnants",
    dying_explosion = "massive-explosion",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-1.40, -1.40}, {1.40, 1.40}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    alert_icon_shift = util.by_pixel(-3, -12),
    map_color = {r = 0, g = 1, b = 0, a = 1},
    created_effect = {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects = {
          type = "script",
          effect_id = "Mega-nuke built"
        }
      }
    },
    dying_trigger_effect =
    {
      type = "nested-result",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects = {
            {
              type = "nested-result",
              action =
              {
                type = "area",
                target_entities = false,
                trigger_from_target = true,
                repeat_count = 1,
                radius = 1,
                action_delivery =
                {
                  type = "projectile",
                  show_in_tooltip = false,
                  projectile = "lingering-fallout",
                  starting_speed = 0.0001,
                }
              }
            },
            {
              type = "nested-result",
              action =
              {
                type = "area",
                target_entities = false,
                trigger_from_target = true,
                repeat_count = 5,
                radius = 5,
                action_delivery =
                {
                  type = "projectile",
                  show_in_tooltip = false,
                  projectile = "fallout",
                  starting_speed = 0.0001
                }
              }
            }
          }
        }
      }
    },
    animation =
    {
      layers =
      {
        {
          filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-base.png",
          width = 212,
          height = 192,
          shift = util.by_pixel(0, -5),
          scale = 0.5,
          hr_version =
          {
            filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-base.png",
            width = 212,
            height = 192,
            shift = util.by_pixel(0, -5),
            scale = 0.5
          }
        },
        {
          filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-shadow.png",
          priority = "high",
          width = 287,
          height = 159,
          repeat_count = repeat_count,
          shift = util.by_pixel(20, 6),
          draw_as_shadow = true,
          scale = 0.5,
          hr_version =
          {
            filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-shadow.png",
            priority = "high",
            width = 287,
            height = 159,
            repeat_count = repeat_count,
            shift = util.by_pixel(20, 6),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    },
    crafting_categories = {"nuclear-detonation"},
    crafting_speed = 1,
    energy_source = {type = "void"},
    energy_usage = "1kW",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    vehicle_impact_sound = sounds.generic_impact,
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/silo-alarm.ogg",
        volume = 1.0
      },
      use_doppler_shift = false,
      audible_distance_modifier = 1,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    }
  },
  {
    type = "assembling-machine",
    name = "fusion-test-site",
    is_military_target = true,
    icon = "__True-Nukes__/graphics/fusion-test-building.png",
    icon_size = 64, icon_mipmaps = 1,
    source_inventory_size = 1,
    result_inventory_size = 1,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 10, result = "fusion-test-site"},
    max_health = 5000,
    corpse = "assembling-machine-1-remnants",
    dying_explosion = "massive-explosion",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-1.40, -1.40}, {1.40, 1.40}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    alert_icon_shift = util.by_pixel(-3, -12),
    map_color = {r = 0, g = 1, b = 0, a = 1},
    created_effect = {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects = {
          type = "script",
          effect_id = "Mega-nuke built"
        }
      }
    },
    dying_trigger_effect =
    {
      type = "nested-result",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects = {
            {
              type = "nested-result",
              action =
              {
                type = "area",
                target_entities = false,
                trigger_from_target = true,
                repeat_count = 1,
                radius = 1,
                action_delivery =
                {
                  type = "projectile",
                  show_in_tooltip = false,
                  projectile = "lingering-fallout",
                  starting_speed = 0.0001,
                }
              }
            },
            {
              type = "nested-result",
              action =
              {
                type = "area",
                target_entities = false,
                trigger_from_target = true,
                repeat_count = 5,
                radius = 5,
                action_delivery =
                {
                  type = "projectile",
                  show_in_tooltip = false,
                  projectile = "fallout",
                  starting_speed = 0.0001
                }
              }
            }
          }
        }
      }
    },
    animation =
    {
      layers =
      {
        {
          filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-base.png",
          width = 212,
          height = 192,
          shift = util.by_pixel(0, -5),
          scale = 0.5,
          hr_version =
          {
            filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-base.png",
            width = 212,
            height = 192,
            shift = util.by_pixel(0, -5),
            scale = 0.5
          }
        },
        {
          filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-shadow.png",
          priority = "high",
          width = 287,
          height = 159,
          repeat_count = repeat_count,
          shift = util.by_pixel(20, 6),
          draw_as_shadow = true,
          scale = 0.5,
          hr_version =
          {
            filename = "__True-Nukes__/graphics/megaton-nuke/megaton-nuke-shadow.png",
            priority = "high",
            width = 287,
            height = 159,
            repeat_count = repeat_count,
            shift = util.by_pixel(20, 6),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    },
    crafting_categories = {"fusion-detonation"},
    crafting_speed = 1,
    energy_source = {type = "void"},
    energy_usage = "1kW",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    vehicle_impact_sound = sounds.generic_impact,
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/silo-alarm.ogg",
        volume = 1.0
      },
      use_doppler_shift = false,
      audible_distance_modifier = 1,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    }
  }
}
