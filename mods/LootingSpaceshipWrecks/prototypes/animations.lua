local salvaged_sprite_priority = "very-low"

function salvaged_assembler_horizontal_integration_patch()
  return
  {
    filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/crash-site-assembling-machine-1-ground.png",
    priority = salvaged_sprite_priority,
    width = 208,
    height = 116,
    shift = util.by_pixel(-24, 12),
    frame_count = 1,
    line_length = 1,
    hr_version =
    {
      filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/hr-crash-site-assembling-machine-1-ground.png",
      priority = salvaged_sprite_priority,
      width = 446,
      height = 234,
      shift = util.by_pixel(-31, 12),
      frame_count = 1,
      line_length = 1,
      scale = 0.5
    }
  }
end

function salvaged_assembler_horizontal_animation(animation_speed)
  return
  {
    layers =
    {
      {
        filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/crash-site-assembling-machine-1-repaired.png",
        priority = salvaged_sprite_priority,
        width = 142,
        height = 92,
        frame_count = 20,
        line_length = 5,
        shift = util.by_pixel(-12, 2),
        animation_speed = animation_speed,
        hr_version =
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/hr-crash-site-assembling-machine-1-repaired.png",
          priority = salvaged_sprite_priority,
          width = 282,
          height = 182,
          frame_count = 20,
          line_length = 5,
          shift = util.by_pixel(-12, 3),
          animation_speed = animation_speed,
          scale = 0.5
        }
      },
      {
        filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/crash-site-assembling-machine-1-repaired-shadow.png",
        priority = salvaged_sprite_priority,
        width = 140,
        height = 84,
        frame_count = 20,
        line_length = 5,
        draw_as_shadow = true,
        shift = util.by_pixel(4, 6),
        animation_speed = animation_speed,
        hr_version =
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/hr-crash-site-assembling-machine-1-repaired-shadow.png",
          priority = salvaged_sprite_priority,
          width = 278,
          height = 168,
          frame_count = 20,
          line_length = 5,
          draw_as_shadow = true,
          shift = util.by_pixel(4, 6),
          animation_speed = animation_speed,
          scale = 0.5
        }
      }
    }
  }
end

function salvaged_assembler_horizontal_visualisation(animation_speed)
  return
  {
    {
      animation =
      {
        filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/crash-site-assembling-machine-1-repaired-light.png",
        priority = salvaged_sprite_priority,
        width = 78,
        height = 64,
        frame_count = 20,
        line_length = 5,
        shift = util.by_pixel(10, -10),
        blend_mode = "additive",
        animation_speed = animation_speed,
        hr_version =
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-assembling-machine/hr-crash-site-assembling-machine-1-repaired-light.png",
          priority = salvaged_sprite_priority,
          width = 162,
          height = 120,
          frame_count = 20,
          line_length = 5,
          shift = util.by_pixel(12, -8),
          blend_mode = "additive",
          animation_speed = animation_speed,
          scale = 0.5
        }
      }
    }
  }
end