local graphics = "__LootingSpaceshipWrecks__/graphics/entity/"
local priority = "very-low"

local lab_body = {
  filename = graphics .. "crash-site-lab/hr-crash-site-lab-repaired.png",
  priority = priority,
  width = 488,
  height = 252,
  frame_count = 1,
  line_length = 1,
  repeat_count = 24,
  shift = util.by_pixel(-34, -2),
  scale = 0.5
}
local lab_shadow = {
  filename = graphics .. "crash-site-lab/hr-crash-site-lab-repaired-shadow.png",
  priority = priority,
  width = 696,
  height = 302,
  frame_count = 1,
  line_length = 1,
  repeat_count = 24,
  shift = util.by_pixel(-27, -4),
  scale = 0.5,
  draw_as_shadow = true
}

return {
  assembler = {
    animation = {
      layers = {
        {
          filename = graphics .. "crash-site-assembling-machine/hr-crash-site-assembling-machine-1-repaired.png",
          priority = priority,
          width = 282,
          height = 182,
          frame_count = 20,
          line_length = 5,
          shift = util.by_pixel(-12, 3),
          animation_speed = 1,
          scale = 0.5
        },
        {
          filename = graphics .. "crash-site-assembling-machine/hr-crash-site-assembling-machine-1-repaired-shadow.png",
          priority = priority,
          width = 278,
          height = 168,
          frame_count = 20,
          line_length = 5,
          draw_as_shadow = true,
          shift = util.by_pixel(4, 6),
          animation_speed = 1,
          scale = 0.5
        }
      }
    },
    working_visualisations = {
      {
        animation = {
          filename = graphics .. "crash-site-assembling-machine/hr-crash-site-assembling-machine-1-repaired-light.png",
          priority = priority,
          width = 162,
          height = 120,
          frame_count = 20,
          line_length = 5,
          shift = util.by_pixel(12, -8),
          blend_mode = "additive",
          animation_speed = 1,
          scale = 0.5
        }
      }
    }
  },
  lab_on = {
    layers = {
      table.deepcopy(lab_body),
      {
        filename = graphics .. "crash-site-lab/hr-crash-site-lab-repaired-beams.png",
        priority = priority,
        width = 130,
        height = 100,
        frame_count = 24,
        line_length = 6,
        animation_speed = 0.5,
        shift = util.by_pixel(21, -36),
        blend_mode = "additive",
        scale = 0.5
      },
      table.deepcopy(lab_shadow)
    }
  },
  lab_off = {layers = {lab_body, lab_shadow}},
  generator = {
    layers = {
      {
        filename = graphics .. "crash-site-generator/hr-crash-site-generator.png",
        priority = priority,
        width = 286,
        height = 252,
        frame_count = 5,
        line_length = 5,
        repeat_count = 16,
        animation_speed = 0.5,
        shift = util.by_pixel(-11, -23),
        scale = 0.5
      },
      {
        filename = graphics .. "crash-site-generator/hr-crash-site-generator-beams.png",
        priority = priority,
        width = 224,
        height = 232,
        frame_count = 16,
        line_length = 4,
        repeat_count = 5,
        animation_speed = 0.5,
        shift = util.by_pixel(-8, -30),
        scale = 0.5
      },
      {
        filename = graphics .. "crash-site-generator/hr-crash-site-generator-shadow.png",
        priority = priority,
        width = 474,
        height = 152,
        frame_count = 1,
        line_length = 1,
        repeat_count = 80,
        draw_as_shadow = true,
        shift = util.by_pixel(25, 5),
        animation_speed = 0.5,
        scale = 0.5
      }
    }
  }
}
