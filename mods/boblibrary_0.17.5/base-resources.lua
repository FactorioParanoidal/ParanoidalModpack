if resource_generator then
resource_generator.setup_resource_autoplace_data("iron-ore",
  {
    name = "iron-ore",
    order = "b",
    base_density = 10,
    has_starting_area_placement = true,
    regular_rq_factor_multiplier = 1.10,
    starting_rq_factor_multiplier = 1.5
  }
)
resource_generator.setup_resource_autoplace_data("copper-ore",
  {
    name = "copper-ore",
    order = "b",
    base_density = 8,
    has_starting_area_placement = true,
    regular_rq_factor_multiplier = 1.10,
    starting_rq_factor_multiplier = 1.2
  }
)
resource_generator.setup_resource_autoplace_data("coal",
  {
    name = "coal",
    order = "b",
    base_density = 8,
    has_starting_area_placement = true,
    regular_rq_factor_multiplier = 1.0,
    starting_rq_factor_multiplier = 1.1
  }
)
resource_generator.setup_resource_autoplace_data("stone",
  {
    name = "stone",
    order = "b",
    base_density = 4,
    has_starting_area_placement = true,
    regular_rq_factor_multiplier = 1.0,
    starting_rq_factor_multiplier = 1.1
  }
)

resource_generator.setup_resource_autoplace_data("crude-oil",
  {
    name = "crude-oil",
    order = "c",
    base_density = 8.2,
    base_spots_per_km2 = 1.8,
    random_probability = 1/48,
    random_spot_size_minimum = 1,
    random_spot_size_maximum = 1,
    additional_richness = 220000,
    has_starting_area_placement = false,
    regular_rq_factor_multiplier = 1
  }
)

resource_generator.setup_resource_autoplace_data("uranium-ore",
  {
    name = "uranium-ore",
    order = "c",
    base_density = 0.9,
    base_spots_per_km2 = 1.25,
    has_starting_area_placement = false,
    random_spot_size_minimum = 2,
    random_spot_size_maximum = 4,
    regular_rq_factor_multiplier = 1
  }
)
end
