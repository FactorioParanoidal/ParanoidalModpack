--Taken from space-age base-data-updates.lua. Using Aquilo as a template.
data.raw.planet["frozeta"].platform_surface_render_parameters = util.table.deepcopy(data.raw.planet["nauvis"].platform_surface_render_parameters)
-- Need to have surface render parameters, otherwise we access a nil value when we try to define a backdrop
data.raw.planet["frozeta"].platform_surface_render_parameters.platform_backdrop =
{
  emission_scales_with_shadow = false,
  radius = data.raw.planet["nauvis"].platform_surface_render_parameters.platform_backdrop.radius * 1.25,
  rotation_seconds = data.raw.planet["nauvis"].platform_surface_render_parameters.platform_backdrop.rotation_seconds / 0.45,
  light_radius = data.raw.planet["nauvis"].platform_surface_render_parameters.platform_backdrop.light_radius * 0.6,
  cloudiness = 0.01,
  surface_vertical_offset = 0.08,
  cloud_vertical_offset = 0.01,
  atmosphere_color = {0.075, 0.065, 0.133, 0.1},
  specular_color = {0.55, 0.43, 0.62, 1.0},
  specular_intensity = 1,
  atmosphere_ray_light_color_1 = {0.2, 0.25665, 0.3, 1.0},
  atmosphere_ray_light_color_2 = {0.1, 0.08431, 0.05059, 1.0},
  cloud_flow_intensity = 0.8,
  cloud_panning_rate = 0.2,
  light_intensity_contrast = 0.3,
  planet_axis = {-33.0, -3.0},
  planet_axis_deviation_amplitude = {10.0, 10.0},
  planet_axis_deviation_seconds = {890.5/0.45, 753.7/0.45},
  position = {-680, 601},
  parallax_strength = {0.95, 0.95},
  light_direction = {-0.42, 0.23, 0.67},
  planet_surface =
  {
    filename = "__secretas__/graphics/space/frozeta.png",
    width = 2048,
    height = 1024
  },
  planet_reflectivity =
  {
    filename = "__space-age__/graphics/space/aquilo-reflectivity.png",
    width = 2048,
    height = 1024
  },
  planet_normal = nil,
  global_cloud =
  {
    filename = "__space-age__/graphics/space/aquilo-cloud.png",
    width = 2048,
    height = 1024
  },
  global_cloud_normal =
  {
    filename = "__space-age__/graphics/space/aquilo-cloud-normal.png",
    width = 2048,
    height = 1024
  },
  global_cloud_flow =
  {
    filename = "__space-age__/graphics/space/aquilo-cloud-flow.png",
    width = 2048,
    height = 1024
  }
}

location_type = "space-location"
if ((mods["dea-dia-system"] == false or mods["dea-dia-system"] == nil) or settings.startup["ignore-dea-dia-compatibility"].value == true ) then

    location_type = "space-location"

end

if (mods["dea-dia-system"] and settings.startup["ignore-dea-dia-compatibility"].value == false) then

    location_type = "planet"

end

data.raw[location_type]["secretas"].platform_surface_render_parameters = util.table.deepcopy(data.raw.planet["nauvis"].platform_surface_render_parameters)
data.raw[location_type]["secretas"].platform_surface_render_parameters.platform_backdrop =
{
  emission_scales_with_shadow = false,
  radius = 2000,
  rotation_seconds = data.raw.planet["nauvis"].platform_surface_render_parameters.platform_backdrop.rotation_seconds * 2 / 4.66,
  light_radius = data.raw.planet["nauvis"].platform_surface_render_parameters.platform_backdrop.light_radius * 1.5,
  cloudiness = 0.9,
  surface_vertical_offset = 0.12,
  cloud_vertical_offset = 0.05,
  specular_intensity = 0,
  atmosphere_color = {0.072, 0.073, 0.097, 0.1},
  cloud_flow_intensity = 0.8,
  cloud_panning_rate = 0.2,
  planet_axis = {3.0, 13.0},
  planet_axis_deviation_amplitude = {10.0, 10.0},
  planet_axis_deviation_seconds = {890.5*2/4.66, 753.7*2/4.66},
  position = {-880, 801},
  parallax_strength = {0.95, 0.95},
  light_direction = {-0.42, 0.23, 0.67},
  light_intensity_contrast = 0.3,
  planet_surface =
  {
    filename = "__space-age__/graphics/space/aquilo.png",
    width = 2048,
    height = 1024
  },
  planet_normal = nil,
  global_cloud =
  {
    filename = "__secretas__/graphics/space/secretas-cloud.png",
    width = 2048,
    height = 1024
  },
  global_cloud_normal =
  {
    filename = "__space-age__/graphics/space/aquilo-cloud-normal.png",
    width = 2048,
    height = 1024
  },
  global_cloud_flow =
  {
    filename = "__space-age__/graphics/space/aquilo-cloud-flow.png",
    width = 2048,
    height = 1024
  }
}