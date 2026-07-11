-- 2.0 port of MIRV 1.0.1 (Klonan). Prototype changes vs 1.1:
-- recipes in long form, collision_mask as {layers=...}, hidden as a property,
-- hr_version dropped (2.0 base renamed the hr sprites), graphics params taken
-- from 2.0 base prototypes where the 1.1 files no longer exist.
local util = require("tf_util/tf_util")

data:extend({
  {
    type = "item",
    name = "mirv-rocket",
    icon = "__MIRV2__/mirv_rocket.png",
    icon_size = 32,
    subgroup = "defensive-structure",
    order = "z[MIRV]",
    stack_size = 1,
    -- 2.0: the silo cargo slot only accepts sendable items, and without an
    -- explicit weight the recipe-derived one (20 atomic bombs) exceeds rocket
    -- capacity; 1*tons = exactly one M.I.R.V per rocket, as the base satellite
    weight = 1 * tons,
    -- "automated" like every other sendable in the pack (SpaceX/ERP/satellite):
    -- shows up in the silo "Allowed items" list and inserters can load it
    send_to_orbit_mode = "automated",
  },
  {
    type = "recipe",
    name = "mirv-rocket",
    energy_required = 10,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {type = "item", name = "atomic-bomb", amount = 20},
      {type = "item", name = "rocket-fuel", amount = 50},
      -- rocket-control-unit was removed in 2.0 base
      {type = "item", name = "processing-unit", amount = 10}
    },
    results = {{type = "item", name = "mirv-rocket", amount = 1}},
    order = "z[MIRV]"
  },
  {
    type = "arrow",
    name = "mirv-entity",
    icon = "__MIRV2__/mirv_item.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    selectable_in_game = false,
    order = "z[MIRV]",
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    circle_picture =
    {
      filename = "__MIRV2__/mirv_template.png",
      priority = "extra-high",
      width = 768,
      height = 548,
      scale = 3,
      shift = util.by_pixel(0, -32)
    },
    arrow_picture =
    {
      filename = "__core__/graphics/empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
    }
  },
  {
    type = "trivial-smoke",
    name = "mirv-smoke",
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    duration = 440,
    fade_in_duration = 0,
    fade_away_duration = 0,
    spread_duration = 380,
    start_scale = 3,
    end_scale = 1,
    cyclic = true,
    affected_by_wind = false,
    movement_slow_down_factor = 0,
    color = {r = 1, g = 1, b = 1},
    render_layer = "lower-object",
    animation =
    {
      width = 624,
      height = 440,
      line_length = 3,
      frame_count = 12,
      axially_symmetrical = false,
      direction_count = 1,
      priority = "high",
      animation_speed = 0.25,
      filename = "__MIRV2__/mirv_anim.png"
    }
  },
  {
    type = "trivial-smoke",
    name = "mirv-smoke-2",
    flags = {"not-on-map"},
    show_when_smoke_off = true,
    duration = 440,
    fade_in_duration = 0,
    fade_away_duration = 0,
    spread_duration = 380,
    start_scale = 3,
    end_scale = 1,
    cyclic = true,
    affected_by_wind = false,
    movement_slow_down_factor = 0,
    color = {r = 1, g = 1, b = 1},
    render_layer = "lower-object",
    animation =
    {
      width = 800,
      height = 565,
      line_length = 1,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      priority = "high",
      animation_speed = 0.25,
      filename = "__MIRV2__/mirv_static.png"
    }
  },
  {
    type = "simple-entity-with-owner",
    name = "mirv-target",
    render_layer = "object",
    icon = "__MIRV2__/mirv-target.png",
    icon_size = 32,
    order = "z[MIRV]",
    max_health = 1,
    selectable_in_game = false,
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{0, 0}, {0, 0}},
    picture =
    {
      filename = "__core__/graphics/empty.png",
      priority = "extra-high",
      width = 1,
      height = 1
    },
    build_sound =
    {
      filename = "__MIRV2__/launch-sound.ogg",
      volume = 1
    }
  },
  {
    type = "technology",
    name = "mirv-technology",
    icon = "__MIRV2__/mirv-technology.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "mirv-rocket"
      },
      {
        type = "unlock-recipe",
        recipe = "mirv-targeting-remote"
      },
    },
    prerequisites = {"rocket-silo", "atomic-bomb"},
    unit =
    {
      count = 10000,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 45
    },
    order = "e-a-c"
  }
})

