local appearance = require("__Warheads__.prototypes.appearance-util")
local nuke_materials = require("data-nukes-material")

specialTechForWarheadWeapon["artillery-shell-atomic-4t"] = "artillery-atomics"
specialTechForWarheadWeapon["artillery-shell-atomic-8t"] = "artillery-atomics"
specialTechForWarheadWeapon["artillery-shell-atomic-20t"] = "artillery-atomics"
specialTechForWarheadWeapon["artillery-shell-atomic-500t"] = "artillery-atomics"
specialTechForWarheadWeapon["artillery-shell-atomic-1kt"] = "artillery-atomics"

specialTechForWarheadWeapon["land-mine-atomic-20t"] = "atomic-bomb"

if(settings.startup["enable-nuclear-tests"].value) then

  if(warheads["TN-warhead-20--1"]) then
    data:extend{
      {
        type = "tool",
        name = "test-pack-atomic-20t-1",
        icons = appearance(warheads["TN-warhead-20--1"]).icons,
        subgroup = "science-pack",
        order = "za[atomic-20t-science-pack]",
        stack_size = 200,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
      }
    }
    generateWarheadAnyway["TN-warhead-20--1"] = true
  end
    
  if(warheads["TN-warhead-500--1"]) then
    data:extend{
      {
        type = "tool",
        name = "test-pack-atomic-500t-1",
        icons = appearance(warheads["TN-warhead-500--1"]).icons,
        subgroup = "science-pack",
        order = "zb[atomic-500t-science-pack]",
        stack_size = 200,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
      }
    }
    generateWarheadAnyway["TN-warhead-500--1"] = true
  end
    
  if(warheads["TN-warhead-20--3"]) then
    data:extend{
      {
        type = "tool",
        name = "test-pack-atomic-20t-3",
        icons = appearance(warheads["TN-warhead-20--3"]).icons,
        subgroup = "science-pack",
        order = "zc[atomic-20t-science-pack]",
        stack_size = 200,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
      }
    }
    generateWarheadAnyway["TN-warhead-20--3"] = true
  end
  
  if(warheads["TN-warhead-1k--1"]) then
    data:extend{
      {
        type = "tool",
        name = "test-pack-atomic-1kt-1",
        icons = appearance(warheads["TN-warhead-1k--1"]).icons,
        subgroup = "science-pack",
        order = "ze[atomic-1kt-science-pack]",
        stack_size = 200,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
      }
    }
    generateWarheadAnyway["TN-warhead-1k--1"] = true
  end
    
  if(warheads["TN-warhead-15k--1"]) then
    data:extend{
      {
        type = "tool",
        name = "test-pack-atomic-15kt-1",
        icons = appearance(warheads["TN-warhead-15k--1"]).icons,
        subgroup = "science-pack",
        order = "zd[atomic-15kt-science-pack]",
        stack_size = 200,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
      }
    }
    generateWarheadAnyway["TN-warhead-15k--1"] = true
  end
    
  if(warheads["TN-warhead-big--1"]) then
    data:extend{
      {
        type = "tool",
        name = "test-pack-atomic-2-stage-100kt-1",
        icons = appearance(warheads["TN-warhead-big--1"].explosions[2]).icons,
        subgroup = "science-pack",
        order = "ze[atomic-100kt-science-pack]",
        stack_size = 200,
        durability = 1,
        durability_description_key = "description.science-pack-remaining-amount-key",
        durability_description_value = "description.science-pack-remaining-amount-value"
      }
    }
    generateWarheadAnyway["TN-warhead-big--1"] = true
  end
end

local standard = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"production-science-pack", 1},
  {"utility-science-pack", 1},
}
local no_prod = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"utility-science-pack", 1},
}
local no_util = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"production-science-pack", 1},
}
local space = {
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1},
  {"production-science-pack", 1},
  {"utility-science-pack", 1},
  {"space-science-pack", 1},
}

if mods["apm_nuclear_ldinc"] then
  table.insert(standard, {"apm_nuclear_science_pack", 1});
  table.insert(no_prod, {"apm_nuclear_science_pack", 1});
  table.insert(no_util, {"apm_nuclear_science_pack", 1});
  table.insert(space, {"apm_nuclear_science_pack", 1});
end

