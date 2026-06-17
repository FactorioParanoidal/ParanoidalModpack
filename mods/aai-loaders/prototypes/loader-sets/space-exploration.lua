AAILoaders.make_tier{
  name = "se-space",
  transport_belt = "se-space-transport-belt",
  color = {255, 255, 255},
  fluid = "lubricant",
  fluid_per_minute = "0.2",
  technology = {
    prerequisites = {"se-space-platform-scaffold", "aai-fast-loader"},
    unit = {
      count = 300,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "se-rocket-science-pack", 1 },
        { "space-science-pack", 1 },
      },
      time = 60
    }
  },
  recipe = {
    crafting_category = "space-crafting",
    ingredients = {
      {type = "item", name = "se-space-transport-belt", amount = 1},
      {type = "item", name = "low-density-structure", amount = 5},
      {type = "item", name = "electric-engine-unit", amount = 5},
      {type = "item", name = "processing-unit", amount = 5},
      {type="fluid", name="lubricant", amount=50}
    },
    energy_required = 10 -- longer crafting time, to match other space entities
  },
  unlubricated_recipe = {
    crafting_category = "space-crafting",
    ingredients = {
      {type = "item", name = "se-space-transport-belt", amount = 1},
      {type = "item", name = "low-density-structure", amount = 50},
      {type = "item", name = "electric-engine-unit", amount = 50},
      {type = "item", name = "processing-unit", amount = 50},
      {type="fluid", name="lubricant", amount = 500}
    },
    energy_required = 50 -- longer crafting time, to match other space entities
  },
  se_allow_in_space = true,
  next_upgrade = "aai-se-deep-space-black-loader"
}

local deep_space_variants = {
  black   = {r=0.1, g=0.1, b=0.1},
  blue    = {r=0, g=0, b=1},
  cyan    = {r=0, g=1, b=1},
  green   = {r=0, g=1, b=0},
  magenta = {r=1, g=0, b=1},
  red     = {r=1, g=0, b=0},
  white   = {r=1, g=1, b=1},
  yellow  = {r=1, g=1, b=0},
}
local black_recipe = {
  crafting_category = "space-crafting",
  ingredients = {
    {type = "item", name = "se-deep-space-transport-belt-black", amount = 1},
    {type = "item", name = "se-nanomaterial", amount = 5},
    {type = "item", name = "se-heavy-assembly", amount = 5},
    {type = "item", name = "se-quantum-processor", amount = 1},
    {type = "item", name = "se-naquium-cube", amount = 1},
    {type="fluid", name="lubricant", amount = 100}
  },
  energy_required = 10 -- longer crafting time, to match other space entities
}
local black_unlubricated_recipe = {
  crafting_category = "space-crafting",
  ingredients = {
    {type = "item", name = "se-deep-space-transport-belt-black", amount = 1},
    {type = "item", name = "se-nanomaterial", amount = 50},
    {type = "item", name = "se-heavy-assembly", amount = 50},
    {type = "item", name = "se-quantum-processor", amount = 10},
    {type = "item", name = "se-naquium-cube", amount = 10},
    {type="fluid", name="lubricant", amount = 1000}
  },
  energy_required = 10 -- longer crafting time, to match other space entities
}
local other_recipe = {
  crafting_category = "crafting",
  ingredients = {
    {type = "item", name = "aai-se-deep-space-black-loader", amount = 1},
    {type = "item", name = "small-lamp", amount = 1}
  },
  energy_required = 0.5
}

for variant_name, colour in pairs(deep_space_variants) do
  local setting = settings.startup["se-deep-space-belt-" .. variant_name]
  if variant_name == "black" or (setting and setting.value) then
    AAILoaders.make_tier {
      name = "se-deep-space-" .. variant_name,
      transport_belt = "se-deep-space-transport-belt-" .. variant_name,
      dark = true,
      color = colour,
      fluid = "lubricant",
      fluid_per_minute = "0.25",
      technology = {
        name =  "aai-se-deep-space-loader",
        prerequisites = {"se-deep-space-transport-belt", "aai-se-space-loader"},
        unit = {
          count  = 500,
          ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "se-rocket-science-pack", 1 },
            { "se-astronomic-science-pack-4", 1 },
            { "se-energy-science-pack-4", 1 },
            { "se-material-science-pack-4", 1 },
            { "se-biological-science-pack-4", 1 },
            { "se-deep-space-science-pack-2", 1 },
          },
          time = 60
        }
      },
      recipe = variant_name == "black" and black_recipe or other_recipe,
      unlubricated_recipe = variant_name == "black" and black_unlubricated_recipe or other_recipe,
      se_allow_in_space = true
    }
  end
end
