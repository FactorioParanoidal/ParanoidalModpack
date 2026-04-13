local beams = {
  "bullet-beam-basic",
  "bullet-beam-blue",
  "bullet-beam-blue-faint",
  "bullet-beam-cyan",
  "bullet-beam-cyan-faint",
  "bullet-beam-green",
  "bullet-beam-green-faint",
  "bullet-beam-magenta",
  "bullet-beam-magenta-faint",
  "bullet-beam-olive",
  "bullet-beam-olive-faint",
  "bullet-beam-orange",
  "bullet-beam-orange-faint",
  "bullet-beam-piercing",
  "bullet-beam-purple",
  "bullet-beam-purple-faint",
  "bullet-beam-red",
  "bullet-beam-red-faint",
  "bullet-beam-teal",
  "bullet-beam-teal-faint",
  "bullet-beam-white",
  "bullet-beam-white-faint",
  "bullet-beam-yellow",
  "bullet-beam-yellow-faint",
}
for _, beam  in pairs(beams) do
  data:extend({
    {
      type = "explosion",
      name = beam,
      flags = {"not-on-map", "placeable-off-grid"},
      hidden = true,
      random_target_offset = true,
      target_offset_y = -0.3,
      animation_speed = 1,
      rotate = true,
      beam = true,
      animations =
      {
        {
        filename = "__bullet-trails__/graphics/entity/projectile/"..beam..".png",
        priority = "extra-high",
        width = 7,
        height = 90,
        frame_count = 5,
        }
      },
      light = {intensity = 0.1, size = 2},
      smoke = "smoke-fast",
      smoke_count = 1,
      smoke_slow_down_factor = 1
    }})
end
