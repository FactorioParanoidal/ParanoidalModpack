--local nauvis = data.raw.planet.nauvis.surface_render_parameters.platform_backdrop
local planet_backdrop = {
    planet_surface = {
        filename = "__muluna-graphics__/graphics/planet/Muluna-compressed-half.png",
        --x = 2048,
        --y = 1024,
        width = 4096, --Double the size of vanilla surfaces, because Muluna needs to rely much more on surface detail for planet detail. There's no clouds nor atmosphere on Muluna.
        height = 2048
    },
    planet_normal =
        {
            filename = "__muluna-graphics__/graphics/planet/normal-map-high-intensity.png",
            width = 4096,
            height = 2048
        },
    surface_normal_intensity = 0.2,
        
    --emission_scales_with_shadow = false,
    --rotation_seconds = nauvis.rotation_seconds,
    --planet_axis = nauvis.planet_axis,
    --planet_axis_deviation_amplidude = nauvis.planet_axis_deviation_amplidtude,
    atmosphere_thickness = 0.0,
    atmosphere_color = {0, 0, 0, 0},
    --specular_intensity = 1,
    radius = 400,
    light_radius = 8.9,
    light_intensity_contrast = 0.3,
    rotation_seconds = -660,
    parallax_strength = {1.05, 1.05}, --Slightly higher parallax strength than Nauvis{0.95,0.95} creates a sense of reduced scale
    light_direction = {-0.42, 0.23, 0.67},
    position = {-480, 401},
    flight_approach_speed= 0.5

   
}

return planet_backdrop