require("entity.demo-player-animations")

data.raw["character-corpse"]["character-corpse"].selection_box = {{-0.7, -0.7}, {0.7, 0.7}}
data.raw["character"]["character"].collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
data.raw["character"]["character"].selection_box = {{-0.4, -1.4}, {0.4, 0.2}}
data.raw["character"]["character"].sticker_box = {{-0.2, -1}, {0.2, 0}}
data.raw["character-corpse"]["character-corpse"].
    pictures =
    {
      {
        layers =
        {
          playeranimations.level1.dead,
          playeranimations.level1.dead_mask,
          playeranimations.level1.dead_shadow,
        }
      },
      {
        layers =
        {
          playeranimations.level1.dead,
          playeranimations.level1.dead_mask,
          playeranimations.level2addon.dead,
          playeranimations.level2addon.dead_mask,
          playeranimations.level1.dead_shadow,
        }
      },
      {
        layers =
        {
          playeranimations.level1.dead,
          playeranimations.level1.dead_mask,
          playeranimations.level3addon.dead,
          playeranimations.level3addon.dead_mask,
          playeranimations.level1.dead_shadow,
        }
      }
    }
data.raw["character"]["character"].
    animations =
    {
      {
        idle =
        {
          layers =
          {
            playeranimations.level1.idle,
            playeranimations.level1.idle_mask,
            playeranimations.level1.idle_shadow,
          }
        },
        idle_with_gun =
        {
          layers =
          {
            playeranimations.level1.idle_gun,
            playeranimations.level1.idle_gun_mask,
            playeranimations.level1.idle_gun_shadow,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            playeranimations.level1.mining_hands,
            playeranimations.level1.mining_hands_mask,
            playeranimations.level1.mining_hands_shadow,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            playeranimations.level1.mining_tool,
            playeranimations.level1.mining_tool_mask,
            playeranimations.level1.mining_tool_shadow,
          }
        },
        running_with_gun =
        {
          layers =
          {
            playeranimations.level1.running_gun,
            playeranimations.level1.running_gun_mask,
            playeranimations.level1.running_gun_shadow,
          }
        },
        running =
        {
          layers =
          {
            playeranimations.level1.running,
            playeranimations.level1.running_mask,
            playeranimations.level1.running_shadow,
          }
        }
      },
      {
        -- heavy-armor is not in the demo
        armors = data.is_demo and {"light-armor"} or {"light-armor", "heavy-armor"},
        idle =
        {
          layers =
          {
            playeranimations.level1.idle,
            playeranimations.level1.idle_mask,
            playeranimations.level2addon.idle,
            playeranimations.level2addon.idle_mask,
            playeranimations.level1.idle_shadow,
          }
        },
        idle_with_gun =
        {
          layers =
          {
            playeranimations.level1.idle_gun,
            playeranimations.level1.idle_gun_mask,
            playeranimations.level2addon.idle_gun,
            playeranimations.level2addon.idle_gun_mask,
            playeranimations.level1.idle_gun_shadow,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            playeranimations.level1.mining_hands,
            playeranimations.level1.mining_hands_mask,
            playeranimations.level2addon.mining_hands,
            playeranimations.level2addon.mining_hands_mask,
            playeranimations.level1.mining_hands_shadow,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            playeranimations.level1.mining_tool,
            playeranimations.level1.mining_tool_mask,
            playeranimations.level2addon.mining_tool,
            playeranimations.level2addon.mining_tool_mask,
            playeranimations.level1.mining_tool_shadow,
          }
        },
        running_with_gun =
        {
          layers =
          {
            playeranimations.level1.running_gun,
            playeranimations.level1.running_gun_mask,
            playeranimations.level2addon.running_gun,
            playeranimations.level2addon.running_gun_mask,
            playeranimations.level1.running_gun_shadow,
          }
        },
        running =
        {
          layers =
          {
            playeranimations.level1.running,
            playeranimations.level1.running_mask,
            playeranimations.level2addon.running,
            playeranimations.level2addon.running_mask,
            playeranimations.level1.running_shadow,
          }
        }
      },
      {
        -- modular armors are not in the demo
        armors = data.is_demo and {} or {"modular-armor", "power-armor", "power-armor-mk2"},
        idle =
        {
          layers =
          {
            playeranimations.level1.idle,
            playeranimations.level1.idle_mask,
            playeranimations.level3addon.idle,
            playeranimations.level3addon.idle_mask,
            playeranimations.level1.idle_shadow,
          }
        },
        idle_with_gun =
        {
          layers =
          {
            playeranimations.level1.idle_gun,
            playeranimations.level1.idle_gun_mask,
            playeranimations.level3addon.idle_gun,
            playeranimations.level3addon.idle_gun_mask,
            playeranimations.level1.idle_gun_shadow,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            playeranimations.level1.mining_hands,
            playeranimations.level1.mining_hands_mask,
            playeranimations.level3addon.mining_hands,
            playeranimations.level3addon.mining_hands_mask,
            playeranimations.level1.mining_hands_shadow,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            playeranimations.level1.mining_tool,
            playeranimations.level1.mining_tool_mask,
            playeranimations.level3addon.mining_tool,
            playeranimations.level3addon.mining_tool_mask,
            playeranimations.level1.mining_tool_shadow,
          }
        },
        running_with_gun =
        {
          layers =
          {
            playeranimations.level1.running_gun,
            playeranimations.level1.running_gun_mask,
            playeranimations.level3addon.running_gun,
            playeranimations.level3addon.running_gun_mask,
            playeranimations.level1.running_gun_shadow,
          }
        },
        running =
        {
          layers =
          {
            playeranimations.level1.running,
            playeranimations.level1.running_mask,
            playeranimations.level3addon.running,
            playeranimations.level3addon.running_mask,
            playeranimations.level1.running_shadow,
          }
        }
      }
    }
	
