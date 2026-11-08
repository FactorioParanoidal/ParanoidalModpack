local sounds = require("__base__.prototypes.entity.sounds")
local space_age_sounds = require("__space-age__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")
local space_age_item_sounds = require("__space-age__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local item_effects = require("__space-age__.prototypes.item-effects")
local meld = require("meld")

data:extend(
{
    {
        type = "item",
        name = "golden-science-pack",
        localised_description = {"item-description.science-pack"},
        icon = "__secretas__/graphics/icons/golden-science-pack.png",
        subgroup = "science-pack",
        color_hint = { text = "Y" },
        order = "k",
        inventory_move_sound = item_sounds.science_inventory_move,
        pick_sound = item_sounds.science_inventory_pickup,
        drop_sound = item_sounds.science_inventory_move,
        stack_size = 200,
        default_import_location = "frozeta",
        weight = 1*kg,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value",
        random_tint_color = item_tints.bluish_science
    },
    {
        type = "item",
        name = "gold-ore",
        icon = "__secretas__/graphics/icons/gold-ore.png",
        order = "zz[golden]",
        subgroup = "raw-resource",
        color_hint = { text = "T" },

        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        stack_size = 50,
        default_import_location = "secretas",
        weight = 10*kg
    },
    {
        type = "item",
        name = "spaceship-scrap",
        icon = "__secretas__/graphics/icons/spaceship-scrap.png",
        pictures =
        {
          { size = 64, filename = "__secretas__/graphics/icons/spaceship-scrap.png",   scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/spaceship-scrap-1.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/spaceship-scrap-2.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/spaceship-scrap-3.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/spaceship-scrap-4.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/spaceship-scrap-5.png", scale = 0.5, mipmap_count = 4 }
        },
        subgroup = "raw-resource",
        order = "b[scrap]-b[spaceshipscrap]",
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        stack_size = 50,
        default_import_location = "frozeta",
        weight = 2*kg,
        -- Paranoidal: its recycling is the spaceship scrap recycling itself (like the Space Age scrap), the recycling rebuild
        -- of zzzparanoidal must not replace it with a self-recycling recipe of the same name.
        auto_recycle = false
    },
    {
        type = "item",
        name = "gold-plate",
        icon = "__secretas__/graphics/icons/gold-plate.png",
        order = "z[goldplate]",
        subgroup = "raw-material",
        color_hint = { text = "T" },
  
        inventory_move_sound = item_sounds.resource_inventory_move,
        pick_sound = item_sounds.resource_inventory_pickup,
        drop_sound = item_sounds.resource_inventory_move,
        stack_size = 50,
        default_import_location = "frozeta",
        weight = 4*kg,
        place_as_tile =
        {
          result = "gold-path",
          condition_size = 1,
          condition = {layers={water_tile=true}}
        }
    },
    {
        type = "item",
        name = "hyper-inserter",
        icon = "__secretas__/graphics/icons/hyper-inserter.png",
        subgroup = "inserter",
        color_hint = { text = "S" },
        order = "h[hyper-inserter]",
        inventory_move_sound = item_sounds.wire_inventory_move,
        pick_sound = item_sounds.wire_inventory_pickup,
        drop_sound = item_sounds.wire_inventory_move,
        place_result = "hyper-inserter",
        stack_size = 50,
        default_import_location = "frozeta",
        weight = 35*kg
    },
    {
        type = "item",
        name = "auric-asteroid-chunk",
        icon = "__secretas__/graphics/icons/auric-asteroid-chunk.png",
        subgroup = "space-material",
        order = "b[auric]-e[chunk]",
        inventory_move_sound = space_age_item_sounds.rock_inventory_move,
        pick_sound = space_age_item_sounds.rock_inventory_pickup,
        drop_sound = space_age_item_sounds.rock_inventory_move,
        stack_size = 1,
        weight = 100 * kg,
        random_tint_color = item_tints.iron_rust
    },
    {
        type = "item",
        name = "steam-recycler",
        icon = "__secretas__/graphics/icons/steam-recycler.png",
        subgroup = "smelting-machine",
        order = "d[steamrecycler]",
        inventory_move_sound = item_sounds.metal_large_inventory_move,
        pick_sound = item_sounds.metal_large_inventory_pickup,
        drop_sound = item_sounds.metal_large_inventory_move,
        place_result = "steam-recycler",
        stack_size = 20,
        weight = 100 * kg,
        default_import_location = "frozeta",
    },

    {
        type = "item",
        name = "golden-biter-egg",
        icon = "__secretas__/graphics/icons/golden-biter-egg.png",
        pictures =
        {
          { size = 64, filename = "__secretas__/graphics/icons/golden-biter-egg.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/golden-biter-egg-1.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/golden-biter-egg-2.png", scale = 0.5, mipmap_count = 4 },
          { size = 64, filename = "__secretas__/graphics/icons/golden-biter-egg-3.png", scale = 0.5, mipmap_count = 4 },
        },
        fuel_categories = {"chemical"},
        fuel_value = "16MJ",
        subgroup = "agriculture-products",
        order = "c[eggs]-b[biter-egg]",
        inventory_move_sound = space_age_item_sounds.agriculture_inventory_move,
        pick_sound = space_age_item_sounds.agriculture_inventory_pickup,
        drop_sound = space_age_item_sounds.agriculture_inventory_move,
        stack_size = 100,
        weight = 2 * kg,
        default_import_location = "frozeta",
        --[[
        spoil_ticks = 0.5 * hour,
        spoil_to_trigger_result =
        {
          items_per_trigger = 5, -- per 5 items the trigger is run
          trigger =
          {
            type = "direct",
            action_delivery =
            {
              type = "instant",
              source_effects =
              {
                {
                  type = "create-entity",
                  entity_name = "big-biter",
                  affects_target = true,
                  show_in_tooltip = true,
                  as_enemy = true,
                  find_non_colliding_position = true,
                  offset_deviation = {{-1, -1}, {1, 1}},
                  non_colliding_fail_result =
                  {
                    type = "direct",
                    action_delivery =
                    {
                      type = "instant",
                      source_effects =
                      {
                        {
                          type = "create-entity",
                          entity_name = "big-biter",
                          affects_target = true,
                          show_in_tooltip = false,
                          as_enemy = true,
                          offset_deviation = {{-1, -1}, {1, 1}},
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        --]]
    },

    --MODULES 
    {
        type = "module",
        name = "quality-module-4-S",
        localised_description = { "item-description.quality-module" },
        icon = "__secretas__/graphics/icons/quality-module-4.png",
        subgroup = "module",
        color_hint = { text = "Q" },
        category = "quality",
        tier = 4,
        order = "d[quality]-d[quality-module-4]",
        inventory_move_sound = item_sounds.module_inventory_move,
        pick_sound = item_sounds.module_inventory_pickup,
        drop_sound = item_sounds.module_inventory_move,
        stack_size = 50,
        weight = 25 * kg,
        effect = { quality = 0.03, speed = -0.05 },
        default_import_location = "frozeta",
    },
    {
        type = "module",
        name = "productivity-module-4-S",
        localised_description = { "item-description.productivity-module" },
        icon = "__secretas__/graphics/icons/productivity-module-4.png",
        subgroup = "module",
        color_hint = { text = "P" },
        category = "productivity",
        tier = 4,
        order = "c[productivity]-d[productivity-module-4]",
        inventory_move_sound = item_sounds.module_inventory_move,
        pick_sound = item_sounds.module_inventory_pickup,
        drop_sound = item_sounds.module_inventory_move,
        stack_size = 50,
        weight = 25 * kg,
        effect = { productivity = 0.15, speed = -0.2, pollution = 0.15, consumption = 1.0  },
        default_import_location = "frozeta",
    },
    {
        type = "module",
        name = "speed-module-4-S",
        localised_description = { "item-description.speed-module" },
        icon = "__secretas__/graphics/icons/speed-module-4.png",
        subgroup = "module",
        color_hint = { text = "S" },
        category = "speed",
        tier = 4,
        order = "a[speed]-d[speed-module-4]",
        inventory_move_sound = item_sounds.module_inventory_move,
        pick_sound = item_sounds.module_inventory_pickup,
        drop_sound = item_sounds.module_inventory_move,
        stack_size = 50,
        weight = 25 * kg,
        effect = { speed = 0.7, quality = -0.3, consumption = 0.95 },
        beacon_tint =
        {
          primary = {0.441, 0.714, 1.000, 1.000}, -- #70b6ffff
          secondary = {0.388, 0.976, 1.000, 1.000}, -- #63f8ffff
        },
        art_style = "vanilla",
        requires_beacon_alt_mode = false,
        default_import_location = "frozeta",
    },
    {
        type = "module",
        name = "efficiency-module-4-S",
        localised_description = { "item-description.efficiency-module" },
        icon = "__secretas__/graphics/icons/efficiency-module-4.png",
        subgroup = "module",
        color_hint = { text = "E" },
        category = "efficiency",
        tier = 4,
        order = "c[efficiency]-d[efficiency-module-4]",
        inventory_move_sound = item_sounds.module_inventory_move,
        pick_sound = item_sounds.module_inventory_pickup,
        drop_sound = item_sounds.module_inventory_move,
        stack_size = 50,
        weight = 25 * kg,
        effect = { consumption = -0.6 },
        beacon_tint =
        {
          primary = {0, 1, 0},
          secondary = {0.370, 1.000, 0.370, 1.000}, -- #5eff5eff
        },
        art_style = "vanilla",
        requires_beacon_alt_mode = false,
        default_import_location = "frozeta",
    },
    {
      type = "item",
      name = "gold-heat-pipe",
      icon = "__secretas__/graphics/icons/gold-heat-pipe.png",
      subgroup = "energy",
      order = "f[nuclear-energy]-c[heat-pipe]",
      inventory_move_sound = item_sounds.metal_small_inventory_move,
      pick_sound = item_sounds.metal_small_inventory_pickup,
      drop_sound = item_sounds.metal_small_inventory_move,
      place_result = "gold-heat-pipe",
      stack_size = 50,
      weight = 20*kg,
      default_import_location = "frozeta",
    },
    {
      type = "item",
      name = "gold-railgun-turret",
      icon = "__secretas__/graphics/icons/gold-railgun-turret.png",
      subgroup = "turret",
      order = "b[turret]-h[railgun-turret]-a[turret]",
      inventory_move_sound = item_sounds.turret_inventory_move,
      pick_sound = item_sounds.turret_inventory_pickup,
      drop_sound = item_sounds.turret_inventory_move,
      place_result = "gold-railgun-turret",
      stack_size = 10,
      default_import_location = "frozeta",
      weight = 1*tons,
    },

}
)