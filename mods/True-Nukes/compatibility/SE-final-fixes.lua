
local basic = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"se-rocket-science-pack", 1}
}
local space = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"se-rocket-science-pack", 1},
  {"space-science-pack", 1},
}
local no_prod = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"se-rocket-science-pack", 1},
  {"space-science-pack", 1},
  {"utility-science-pack", 1},
}
local no_util = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"se-rocket-science-pack", 1},
  {"space-science-pack", 1},
  {"production-science-pack", 1},
}
local expensive = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"se-rocket-science-pack", 1},
  {"space-science-pack", 1},
  {"production-science-pack", 1},
  {"utility-science-pack", 1},
}
local energy = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"se-rocket-science-pack", 1},
  {"space-science-pack", 1},
  {"utility-science-pack", 1},
  {"se-energy-science-pack-1", 1},
}

local hasSmall = settings.startup["enable-small-atomics"].value
local hasCompactSmall = settings.startup["enable-compact-small-atomics"].value and hasSmall

local hasMedium = settings.startup["enable-medium-atomics"].value 
local hasCompactMedium = settings.startup["enable-compact-medium-atomics"].value and hasMedium

local hasLarge = settings.startup["enable-large-atomics"].value 
local hasCompactLarge = settings.startup["enable-compact-large-atomics"].value and hasLarge

local has15kt = settings.startup["enable-15kt"].value 
local hasCompact15kt = settings.startup["enable-compact-15kt"].value and has15kt

local hasFusion = settings.startup["enable-fusion"].value 
local hasCompactFusion = settings.startup["enable-compact-fusion"].value and hasFusion

data.raw.technology["basic-atomic-weapons"].unit.ingredients = basic

if(hasMedium and settings.startup["enable-nuclear-tests"].value) then
  data.raw.technology["atomic-bomb"].unit.ingredients = {{"test-pack-atomic-20t-1", 1}}
  data.raw.technology["atomic-bomb"].unit.count = 1
  data.raw.technology["atomic-bomb"].unit.time = 1
else
  data.raw.technology["atomic-bomb"].unit.ingredients = basic
end


if(data.raw.technology["expanded-atomics"]) then
  data.raw.technology["expanded-atomics"].unit.ingredients = space
  if(data.raw.technology["kovarex-enrichment-process"] and data.raw.technology["kovarex-enrichment-process"].enabled) then
    data.raw.technology["expanded-atomics"].prerequisites = {"atomic-bomb", "nuclear-fuel-reprocessing", "space-science-pack"}
  end
end

if(settings.startup["enable-large-atomics"].value) then
  data.raw.technology["full-fission-atomics"].unit = {
    count = 250,
    ingredients = space,
    time = 45
  }
  if(settings.startup["enable-nuclear-tests"].value) then
    data.raw.technology["full-fission-atomics"].unit =
      {
        count = 1,
        ingredients = {{"test-pack-atomic-500t-1", 1}},
        time = 1
      }
  end
end
if(data.raw.technology["artillery-atomics"]) then
  data.raw.technology["artillery-atomics"].unit.ingredients = no_util
  if(data.raw.technology["kovarex-enrichment-process"] and data.raw.technology["kovarex-enrichment-process"].enabled) then
    table.insert(data.raw.technology["artillery-atomics"].prerequisites, "kovarex-enrichment-process")
  end
end
if(data.raw.technology["californium-processing"]) then
  data.raw.technology["californium-processing"].unit.ingredients = {
    {"automation-science-pack", 2},
    {"logistic-science-pack", 2},
    {"chemical-science-pack", 1},
    {"se-rocket-science-pack", 1},
    {"space-science-pack", 1},
    {"production-science-pack", 1},
  }
end
if(data.raw.technology["californium-weapons"]) then
  data.raw.technology["californium-weapons"].unit.ingredients = no_prod

end
if(data.raw.technology["compact-californium-weapons"]) then
  data.raw.technology["compact-californium-weapons"].unit.ingredients = expensive
end
if(data.raw.technology["compact-full-fission-weapons"]) then
  data.raw.technology["compact-full-fission-weapons"].unit.ingredients = {}
  if(settings.startup["enable-nuclear-tests"].value) then
    if(settings.startup["enable-15kt"].value) then
      table.insert(data.raw.technology["compact-full-fission-weapons"].unit.ingredients, {"test-pack-atomic-15kt-1", 1})
    else
      table.insert(data.raw.technology["compact-full-fission-weapons"].unit.ingredients, {"test-pack-atomic-1kt-1", 1})
    end
    if(settings.startup["enable-compact-medium-atomics"].value or settings.startup["enable-compact-small-atomics"].value) then
      table.insert(data.raw.technology["compact-full-fission-weapons"].unit.ingredients, {"test-pack-atomic-20t-3", 1})
    end
  end
  if not next(data.raw.technology["compact-full-fission-weapons"].unit.ingredients[1]) then
    data.raw.technology["compact-full-fission-weapons"].unit = {
      count = 200,
      ingredients = energy,
      time = 60
    }
  end
end

if(hasFusion) then
  data.raw.technology["fusion-weapons"].unit = {
    count = 500,
    ingredients = energy,
    time = 60
  }
end
if(hasCompactFusion) then
  data.raw.technology["compact-fusion-weapons"].unit = {
    count = 500,
    ingredients = energy,
    time = 60
  }
  if(settings.startup["enable-nuclear-tests"].value) then
    data.raw.technology["compact-fusion-weapons"].unit =
      {
        count = 1,
        ingredients = {{"test-pack-atomic-2-stage-100kt-1", 1}},
        time = 1
      }
  end
end

if(hasCompactSmall or hasCompactMedium or
  settings.startup["enable-compact-large-atomics"].value or settings.startup["enable-compact-15kt"].value) then
  data.raw.technology["dense-neutron-flux"].unit = {
    count = 500,
    ingredients = energy,
    time = 60
  }
end












