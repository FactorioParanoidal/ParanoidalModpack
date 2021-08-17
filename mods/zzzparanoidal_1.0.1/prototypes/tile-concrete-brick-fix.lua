local concrete_brick_fix = table.deepcopy(data.raw["tile"]["refined-concrete"])

concrete_brick_fix.name = "concrete-brick-fix"
concrete_brick_fix.minable = {mining_time = 0.1, result = "concrete-brick"}
--concrete_brick_fix.layer = "100"
concrete_brick_fix.variants.material_background = 
{
    picture = "__SingleColorTerrain__/graphics/concrete/concrete.png",
    count = 8,
    hr_version =
    {
      picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete.png",
      count = 8,
      scale = 0.5
    }
}

data:extend{concrete_brick_fix}

data.raw["item"]["concrete-brick"].place_as_tile.result = "concrete-brick-fix"
