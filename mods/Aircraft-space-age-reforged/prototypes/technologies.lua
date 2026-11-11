local path = require("shared.aircraft").path .. "graphics/technology/"
local function tech(name, icon, prerequisites, recipes, count, packs, time)
  local effects, ingredients = {}, {}
  for _, recipe in ipairs(recipes) do effects[#effects + 1] = {type = "unlock-recipe", recipe = recipe} end
  for _, pack in ipairs(packs) do ingredients[#ingredients + 1] = {pack, 1} end
  return {
    type = "technology", name = name, icon = path .. icon .. ".png", icon_size = 256,
    prerequisites = prerequisites, effects = effects,
    unit = {count = count, ingredients = ingredients, time = time}, order = "c-h-" .. name
  }
end
local R, G, B, M, P, U, S = "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack"

data:extend({
  tech("advanced-aerodynamics", "advanced_aerodynamics_tech", {"automobilism", "robotics", "chemical-science-pack"}, {}, 350, {R, G, B}, 45),
  tech("gunships", "gunships", {"military-3", "advanced-aerodynamics", "rocketry"}, {"gunship"}, 500, {R, G, B, M}, 60),
  tech("cargo-planes", "cargo-planes", {"advanced-aerodynamics", "military"}, {"cargo-plane"}, 500, {R, G, B}, 30),
  tech("jets", "jets", {"gunships", "explosive-rocketry", "military-4"}, {"jet"}, 1000, {R, G, B, M, P}, 75),
  tech("flying-fortress", "flying-fortress", {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack"}, {"flying-fortress"}, 3000, {R, G, B, M, U, P, S}, 120),
  tech("high-explosive-cannon-shells", "high_explosive_shell_tech", {"artillery"}, {"high-explosive-cannon-shell"}, 350, {R, G, B, M}, 45),
  tech("napalm", "napalm_tech", {"flammables", "flamethrower"}, {"napalm"}, 200, {R, G, B, M}, 20),
  tech("afterburner", "aircraft_afterburner_tech", {"advanced-aerodynamics", "utility-science-pack"}, {"aircraft-afterburner"}, 400, {R, G, B, U}, 45),
  tech("aircraft-energy-shield", "aircraft_energy_shield_tech", {"gunships", "energy-shield-mk2-equipment"}, {"aircraft-energy-shield"}, 400, {R, G, B, M, U}, 45)
})
