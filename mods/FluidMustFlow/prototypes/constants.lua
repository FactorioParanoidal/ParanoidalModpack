return {
  volume = 400,
  extent = 1000,
  duct_circuit_connector = circuit_connector_definitions.create_vector(universal_connector_template, {
    { variation = 0, main_offset = util.by_pixel(5, -18), shadow_offset = util.by_pixel(2, 0), draw_shadow = true },
    { variation = 0, main_offset = util.by_pixel(5, -14), shadow_offset = util.by_pixel(2, 0), draw_shadow = true },
    { variation = 0, main_offset = util.by_pixel(5, -18), shadow_offset = util.by_pixel(2, 0), draw_shadow = true },
    { variation = 0, main_offset = util.by_pixel(5, -14), shadow_offset = util.by_pixel(2, 0), draw_shadow = true },
  }),
}
