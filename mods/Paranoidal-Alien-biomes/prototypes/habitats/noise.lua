-- All fields are seed/position functions, shared by every component of a habitat.
-- Voronoi centres have ample separation: the crater footprint cannot reach a cell edge
-- with grid 512, jitter 0.5 and an outer radius below 66 tiles.
local function expression(name, value)
  data:extend({{type = "noise-expression", name = name, expression = value}})
end
local function voronoi(kind, seed, grid)
  return string.format("%s{x=x, y=y, seed0=map_seed, seed1=%d, grid_size=%d, distance_type='euclidean', jitter=0.5}", kind, seed, grid)
end
expression("ab_habitat_start_distance", "distance_from_nearest_point{x=x, y=y, points=starting_positions}")
expression("ab_habitat_outside_start", "clamp((ab_habitat_start_distance - max(192, starting_area_radius)) / 64, 0, 1)")
expression("ab_habitat_detail", "basis_noise{x=x, y=y, seed0=map_seed, seed1=87103, input_scale=1/24, output_scale=1}")
expression("ab_habitat_wetland_patch", "clamp(0.4 + basis_noise{x=x, y=y, seed0=map_seed, seed1=87101, input_scale=1/96, output_scale=1}, 0, 1)")
-- This is a lowland band, not a promise of water adjacency at every tile.
expression("ab_habitat_wetland", "ab_habitat_outside_start * clamp((moisture - 0.70) / 0.18, 0, 1) * clamp((elevation - 0.2) / 2, 0, 1) * clamp((12 - elevation) / 8, 0, 1) * (temperature > 5) * (temperature < 85) * ab_habitat_wetland_patch")
-- Relative layers inside that same lowland; elevation is not a shoreline-distance map.
expression("ab_habitat_wetland_edge", "1 - clamp((elevation - 1) / 3, 0, 1)")
expression("ab_habitat_wetland_interior", "clamp((elevation - 1) / 3, 0, 1) * clamp((ab_habitat_wetland_patch - 0.25) / 0.5, 0, 1)")
expression("ab_habitat_outcrop", "ab_habitat_outside_start * clamp((elevation - 2) / 8, 0, 1) * clamp((basis_noise{x=x, y=y, seed0=map_seed, seed1=87102, input_scale=1/80, output_scale=1} - 0.25) * 3, 0, 1) * clamp(0.6 + ab_habitat_detail, 0, 1)")
expression("ab_habitat_crater_cell", voronoi("voronoi_cell_id", 87104, 512))
expression("ab_habitat_crater_distance", "512 * " .. voronoi("voronoi_spot_noise", 87104, 512))
expression("ab_habitat_crater_radius", "24 + 24 * ab_habitat_crater_cell")
expression("ab_habitat_crater", "ab_habitat_outside_start * (ab_habitat_crater_cell > 0.65) * (elevation > 1) * (moisture < 0.65) * (temperature > 0) * (temperature < 100)")
-- Additive ecotones reuse the lowland patch, not independent tree placement.
expression("ab_habitat_wetland_margin", "ab_habitat_outside_start * clamp((moisture - 0.58) / 0.12, 0, 1) * clamp((0.84 - moisture) / 0.12, 0, 1) * clamp((elevation - 1) / 3, 0, 1) * clamp((14 - elevation) / 8, 0, 1) * (temperature > 5) * (temperature < 85) * ab_habitat_wetland_patch")
expression("ab_habitat_dry_margin", "ab_habitat_outside_start * clamp((moisture - 0.24) / 0.10, 0, 1) * clamp((0.58 - moisture) / 0.14, 0, 1) * clamp((elevation - 4) / 4, 0, 1) * clamp((24 - elevation) / 10, 0, 1) * (temperature > 15) * (temperature < 100) * ab_habitat_wetland_patch")
-- Narrow, broken ground marks: neither water tiles nor a drainage simulation.
expression("ab_habitat_silt_band", "clamp(1 - abs(basis_noise{x=x, y=y, seed0=map_seed, seed1=87105, input_scale=1/180, output_scale=1} + 0.2 * ab_habitat_detail) * 8, 0, 1)")
expression("ab_habitat_silt_trace", "ab_habitat_outside_start * clamp((moisture - 0.56) / 0.12, 0, 1) * clamp((0.84 - moisture) / 0.12, 0, 1) * clamp((elevation - 0.4) / 2, 0, 1) * clamp((9 - elevation) / 5, 0, 1) * (temperature > 5) * (temperature < 85) * ab_habitat_wetland_patch * ab_habitat_silt_band")
