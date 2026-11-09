-- Adds circuit connection definitions for maraxsis entities to the pre-existing global table
-- for base-game implementation details, see https://github.com/wube/factorio-data/blob/ed3d12197fbbe63fcd19c0eb23bc826cea44410f/core/lualib/circuit-connector-sprites.lua#L101
-- variation counts from 0 (Python-like).

circuit_connector_definitions["maraxsis-hydro-plant"] = circuit_connector_definitions.create_vector(
    universal_connector_template,
    { --Directions are up, right, down, left.
        {variation = 11, main_offset = util.by_pixel(48, 26), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
        {variation = 11, main_offset = util.by_pixel(48, 26), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
        {variation = 11, main_offset = util.by_pixel(48, 26), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
        {variation = 11, main_offset = util.by_pixel(48, 26), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
    }
)

circuit_connector_definitions["maraxsis-sonar"] = circuit_connector_definitions.create_single(
    universal_connector_template,
    {variation = 29, main_offset = util.by_pixel(-91, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = false}
)

circuit_connector_definitions["maraxsis-regulator"] = circuit_connector_definitions.create_single(
    universal_connector_template,
    {variation = 1, main_offset = util.by_pixel(58, -58), shadow_offset = util.by_pixel(0, 0), show_shadow = false}
)
