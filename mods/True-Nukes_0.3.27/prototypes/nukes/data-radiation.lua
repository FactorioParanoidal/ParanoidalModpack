local fireutil = require("__base__.prototypes.fire-util")
data:extend({
  fireutil.add_basic_fire_graphics_and_effects_definitions
  {
    type = "fire",
    name = "nuclear-fire",
    flags = {"placeable-off-grid", "not-on-map"},
    damage_per_tick = {amount = 130 / 60, type = "fire"},
    maximum_damage_multiplier = 6,
    damage_multiplier_increase_per_added_fuel = 1,
    damage_multiplier_decrease_per_tick = 0.0005,

    spawn_entity = "fire-flame-on-tree",

    spread_delay = 300,
    spread_delay_deviation = 180,
    maximum_spread_count = 100,

    emissions_per_second = 0.005,

    initial_lifetime = 600,
    lifetime_increase_by = 150,
    lifetime_increase_cooldown = 4,
    maximum_lifetime = 3600,
    delay_between_initial_flames = 10,
  --initial_flame_count = 1,

  }})

local radiation_cloud_vis_dum = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud-visual-dummy"])
radiation_cloud_vis_dum.name="radiation-cloud-visual-dummy"
radiation_cloud_vis_dum.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
radiation_cloud_vis_dum.duration=60*60

local radiation_cloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
radiation_cloud.name="dangerous-radiation-cloud"
radiation_cloud.action.action_delivery.target_effects.action.action_delivery.target_effects.damage.amount=20
radiation_cloud.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
radiation_cloud.created_effect[1].action_delivery.target_effects[1].entity_name = "radiation-cloud-visual-dummy"
radiation_cloud.created_effect[2].action_delivery.target_effects[1].entity_name = "radiation-cloud-visual-dummy"
radiation_cloud.duration=60*60

local fallout =
  {
    type = "projectile",
    name = "fallout",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects ={
          {
            type = "create-entity",
            entity_name = "dangerous-radiation-cloud"
          },
          {
            type = "create-entity",
            entity_name = "radiation-cloud"
          }
        }
      }
    },
    animation =
    {
      filename = "__core__/graphics/empty.png",
      frame_count = 1,
      width = 1,
      height = 1,
      priority = "high"
    }
  }



local lingering_radiation_cloud_vis_dum = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud-visual-dummy"])
lingering_radiation_cloud_vis_dum.name="lingering-radiation-cloud-visual-dummy"
lingering_radiation_cloud_vis_dum.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
lingering_radiation_cloud_vis_dum.duration=60*300
lingering_radiation_cloud_vis_dum.fade_away_duration = 60 * 60


local lingering_radiation_cloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
lingering_radiation_cloud.name="lingering-radiation-cloud"
lingering_radiation_cloud.color = {r = 0.220, g = 0.220, b = 0.220, a = 0.800}
lingering_radiation_cloud.duration=60*300
lingering_radiation_cloud.fade_away_duration = 40 * 60
lingering_radiation_cloud.created_effect[1].action_delivery.target_effects[1].entity_name = "lingering-radiation-cloud-visual-dummy"
lingering_radiation_cloud.created_effect[2].action_delivery.target_effects[1].entity_name = "lingering-radiation-cloud-visual-dummy"

local lingering_fallout =
  {
    type = "projectile",
    name = "lingering-fallout",
    flags = {"not-on-map"},
    acceleration = 0.005,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "create-entity",
          entity_name = "lingering-radiation-cloud"
        }
      }
    },
    animation =
    {
      filename = "__core__/graphics/empty.png",
      frame_count = 1,
      width = 1,
      height = 1,
      priority = "high"
    }
  }

data:extend{radiation_cloud_vis_dum, radiation_cloud, fallout, lingering_radiation_cloud_vis_dum, lingering_radiation_cloud, lingering_fallout}