local turret =
{
  type = "artillery-turret",
  name = "mirv-launcher",
  localised_name = {"item-name.mirv-rocket"},
  icon = "__MIRV2__/mirv_rocket.png",
  icon_size = 32,
  flags = {"placeable-neutral", "placeable-player", "player-creation"},

  collision_mask = {layers = {}},

  -- mandatory in 2.0; zero shift, the turret is invisible anyway
  cannon_base_shift = {0.0, 0.0, 0.0},

  inventory_size = 1,
  ammo_stack_limit = 5,
  automated_ammo_count = 1,
  gun = "mirv-launcher-gun",
  turret_rotation_speed = 1,
  manual_range_modifier = 1000000,
  disable_automatic_firing = not settings.startup["mirv-auto-launch"].value,

  base_picture = util.empty_sprite(),
  cannon_barrel_pictures = util.empty_sprite(),
  cannon_base_pictures = util.empty_sprite(),
  order = "lol",
  alert_when_attacking = false

}

local gun =
{
  type = "gun",
  name = "mirv-launcher-gun",
  localised_name = {"item-name.mirv-rocket"},
  icon = "__base__/graphics/icons/tank-cannon.png",
  icon_size = 64,
  hidden = true,
  subgroup = "gun",
  order = "z[artillery]-a[cannon]",
  attack_parameters =
  {
    type = "projectile",
    ammo_category = util.ammo_category("mirv-launcher"),
    cooldown = 15 * 60,
    movement_slow_down_factor = 0,
    range = 1000
  },
  stack_size = 1
}

local ammo =
{
  type = "ammo",
  name = "mirv-ammo",
  icon = "__base__/graphics/icons/atomic-bomb.png",
  icon_size = 64,
  -- 2.0: ammo category moved from ammo_type.category to the item level
  ammo_category = util.ammo_category("mirv-launcher"),
  ammo_type =
  {
    target_type = "position",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {

          {
            type = "script",
            effect_id = "mirv-launch"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 120,
              target_entities = false,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 0 , type = "physical"}
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  subgroup = "ammo",
  order = "d[rocket-launcher]-c[atomic-bomb]",
  stack_size = 10
}

local nuke_target_effects =
{
  {
    type = "nested-result",
    action =
    {
      type = "area",
      target_entities = false,
      trigger_from_target = true,
      repeat_count = 50,
      radius = 10,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          }
        }
      }
    }
  }
}

if settings.startup["mirv-pollution-on-detonation"].value then
  table.insert(nuke_target_effects,
  {
    type = "script",
    effect_id = "mirv-pollute"
  })
end

-- sprite params from 2.0 base explosion-animations.lua (bigass_explosion)
local do_whacka_do = function()
  local watra = 1 + ((math.random() - 0.5))
  return
  {
    filename = "__base__/graphics/entity/bigass-explosion/hr-bigass-explosion-36f.png",
    draw_as_glow = true,
    animation_speed = 0.5 * watra,
    width = 324,
    height = 416,
    frame_count = 36,
    shift = util.by_pixel(0, -48),
    scale = 1 / watra,
    stripes =
    {
      {
        filename = "__base__/graphics/entity/bigass-explosion/bigass-explosion-36f-1.png",
        width_in_frames = 6,
        height_in_frames = 3
      },
      {
        filename = "__base__/graphics/entity/bigass-explosion/bigass-explosion-36f-2.png",
        width_in_frames = 6,
        height_in_frames = 3
      }
    },
    usage = "explosion"
  }
end

