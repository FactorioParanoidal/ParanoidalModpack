local util = require("data/tf_util/tf_util")
local shared = require("shared")
local name = shared.entities.repair_turret
local repair_range = require("shared").repair_range

local attach_beam_graphics = require("data/entities/repair_turret/beam_sprites")

local turret = util.copy(data.raw.roboport.roboport)

local shift = function(current_shift)
  return {current_shift[1], current_shift[2] - 1}
end

local path = util.path("data/entities/repair_turret/")

local picture = {
  layers = {
    {
      filename = path .. "repair_turret.png",
      width = 140,
      height = 260,
      frame_count = 1,
      direction_count = 1,
      shift = shift{0, 0},
      scale = 0.5
    },
    {
      filename = path .. "repair_turretglotint.png",
      width = 120,
      height = 120,
      frame_count = 1,
      direction_count = 1,
      shift = shift(util.by_pixel(0, 10)),
      scale = 0.5,
      draw_as_glow = true,
      tint = {g = 0.5, r = 0.9, b = 0, a = 0.5}
    },
    {
      filename = path .. "repair_turretglo.png",
      width = 120,
      height = 120,
      frame_count = 1,
      direction_count = 1,
      shift = shift(util.by_pixel(0, 10)),
      scale = 0.5,
      draw_as_glow = true
    },
    {
      filename = path .. "repair_turretsh.png",
      width = 530,
      height = 92,
      frame_count = 1,
      direction_count = 1,
      shift = shift(util.by_pixel(98, 48)),
      scale = 0.5,
      draw_as_shadow = true
    },
    {
      filename = path .. "repair_turretmsk.png",
      flags = {"mask"},
      line_length = 1,
      width = 120,
      height = 120,
      axially_symmetrical = false,
      direction_count = 1,
      frame_count = 1,
      shift = shift(util.by_pixel(0, 15)),
      tint = {g = 1, r = 0, b = 0, a = 0.5},
      scale = 0.5
      --apply_runtime_tint = true
    },
  }
}

local animation =
{
  layers =
  {
    {
      filename = path .. "turret.png",
      priority = "medium",
      width = 124,
      height = 164,
      line_length = 8,
      frame_count = 8,
      animation_speed = 0.4,
      shift = shift(util.by_pixel(0, -63)),
      scale = 0.5,
    },
    {
      filename = path .. "turretglo.png",
      priority = "medium",
      width = 124,
      height = 164,
      line_length = 8,
      frame_count = 8,
      animation_speed = 0.4,
      shift = shift(util.by_pixel(0, -63)),
      scale = 0.5,
      draw_as_glow = true,
    },
    {
      filename = path .. "turretsh.png",
      width = 202,
      height = 92,
      animation_speed = 0.4,
      line_length = 8,
      frame_count = 8,
      shift = shift(util.by_pixel(164, 48)),
      draw_as_shadow = true,
      scale = 0.5,
      --apply_runtime_tint = true
    }
  }
}

turret.name = name
turret.localised_name = {name}
turret.localised_description = {name .. "-description", tostring(repair_range)}
turret.icon = path .. "repairturret64.png"
turret.icon_size = 64
turret.icon_mipmaps = 0
turret.logistics_radius = 2
turret.logistics_connection_distance = repair_range
turret.construction_radius = repair_range * 2
turret.radar_range = 2
turret.robot_slots_count = 0
turret.material_slots_count = 1
turret.charging_energy = "10MW"
turret.energy_usage = "2kW"
turret.energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  input_flow_limit = "1MW",
  buffer_capacity = "10MJ"
}
turret.recharge_minimum = "20kJ"
turret.collision_box = util.area({0,0}, 0.7)
turret.selection_box = util.area({0,0}, 1)
--turret.hit_visualization_box = util.area({0, -2.5}, 0.1)
--turret.drawing_box = {{-1, -2.5},{1, 1}}
turret.working_sound = nil
turret.base = picture
turret.base_animation = animation
turret.base_patch = util.empty_sprite()
turret.charging_offsets = {{0, -2.5}}
turret.charge_approach_distance = 2
--turret.recharging_animation = util.empty_sprite()
turret.door_animation_down = util.empty_sprite()
turret.door_animation_up = util.empty_sprite()
turret.circuit_wire_max_distance = 0
turret.corpse = "repair-turret-remnants"
turret.minable = {result = name, mining_time = 0.5}

local item = util.copy(data.raw.item.roboport)
item.name = name
item.localised_name = {name}
item.icon = turret.icon
item.icon_size = turret.icon_size
item.icon_mipmaps = 0
item.place_result = name
item.subgroup = "defensive-structure"
item.order = "b[turret]-az[repair-turret]"
item.stack_size = 20

local laser_beam = util.copy(data.raw.beam["laser-beam"])

local repair_beam = util.copy(data.raw.beam["electric-beam"])
attach_beam_graphics(repair_beam)
repair_beam.graphics_set.ground = laser_beam.graphics_set.ground
for k, v in pairs (repair_beam.graphics_set.ground) do
  v.repeat_count = 16