if (not settings.startup["keep-atomic-bomb-without-changes"]) and
  (not settings.startup["enable-compact-medium-atomics"].value) and
  (not settings.startup["enable-medium-atomics"].value) then
  data.raw.technology["atomic-bomb"].effects[1] = nil
end
data.raw.technology["atomic-bomb"].prerequisites = {"basic-atomic-weapons", "rocket-control-unit", "rocket-fuel", "rocketry"}


data.raw.technology["atomic-bomb"].unit.count = 1
if(settings.startup["enable-medium-atomics"].value and settings.startup["enable-nuclear-tests"].value) then
  data.raw.technology["atomic-bomb"].unit.ingredients = {{"test-pack-atomic-20t-1", 1}}
else
  data.raw.technology["atomic-bomb"].unit.ingredients = no_prod
end
data.raw.technology["atomic-bomb"].order = "e-a-c"
data.raw.technology["atomic-bomb"].icon = "__True-Nukes__/graphics/nuke-tech.png"

data:extend{
  {
    type = "technology",
    name = "basic-atomic-weapons",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__True-Nukes__/graphics/nuke-tech-basic.png",
    effects =
    {
      
    },
    prerequisites = {"military-4", "uranium-processing"},
    unit =
    {
      count = 1000,
      ingredients = no_prod,
      time = 45
    },
    order = "e-a-c"
  },
}

if(settings.startup["enable-fire-shield"].value) then
    table.insert(data.raw.technology["basic-atomic-weapons"].effects, {
        type = "unlock-recipe",
        recipe = "fire-shield-equipment"
      })
end


if(settings.startup["enable-large-atomics"].value) then
  data:extend{
    {
      type = "technology",
      name = "expanded-atomics",
      icon_size = 256, icon_mipmaps = 4,
      icon = "__base__/graphics/technology/atomic-bomb.png",
      effects = {},
      prerequisites = {"atomic-bomb", "kovarex-enrichment-process", "production-science-pack"},
      unit =
      {
        count = 2000,
        ingredients = standard,
        time = 45
      },
      order = "e-a-d"
    },
  }
end
if(settings.startup["enable-large-atomics"].value) then
  data:extend{
    {
      type = "technology",
      name = "full-fission-atomics",
      icon_size = 256, icon_mipmaps = 4,
      icon = "__base__/graphics/technology/atomic-bomb.png",
      effects = {},
      prerequisites = {"expanded-atomics"},
      unit =
      {
        count = 250,
        ingredients = no_util,
        time = 45
      },
      order = "e-a-f"
    },
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
if(settings.startup["enable-medium-atomics"].value or settings.startup["enable-large-atomics"].value or settings.startup["enable-compact-15kt"].value) then
  data:extend{
    {
      type = "technology",
      name = "artillery-atomics",
      icon_size = 256, icon_mipmaps = 4,
      icon = "__True-Nukes__/graphics/atomic-artillery-tech.png",
      effects = {},
      prerequisites = {"expanded-atomics", "artillery"},
      unit =
      {
        count = 1000,
        ingredients = no_util,
        time = 60
      },
      order = "e-a-e"
    },
  }
end


if(nuke_materials.smallBoomMaterial == "californium") then
  if(settings.startup["enable-small-atomics"].value or settings.startup["enable-compact-medium-atomics"].value ) then
    data:extend{
      {
        type = "technology",
        name = "californium-processing",
        icon_size = 256, icon_mipmaps = 4,
        icon = "__True-Nukes__/graphics/californium-processing-tech.png",
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "californium-processing"
          },
        },
        prerequisites = {"kovarex-enrichment-process"},
        unit =
        {
          count = 500,
          ingredients = {
            {"automation-science-pack", 2},
            {"logistic-science-pack", 2},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
          },
          time = 30
        },
        order = "e-p-b-d"
      },
      {
        type = "technology",
        name = "californium-weapons",
        icon_size = 256, icon_mipmaps = 4,
        icon = "__True-Nukes__/graphics/small-atomic-tech.png",
        effects = {},
        prerequisites = {"expanded-atomics", "californium-processing"},
        unit =
        {
          count = 500,
          ingredients = no_prod,
          time = 45
        },
        order = "e-a-g"
      },
    }
  elseif settings.startup["enable-compact-large-atomics"].value then
    data:extend{
      {
        type = "technology",
        name = "californium-processing",
        icon_size = 256, icon_mipmaps = 4,
        icon = "__True-Nukes__/graphics/californium-processing-tech.png",
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "californium-processing"
          },
        },
        prerequisites = {"kovarex-enrichment-process"},
        unit =
        {
          count = 500,
          ingredients = {
            {"automation-science-pack", 2},
            {"logistic-science-pack", 2},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
          },
          time = 30
        },
        order = "e-p-b-d"
      },
    }
  end
