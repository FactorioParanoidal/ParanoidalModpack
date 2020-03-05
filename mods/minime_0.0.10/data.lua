require("entity.demo-player-animations")

-- data.raw["character-corpse"]["character-corpse"].selection_box = {{-0.7, -0.7}, {0.7, 0.7}}
data.raw["character"]["character"].collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
-- data.raw["character"]["character"].selection_box = {{-0.4, -1.4}, {0.4, 0.2}}
-- data.raw["character"]["character"].sticker_box = {{-0.2, -1}, {0.2, 0}}

data.raw["character-corpse"]["character-corpse"].pictures =
    {
      {
        layers =
        {
          character_animations.level1.dead,
          character_animations.level1.dead_mask,
          character_animations.level1.dead_shadow
        }
      },
      {
        layers =
        {
          character_animations.level1.dead,
          character_animations.level1.dead_mask,
          character_animations.level2addon.dead,
          character_animations.level2addon.dead_mask,
          character_animations.level1.dead_shadow
        }
      },
      {
        layers =
        {
          character_animations.level1.dead,
          character_animations.level1.dead_mask,
          character_animations.level3addon.dead,
          character_animations.level3addon.dead_mask,
          character_animations.level1.dead_shadow
        }
      }
    }
data.raw["character"]["character"].animations =
    {
      {
        idle =
        {
          layers =
          {
            character_animations.level1.idle,
            character_animations.level1.idle_mask,
            character_animations.level1.idle_shadow
          }
        },
        idle_with_gun =
        {
          layers =
          {
            character_animations.level1.idle_gun,
            character_animations.level1.idle_gun_mask,
            character_animations.level1.idle_gun_shadow
          }
        },
        mining_with_tool =
        {
          layers =
          {
            character_animations.level1.mining_tool,
            character_animations.level1.mining_tool_mask,
            character_animations.level1.mining_tool_shadow
          }
        },
        running_with_gun =
        {
          layers =
          {
            character_animations.level1.running_gun,
            character_animations.level1.running_gun_mask,
            character_animations.level1.running_gun_shadow
          }
        },
        flipped_shadow_running_with_gun =
        {
          layers =
          {
            character_animations.level1.running_gun_shadow_flipped
          }
        },
        running =
        {
          layers =
          {
            character_animations.level1.running,
            character_animations.level1.running_mask,
            character_animations.level1.running_shadow
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
            character_animations.level1.idle,
            character_animations.level1.idle_mask,
            character_animations.level2addon.idle,
            character_animations.level2addon.idle_mask,
            character_animations.level1.idle_shadow,
            character_animations.level2addon.idle_shadow
          }
        },
        idle_with_gun =
        {
          layers =
          {
            character_animations.level1.idle_gun,
            character_animations.level1.idle_gun_mask,
            character_animations.level2addon.idle_gun,
            character_animations.level2addon.idle_gun_mask,
            character_animations.level1.idle_gun_shadow,
            character_animations.level2addon.idle_gun_shadow
          }
        },
        mining_with_tool =
        {
          layers =
          {
            character_animations.level1.mining_tool,
            character_animations.level1.mining_tool_mask,
            character_animations.level2addon.mining_tool,
            character_animations.level2addon.mining_tool_mask,
            character_animations.level1.mining_tool_shadow,
            character_animations.level2addon.mining_tool_shadow
          }
        },
        running_with_gun =
        {
          layers =
          {
            character_animations.level1.running_gun,
            character_animations.level1.running_gun_mask,
            character_animations.level2addon.running_gun,
            character_animations.level2addon.running_gun_mask,
            character_animations.level1.running_gun_shadow,
            character_animations.level2addon.running_gun_shadow
          }
        },
        flipped_shadow_running_with_gun =
        {
          layers =
          {
            character_animations.level1.running_gun_shadow_flipped,
            character_animations.level2addon.running_gun_shadow_flipped
          }
        },
        running =
        {
          layers =
          {
            character_animations.level1.running,
            character_animations.level1.running_mask,
            character_animations.level2addon.running,
            character_animations.level2addon.running_mask,
            character_animations.level1.running_shadow,
            character_animations.level2addon.running_shadow
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
            character_animations.level1.idle,
            character_animations.level1.idle_mask,
            character_animations.level3addon.idle,
            character_animations.level3addon.idle_mask,
            character_animations.level1.idle_shadow,
            character_animations.level3addon.idle_shadow
          }
        },
        idle_with_gun =
        {
          layers =
          {
            character_animations.level1.idle_gun,
            character_animations.level1.idle_gun_mask,
            character_animations.level3addon.idle_gun,
            character_animations.level3addon.idle_gun_mask,
            character_animations.level1.idle_gun_shadow,
            character_animations.level3addon.idle_gun_shadow
          }
        },
        mining_with_tool =
        {
          layers =
          {
            character_animations.level1.mining_tool,
            character_animations.level1.mining_tool_mask,
            character_animations.level3addon.mining_tool,
            character_animations.level3addon.mining_tool_mask,
            character_animations.level1.mining_tool_shadow,
            character_animations.level3addon.mining_tool_shadow
          }
        },
        running_with_gun =
        {
          layers =
          {
            character_animations.level1.running_gun,
            character_animations.level1.running_gun_mask,
            character_animations.level3addon.running_gun,
            character_animations.level3addon.running_gun_mask,
            character_animations.level1.running_gun_shadow,
            character_animations.level3addon.running_gun_shadow
          }
        },
        flipped_shadow_running_with_gun =
        {
          layers =
          {
            character_animations.level1.running_gun_shadow_flipped,
            character_animations.level3addon.running_gun_shadow_flipped
          }
        },
        running =
        {
          layers =
          {
            character_animations.level1.running,
            character_animations.level1.running_mask,
            character_animations.level3addon.running,
            character_animations.level3addon.running_mask,
            character_animations.level1.running_shadow,
            character_animations.level3addon.running_shadow
          }
        }
      }
    }