local nuke_explosion =
{
  type = "explosion",
  name = "nuke-explosion",
  flags = {"not-on-map"},
  animations =
  {
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
    do_whacka_do(), do_whacka_do(), do_whacka_do(),
  },
  light = {intensity = 1, size = 50, color = {r=1.0, g=1.0, b=1.0}},
  sound =
  {
    aggregation =
    {
      max_count = 2,
      remove = true
    },
    variations =
    {
      {
        filename = "__base__/sound/fight/large-explosion-1.ogg",
        volume = 1.0
      },
      {
        filename = "__base__/sound/fight/large-explosion-2.ogg",
        volume = 1.0
      }
    }
  }
}

local fire_util = require("tf_util/tf_fire_util")
local fiery_particle =
{
  type = "optimized-particle",
  name = "fiery-particle",
  life_time = 100,
  movement_modifier = 0,
  pictures = fire_util.create_fire_pictures{scale = 2}
}


data:extend{fiery_particle}

-- sheet params from 2.0 base remnants.lua (small-scorchmark); the 1.1 base
-- random scale maps onto the ex-hr sheets as scale/2
local make_scorchmark = function(name)
  local scale = math.random(50, 250) / 100
  data:extend
  {
    {
      type = "corpse",
      name = name,
      icon = "__base__/graphics/icons/small-scorchmark.png",
      flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
      hidden_in_factoriopedia = true,
      collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
      collision_mask = {layers = {doodad = true}, not_colliding_with_itself = true},
      selection_box = {{-1, -1}, {1, 1}},
      selectable_in_game = false,
      time_before_removed = 60 * 60 * (scale + 2),
      final_render_layer = "ground-patch-higher2",
      subgroup = "remnants",
      order="d[remnants]-b[scorchmark]-a[small]",
      remove_on_entity_placement = false,
      remove_on_tile_placement = true,
      ground_patch =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/scorchmark/small-scorchmark.png",
          width = 256,
          height = 182,
          line_length = 4,
          shift = util.by_pixel(0, 2),
          variation_count = 4,
          scale = scale / 2
        }
      },
      ground_patch_higher =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/scorchmark/small-scorchmark-top.png",
          width = 68,
          height = 54,
          line_length = 4,
          shift = util.by_pixel(0, -2),
          variation_count = 4,
          scale = 0.5 * scale
        }
      }
    }
  }
  return name
end

local pictures = fire_util.create_fire_pictures({scale = 3, shift = {0, 3}})

local make_fire = function(name)
  local fire = util.copy(data.raw.fire["fire-flame"])
  fire.name = name
  fire.initial_lifetime = math.random(5, 20) * 60
  fire.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
  fire.collision_mask = {layers = {doodad = true}, not_colliding_with_itself = true}
  data:extend{fire}
  return name
end

local total = #pictures
local proj_count = math.ceil(2000 / total)
for k, picture in pairs (pictures) do

  local effect =
  {
    type = "nested-result",
    action =
    {
      {

        type = "area",
        target_entities = false,
        trigger_from_target = true,
        repeat_count = proj_count,
        radius = 100,
        action_delivery =
        {
          type = "artillery",
          projectile = "mirv-nuke-projectile"..k,
          starting_speed = 0.75,
          starting_speed_deviation = 0.2,
          direction_deviation = 0,
          range_deviation = 0.5
        }
      }
    }
  }

  table.insert(nuke_target_effects, effect)

  local nested_projectile =
  {
    type = "artillery-projectile",
    name = "mirv-nuke-projectile"..k,
    flags = {"not-on-map"},
    map_color = {1, 1, 1},
    reveal_map = true,
    picture = picture,
    chart_picture =
    {
      filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
      flags = { "icon" },
      frame_count = 1,
      width = 64,
      height = 64,
      priority = "high",
      scale = math.random(20, 30) / 100
    },
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 5.0,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "create-fire",
                    entity_name = make_fire("nuke-fire"..k),
                    initial_ground_flame_count = math.random(10, 20),
                    check_buildability = true,
                    probability = 0.1
                  },
                  {
                    type = "damage",
                    damage = {amount = 2000 , type = "physical"}
                  },
                }
              }
            }
          },
          {

            type = "create-particle",
            repeat_count = 3,
            particle_name = "fiery-particle",
            initial_height = 0.1,
            offset_deviation = {{-3, -3}, {3,3}}

          },
          {
            type = "show-explosion-on-chart",
            scale = math.random(6, 12)/32
          },
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          },
          {
            type = "create-entity",
            entity_name = make_scorchmark("nuke-scorchmark"..k.."1"),
            check_buildability = true,
            offset_deviation = {{-4, -4},{4, 4}}
          },
          {
            type = "create-entity",
            entity_name = make_scorchmark("nuke-scorchmark"..k.."2"),
            check_buildability = true,
            offset_deviation = {{-4, -4},{4, 4}}
          }
        }
      }
    }
  }
  data:extend{nested_projectile}