else
    data:extend{
      {
        type = "technology",
        name = "californium-weapons",
        icon_size = 256, icon_mipmaps = 4,
        icon = "__True-Nukes__/graphics/small-atomic-tech.png",
        effects = {},
        prerequisites = {"expanded-atomics"},
        unit =
        {
          count = 500,
          ingredients = no_prod,
          time = 45
        },
        order = "e-a-g"
      },
    }
end

if(settings.startup["enable-compact-medium-atomics"].value or settings.startup["enable-compact-small-atomics"].value) then
  data:extend{
    {
      type = "technology",
      name = "compact-californium-weapons",
      icon_size = 256, icon_mipmaps = 4,
      icon = "__True-Nukes__/graphics/many-small-atomic-tech.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "neutron-reflector"
        },
      },
      prerequisites = {"californium-weapons"},
      unit =
      {
        count = 1000,
        ingredients = standard,
        time = 45
      },
      order = "e-a-h"
    },
  }

end

if(settings.startup["enable-compact-15kt"].value or settings.startup["enable-compact-large-atomics"].value) then
  data:extend{
    {
      type = "technology",
      name = "compact-full-fission-weapons",
      icon_size = 256, icon_mipmaps = 4,
      icon = "__True-Nukes__/graphics/many-atomic-tech.png",
      effects = {},
      prerequisites = {"full-fission-atomics", "artillery-atomics"},
      unit =
      {
        count = 1,
        ingredients = {},
        time = 1
      },
      order = "e-a-i"
    },
  }
  local canDoTest = true
  if(settings.startup["enable-nuclear-tests"].value) then
    if(settings.startup["enable-15kt"].value) then
      table.insert(data.raw.technology["compact-full-fission-weapons"].unit.ingredients, {"test-pack-atomic-15kt-1", 1})
    elseif(settings.startup["enable-large-atomics"].value)then
      table.insert(data.raw.technology["compact-full-fission-weapons"].unit.ingredients, {"test-pack-atomic-1kt-1", 1})
    else
      canDoTest = false
    end
  end
  if(settings.startup["enable-compact-medium-atomics"].value or settings.startup["enable-compact-small-atomics"].value) then
    table.insert(data.raw.technology["compact-full-fission-weapons"].prerequisites, "compact-californium-weapons")

    if(settings.startup["enable-nuclear-tests"].value and canDoTest) then
      table.insert(data.raw.technology["compact-full-fission-weapons"].unit.ingredients, {"test-pack-atomic-20t-3", 1})
    end
  elseif(settings.startup["enable-compact-medium-atomics"].value or settings.startup["enable-compact-small-atomics"].value or settings.startup["enable-compact-large-atomics"].value) then
    if(nuke_materials.smallBoomMaterial == "californium") then
      table.insert(data.raw.technology["compact-full-fission-weapons"].prerequisites, "californium-processing")
    end
    table.insert(data.raw.technology["compact-full-fission-weapons"].effects, 
      {
        type = "unlock-recipe",
        recipe = "neutron-reflector"
      })
  else
    table.insert(data.raw.technology["compact-full-fission-weapons"].effects, 
      {
        type = "unlock-recipe",
        recipe = "neutron-reflector"
      })
  end

  if not next(data.raw.technology["compact-full-fission-weapons"].unit.ingredients[1]) then
    data.raw.technology["compact-full-fission-weapons"].unit = {
      count = 500,
      ingredients = space,
      time = 60
    }
  end
