-------------------------------------------------------------------------------------------------
--скрываем био-пушку и снаряды для нее

data.raw["technology"]["bi-tech-bio-cannon"].hidden = "true"

data.raw["item"]["bi-bio-cannon-area"].flags = {"hidden"}

data.raw["ammo"]["bi-bio-cannon-proto-ammo"].flags = {"hidden"}
data.raw["ammo"]["bi-bio-cannon-basic-ammo"].flags = {"hidden"}
data.raw["ammo"]["bi-bio-cannon-poison-ammo"].flags = {"hidden"}

data.raw["recipe"]["bi-bio-cannon"].hidden = "true"
data.raw["recipe"]["bi-bio-cannon-proto-ammo"].hidden = "true"
data.raw["recipe"]["bi-bio-cannon-basic-ammo"].hidden = "true"
data.raw["recipe"]["bi-bio-cannon-poison-ammo"].hidden = "true"

-------------------------------------------------------------------------------------------------
--привязываем базовую артиллерию к новому прототипу
data.raw["technology"]["artillery"].prerequisites = {"artillery-prototype", "tank"}

-------------------------------------------------------------------------------------------------
--копируем базовую артиллерию и меняем ей параметры
local artillery_turret_prototype = table.deepcopy(data.raw["artillery-turret"]["artillery-turret"])

artillery_turret_prototype.name = "artillery-turret-prototype"
artillery_turret_prototype.minable = {mining_time = 0.1, result = "artillery-turret-prototype"}
artillery_turret_prototype.icon = "__zzzparanoidal__/prototypes/artillery-prototype/artillery-turret.png"
artillery_turret_prototype.gun = "artillery-gun-prototype"
artillery_turret_prototype.ammo_stack_limit = "5"
artillery_turret_prototype.max_health = 1000
artillery_turret_prototype.turret_rotation_speed = "0.0003"
artillery_turret_prototype.turn_after_shooting_cooldown = "100"
artillery_turret_prototype.manual_range_modifier = "1"
artillery_turret_prototype.cannon_parking_speed = "0.125"
artillery_turret_prototype.base_picture.layers = 
{
    {
      filename = "__zzzparanoidal__/prototypes/artillery-prototype/artillery-turret-base.png",
      priority = "high",
      width = 104,
      height = 100,
      direction_count = 1,
      frame_count = 1,
      shift = util.by_pixel(-0, 22),
      hr_version =
      {
        filename = "__zzzparanoidal__/prototypes/artillery-prototype/hr-artillery-turret-base.png",
        priority = "high",
        line_length = 1,
        width = 207,
        height = 199,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(-0, 22),
        scale = 0.5
      }
    },
    {
      filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
      priority = "high",
      line_length = 1,
      width = 138,
      height = 75,
      frame_count = 1,
      direction_count = 1,
      shift = util.by_pixel(18, 38),
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/artillery-turret/hr-artillery-turret-base-shadow.png",
        priority = "high",
        line_length = 1,
        width = 277,
        height = 149,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(18, 38),
        draw_as_shadow = true,
        scale = 0.5
      }
    }
  }

data:extend{artillery_turret_prototype}

--------------------------------------------------------------------------------------------------