playeranimations = 
{
  level1 =
  {
    dead =
    {
      filename = "__base__/graphics/entity/character/level1_dead.png",
      width = 58,
      height = 58,
      shift = util.by_pixel(-4.9,-3.5),
      frame_count = 2,
	  scale = 0.7,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_dead.png",
        width = 114,
        height = 112,
        shift = util.by_pixel(-4.9,-3.85),
        frame_count = 2,
        scale = 0.35
      },
    },
    dead_mask =
    {
      filename = "__base__/graphics/entity/character/level1_dead_mask.png",
      width = 46,
      height = 36,
      shift = util.by_pixel(-1.4,-4.2),
      frame_count = 2,
	  scale = 0.7,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_dead_mask.png",
        width = 88,
        height = 70,
        shift = util.by_pixel(-1.75,-4.55),
        frame_count = 2,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    dead_shadow =
    {
      filename = "__base__/graphics/entity/character/level1_dead_shadow.png",
      width = 58,
      height = 54,
      shift = util.by_pixel(-4.9,-1.4),
      frame_count = 2,
	  scale = 0.7,
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_dead_shadow.png",
        width = 114,
        height = 106,
        shift = util.by_pixel(-5.25,-1.75),
        frame_count = 2,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
    idle =
    {
      filename = "__base__/graphics/entity/character/level1_idle.png",
      width = 46,
      height = 58,
      shift = util.by_pixel(0.0,-14.7),
      frame_count = 22,
      direction_count = 8,
	  scale = 0.7,
      animation_speed = 0.15,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_idle.png",
        width = 92,
        height = 116,
        shift = util.by_pixel(0.0,-14.7),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        scale = 0.35
      },
    },
    idle_mask =
    {
      filename = "__base__/graphics/entity/character/level1_idle_mask.png",
      width = 28,
      height = 46,
      shift = util.by_pixel(0.0,-18.2),
      frame_count = 22,
      direction_count = 8,
	  scale = 0.7,
      animation_speed = 0.15,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_idle_mask.png",
        width = 56,
        height = 90,
        shift = util.by_pixel(0.0,-18.2),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    idle_shadow =
    {
      filename = "__base__/graphics/entity/character/level1_idle_shadow.png",
      width = 52,
      height = 38,
      shift = util.by_pixel(0.0,0.7),
      frame_count = 22,
      direction_count = 8,
	  scale = 0.7,
      animation_speed = 0.15,
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_idle_shadow.png",
        width = 104,
        height = 74,
        shift = util.by_pixel(0.0,0.7),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
    idle_gun =
    {
      filename = "__base__/graphics/entity/character/level1_idle_gun.png",
      width = 56,
      height = 64,
      shift = util.by_pixel(0.0,-10.78),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_idle_gun.png",
        width = 110,
        height = 128,
        shift = util.by_pixel(0.0,-15.4),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        scale = 0.35
      },
    },
    idle_gun_mask =
    {
      filename = "__base__/graphics/entity/character/level1_idle_gun_mask.png",
      width = 36,
      height = 44,
      shift = util.by_pixel(-0.49,-10.78),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_idle_gun_mask.png",
        width = 72,
        height = 88,
        shift = util.by_pixel(-0.35,-15.4),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    idle_gun_shadow =
    {
      filename = "__base__/graphics/entity/character/level1_idle_gun_shadow.png",
      width = 64,
      height = 46,
      shift = util.by_pixel(0.0,0.49),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_idle_gun_shadow.png",
        width = 128,
        height = 90,
        shift = util.by_pixel(0.0,0.7),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
    mining_hands =
    {
      filename = "__base__/graphics/entity/character/level1_mining_hands.png",
      width = 48,
      height = 54,
      shift = util.by_pixel(0.0,-8.4),
      frame_count = 14,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_mining_hands.png",
        width = 94,
        height = 106,
        shift = util.by_pixel(0.0,-8.75),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    mining_hands_mask =
    {
      filename = "__base__/graphics/entity/character/level1_mining_hands_mask.png",
      width = 38,
      height = 46,
      shift = util.by_pixel(0.0,-11.2),
      frame_count = 14,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_mining_hands_mask.png",
        width = 76,
        height = 90,
        shift = util.by_pixel(0.0,-11.2),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    mining_hands_shadow =
    {
      filename = "__base__/graphics/entity/character/level1_mining_hands_shadow.png",
      width = 48,
      height = 34,
      shift = util.by_pixel(0.0,0.7),
      frame_count = 14,
      direction_count = 8,
	  scale = 0.7,
      animation_speed = 0.857,
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_mining_hands_shadow.png",
        width = 94,
        height = 66,
        shift = util.by_pixel(0.0,0.7),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
    mining_tool =
    {
      stripes =
      {
        {
        filename = "__base__/graphics/entity/character/level1_mining_tool-1.png",
        width_in_frames = 13,
        height_in_frames = 8,
        },
        {
        filename = "__base__/graphics/entity/character/level1_mining_tool-2.png",
        width_in_frames = 13,
        height_in_frames = 8,
        },
      },
      width = 98,
      height = 98,
      shift = util.by_pixel(0.0,-10.5),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      hr_version =
      {
        stripes =
        {
          {
          filename = "__base__/graphics/entity/character/hr-level1_mining_tool-1.png",
          width_in_frames = 13,
          height_in_frames = 8,
          },
          {
          filename = "__base__/graphics/entity/character/hr-level1_mining_tool-2.png",
          width_in_frames = 13,
          height_in_frames = 8,
          },
        },
        width = 196,
        height = 194,
        shift = util.by_pixel(0.0,-10.5),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        scale = 0.35
      },
    },
    mining_tool_mask =
    {
      filename = "__base__/graphics/entity/character/level1_mining_tool_mask.png",
      width = 70,
      height = 70,
      shift = util.by_pixel(0.0,-13.3),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_mining_tool_mask.png",
        width = 140,
        height = 138,
        shift = util.by_pixel(0.35,-13.3),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    mining_tool_shadow =
    {
      stripes =
      {
        {
        filename = "__base__/graphics/entity/character/level1_mining_tool_shadow-1.png",
        width_in_frames = 13,
        height_in_frames = 8,
        },
        {
        filename = "__base__/graphics/entity/character/level1_mining_tool_shadow-2.png",
        width_in_frames = 13,
        height_in_frames = 8,
        },
      },
      width = 100,
      height = 72,
      shift = util.by_pixel(0.0,0.7),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      draw_as_shadow = true,
      hr_version =
      {
        stripes =
        {
          {
          filename = "__base__/graphics/entity/character/hr-level1_mining_tool_shadow-1.png",
          width_in_frames = 13,
          height_in_frames = 8,
          },
          {
          filename = "__base__/graphics/entity/character/hr-level1_mining_tool_shadow-2.png",
          width_in_frames = 13,
          height_in_frames = 8,
          },
        },
        width = 200,
        height = 142,
        shift = util.by_pixel(0.0,0.7),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
    running =
    {
      filename = "__base__/graphics/entity/character/level1_running.png",
      width = 44,
      height = 66,
      shift = util.by_pixel(0.0,-12.6),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_running.png",
        width = 88,
        height = 132,
        shift = util.by_pixel(0.0,-12.6),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    running_mask =
    {
      filename = "__base__/graphics/entity/character/level1_running_mask.png",
      width = 40,
      height = 56,
      shift = util.by_pixel(0.0,-15.4),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_running_mask.png",
        width = 78,
        height = 110,
        shift = util.by_pixel(0.0,-15.4),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    running_shadow =
    {
      filename = "__base__/graphics/entity/character/level1_running_shadow.png",
      width = 46,
      height = 34,
      shift = util.by_pixel(0.0,2.8),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_running_shadow.png",
        width = 92,
        height = 66,
        shift = util.by_pixel(0.0,2.45),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.857,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
    running_gun =
    {
      filename = "__base__/graphics/entity/character/level1_running_gun.png",
      width = 56,
      height = 68,
      shift = util.by_pixel(3.0,-14.0),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_running_gun.png",
        width = 108,
        height = 136,
        shift = util.by_pixel(1.75,-13.65),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    running_gun_mask =
    {
      filename = "__base__/graphics/entity/character/level1_running_gun_mask.png",
      width = 34,
      height = 50,
      shift = util.by_pixel(1.0,-16.1),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_running_gun_mask.png",
        width = 66,
        height = 100,
        shift = util.by_pixel(0.7,-16.1),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    running_gun_shadow =
    {
      filename = "__base__/graphics/entity/character/level1_running_gun_shadow.png",
      width = 60,
      height = 48,
      shift = util.by_pixel(2.8,0.7),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.857,
      draw_as_shadow = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level1_running_gun_shadow.png",
        width = 120,
        height = 96,
        shift = util.by_pixel(3.15,0.7),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.857,
        draw_as_shadow = true,
        scale = 0.35
      },
    },
  },
  level2addon =
  {
    dead =
    {
      filename = "__base__/graphics/entity/character/level2addon_dead.png",
      width = 44,
      height = 34,
      shift = util.by_pixel(-0.7,-3.5),
      frame_count = 2,
	  scale = 0.7,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_dead.png",
        width = 86,
        height = 68,
        shift = util.by_pixel(-0.7,-3.5),
        frame_count = 2,
        scale = 0.35
      },
    },
    dead_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_dead_mask.png",
      width = 44,
      height = 34,
      shift = util.by_pixel(0.0,-3.5),
      frame_count = 2,
	  scale = 0.7,	  
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_dead_mask.png",
        width = 86,
        height = 66,
        shift = util.by_pixel(-0.35,-3.85),
        frame_count = 2,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    idle =
    {
      filename = "__base__/graphics/entity/character/level2addon_idle.png",
      width = 28,
      height = 44,
      shift = util.by_pixel(0.0,-18.9),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_idle.png",
        width = 56,
        height = 86,
        shift = util.by_pixel(0.35,-19.25),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        scale = 0.35
      },
    },
    idle_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_idle_mask.png",
      width = 26,
      height = 42,
      shift = util.by_pixel(0.0,-19.6),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_idle_mask.png",
        width = 52,
        height = 84,
        shift = util.by_pixel(0.0,-19.6),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    idle_gun =
    {
      filename = "__base__/graphics/entity/character/level2addon_idle_gun.png",
      width = 36,
      height = 44,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_idle_gun.png",
        width = 72,
        height = 86,
        shift = util.by_pixel(0.0,-17.5),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        scale = 0.35
      },
    },
    idle_gun_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_idle_gun_mask.png",
      width = 36,
      height = 44,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_idle_gun_mask.png",
        width = 72,
        height = 84,
        shift = util.by_pixel(0.0,-17.85),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    mining_hands =
    {
      filename = "__base__/graphics/entity/character/level2addon_mining_hands.png",
      width = 42,
      height = 46,
      shift = util.by_pixel(0.0,-11.9),
      frame_count = 14,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_mining_hands.png",
        width = 82,
        height = 90,
        shift = util.by_pixel(0.0,-11.9),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    mining_hands_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_mining_hands_mask.png",
      width = 40,
      height = 46,
      shift = util.by_pixel(0.0,-11.9),
      frame_count = 14,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_mining_hands_mask.png",
        width = 80,
        height = 90,
        shift = util.by_pixel(0.0,-11.9),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    mining_tool =
    {
      filename = "__base__/graphics/entity/character/level2addon_mining_tool.png",
      width = 72,
      height = 62,
      shift = util.by_pixel(0.0,-14.7),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_mining_tool.png",
        width = 142,
        height = 124,
        shift = util.by_pixel(0.0,-14.7),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        scale = 0.35
      },
    },
    mining_tool_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_mining_tool_mask.png",
      width = 70,
      height = 60,
      shift = util.by_pixel(0.0,-15.4),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_mining_tool_mask.png",
        width = 140,
        height = 120,
        shift = util.by_pixel(0.0,-15.4),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    running =
    {
      filename = "__base__/graphics/entity/character/level2addon_running.png",
      width = 36,
      height = 54,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_running.png",
        width = 70,
        height = 106,
        shift = util.by_pixel(0.0,-17.5),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    running_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_running_mask.png",
      width = 36,
      height = 54,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_running_mask.png",
        width = 70,
        height = 104,
        shift = util.by_pixel(0.0,-17.85),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    running_gun =
    {
      filename = "__base__/graphics/entity/character/level2addon_running_gun.png",
      width = 36,
      height = 48,
      shift = util.by_pixel(0.7,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_running_gun.png",
        width = 68,
        height = 94,
        shift = util.by_pixel(0.35,-17.85),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    running_gun_mask =
    {
      filename = "__base__/graphics/entity/character/level2addon_running_gun_mask.png",
      width = 36,
      height = 48,
      shift = util.by_pixel(0.7,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level2addon_running_gun_mask.png",
        width = 68,
        height = 94,
        shift = util.by_pixel(0.35,-17.85),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
  },
  level3addon =
  {
    dead =
    {
      filename = "__base__/graphics/entity/character/level3addon_dead.png",
      width = 44,
      height = 34,
      shift = util.by_pixel(-0.7,-3.5),
      frame_count = 2,
	  scale = 0.7,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_dead.png",
        width = 88,
        height = 68,
        shift = util.by_pixel(-0.35,-3.5),
        frame_count = 2,
        scale = 0.35
      },
    },
    dead_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_dead_mask.png",
      width = 36,
      height = 30,
      shift = util.by_pixel(2.1,-2.8),
      frame_count = 2,
	  scale = 0.7,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_dead_mask.png",
        width = 72,
        height = 60,
        shift = util.by_pixel(2.1,-2.45),
        frame_count = 2,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    idle =
    {
      filename = "__base__/graphics/entity/character/level3addon_idle.png",
      width = 38,
      height = 44,
      shift = util.by_pixel(0.0,-19.6),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_idle.png",
        width = 74,
        height = 86,
        shift = util.by_pixel(0.0,-19.6),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        scale = 0.35
      },
    },
    idle_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_idle_mask.png",
      width = 38,
      height = 38,
      shift = util.by_pixel(0.0,-21.7),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_idle_mask.png",
        width = 74,
        height = 72,
        shift = util.by_pixel(0.0,-22.05),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    idle_gun =
    {
      filename = "__base__/graphics/entity/character/level3addon_idle_gun.png",
      width = 40,
      height = 44,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_idle_gun.png",
        width = 78,
        height = 88,
        shift = util.by_pixel(0.0,-17.15),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        scale = 0.35
      },
    },
    idle_gun_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_idle_gun_mask.png",
      width = 38,
      height = 36,
      shift = util.by_pixel(0.0,-19.6),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.15,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_idle_gun_mask.png",
        width = 76,
        height = 68,
        shift = util.by_pixel(0.0,-19.95),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.15,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    mining_hands =
    {
      filename = "__base__/graphics/entity/character/level3addon_mining_hands.png",
      width = 42,
      height = 48,
      shift = util.by_pixel(0.0,-11.9),
      frame_count = 14,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_mining_hands.png",
        width = 82,
        height = 94,
        shift = util.by_pixel(0.0,-11.9),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        scale = 0.35
      },
    },
    mining_hands_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_mining_hands_mask.png",
      width = 40,
      height = 40,
      shift = util.by_pixel(0.0,-14.0),
      frame_count = 14,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.857,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_mining_hands_mask.png",
        width = 80,
        height = 78,
        shift = util.by_pixel(0.0,-14.35),
        frame_count = 14,
        direction_count = 8,
        animation_speed = 0.857,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    mining_tool =
    {
      filename = "__base__/graphics/entity/character/level3addon_mining_tool.png",
      width = 72,
      height = 64,
      shift = util.by_pixel(0.0,-14.7),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_mining_tool.png",
        width = 144,
        height = 124,
        shift = util.by_pixel(0.0,-15.05),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        scale = 0.35
      },
    },
    mining_tool_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_mining_tool_mask.png",
      width = 70,
      height = 56,
      shift = util.by_pixel(0.0,-16.8),
      frame_count = 26,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.9,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_mining_tool_mask.png",
        width = 138,
        height = 112,
        shift = util.by_pixel(0.0,-16.8),
        frame_count = 26,
        direction_count = 8,
        animation_speed = 0.9,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    running =
    {
      filename = "__base__/graphics/entity/character/level3addon_running.png",
      width = 40,
      height = 54,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.6,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_running.png",
        width = 80,
        height = 108,
        shift = util.by_pixel(0.0,-17.5),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.6,
        scale = 0.35
      },
    },
    running_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_running_mask.png",
      width = 40,
      height = 44,
      shift = util.by_pixel(0.0,-20.3),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 8,
      animation_speed = 0.6,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_running_mask.png",
        width = 78,
        height = 88,
        shift = util.by_pixel(0.0,-19.95),
        frame_count = 22,
        direction_count = 8,
        animation_speed = 0.6,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
    running_gun =
    {
      filename = "__base__/graphics/entity/character/level3addon_running_gun.png",
      width = 38,
      height = 48,
      shift = util.by_pixel(0.0,-17.5),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.6,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_running_gun.png",
        width = 76,
        height = 96,
        shift = util.by_pixel(0.35,-17.15),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.6,
        scale = 0.35
      },
    },
    running_gun_mask =
    {
      filename = "__base__/graphics/entity/character/level3addon_running_gun_mask.png",
      width = 38,
      height = 38,
      shift = util.by_pixel(0.7,-20.3),
      frame_count = 22,
	  scale = 0.7,
      direction_count = 18,
      animation_speed = 0.6,
      apply_runtime_tint = true,
      hr_version =
      {
        filename = "__base__/graphics/entity/character/hr-level3addon_running_gun_mask.png",
        width = 74,
        height = 74,
        shift = util.by_pixel(0.35,-20.65),
        frame_count = 22,
        direction_count = 18,
        animation_speed = 0.6,
        apply_runtime_tint = true,
        scale = 0.35
      },
    },
  },
}
