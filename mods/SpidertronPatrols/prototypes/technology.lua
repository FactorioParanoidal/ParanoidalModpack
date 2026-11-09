local spiderling_tech = {
  type = "technology",
  name = "sp-spiderling",
  icon = "__SpidertronPatrols__/graphics/technology/spiderling.png",  -- 55% scaled tech icon
  icon_size = 256,
  effects = {
    {
      type = "unlock-recipe",
      recipe = "sp-spiderling"
    },
  },
  prerequisites = {
    "power-armor",
    "exoskeleton-equipment",
    "efficiency-module-2",
    "low-density-structure",
    "military-3",
    "rocketry",
    "radar",
  },
  unit = {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
  },
    time = 30
  }
}
if mods["space-age"] then
  table.insert(spiderling_tech.unit.ingredients, {"space-science-pack", 1})
end

local patrol_tech = {
  type = "technology",
  name = "sp-spidertron-automation",
  localised_name = {"technology-name.sp-spidertron-automation", SPIDERTRON_NAME_CAPITALISED},
  localised_description = {"technology-description.sp-spidertron-automation", SPIDERTRON_NAME},
  icon = "__SpidertronPatrols__/graphics/technology/spidertron-automation.png",
  icon_size = 256,
  effects = {
    {
      type = "unlock-recipe",
      recipe = "sp-spidertron-dock"
    },
  },
  prerequisites = {
    "sp-spiderling",
    "automated-rail-transportation",
    "bulk-inserter",
  },
  unit = {
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
    },
    time = 30
  }
}
if mods["space-age"] then
  table.insert(patrol_tech.unit.ingredients, {"space-science-pack", 1})
end

-- Modify the above if some features are disabled
local spiderling_enabled = settings.startup["sp-enable-spiderling"].value
local dock_enabled = settings.startup["sp-enable-dock"].value
if not spiderling_enabled then
  if mods["space-age"] then
    patrol_tech.prerequisites = {"space-science-pack", "automated-rail-transportation", "bulk-inserter"}
  else
    patrol_tech.prerequisites = {"chemical-science-pack", "automated-rail-transportation", "bulk-inserter"}
  end
end

if spiderling_enabled then
  data:extend{spiderling_tech}
end
if dock_enabled then
  data:extend{patrol_tech}
end


if spiderling_enabled then
  -- Add spiderling, remove exoskeleton and rocketry from spidertron prereqs because they are covered in spiderling
  local spidertron_tech = data.raw.technology.spidertron
  spidertron_tech.prerequisites = {
    "sp-spiderling",  -- Added
    "military-4",
    --"exoskeleton-equipment",
    "fission-reactor-equipment",
    --"rocketry",
    "efficiency-module-3"
  }
  if mods["space-age"] then
    table.insert(spidertron_tech.prerequisites, "rocket-turret")
  end
end