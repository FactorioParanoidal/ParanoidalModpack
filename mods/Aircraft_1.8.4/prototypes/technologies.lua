local TECHPATH = "__Aircraft__/graphics/technology/"

local function unlock(recipe)
  return {
    type = "unlock-recipe",
    recipe = recipe
  }
end

data:extend({
  { -- Advanced Aerodynamics (base tech)
    type = "technology",
    name = "advanced-aerodynamics",
    icon = TECHPATH .. "advanced_aerodynamics_tech.png",
    icon_size = 256,
    prerequisites = {"automobilism", "robotics"},
    unit = {
      count = 350,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 45
    },
    order = "c-h-b"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Gunship
    type = "technology",
    name = "gunships",
    icon = TECHPATH .. "gunship.png",
    icon_size = 256,
    effects = { unlock("gunship") },
    prerequisites = {"military-3", "advanced-aerodynamics", "rocketry"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 60
    },
    order = "c-h-c"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Cargo Plane
    type = "technology",
    name = "cargo-planes",
    icon = TECHPATH .. "cargo_plane.png",
    icon_size = 256,
    effects = { unlock("cargo-plane") },
    prerequisites = {"advanced-aerodynamics"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "c-h-d"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Jet
    type = "technology",
    name = "jets",
    icon = TECHPATH .. "jet.png",
    icon_size = 256,
    effects = { unlock("jet") },
    prerequisites = {"gunships", "explosive-rocketry", "military-4"},
    unit = {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 75
    },
    order = "c-h-e"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Flying Fortress
    type = "technology",
    name = "flying-fortress",
    icon = TECHPATH .. "flying_fortress.png",
    icon_size = 256,
    effects = { unlock("flying-fortress") },
    prerequisites = {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack"},
    unit = {
      count = 3000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 120
    },
    order = "c-h-f"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- High Explosive Cannon Shells
    type = "technology",
    name = "high-explosive-cannon-shells",
    icon = TECHPATH .. "high_explosive_shell_tech.png",
    icon_size = 256,
    effects = { unlock("high-explosive-cannon-shell") },
    prerequisites = {"artillery"},
    unit = {
      count = 350,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 45
    },
    order = "c-h-g"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Napalm
    type = "technology",
    name = "napalm",
    icon = TECHPATH .. "napalm_tech.png",
    icon_size = 256,
    effects = { unlock("napalm") },
    prerequisites = {"flammables", "jets"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 20,
    },
    order = "c-h-h",
  },
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Afterburner
    type = "technology",
    name = "afterburner",
    icon = TECHPATH .. "aircraft_afterburner_tech.png",
    icon_size = 256,
    effects = { unlock("aircraft-afterburner") },
    prerequisites = {"advanced-aerodynamics"},
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 45,
    },
    order = "c-h-h",
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Aircraft Energy Shield
    type = "technology",
    name = "aircraft-energy-shield",
    icon = TECHPATH .. "aircraft_energy_shield_tech.png",
    icon_size = 256,
    effects = { unlock("aircraft-energy-shield") },
    prerequisites = {"advanced-aerodynamics", "energy-shield-mk2-equipment"},
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 45,
    },
    order = "c-h-i",
    --Hey,   ^^^^^   a lil' easter egg for ya
  },
})