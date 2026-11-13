local mod_name = "visible-pollutants"
local Visuals = require("scripts.visuals")

-- Keep the original ID/geometry for saved render objects until their lazy fade.
data:extend({
  {
    type = "sprite",
    name = mod_name .. "-pollution",
    filename = "__" .. mod_name .. "__/graphics/pollution.png",
    size = 1024,
    scale = 3,
  }
})

for _, variant in ipairs(Visuals.Variants) do
  data:extend({
    {
      type = "sprite",
      name = Visuals.sprite_name(variant),
      filename = "__" .. mod_name .. "__/graphics/pollution-" .. variant .. ".png",
      size = Visuals.TextureSize,
      scale = Visuals.WorldSize / 32,
      premul_alpha = true, -- PNGs are straight alpha; the loader premultiplies once.
      flags = { "smoke", "linear-mip-level" },
    }
  })
end

-- One optional native cycle, not a second layer over the four HD forms.
data:extend({
  {
    type = "animation",
    name = Visuals.Animation,
    filename = "__" .. mod_name .. "__/graphics/pollution-veil-drift.png",
    size = Visuals.AnimationSize,
    frame_count = Visuals.FrameCount,
    line_length = Visuals.LineLength,
    scale = Visuals.WorldSize * 32 / Visuals.AnimationSize,
    animation_speed = 1, -- playback rate is set by the rendering object
    run_mode = "forward",
    premul_alpha = true,
    flags = { "smoke", "linear-mip-level" },
  }
})
