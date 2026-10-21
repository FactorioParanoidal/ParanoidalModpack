function get_number(num)     
  return 
  {
    type = "sprite",
    name = "flinumber".. num,
    filename = "__Fluid-level-indicator__/graphics/sprites/spritesheet.png",
    x = num * 94,
    width = 94,
    height = 144,
    scale = 1.5,
    draw_as_glow=true,
    apply_runtime_tint = true
  }
end

data:extend(
{
  {
    type = "sprite",
    name = "flinumberpc",
    filename = "__Fluid-level-indicator__/graphics/sprites/spritesheet.png",
    x = 10 * 94,
    width = 94,
    height = 144,
    scale = 1.5,
    draw_as_glow=true,
    apply_runtime_tint = true
  }
})

for number=0,9 do
  data:extend
  {
    get_number(number)
  }
end