data:extend({
    {
        type = "gun",
        name = "artillery-gun-prototype",
        icon = "__base__/graphics/icons/tank-cannon.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"hidden"},
        subgroup = "gun",
        order = "z[artillery]-a[cannon]",
        attack_parameters =
        {
          type = "projectile",
          ammo_category = "artillery-shell-prototype",
          cooldown = 600,
          movement_slow_down_factor = 10,
          projectile_creation_distance = 1.6,
          projectile_center = {-0.15625, -0.07812},
          range = 70,
          --turn_range = 0.4,
          min_range = 35,
          projectile_creation_parameters = require("__base__.prototypes.entity.artillery-cannon-muzzle-flash-shifting"),
          sound =
          {
            {
              filename = "__zzzparanoidal__/prototypes/artillery-prototype/artillery-shoots.ogg",
              volume = 0.7
            }
          },
          shell_particle =
          {
            name = "artillery-shell-particle",
            direction_deviation = 0.05,
            direction = 0.4,
            speed = 0.10,
            speed_deviation = 0.1,
            vertical_speed = 0.05,
            vertical_speed_deviation = 0.01,
            center = {0, -0.5},
            creation_distance = 0.5,
            creation_distance_orientation = 0.4,
            starting_frame_speed = 0.5,
            starting_frame_speed_deviation = 0.5,
            use_source_position = true,
            height = 1
          }
        },
        stack_size = 1
      }, 
--------------------------------------------------------------------------------------------------
{
        type = "ammo-category",
        name = "artillery-shell-prototype"
}, 
--------------------------------------------------------------------------------------------------
{
        type = "ammo",
        name = "artillery-shell-prototype",
        icon = "__zzzparanoidal__/prototypes/artillery-prototype/artillery-shell.png",
        icon_size = 64, icon_mipmaps = 4,
        ammo_type =
        {
          category = "artillery-shell-prototype",
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "artillery",
              projectile = "artillery-projectile-prototype",
              starting_speed = 1,
              direction_deviation = 0,
              range_deviation = 0,
              source_effects =
              {
                type = "create-explosion",
                entity_name = "artillery-cannon-muzzle-flash"
              }
            }
          }
        },
        subgroup = "ammo",
        order = "d[explosive-cannon-shell]-d[artillery]",
        stack_size = 1
},
--------------------------------------------------------------------------------------------------
{
    type = "recipe",
    name = "artillery-shell-prototype",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
      {"steel-plate", 5},
      {"bronze-alloy", 2},
      {"explosives", 3}
    },
    result = "artillery-shell-prototype"
},
--------------------------------------------------------------------------------------------------
{
    type = "artillery-projectile",
    name = "artillery-projectile-prototype",
    flags = {"not-on-map"},
    reveal_map = true,
    map_color = {r=1, g=1, b=0},
    picture =
    {
      filename = "__zzzparanoidal__/prototypes/artillery-prototype/hr-shell.png",
      draw_as_glow = true,
      width = 64,
      height = 64,
      scale = 0.5
    },
    shadow =
    {
      filename = "__base__/graphics/entity/artillery-projectile/hr-shell-shadow.png",
      width = 64,
      height = 64,
      scale = 0.5
    },
    chart_picture =
    {
      filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
      flags = { "icon" },
      frame_count = 1,
      width = 64,
      height = 64,
      priority = "high",
      scale = 0.25
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
              radius = 2.0,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 200 , type = "physical"}
                  },
                  {
                    type = "damage",
                    damage = {amount = 200 , type = "explosion"}
                  }
                }
              }
            }
          },
          {
            type = "create-trivial-smoke",
            smoke_name = "artillery-smoke",
            initial_height = 0,
            speed_from_center = 0.05,
            speed_from_center_deviation = 0.005,
            offset_deviation = {{-4, -4}, {4, 4}},
            max_radius = 3.5,
            repeat_count = 4 * 4 * 15
          },
          {
            type = "create-entity",
            entity_name = "big-artillery-explosion"
          },
          {
            type = "show-explosion-on-chart",
            scale = 8/32
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "medium-scorchmark-tintable",
            check_buildability = true
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
          type = "destroy-decoratives",
          from_render_layer = "decorative",
          to_render_layer = "object",
          include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
          include_decals = false,
          invoke_decorative_trigger = true,
          decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
          radius = 3.5 -- large radius for demostrative purposes
          }
        }
      }
    },
    height_from_ground = 280 / 64
  },
--------------------------------------------------------------------------------------------------
{
        type = "item",
        name = "artillery-turret-prototype",
        icon = "__zzzparanoidal__/prototypes/artillery-prototype/artillery-turret.png",
        icon_size = 64, icon_mipmaps = 4, 
        subgroup = "defensive-structure",
        order = "b[turret]-d[artillery-turret]-a[turret]",
        place_result = "artillery-turret-prototype",
        stack_size = 1
      },
--------------------------------------------------------------------------------------------------
      {
        type = "recipe",
        name = "artillery-turret-prototype",
        icon = "__zzzparanoidal__/prototypes/artillery-prototype/artillery-turret.png",
        icon_size = 64, icon_mipmaps = 4, 
        enabled = false,
        energy_required = 20,
        ingredients =
        {
          {"block-construction-2", 10},
          {"block-mechanical-1", 5},
          {"block-electronics-2", 2},
          {"block-warfare-2", 2},
          {"concrete-brick", 100},
        },
        result = "artillery-turret-prototype"
      },
--------------------------------------------------------------------------------------------------
      {
        type = "technology",
        name = "artillery-prototype",
        icon_size = 256, icon_mipmaps = 4,
        icon = "__zzzparanoidal__/prototypes/artillery-prototype/artillery.png",
        effects = {
          {
            type = "unlock-recipe",
            recipe = "artillery-turret-prototype"
          },
          {
            type = "unlock-recipe",
            recipe = "artillery-shell-prototype"
          },  
        },
        prerequisites = {"military-2", "explosives"},
        unit = {
          count = 300,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1},
          },
          time = 30,
        }
      }, 
    })