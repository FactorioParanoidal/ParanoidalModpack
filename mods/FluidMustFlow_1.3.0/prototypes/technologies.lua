local effects = {
  {
    type = "unlock-recipe",
    recipe = "duct-small",
  },
  {
    type = "unlock-recipe",
    recipe = "duct-t-junction",
  },
  {
    type = "unlock-recipe",
    recipe = "duct-curve",
  },
  {
    type = "unlock-recipe",
    recipe = "duct-cross",
  },
  {
    type = "unlock-recipe",
    recipe = "duct-underground",
  },
  {
    type = "unlock-recipe",
    recipe = "non-return-duct",
  },
  {
    type = "unlock-recipe",
    recipe = "duct-end-point-intake",
  },
  {
    type = "unlock-recipe",
    recipe = "duct-end-point-outtake",
  },
}

if not settings.startup["fmf-enable-duct-auto-join"].value then
  table.insert(effects, {
    type = "unlock-recipe",
    recipe = "duct",
  })
  table.insert(effects, {
    type = "unlock-recipe",
    recipe = "duct-long",
  })
end

--- Gets the first technology that unlocks the given recipe
--- @param recipe_name string
--- @return string
local function get_recipe_tech(recipe_name)
  for name, technology in pairs(data.raw.technology) do
    if technology.enabled ~= false and technology.effects then
      for _, effect in pairs(technology.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
          return name
        end
      end
    end
  end
end

local prerequisites = {}
local chemical_science_pack = get_recipe_tech("chemical-science-pack")
local pseudo_fluid_handling = get_recipe_tech("pump")
if chemical_science_pack then
  table.insert(prerequisites, chemical_science_pack)
end
if pseudo_fluid_handling then
  table.insert(prerequisites, pseudo_fluid_handling)
end

data:extend({
  {
    type = "technology",
    -- WHY IS THIS CAPITALIZED!?!?!?!?!?!
    name = "Ducts",
    icon_size = 128,
    icon = "__FluidMustFlow__/graphics/icon/technologies/iron_duct_tecnology.png",
    upgrade = false,
    effects = effects,
    prerequisites = prerequisites,
    unit = {
      count = 30,
      ingredients = {
        { "automation-science-pack", 2 },
        { "logistic-science-pack", 2 },
        { "chemical-science-pack", 1 },
      },
      time = 20,
    },
  },
})
