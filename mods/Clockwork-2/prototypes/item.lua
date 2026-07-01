data:extend(
{
	{
    type = "capsule",
    name = "ln-flare-capsule",
    icon = "__Clockwork-2__/graphics/flare-capsule.png",
    icon_size = 128,
    subgroup = "capsule",
    order = "a[flare-capsule]",
    stack_size = 100,
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 30,
        projectile_creation_distance = 0.6,
        range = 50,
        ammo_type =
        {
          category = "capsule",
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "projectile",
              projectile = "ln-flare-capsule",
              starting_speed = 0.3
            }
          }
        },
        sound =
        {
          aggregation =
          {
            max_count = 1,
            remove = false
          },
          variations =
          {
            {
              filename = "__Clockwork-2__/sounds/flare-launch1.ogg",
              volume = 0.5
            },
            {
              filename = "__Clockwork-2__/sounds/flare-launch2.ogg",
              volume = 0.5
            }
          }
        }
      }
    }
  }
})