end
util.recursive_hack_tint(repair_beam, {g = 1, r = 0.1, b = 0.1})
repair_beam.damage_interval = 10000
repair_beam.name = "repair-beam"
repair_beam.localised_name = "repair-beam"
repair_beam.action_triggered_automatically = false
repair_beam.action = nil

local deconstruct_beam = util.copy(data.raw.beam["electric-beam"])
attach_beam_graphics(deconstruct_beam)
deconstruct_beam.graphics_set.ground = laser_beam.graphics_set.ground
for k, v in pairs (deconstruct_beam.graphics_set.ground) do
  v.repeat_count = 16
end
util.recursive_hack_tint(deconstruct_beam, {g = 0.1, r = 1, b = 0.1})
deconstruct_beam.damage_interval = 10000
deconstruct_beam.name = "deconstruct-beam"
deconstruct_beam.localised_name = "deconstruct-beam"
deconstruct_beam.action_triggered_automatically = false
deconstruct_beam.action = nil

local construct_beam = util.copy(data.raw.beam["electric-beam"])
attach_beam_graphics(construct_beam)
construct_beam.graphics_set.ground = laser_beam.graphics_set.ground
for k, v in pairs (construct_beam.graphics_set.ground) do
  v.repeat_count = 16
end
util.recursive_hack_tint(construct_beam, {g = 0.8, r = 0.8, b = 0.1})
construct_beam.damage_interval = 10000
construct_beam.name = "construct-beam"
construct_beam.localised_name = "construct-beam"
construct_beam.action_triggered_automatically = false
construct_beam.action = nil



local technology =
{
  name = name,
  localised_name = {name},
  type = "technology",
  icon = path .. "repairturret256.png",
  icon_size = 256,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = name
    }
  },

  prerequisites = {"gun-turret"},
  unit =
  {
    count = 100,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  },
  order = name
}

local can_construct_technology =
{
  name = "repair-turret-construction",
  localised_name = {"repair-turret-construction"},
  type = "technology",
  icon = path .. "repairturret256.png",
  icon_size = 256,
  effects =
  {
    {
      type = "nothing",
      effect_description = {"repair-turret-construction-description"}
    },
    {
      type = "nothing",
      effect_description = {"repair-turret-deconstruction-description"}
    }
  },

  prerequisites = {name, "construction-robotics"},
  unit =
  {
    count = 500,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1}
    },
    time = 30
  },
  order = name
}

local recipe =
{
  type = "recipe",
  name = name,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "iron-gear-wheel", amount = 15},
    {type = "item", name = "electronic-circuit", amount = 10},
    {type = "item", name = "steel-plate", amount = 5}
  },
  energy_required = 10,
  results = {{type = "item", name = name, amount = 1}}
}

local projectile = util.copy(data.raw.projectile["rocket"])
projectile.name = "repair-bullet"
projectile.localised_name = "Repair bullet"
projectile.smoke = nil
projectile.acceleration = 0.00
projectile.turning_speed_increases_exponentially_with_projectile_speed = false
projectile.height = 0
projectile.shadow = nil
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = { amount = -30, type = util.damage_type("repair")}
      }
    }
  }
}

projectile.animation = {}

for scale = 1.4, 1.6, 0.05 do
  for speed = 0.2, 0.4, 0.05 do
    table.insert(projectile.animation,
    {
      filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = scale,
      animation_speed = speed,
      repeat_count = 5,
      shift = {0, 0}
    }
  )
  end
end

projectile.light =
{
  intensity = 0.5, size = 5, color = {r=0.1, g=1.0, b=0.1}, add_perspective = true
}

local animations =
{
  {
    filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
    priority = "high",
    width = 37,
    height = 35,
    frame_count = 16,
    scale = 1.6,
    animation_speed = 0.3,
    repeat_count = 5,
    shift = {0, 0.5}
  },
  {
    filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
    priority = "high",
    width = 37,
    height = 35,
    frame_count = 16,
    scale = 1.5,
    animation_speed = 0.35,
    repeat_count = 5,
    shift = {0, 0.5}
  },
  {
    filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
    priority = "high",
    width = 37,
    height = 35,
    frame_count = 16,
    scale = 1.4,
    animation_speed = 0.25,
    repeat_count = 5,
    shift = {0, 0.5}
  }
}
util.recursive_hack_tint(animations,{r = 0, g = 1, b = 0})

local explosion =
{
  type = "explosion",
  name = "transmission-explosion",
  flags = {"not-on-map"},
  animations = animations,
  --height = 2.5,
  light =
  {
    {
      intensity = 0.5, size = 5, color = {r=0.1, g=1.0, b=0.1}, add_perspective = true
    }

  },
  sound = nil,
  created_effect = nil,
  old_created_effect =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-particle",
          repeat_count = 1,
          entity_name = "copper-ore-particle",
          initial_height = 2.5,
          speed_from_center = 0.08,
          speed_from_center_deviation = 0.15,
          initial_vertical_speed = 0.08,
          initial_vertical_speed_deviation = 0.15,
          offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
        }
      }
    }
  }
}

