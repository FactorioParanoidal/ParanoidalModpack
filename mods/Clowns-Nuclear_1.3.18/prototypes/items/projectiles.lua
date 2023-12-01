
require("prototypes.items.nuclear_action_tables")
--------------------------------------------------------------------------------------------------

--THERMONUCLEAR BOMB PROJECTILE

data:extend(
{
	{
    type = "projectile",
    name = "thermonuclear-rocket",
    flags = {"not-on-map"},
    acceleration = 0.002,
    action = clowns_actions_thermonuke,
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

local nuke_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
nuke_artillery_projectile.name = "artillery-projectile-nuclear"
for i,j in pairs(clowns_actions_nuke.action_delivery.target_effects) do
  table.insert(nuke_artillery_projectile.action.action_delivery.target_effects,j)
end

local thermonuke_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
thermonuke_artillery_projectile.name = "artillery-projectile-thermonuclear"
thermonuke_artillery_projectile.action = clowns_actions_thermonuke

if settings.startup["artillery-shells"].value == true then
	data:extend(
	{
		nuke_artillery_projectile,
		thermonuke_artillery_projectile,
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
