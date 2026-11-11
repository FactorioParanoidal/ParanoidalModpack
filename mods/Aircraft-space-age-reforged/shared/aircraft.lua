-- Shared by settings and data: identifiers, geometry and movement have one owner.
local M = { path = "__Aircraft-space-age-reforged__/" }

local function resistance(fire, physical, impact, explosion, acid)
  local names = {"fire", "physical", "impact", "explosion", "acid"}
  local result = {}
  for i, value in ipairs({fire, physical, impact, explosion, acid}) do
    result[i] = {type = names[i], decrease = value[1], percent = value[2]}
  end
  return result
end

M.aircraft = {
  {
    name = "gunship", sheet = "gunship", technology = "gunships", order = "e",
    health = 500, inventory = 30, grid = "gunship-equipment-grid", grid_size = {8, 4},
    guns = {"aircraft-machine-gun", "aircraft-rocket-launcher"},
    weight = 750, wing_area = 2, effectivity = 0.7, power_kw = 650,
    brake_kw = 450, friction = 0.003, rotation = 0.01, fuel_slots = 4,
    impact_energy = 0.5, stop_speed = 0.2, lights = {{-43, -416, 5}, {43, -416, 5}},
    trails = {{-16, 60, 38}, {16, 60, 38}},
    normal = resistance({2, 50}, {2, 30}, {10, 60}, {10, 30}, {60, 20}),
    hard = resistance({0, 25}, {0, 15}, {0, 30}, {0, 15}, {0, 10})
  },
  {
    name = "cargo-plane", sheet = "cargo_plane", technology = "cargo-planes", order = "f",
    health = 500, inventory = 120, guns = {"cargo-plane-machine-gun"},
    weight = 3500, wing_area = 12, effectivity = 1, power_kw = 1250,
    brake_kw = 650, friction = 0.01, rotation = 0.006, fuel_slots = 10,
    impact_energy = 0.5, stop_speed = 0.2, lights = {{0, -416, 8}}, trails = {{0, 40, 36}},
    normal = resistance({2, 50}, {2, 30}, {5, 60}, {2, 30}, {60, 20}),
    hard = resistance({0, 10}, {0, 5}, {0, 5}, {0, 10}, {0, 5})
  },
  {
    name = "jet", sheet = "jet", technology = "jets", order = "g",
    health = 250, inventory = 5, grid = "jet-equipment-grid", grid_size = {8, 4},
    guns = {"aircraft-machine-gun", "aircraft-rocket-launcher", "napalm-launcher"},
    weight = 500, wing_area = 1, effectivity = 0.9, power_kw = 850,
    brake_kw = 2000, friction = 0.001, rotation = 0.01, fuel_slots = 8,
    impact_energy = 0.5, stop_speed = 0.2, lights = {{-22, -416, 5}, {22, -416, 5}},
    trails = {{0, 62, 38}},
    normal = resistance({0, 100}, {0, 30}, {0, 60}, {1, 30}, {60, 20}),
    hard = resistance({0, 25}, {0, 15}, {0, 30}, {0, 15}, {0, 10})
  },
  {
    name = "flying-fortress", sheet = "flying_fortress", technology = "flying-fortress", order = "h",
    health = 2000, inventory = 20, grid = "flying-fortress-equipment-grid", grid_size = {13, 12},
    guns = {"flying-fortress-machine-gun", "aircraft-cannon", "flying-fortress-rocket-launcher"},
    weight = 3000, wing_area = 6, effectivity = 2.3, power_kw = 1850,
    brake_kw = 850, friction = 0.015, rotation = 0.004, fuel_slots = 8,
    impact_energy = 0.8, stop_speed = 0.1, lights = {{-22, -416, 5}, {22, -416, 5}},
    trails = {{0, 65, 38}},
    normal = resistance({0, 100}, {0, 30}, {0, 60}, {1, 30}, {60, 20}),
    hard = resistance({0, 25}, {0, 20}, {0, 35}, {0, 20}, {0, 15})
  }
}

function M.name(spec, carbon)
  return spec.name .. (carbon and "-carbon-fiber" or "")
end

function M.icon(spec, carbon)
  return M.path .. "graphics/icons/" .. (carbon and spec.name .. "_carbon" or spec.sheet) .. "_icon.png"
end

function M.liftoff(spec, carbon)
  -- Preserve AircraftRealism's transition-speed convention (km/h); a gameplay heuristic, not a flight simulator.
  local weight = spec.weight * (carbon and 0.5 or 1)
  return math.sqrt(2 * 8.314472 * 293.15 * weight * 10 / (1.75 * 1000 * spec.wing_area))
end

return M
