-- distribution axes control biome type placement
--            volcanic
-- sand    |    dirt    |    grass
--             frozen
-- other axes used for biome subtypes (mineral/vegetation colors)
-- since new dimensions can't be created and noise layers are not sufficient
--    sub-sections of the distribution axes need to be used for subtypes
-- subtype variations (alternate textures) controlled maily by noise layers

return {
  distribution_temperature = {
    dimension = "temperature",
    low =   -50,
    high =  150,
  },
  distribution_moisture = {
    dimension = "moisture",
    low =   0,
    high =  1,
  },
  volcanic_a = { -- heat
    dimension = "temperature",
    low =   100,
    high =  150,
  },
  volcanic_b = { -- color: orange, green, blue, purple
    dimension = "aux",
    low =   0,
    high =  1,
  },
  mineral_a = { -- saturation: greys -> purple red tan
    dimension = "temperature", -- subsection of distribution axes
    low =   0,
    high =  100,
  },
  mineral_b = { -- lightness:  light tan -> dark purple
    dimension = "aux",
    low =   0,
    high =  1,
  },
  vegetation_a = { -- blue -> red
    dimension = "temperature",
    low =   0,
    high =  100,
  },
  vegetation_b = { -- green -> purple
    dimension = "aux",
    low =   0,
    high =  1,
  }
}