end
if(settings.startup["enable-fusion"].value or settings.startup["enable-fusion-building"].value) then
  data:extend{
    {
      type = "technology",
      name = "tritium-processing",
      icon_size = 256, icon_mipmaps = 1,
      icon = "__True-Nukes__/graphics/tritium-processing.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "tritium-breeder-fuel-cell"
        },
        {
          type = "unlock-recipe",
          recipe = "tritium-extraction"
        }
      },
      prerequisites = {"nuclear-fuel-reprocessing"},
      unit =
      {
        count = 2000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1}
        },
        time = 45
      },
      order = "e-a-l"
    },
    {
      type = "technology",
      name = "fusion-weapons",
      icon_size = 256, icon_mipmaps = 1,
      icon = "__True-Nukes__/graphics/fusion-bomb.png",
      effects = {
        {
          type = "unlock-recipe",
          recipe = "FOGBANK"
        }
      },
      prerequisites = {"tritium-processing"},
      unit =
      {
        count = 2000,
        ingredients = space,
        time = 45
      },
      order = "e-a-j"
    }
  }
  if(settings.startup["enable-compact-15kt"].value or settings.startup["enable-compact-large-atomics"].value) then
      table.insert(data.raw.technology["fusion-weapons"].prerequisites, "compact-full-fission-weapons")
  else
    if (settings.startup["enable-compact-medium-atomics"].value or settings.startup["enable-compact-small-atomics"].value) then
      table.insert(data.raw.technology["fusion-weapons"].prerequisites, "compact-californium-weapons")
    end
    if (settings.startup["enable-large-atomics"].value) then
      table.insert(data.raw.technology["fusion-weapons"].prerequisites, "full-fission-atomics")
    end
  end
end
if(settings.startup["enable-compact-fusion"].value) then
  data:extend{
    {
      type = "technology",
      name = "compact-fusion-weapons",
      icon_size = 256, icon_mipmaps = 1,
      icon = "__True-Nukes__/graphics/fusion-bomb.png",
      effects = {},
      prerequisites = {"fusion-weapons"},
      unit =
      {
        count = 1000,
        ingredients = space,
        time = 90
      },
      order = "e-a-k"
    }
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

if(settings.startup["enable-compact-small-atomics"].value or settings.startup["enable-compact-medium-atomics"].value or
  settings.startup["enable-compact-large-atomics"].value or settings.startup["enable-compact-15kt"].value) then

  data:extend{
    {
      type = "technology",
      name = "dense-neutron-flux",
      icons = {
        {icon = "__Warheads__/graphics/blank-64.png", icon_size = 64, scale = 1, shift = {0, -0}},
        {icon = "__True-Nukes__/graphics/californium-processing-tech.png", icon_size = 256, scale = 0.125, shift = {12, -12}, icon_mipmaps = 4},
        {icon = "__base__/graphics/technology/kovarex-enrichment-process.png", icon_size = 256, scale = 0.125, shift = {-12, -12}, icon_mipmaps = 4},
        {icon = "__True-Nukes__/graphics/tritium-processing.png", icon_size = 256, scale = 0.125, shift = {0, 16}, icon_mipmaps = 4},
        {icon = "__True-Nukes__/graphics/plus-red.png", icon_size = 32, scale = 0.5, shift = {24, -24}},
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "advanced-kovarex-enrichment-process"
        },
      },
      prerequisites = {},
      unit =
      {
        count = 1000,
        ingredients = standard,
        time = 45
      },
      order = "e-a-h"
    },
  }
  if data.raw.recipe["advanced-californium-processing"] then
    table.insert(data.raw.technology["dense-neutron-flux"].effects, {
      type = "unlock-recipe",
      recipe = "advanced-californium-processing"
    })
  end
  if data.raw.technology["compact-californium-weapons"] then
    table.insert(data.raw.technology["dense-neutron-flux"].prerequisites, "compact-californium-weapons")
  elseif data.raw.technology["compact-full-fission-weapons"] then
    table.insert(data.raw.technology["dense-neutron-flux"].prerequisites, "compact-full-fission-weapons")
  end
  if data.raw.technology["tritium-processing"] then
    table.insert(data.raw.technology["dense-neutron-flux"].prerequisites, "tritium-processing")
    table.insert(data.raw.technology["dense-neutron-flux"].effects, {
      type = "unlock-recipe",
      recipe = "advanced-tritium-breeder-fuel-cell"
    })
    table.insert(data.raw.technology["dense-neutron-flux"].effects, {
      type = "unlock-recipe",
      recipe = "advanced-tritium-extraction"
    })
  end
end