data:extend
{
  turret,
  item,
  repair_beam,
  deconstruct_beam,
  construct_beam,
  technology,
  can_construct_technology,
  recipe,
  projectile,
  explosion
}

local n1 = 0
local n = function()
  n1 = n1 + 1
  return n1
end

local power_technologies =
{
  {
    name = "repair-turret-power-"..n(),
    localised_name = {"repair-turret-power"},
    type = "technology",
    icon = path .. "repairturret256.png",
    icon_size = 256,
    upgrade = true,
    effects =
    {
      {
        type = "nothing",
        effect_description = {"repair-turret-power-description"}
      }
    },

    prerequisites = {name},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = name
  },
  {
    name = "repair-turret-power-"..n(),
    localised_name = {"repair-turret-power"},
    type = "technology",
    icon = path .. "repairturret256.png",
    icon_size = 256,
    upgrade = true,
    effects =
    {
      {
        type = "nothing",
        effect_description = {"repair-turret-power-description"}
      }
    },
    prerequisites = {"repair-turret-power-"..n1-1},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = name
  },
  {
    name = "repair-turret-power-"..n(),
    localised_name = {"repair-turret-power"},
    type = "technology",
    icon = path .. "repairturret256.png",
    icon_size = 256,
    upgrade = true,
    effects =
    {
      {
        type = "nothing",
        effect_description = {"repair-turret-power-description"}
      }
    },
    prerequisites = {"repair-turret-power-"..n1-1},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 30
    },
    order = name
  },
}
data:extend(power_technologies)

n1 = 0

local efficiency_technologies =
{
  {
    name = "repair-turret-efficiency-"..n(),
    localised_name = {"repair-turret-efficiency"},
    type = "technology",
    icon = path .. "repairturret256.png",
    icon_size = 256,
    upgrade = true,
    effects =
    {
      {
        type = "nothing",
        effect_description = {"repair-turret-efficiency-description"}
      }
    },
    prerequisites = {name},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = name
  },
  {
    name = "repair-turret-efficiency-"..n(),
    localised_name = {"repair-turret-efficiency"},
    type = "technology",
    icon = path .. "repairturret256.png",
    icon_size = 256,
    upgrade = true,
    effects =
    {
      {
        type = "nothing",
        effect_description = {"repair-turret-efficiency-description"}
      }
    },
    prerequisites = {"repair-turret-efficiency-"..n1-1},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = name
  },
  {
    name = "repair-turret-efficiency-"..n(),
    localised_name = {"repair-turret-efficiency"},
    type = "technology",
    icon = path .. "repairturret256.png",
    icon_size = 256,
    upgrade = true,
    effects =
    {
      {
        type = "nothing",
        effect_description = {"repair-turret-efficiency-description"}
      }
    },
    prerequisites = {"repair-turret-efficiency-"..n1-1},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 30
    },
    order = name
  },
}
data:extend(efficiency_technologies)

local projectile = util.copy(data.raw.projectile["rocket"])
projectile.name = "deconstruct-bullet"
projectile.localised_name = "Deconstruct bullet"
projectile.smoke = nil
projectile.acceleration = 0.02
projectile.max_speed = 0.25
projectile.height = 0
projectile.shadow = nil
projectile.action = nil

projectile.animation = {}

for scale = 1.4, 1.6, 0.05 do
  for speed = 0.2, 0.4, 0.05 do
    table.insert(projectile.animation,
    {
      filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
      priority = "high",
      width = 37,
      height = 35,
      frame_count = 16,
      scale = scale,
      animation_speed = speed,
      shift = {0, 0},
      tint = {r = 1, g = 0.2, b = 0.2},
      blend_mode = "additive"
    }
  )
  end
end

projectile.light =
{
  intensity = 0.5, size = 5, color = {r=1, g=0.2, b=0.2}, add_perspective = true
}

data:extend
{
  projectile
}

local remnants ={
  {
      type = "corpse",
      name = "repair-turret-remnants",
      icon = path.."repairturret128.png",
      icon_size = 128,
      flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
      subgroup = "transport-remnants",
      order = "a-k-a",
      selection_box = {{-1, -1}, {1, 1}},
      selectable_in_game = false,
      time_before_removed = 60 * 60 * 15,
      final_render_layer = "remnants",
      remove_on_tile_placement = false,
      animation =
      {
        layers =
        {
          {
            filename = path .. "hr-repairturretrem.png",
            line_length = 1,
            width = 192,
            height = 192,
            frame_count = 1,
            direction_count = 4,
            shift = util.by_pixel(0,0),
            scale = 0.5,
          },
          {
            filename = path .. "hr-repairturretremmsk.png",
            line_length = 1,
            width = 128,
            height = 128,
            frame_count = 1,
            direction_count = 4,
            tint = {g = 1, r = 0, b = 0, a = 0.5},
            shift = util.by_pixel(0,0),
            scale = 0.5,
          }
        }
      }
  },
}

data:extend(remnants)
