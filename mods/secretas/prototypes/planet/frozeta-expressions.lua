--Copied from vulcanus

data:extend{
  ---- Constants
  {
    type = "noise-expression",
    name = "frozeta_ore_spacing",
    expression = 105
  },
  {
    type = "noise-expression",
    name = "frozeta_shared_influence",
    expression = 105 * 3
  },
  {
    type = "noise-expression",
    name = "frozeta_biome_contrast",
    expression = 2 -- higher values mean sharper transitions
  },
  {
    type = "noise-expression",
    name = "frozeta_cracks_scale",
    expression = 0.325
  },

  {
    --functions more like a cliffiness multiplier as all the mountain tiles have it offset.
    type = "noise-expression",
    name = "frozeta_mountains_elevation_multiplier",
    expression = 1.5
  },

  ---- HELPERS
  {
    type = "noise-expression",
    name = "frozeta_starting_area_multiplier",
    -- reduced richness for starting resources
    expression = "lerp(1, 0.06, clamp(0.5 + frozeta_starting_circle, 0, 1))"
  },
  {
    type = "noise-expression",
    name = "frozeta_richness_multiplier",
    expression = "6 + distance / 10000"
  },
  {
    type = "noise-expression",
    name = "frozeta_scale_multiplier",
    expression = "slider_rescale(control:frozeta_noise_scale:frequency, 3)"
  },
  {
    type = "noise-function",
    name = "frozeta_detail_noise",
    parameters = {"seed1", "scale", "octaves", "magnitude"},
    expression = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    seed0 = map_seed,\z
                                    seed1 = seed1 + 12243,\z
                                    octaves = octaves,\z
                                    persistence = 0.6,\z
                                    input_scale = 1 / 50 / scale,\z
                                    output_scale = magnitude}"
  },
  {
    type = "noise-function",
    name = "frozeta_plasma",
    parameters = {"seed", "scale", "scale2", "magnitude1", "magnitude2"},
    expression = "abs(basis_noise{x = x,\z
                                  y = y,\z
                                  seed0 = map_seed,\z
                                  seed1 = 12643,\z
                                  input_scale = 1 / 50 / scale,\z
                                  output_scale = magnitude1}\z
                      - basis_noise{x = x,\z
                                    y = y,\z
                                    seed0 = map_seed,\z
                                    seed1 = 13423 + seed,\z
                                    input_scale = 1 / 50 / scale2,\z
                                    output_scale = magnitude2})"
  },
  {
    type = "noise-function",
    name = "frozeta_threshold",
    parameters = {"value", "threshold"},
    expression = "(value - (1 - threshold)) * (1 / threshold)"
  },
  {
    type = "noise-function",
    name = "frozeta_contrast",
    parameters = {"value", "c"},
    expression = "clamp(value, c, 1) - c"
  },

  ---- ELEVATION
  {
    type = "noise-expression",
    name = "frozeta_elevation",
    --intended_property = "elevation",
    expression = "max(-500, frozeta_elev)"
  },
  ---- TEMPERATURE: Used to place hot vs cold tilesets, e.g. cold - warm - hot cracks.
  {
    type = "noise-expression",
    name = "frozeta_temperature",
    --intended_property = "temperature",
    expression = "100\z
                  + 100 * var('control:temperature:bias')\z
                  - min(frozeta_elev, frozeta_elev / 100)\z
                  - 2 * frozeta_moisture\z
                  - 1 * frozeta_aux\z
                  - 20 * frozeta_dark_frozen_biome\z
                  + 200 * max(0, frozeta_mountain_volcano_spots - 0.6)"
  },
  ---- AUX (0-1): On frozeta this is Rockiness.
  ---- 0 is flat and arranged as paths through rocks.
  ---- 1 are rocky "islands" for rock clusters, chimneys, etc.
  {
    type = "noise-expression",
    name = "frozeta_aux",
    --intended_property = "aux",
    expression = "clamp(min(abs(multioctave_noise{x = x,\z
                                                  y = y,\z
                                                  seed0 = map_seed,\z
                                                  seed1 = 2,\z
                                                  octaves = 5,\z
                                                  persistence = 0.6,\z
                                                  input_scale = 0.2,\z
                                                  output_scale = 0.6}),\z
                            0.3 - 0.6 * frozeta_flood_paths), 0, 1)"
  },
  
  --Originally from vulcanus, but I don't think this is necessary here.
  ---- MOISTURE (0-1): On frozeta used for vegetation clustering.
  ---- 0 is no vegetation, such as ash bowels in the dark_frozen.
  ---- 1 is vegetation pathches (mainly in dark_frozen).
  ---- As this drives the ash bowls, it also has an impact on small rock & pebble placement.
  {
    type = "noise-expression",
    name = "frozeta_moisture",
    --intended_property = "moisture",
    expression = "clamp(1\z
                        - abs(multioctave_noise{x = x,\z
                                                y = y,\z
                                                seed0 = map_seed,\z
                                                seed1 = 4,\z
                                                octaves = 2,\z
                                                persistence = 0.6,\z
                                                input_scale = 0.025,\z
                                                output_scale = 0.25})\z
                        - abs(multioctave_noise{x = x,\z
                                                y = y,\z
                                                seed0 = map_seed,\z
                                                seed1 = 400,\z
                                                octaves = 3,\z
                                                persistence = 0.62,\z
                                                input_scale = 0.051144353,\z
                                                output_scale = 0.25})\z
                        - 0.2 * frozeta_flood_cracks_a, 0, 1)"
  },

  ---- Starting Area blobs
  {
    type = "noise-expression",
    name = "frozeta_starting_area_radius",
    expression = "0.7 * 0.75"
  },
  {
    type = "noise-expression",
    name = "frozeta_starting_direction",
    expression = "-1 + 2 * (map_seed_small & 1)"
  },
  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_angle",
    expression = "map_seed_normalized * 3600"
  },
  {
    type = "noise-expression",
    name = "frozeta_mountains_angle",
    expression = "frozeta_dark_frozen_angle + 120 * frozeta_starting_direction"
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_angle",
    expression = "frozeta_dark_frozen_angle + 240 * frozeta_starting_direction"
  },
  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_start",
    -- requires more influence because it is smaller and has no mountain boost
    expression = "4 * starting_spot_at_angle{ angle = frozeta_dark_frozen_angle,\z
                                              distance = 170 * frozeta_starting_area_radius,\z
                                              radius = 350 * frozeta_starting_area_radius,\z
                                              x_distortion = 0.1 * frozeta_starting_area_radius * (frozeta_wobble_x + frozeta_wobble_large_x + frozeta_wobble_huge_x),\z
                                              y_distortion = 0.1 * frozeta_starting_area_radius * (frozeta_wobble_y + frozeta_wobble_large_y + frozeta_wobble_huge_y)}"
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_start",
    expression = "2 * starting_spot_at_angle{ angle = frozeta_basalts_angle,\z
                                              distance = 250,\z
                                              radius = 550 * frozeta_starting_area_radius,\z
                                              x_distortion = 0.1 * frozeta_starting_area_radius * (frozeta_wobble_x + frozeta_wobble_large_x + frozeta_wobble_huge_x),\z
                                              y_distortion = 0.1 * frozeta_starting_area_radius * (frozeta_wobble_y + frozeta_wobble_large_y + frozeta_wobble_huge_y)}"
  },
  {
    type = "noise-expression",
    name = "frozeta_mountains_start",
    expression = "2 * starting_spot_at_angle{ angle = frozeta_mountains_angle,\z
                                              distance = 250 * frozeta_starting_area_radius,\z
                                              radius = 500 * frozeta_starting_area_radius,\z
                                              x_distortion = 0.05 * frozeta_starting_area_radius * (frozeta_wobble_x + frozeta_wobble_large_x + frozeta_wobble_huge_x),\z
                                              y_distortion = 0.05 * frozeta_starting_area_radius * (frozeta_wobble_y + frozeta_wobble_large_y + frozeta_wobble_huge_y)}"
  },
  {
    type = "noise-expression",
    name = "frozeta_starting_area", -- used for biome blending
    expression = "clamp(max(frozeta_basalts_start, frozeta_mountains_start, frozeta_dark_frozen_start), 0, 1)"
  },
  {
    type = "noise-expression",
    name = "frozeta_starting_circle", -- Used to push random ores away. No not clamp.
    -- 600-650 circle
    expression = "1 + frozeta_starting_area_radius * (300 - distance) / 50"
  },

  ---- BIOME NOISE

  {
    type = "noise-function",
    name = "frozeta_biome_noise",
    parameters = {"seed1", "scale"},
    expression = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.65,\z
                                    seed0 = map_seed,\z
                                    seed1 = seed1,\z
                                    octaves = 5,\z
                                    input_scale = frozeta_scale_multiplier / scale}"
  },
  {
    type = "noise-function",
    name = "frozeta_biome_multiscale",
    parameters = {"seed1", "scale", "bias"},
    expression = "bias + lerp(frozeta_biome_noise(seed1, scale * 0.5),\z
                              frozeta_biome_noise(seed1 + 1000, scale),\z
                              clamp(distance / 10000, 0, 1))"
  },
  {
    type = "noise-expression",
    name = "frozeta_mountains_biome_noise",
    expression = "frozeta_biome_multiscale{seed1 = 342,\z
                                            scale = 60,\z
                                            bias = 0}"
  },
  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_biome_noise",
    expression = "frozeta_biome_multiscale{seed1 = 12416,\z
                                            scale = 40,\z
                                            bias = 0}"
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_biome_noise",
    expression = "frozeta_biome_multiscale{seed1 = 42416,\z
                                            scale = 80,\z
                                            bias = 0}"
  },


  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_raw",
    expression = "lerp(frozeta_dark_frozen_biome_noise, starting_weights, clamp(2 * frozeta_starting_area, 0, 1))",
    local_expressions =
    {
      starting_weights = "-frozeta_mountains_start + frozeta_dark_frozen_start - frozeta_basalts_start"
    }
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_raw",
    expression = "lerp(frozeta_basalts_biome_noise, starting_weights, clamp(2 * frozeta_starting_area, 0, 1))",
    local_expressions =
    {
      starting_weights = "-frozeta_mountains_start - frozeta_dark_frozen_start + frozeta_basalts_start"
    }
  },

  {
    type = "noise-expression",
    name = "frozeta_mountains_raw_pre_volcano",
    expression = "lerp(frozeta_mountains_biome_noise, starting_weights, clamp(2 * frozeta_starting_area, 0, 1))",
    local_expressions =
    {
      starting_weights = "frozeta_mountains_start - frozeta_dark_frozen_start - frozeta_basalts_start"
    }
  },
  {
    type = "noise-expression",
    name = "frozeta_mountains_biome_full_pre_volcano",
    expression = "frozeta_mountains_raw_pre_volcano - max(frozeta_dark_frozen_raw, frozeta_basalts_raw)"
  },

  {
    type = "noise-expression",
    name = "frozeta_mountain_volcano_spots",
    expression = "max(frozeta_starting_volcano_spot, raw_spots - starting_protector)",
    local_expressions =
    {
      starting_protector = "clamp(starting_spot_at_angle{ angle = frozeta_mountains_angle + 180 * frozeta_starting_direction,\z
                                                          distance = (400 * frozeta_starting_area_radius) / 2,\z
                                                          radius = 800 * frozeta_starting_area_radius,\z
                                                          x_distortion = frozeta_wobble_x/2 + frozeta_wobble_large_x/12 + frozeta_wobble_huge_x/80,\z
                                                          y_distortion = frozeta_wobble_y/2 + frozeta_wobble_large_y/12 + frozeta_wobble_huge_y/80}, 0, 1)",
      raw_spots = "spot_noise{x = x + frozeta_wobble_x/2 + frozeta_wobble_large_x/12 + frozeta_wobble_huge_x/80,\z
                              y = y + frozeta_wobble_y/2 + frozeta_wobble_large_y/12 + frozeta_wobble_huge_y/80,\z
                              seed0 = map_seed,\z
                              seed1 = 1,\z
                              candidate_spot_count = 1,\z
                              suggested_minimum_candidate_point_spacing = volcano_spot_spacing,\z
                              skip_span = 1,\z
                              skip_offset = 0,\z
                              region_size = 256,\z
                              density_expression = volcano_area / volcanism_sq,\z
                              spot_quantity_expression = volcano_spot_radius * volcano_spot_radius,\z
                              spot_radius_expression = volcano_spot_radius,\z
                              hard_region_target_quantity = 0,\z
                              spot_favorability_expression = volcano_area,\z
                              basement_value = 0,\z
                              maximum_spot_basement_radius = volcano_spot_radius}",
      volcano_area = "lerp(frozeta_mountains_biome_full_pre_volcano, 0, frozeta_starting_area)",
      volcano_spot_radius = "200 * volcanism",
      volcano_spot_spacing = "1500 * volcanism",
      volcanism = "0.3 + 0.7 * slider_rescale(control:frozeta_noise_scale:size, 3) / slider_rescale(frozeta_scale_multiplier, 3)",
      volcanism_sq = "volcanism * volcanism"
    }
  },
  {
    type = "noise-expression",
    name = "frozeta_starting_volcano_spot",
    expression = "clamp(starting_spot_at_angle{ angle = frozeta_mountains_angle,\z
                                                distance = 400 * frozeta_starting_area_radius,\z
                                                radius = 200,\z
                                                x_distortion = frozeta_wobble_x/2 + frozeta_wobble_large_x/12 + frozeta_wobble_huge_x/80,\z
                                                y_distortion = frozeta_wobble_y/2 + frozeta_wobble_large_y/12 + frozeta_wobble_huge_y/80}, 0, 1)"
  },

  {
    type = "noise-expression",
    name = "frozeta_mountains_raw_volcano",
    -- moderate influence for the outer 1/3 of the volcano, ramp to high influence for the middle third, and maxed for the innter third
    expression = "0.5 * frozeta_mountains_raw_pre_volcano + max(2 * frozeta_mountain_volcano_spots, 10 * clamp((frozeta_mountain_volcano_spots - 0.33) * 3, 0, 1))"
  },

  -- full range biomes with no clamping, good for away-from-edge targeting.
  {
    type = "noise-expression",
    name = "frozeta_mountains_biome_full",
    expression = "frozeta_mountains_raw_volcano - max(frozeta_dark_frozen_raw, frozeta_basalts_raw)"
  },
  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_biome_full",
    expression = "frozeta_dark_frozen_raw - max(frozeta_mountains_raw_volcano, frozeta_basalts_raw)"
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_biome_full",
    expression = "frozeta_basalts_raw - max(frozeta_mountains_raw_volcano, frozeta_dark_frozen_raw)"
  },

  -- clamped 0-1 biomes
  {
    type = "noise-expression",
    name = "frozeta_mountains_biome",
    expression = "clamp(frozeta_mountains_biome_full * frozeta_biome_contrast, 0, 1)"
  },
  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_biome",
    expression = "clamp(frozeta_dark_frozen_biome_full * frozeta_biome_contrast, 0, 1)"
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_biome",
    expression = "clamp(frozeta_basalts_biome_full * frozeta_biome_contrast, 0, 1)"
  },


  {
    type = "noise-expression",
    name = "frozeta_resource_penalty",
    expression = "random_penalty_inverse(2.5, 1)"
  },
  {
    type = "noise-expression",
    name = "frozeta_wobble_x",
    expression = "frozeta_detail_noise{seed1 = 1299, scale = 1/8, octaves = 3, magnitude = 4}"
  },
  {
    type = "noise-expression",
    name = "frozeta_wobble_y",
    expression = "frozeta_detail_noise{seed1 = 1010, scale = 1/8, octaves = 3, magnitude = 4}"
  },
  {
    type = "noise-expression",
    name = "frozeta_wobble_large_x",
    expression = "frozeta_detail_noise{seed1 = 20, scale = 1/2, octaves = 2, magnitude = 50}"
  },
  {
    type = "noise-expression",
    name = "frozeta_wobble_large_y",
    expression = "frozeta_detail_noise{seed1 = 1020, scale = 1/2, octaves = 2, magnitude = 50}"
  },
  {
    type = "noise-expression",
    name = "frozeta_wobble_huge_x",
    expression = "frozeta_detail_noise{seed1 = 30, scale = 2, octaves = 2, magnitude = 800}"
  },
  {
    type = "noise-expression",
    name = "frozeta_wobble_huge_y",
    expression = "frozeta_detail_noise{seed1 = 1030, scale = 2, octaves = 2, magnitude = 800}"
  },

  {
    type = "noise-expression",
    name = "frozeta_mountain_basis_noise",
    expression = "basis_noise{x = x,\z
                              y = y,\z
                              seed0 = map_seed,\z
                              seed1 = 13423,\z
                              input_scale = 1 / 500,\z
                              output_scale = 250}"
  },
  {
    type = "noise-expression",
    name = "frozeta_mountain_plasma",
    expression = "frozeta_plasma(102, 2.5, 10, 125, 625)"
  },
  {
    type = "noise-expression",
    name = "frozeta_mountain_elevation",
    expression = "lerp(max(clamp(frozeta_mountain_plasma, -100, 10000), frozeta_mountain_basis_noise),\z
                       frozeta_mountain_plasma,\z
                       clamp(0.7 * frozeta_mountain_basis_noise, 0, 1))\z
                  * (1 - clamp(frozeta_plasma(13, 2.5, 10, 0.15, 0.75), 0, 1))",
  },
  {
    type = "noise-expression",
    name = "frozeta_mountain_lava_spots",
    expression = "clamp(frozeta_threshold(frozeta_mountain_volcano_spots * 1.95 - 0.95,\z
                                           0.4 * clamp(frozeta_threshold(frozeta_mountains_biome, 0.5), 0, 1))\z
                                           * frozeta_threshold(clamp(frozeta_plasma(17453, 0.2, 0.4, 10, 20) / 20, 0, 1), 1.8),\z
                        0, 1)"
  },
  {
    type = "noise-function",
    name = "volcano_inverted_peak",
    parameters = {"spot", "inversion_point"},
    expression = "(inversion_point - abs(spot - inversion_point)) / inversion_point"
  },
  {
    type = "noise-expression",
    name = "frozeta_mountains_func",
    expression = "lerp(frozeta_mountain_elevation, 700 * volcano_inverted_peak(frozeta_mountain_volcano_spots, 0.65), clamp(frozeta_mountain_volcano_spots * 3, 0, 1))\z
     + 200 * (aux - 0.5) * (frozeta_mountain_volcano_spots + 0.5)"
  },
  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_func",
    expression = "300 + 0.001 * min(basis_noise{x = x,\z
                                                y = y,\z
                                                seed0 = map_seed,\z
                                                seed1 = 12643,\z
                                                input_scale = frozeta_scale_multiplier / 50 / scale,\z
                                                output_scale = 150},\z
                                    basis_noise{x = x,\z
                                                y = y,\z
                                                seed0 = map_seed,\z
                                                seed1 = 12643,\z
                                                input_scale = frozeta_scale_multiplier / 50 / scale,\z
                                                output_scale = 150})",
    local_expressions = {scale = 3}
  },
  {
    type = "noise-expression",
    name = "frozeta_hairline_cracks",
    expression = "frozeta_plasma(15223, 0.3 * frozeta_cracks_scale, 0.6 * frozeta_cracks_scale, 0.6, 1)"
  },
  {
    type = "noise-expression",
    name = "frozeta_flood_cracks_a",
    expression = "lerp(min(frozeta_plasma(7543, 2.5 * frozeta_cracks_scale, 4 * frozeta_cracks_scale, 0.5, 1),\z
                           frozeta_plasma(7443, 1.5 * frozeta_cracks_scale, 3.5 * frozeta_cracks_scale, 0.5, 1)),\z
                       1,\z
                       clamp(frozeta_detail_noise(241, 2 * frozeta_cracks_scale, 2, 0.25), 0, 1))"
  },
  {
    type = "noise-expression",
    name = "frozeta_flood_cracks_b",
    expression = "lerp(1,\z
                       min(frozeta_plasma(12223, 2 * frozeta_cracks_scale, 3 * frozeta_cracks_scale, 0.5, 1),\z
                           frozeta_plasma(152, 1 * frozeta_cracks_scale, 1.5 * frozeta_cracks_scale, 0.25, 0.5)) - 0.5,\z
                       clamp(0.2 + frozeta_detail_noise(821, 6 * frozeta_cracks_scale, 2, 0.5), 0, 1))"
  },
  {
    type = "noise-expression",
    name = "frozeta_flood_paths",
    -- make paths through the lava cracks, get walkable areas above 0, the first value is the path height
    expression = "0.4\z
                  - frozeta_plasma(1543, 1.5 * frozeta_cracks_scale, 3 * frozeta_cracks_scale, 0.5, 1)\z
                  + min(0, frozeta_detail_noise(121, frozeta_cracks_scale * 4, 2, 0.5))",
  },
  {
    type = "noise-expression",
    name = "frozeta_flood_basalts_func",
    -- add hairline cracks to break up edges, crop hearilyie cracks peaks so it is more of a plates + cracks pattern
    -- lava level should be 0 and below, solid ground above 0
    expression = "min(max(frozeta_flood_cracks_a - 0.125, frozeta_flood_paths), frozeta_flood_cracks_b) + 0.3 * min(0.5, frozeta_hairline_cracks)"
  },

  {
    type = "noise-expression",
    name = "frozeta_elevation_offset",
    expression = "0"
  },
  {
    type = "noise-function",
    name = "frozeta_biome_blend",
    parameters = {"fade", "noise", "offset"},
    expression = "fade * (noise - offset)"
  },
  {
    type = "noise-expression",
    name = "frozeta_elev",
    expression = "frozeta_elevation_offset\z
                  + lerp(lerp(120 * frozeta_basalt_lakes_multisample,\z
                              20 + frozeta_mountains_func * frozeta_mountains_elevation_multiplier,\z
                              frozeta_mountains_biome),\z
                         frozeta_dark_frozen_func,\z
                         frozeta_dark_frozen_biome)",
    local_expressions =
    {
      frozeta_basalt_lakes_multisample = "min(multisample(frozeta_basalt_lakes, 0, 0),\z
                                               multisample(frozeta_basalt_lakes, 1, 0),\z
                                               multisample(frozeta_basalt_lakes, 0, 1),\z
                                               multisample(frozeta_basalt_lakes, 1, 1))"
    }
  },
  {
    type = "noise-expression",
    name = "frozeta_basalt_lakes",
    expression = "min(1,\z
                      -0.2 + frozeta_flood_basalts_func\z
                      - 0.35 * clamp(frozeta_contrast(frozeta_detail_noise(837, 1/40, 4, 1.25), 0.95)\z
                                     * frozeta_contrast(frozeta_detail_noise(234, 1/50, 4, 1), 0.95)\z
                                     * frozeta_detail_noise(643, 1/70, 4, 0.7),\z
                                     0, 3))"
  },

  ---- RESOURCES


  {
    type = "noise-expression",
    name = "frozeta_resource_wobble_x",
    expression = "frozeta_wobble_x + 0.25 * frozeta_wobble_large_x"
  },
  {
    type = "noise-expression",
    name = "frozeta_resource_wobble_y",
    expression = "frozeta_wobble_y + 0.25 * frozeta_wobble_large_y"
  },
  {
    type = "noise-expression",
    name = "frozeta_starting_spaceship_scrap", -- don't use the slider for radius becuase it can make scrap in the safe area
    expression = "starting_spot_at_angle{ angle = frozeta_basalts_angle - 10 * frozeta_starting_direction,\z
                                          distance = 450 * frozeta_starting_area_radius,\z
                                          radius = 30 / 1.5,\z
                                          x_distortion = 0.5 * frozeta_resource_wobble_x,\z
                                          y_distortion = 0.5 * frozeta_resource_wobble_y}"
  },


 
  {
    type = "noise-function",
    name = "frozeta_spot_noise",
    parameters = {"seed", "count", "spacing", "span", "offset", "region_size", "density", "quantity", "radius", "favorability"},
    expression = "spot_noise{x = x + frozeta_resource_wobble_x,\z
                             y = y + frozeta_resource_wobble_y,\z
                             seed0 = map_seed,\z
                             seed1 = seed,\z
                             candidate_spot_count = count,\z
                             suggested_minimum_candidate_point_spacing = 128,\z
                             skip_span = span,\z
                             skip_offset = offset,\z
                             region_size = region_size,\z
                             density_expression = density,\z
                             spot_quantity_expression = quantity,\z
                             spot_radius_expression = radius,\z
                             hard_region_target_quantity = 0,\z
                             spot_favorability_expression = favorability,\z
                             basement_value = -1,\z
                             maximum_spot_basement_radius = 128}"
  },
  {
    type = "noise-expression",
    name = "frozeta_basalts_resource_favorability",
    expression = "clamp(((frozeta_basalts_biome_full * (frozeta_starting_area < 0.01)) - buffer) * contrast, 0, 1)",
    local_expressions =
    {
      buffer = 0.3, -- push ores away from biome edges.
      contrast = 2
    }
  },
  {
    type = "noise-expression",
    name = "frozeta_mountains_resource_favorability",
    expression = "clamp(main_region - (frozeta_mountain_volcano_spots > 0.78), 0, 1)",
    local_expressions =
    {
      buffer = 0.4, -- push ores away from biome edges.
      contrast = 2,
      main_region = "clamp(((frozeta_mountains_biome_full * (frozeta_starting_area < 0.01)) - buffer) * contrast, 0, 1)"
    }
  },

  {
    type = "noise-expression",
    name = "frozeta_dark_frozen_resource_favorability",
    expression = "clamp(((frozeta_dark_frozen_biome_full * (frozeta_starting_area < 0.01)) - buffer) * contrast, 0, 1)",
    local_expressions =
    {
      buffer = 0.3, -- push ores away from biome edges.
      contrast = 2
    }
  },
  {
    type = "noise-function",
    name = "frozeta_place_metal_spots",
    parameters = {"seed", "count", "offset", "size", "freq", "favor_biome"},
    expression = "min(clamp(-1 + 4 * favor_biome, -1, 1), metal_spot_noise - frozeta_hairline_cracks / 30000)",
    local_expressions =
    {
      metal_spot_noise = "frozeta_spot_noise{seed = seed,\z
                                              count = count,\z
                                              spacing = frozeta_ore_spacing,\z
                                              span = 3,\z
                                              offset = offset,\z
                                              region_size = 500 + 500 / freq,\z
                                              density = favor_biome * 4,\z
                                              quantity = size * size,\z
                                              radius = size,\z
                                              favorability = favor_biome > 0.9}"
    }
  },

  {
    type = "noise-function",
    name = "frozeta_place_non_metal_spots",
    parameters = {"seed", "count", "offset", "size", "freq", "favor_biome"},
    expression = "min(2 * favor_biome - 1, frozeta_spot_noise{seed = seed,\z
                                                               count = count,\z
                                                               spacing = frozeta_ore_spacing,\z
                                                               span = 3,\z
                                                               offset = offset,\z
                                                               region_size = 400 + 400 / freq,\z
                                                               density = favor_biome * 4,\z
                                                               quantity = size * size,\z
                                                               radius = size,\z
                                                               favorability = favor_biome > 0.9})"
  },

  {
    type = "noise-expression",
    name = "frozeta_spaceship_scrap_size",
    expression = "slider_rescale(control:spaceship_scrap:size, 2)"
  },
  {
    type = "noise-expression",
    name = "frozeta_spaceship_scrap_region",
    -- -1 to 1: needs a positive region for resources & decoratives plus a subzero baseline and skirt for surrounding decoratives.
    expression = "max(frozeta_starting_spaceship_scrap,\z
                      min(1 - frozeta_starting_circle,\z
                          frozeta_place_metal_spots(612, 20, 2,\z
                                                     frozeta_spaceship_scrap_size * min(1.2, frozeta_ore_dist) * 25,\z
                                                     control:spaceship_scrap:frequency,\z
                                                     frozeta_basalts_resource_favorability)))"
  },
  

  {
    type = "noise-expression",
    name = "frozeta_spaceship_scrap_probability",
    expression = "(control:spaceship_scrap:size > 0) * (1700 * ((1 + frozeta_spaceship_scrap_region) * random_penalty_between(0.9, 1, 1) - 0.7))"
  },

  {
    type = "noise-expression",
    name = "frozeta_spaceship_scrap_richness",
    expression = "frozeta_spaceship_scrap_region * random_penalty_between(0.9, 1, 1)\z
                  * 10000 * frozeta_starting_area_multiplier\z
                  * control:spaceship_scrap:richness / frozeta_spaceship_scrap_size"
  },






  {
    type = "noise-expression",
    name = "frozeta_ore_dist",
    expression = "max(1, distance / 2900)"
  },

  -- DECORATIVES - Inherited from Vulcanus. TODO REFINE.
  {
    type = "noise-expression",
    name = "frozeta_decorative_knockout", -- small wavelength noise (5 tiles-ish) to make decoratives patchy
    expression = "multioctave_noise{x = x, y = y, persistence = 0.7, seed0 = map_seed, seed1 = 1300000, octaves = 2, input_scale = 1/3}"
  },

  {
    type = "noise-expression",
    name = "frozeta_rock_noise",
    expression = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    seed0 = map_seed,\z
                                    seed1 = 137,\z
                                    octaves = 4,\z
                                    persistence = 0.65,\z
                                    input_scale = 0.1,\z
                                    output_scale = 0.4}"
    -- 0.1 / slider_rescale(var('control:rocks:frequency'), 2),\z
  },

--[[
  {
    type = "noise-expression",
    name = "frozeta_tree",
    expression = "min(10 * (frozeta_dark_frozen_biome - 0.9),\z
                      -1.5 + 1.5 * moisture + 0.5 * (moisture > 0.9) - 0.5 * aux + 0.5 * frozeta_decorative_knockout)"
  }
--]]
}