end

local projectile =
{
  type = "artillery-projectile",
  name = "mirv-projectile",
  flags = {"not-on-map"},
  reveal_map = false,
  map_color = {r = 0, g = 1, b = 0},
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects = nuke_target_effects
    }
  },
  chart_picture =
  {
    layers =
    {

      {
        filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
        flags = { "icon" },
        frame_count = 1,
        width = 64,
        height = 64,
        priority = "high",
        scale = 1,
        shift = {0.05, -0.5}
      },
      {
        filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
        flags = { "icon" },
        frame_count = 1,
        width = 64,
        height = 64,
        priority = "high",
        scale = 0.5,
        shift = {0.05, -0.8}
      },
      {
        filename = "__MIRV2__/mirv_projectile.png",
        width = 64,
        height = 64,
        scale = 0.5,
        frame_count = 1
      }
    }
  },
  light = {intensity = 0.8, size = 15},
  -- 02-rocket.png is gone in 2.0; rocket-static-pod is the 2.0 silo rocket sprite
  picture = util.sprite_load("__base__/graphics/entity/rocket-silo/rocket-static-pod",
  {
    priority = "high",
    scale = 0.25,
    dice_y = 4
  })
}

local remote =
{
  type = "capsule",
  name = "mirv-targeting-remote",
  icon = "__MIRV2__/mirv-targeting-remote.png",
  icon_size = 64,
  capsule_action =
  {
    type = "artillery-remote",
    flare = "mirv-flare"
  },
  subgroup = "capsule",
  order = "zz",
  stack_size = 1
}

local flare =
{
  type = "artillery-flare",
  name = "mirv-flare",
  icon = "__base__/graphics/icons/artillery-targeting-remote.png",
  icon_size = 64,
  flags = {"placeable-off-grid", "not-on-map"},
  map_color = {r=1, g=0.5, b=0},
  life_time = 60 * 60,
  initial_height = 0,
  initial_vertical_speed = 0,
  initial_frame_speed = 1,
  shots_per_flare = 1,
  early_death_ticks = 3 * 60,
  shot_category = util.ammo_category("mirv-launcher"),
  pictures =
  {
    {
      filename = "__core__/graphics/shoot-cursor-red.png",
      priority = "low",
      width = 258,
      height = 183,
      frame_count = 1,
      scale = 1,
      flags = {"icon"}
    }
  }
}

local remote_recipe =
{
  type = "recipe",
  name = "mirv-targeting-remote",
  enabled = false,
  ingredients =
  {
    {type = "item", name = "processing-unit", amount = 1},
    {type = "item", name = "radar", amount = 1}
  },
  results = {{type = "item", name = "mirv-targeting-remote", amount = 1}}
}

data:extend
{
  turret,
  gun,
  ammo,
  projectile,
  remote,
  flare,
  remote_recipe,
  nuke_explosion

}

local artillery_flare = data.raw["artillery-flare"]["artillery-flare"]
if artillery_flare then
  artillery_flare.shot_category = artillery_flare.shot_category or "artillery-shell"
end
