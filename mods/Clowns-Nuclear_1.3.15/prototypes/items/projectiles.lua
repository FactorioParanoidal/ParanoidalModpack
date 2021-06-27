local explosion_animations = require("__base__.prototypes.entity.explosion-animations")
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")
local sounds = require("__base__.prototypes.entity.sounds")

local max_nuke_shockwave_movement_distance_deviation = 10

local max_nuke_shockwave_movement_distance = 25 + max_nuke_shockwave_movement_distance_deviation / 6

local nuke_shockwave_starting_speed_deviation = 0.075

--THERMONUCLEAR EXPLOSION

local thermonuclear_action = {
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "set-tile",
        tile_name = "nuclear-ground",
        radius = 12,
        apply_projection = true,
        tile_collision_mask = { "water-tile" },
      },
      {
        type = "destroy-cliffs",
        radius = 18,
        explosion = "explosion"
      },
      {
        type = "create-entity",
        entity_name = "nuke-explosion"
      },
      {
        type = "camera-effect",
        effect = "screen-burn",
        duration = 60,
        ease_in_duration = 5,
        ease_out_duration = 60,
        delay = 0,
        strength = 6,
        full_strength_max_distance = 200,
        max_distance = 800
      },
      {
        type = "play-sound",
        sound = sounds.nuclear_explosion(0.9),
        play_on_target_position = false,
        -- min_distance = 200,
        max_distance = 1000,
        -- volume_modifier = 1,
        audible_distance_modifier = 3
      },
      {
        type = "play-sound",
        sound = sounds.nuclear_explosion_aftershock(0.4),
        play_on_target_position = false,
        -- min_distance = 200,
        max_distance = 1000,
        -- volume_modifier = 1,
        audible_distance_modifier = 3
      },
      {
        type = "damage",
        damage = {amount = 4000, type = "explosion"}
      },
      {
        type = "create-entity",
        entity_name = "huge-scorchmark",
        check_buildability = true,
      },
      {
        type = "invoke-tile-trigger",
        repeat_count = 1,
      },
      {
        type = "destroy-decoratives",
        include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
        include_decals = true,
        invoke_decorative_trigger = true,
        decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
        radius = 14 -- large radius for demostrative purposes
      },
      {
        type = "create-decorative",
        decorative = "nuclear-ground-patch",
        spawn_min_radius = 11.5,
        spawn_max_radius = 12.5,
        spawn_min = 30,
        spawn_max = 40,
        apply_projection = true,
        spread_evenly = true
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 1000,
          radius = 7,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-ground-zero-projectile",
            starting_speed = 0.6 * 0.8,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
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
          repeat_count = 1000,
          radius = 30,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave",
            starting_speed = 0.3 ,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
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
          repeat_count = 2000,
          radius = 50,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave",
            starting_speed = 0.4 ,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
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
          repeat_count = 3000,
          radius = 70,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave",
            starting_speed = 0.5 ,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 1000,
          radius = 30,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
            starting_speed = 0.3,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 1000,
          radius = 50,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
            starting_speed = 0.4,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 1000,
          radius = 70,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
            starting_speed = 0.5,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 700,
          radius = 10,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
            starting_speed = 0.5 * 0.65,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 1000,
          radius = 16,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
            starting_speed = 0.5 * 0.65,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 300,
          radius = 26,
          action_delivery =
          {
            type = "projectile",
            projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
            starting_speed = 0.5 * 0.65,
            starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          show_in_tooltip = false,
          target_entities = false,
          trigger_from_target = true,
          repeat_count = 10,
          radius = 16,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "create-entity",
                entity_name = "nuclear-smouldering-smoke-source",
                tile_collision_mask = { "water-tile" }
              }
            }
          }
        }
      }
    }
  }
}

--NUCLEAR EXPLOSION

local nuclear_action =
{
	type = "nested-result",
	action =
	{
		type = "area",
		target_entities = false,
		trigger_from_target = true,
		repeat_count = 2000,
		radius = 35,
		action_delivery =
		{
			type = "projectile",
			projectile = "atomic-bomb-wave",
			starting_speed = 0.5
		}
	}
}

--THERMONUCLEAR BOMB PROJECTILE

data:extend(
{
	{
    type = "projectile",
    name = "thermonuclear-rocket",
    flags = {"not-on-map"},
    acceleration = 0.002,
    action = thermonuclear_action,
    light = {intensity = 1, size = 90, color = {r=1.0, g=1.0, b=1.0}},--{intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
	}
}
)

--ARTILLERY SHELL PROJECTILES

local nuclear_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
nuclear_artillery_projectile.name = "artillery-projectile-nuclear"
table.insert(nuclear_artillery_projectile.action.action_delivery.target_effects, nuclear_action)


local thermonuclear_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
thermonuclear_artillery_projectile.name = "artillery-projectile-thermonuclear"
thermonuclear_artillery_projectile.action = thermonuclear_action


if settings.startup["artillery-shells"].value == true then
	data:extend(
	{
		nuclear_artillery_projectile,
		thermonuclear_artillery_projectile,
		{
			type = "ammo",
			name = "artillery-shell-nuclear",
			icons =
			{
				{
					icon = "__base__/graphics/icons/artillery-shell.png",
					icon_size=64
				},
				{
					icon = "__base__/graphics/icons/atomic-bomb.png",
					icon_size=64,
					scale = 0.2,--0.4
					shift = {-10, -10},
				},
			},
			ammo_type =
			{
				category = "artillery-shell",
				target_type = "position",
				action =
				{
					type = "direct",
					action_delivery =
					{
						type = "artillery",
						projectile = "artillery-projectile-nuclear",
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
			order = "d[explosive-cannon-shell]-d[artillery]2",
			stack_size = 1
		},

		{
			type = "ammo",
			name = "artillery-shell-thermonuclear",
			icons =
			{
				{
					icon = "__base__/graphics/icons/artillery-shell.png",
					icon_size=64,
				},
				{
					icon = "__Clowns-Nuclear__/graphics/icons/thermonuclear-bomb.png",
					icon_size=32,
					scale = 0.4,
					shift = {-10, -10},
				},
			},
			ammo_type =
			{
				category = "artillery-shell",
				target_type = "position",
				action =
				{
					type = "direct",
					action_delivery =
					{
						type = "artillery",
						projectile = "artillery-projectile-thermonuclear",
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
			order = "d[explosive-cannon-shell]-d[artillery]2",
			stack_size = 1
		},
	}
	)
end
