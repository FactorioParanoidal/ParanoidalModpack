if not settings.startup["tankplatoon-tank-to-recipe-keep"].value then
  data.raw["recipe"]["tank"].enabled = false
end



data:extend
{
  -- Tanks
  {
    type = "recipe",
    name = "Schall-tank-L",
    normal =
    {
      enabled = false,
      energy_required = 3,
      ingredients =
      {
        {"engine-unit", 16},
        {"steel-plate", 25},
        {"iron-gear-wheel", 8},
        {"advanced-circuit", 5}
      },
      result = "Schall-tank-L"
    },
    expensive =
    {
      enabled = false,
      energy_required = 5,
      ingredients =
      {
        {"engine-unit", 32},
        {"steel-plate", 50},
        {"iron-gear-wheel", 15},
        {"advanced-circuit", 10}
      },
      result = "Schall-tank-L"
    }
  },
  {
    type = "recipe",
    name = "Schall-tank-M",
    normal =
    {
      enabled = false,
      energy_required = 5,
      ingredients =
      {
        {"engine-unit", 32},
        {"steel-plate", 50},
        {"iron-gear-wheel", 15},
        {"advanced-circuit", 10}
      },
      result = "Schall-tank-M"
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {"engine-unit", 64},
        {"steel-plate", 100},
        {"iron-gear-wheel", 30},
        {"advanced-circuit", 20}
      },
      result = "Schall-tank-M"
    }
  },
  {
    type = "recipe",
    name = "Schall-tank-H",
    normal =
    {
      enabled = false,
      energy_required = 20,
      ingredients =
      {
        {"engine-unit", 100},
        {"steel-plate", 150},
        {"iron-gear-wheel", 50},
        {"advanced-circuit", 30}
      },
      result = "Schall-tank-H"
    },
    expensive =
    {
      enabled = false,
      energy_required = 32,
      ingredients =
      {
        {"engine-unit", 200},
        {"steel-plate", 300},
        {"iron-gear-wheel", 100},
        {"advanced-circuit", 60}
      },
      result = "Schall-tank-H"
    }
  },
  {
    type = "recipe",
    name = "Schall-tank-SH",
    normal =
    {
      enabled = false,
      energy_required = 60,
      ingredients =
      {
        {"engine-unit", 300},
        {"steel-plate", 400},
        {"iron-gear-wheel", 120},
        {"advanced-circuit", 80},
        {"military-science-pack", 200}
      },
      result = "Schall-tank-SH"
    },
    expensive =
    {
      enabled = false,
      energy_required = 100,
      ingredients =
      {
        {"engine-unit", 600},
        {"steel-plate", 800},
        {"iron-gear-wheel", 240},
        {"advanced-circuit", 160},
        {"military-science-pack", 400}
      },
      result = "Schall-tank-SH"
    }
  },
  {
    type = "recipe",
    name = "Schall-tank-F",
    normal =
    {
      enabled = false,
      energy_required = 5,
      ingredients =
      {
        {"engine-unit", 32},
        {"steel-plate", 50},
        {"iron-gear-wheel", 15},
        {"advanced-circuit", 10}
      },
      result = "Schall-tank-F"
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {"engine-unit", 64},
        {"steel-plate", 100},
        {"iron-gear-wheel", 30},
        {"advanced-circuit", 20}
      },
      result = "Schall-tank-F"
    }
  },
  -- Rocket Artillery
  {
    type = "recipe",
    name = "Schall-ht-RA",
    normal =
    {
      enabled = false,
      energy_required = 5,
      ingredients =
      {
        {"engine-unit", 32},
        {"steel-plate", 50},
        {"iron-gear-wheel", 15},
        {"advanced-circuit", 10}
      },
      result = "Schall-ht-RA"
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {"engine-unit", 64},
        {"steel-plate", 100},
        {"iron-gear-wheel", 30},
        {"advanced-circuit", 20}
      },
      result = "Schall-ht-RA"
    }
  },
  -- Tanks MK1
  {
    type = "recipe",
    name = "Schall-tank-L-mk1",
    enabled = false,
    energy_required = 6,
    ingredients =
    {
      {"Schall-tank-L", 1},
      {"processing-unit", 30},
      {"electric-engine-unit", 10},
    },
    result = "Schall-tank-L-mk1"
  },
  {
    type = "recipe",
    name = "Schall-tank-M-mk1",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"Schall-tank-M", 1},
      {"processing-unit", 40},
      {"electric-engine-unit", 20},
    },
    result = "Schall-tank-M-mk1"
  },
  {
    type = "recipe",
    name = "Schall-tank-H-mk1",
    enabled = false,
    energy_required = 40,
    ingredients =
    {
      {"Schall-tank-H", 1},
      {"processing-unit", 80},
      -- {"fusion-reactor-2-equipment", 1},
      {"electric-engine-unit", 60},
    },
    result = "Schall-tank-H-mk1"
  },
  {
    type = "recipe",
    name = "Schall-tank-SH-mk1",
    enabled = false,
    energy_required = 120,
    ingredients =
    {
      {"Schall-tank-SH", 1},
      {"processing-unit", 160},
      -- {"fusion-reactor-3-equipment", 1},
      {"electric-engine-unit", 120},
    },
    result = "Schall-tank-SH-mk1"
  },
  {
    type = "recipe",
    name = "Schall-tank-F-mk1",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"Schall-tank-F", 1},
      {"processing-unit", 40},
      {"electric-engine-unit", 20},
    },
    result = "Schall-tank-F-mk1"
  },
  {
    type = "recipe",
    name = "Schall-ht-RA-mk1",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"Schall-ht-RA", 1},
      {"processing-unit", 40},
      {"electric-engine-unit", 20},
    },
    result = "Schall-ht-RA-mk1"
  },
  -- Tanks MK2
  {
    type = "recipe",
    name = "Schall-tank-L-mk2",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"Schall-tank-L-mk1", 1},
      {"effectivity-module-2", 16},
      {"speed-module-2", 16},
    },
    result = "Schall-tank-L-mk2"
  },
  {
    type = "recipe",
    name = "Schall-tank-M-mk2",
    enabled = false,
    energy_required = 15,
    ingredients =
    {
      {"Schall-tank-M-mk1", 1},
      {"effectivity-module-2", 25},
      {"speed-module-2", 25},
    },
    result = "Schall-tank-M-mk2"
  },
  {
    type = "recipe",
    name = "Schall-tank-H-mk2",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"Schall-tank-H-mk1", 1},
      {"effectivity-module-2", 32},
      {"speed-module-2", 32},
    },
    result = "Schall-tank-H-mk2"
  },
  {
    type = "recipe",
    name = "Schall-tank-SH-mk2",
    enabled = false,
    energy_required = 180,
    ingredients =
    {
      {"Schall-tank-SH-mk1", 1},
      {"effectivity-module-2", 40},
      {"speed-module-2", 40},
    },
    result = "Schall-tank-SH-mk2"
  },
  {
    type = "recipe",
    name = "Schall-tank-F-mk2",
    enabled = false,
    energy_required = 15,
    ingredients =
    {
      {"Schall-tank-F-mk1", 1},
      {"effectivity-module-2", 25},
      {"speed-module-2", 25},
    },
    result = "Schall-tank-F-mk2"
  },
  {
    type = "recipe",
    name = "Schall-ht-RA-mk2",
    enabled = false,
    energy_required = 15,
    ingredients =
    {
      {"Schall-ht-RA-mk1", 1},
      {"effectivity-module-2", 25},
      {"speed-module-2", 25},
    },
    result = "Schall-ht-RA-mk2"
  },
  -- Autocannon Shell
  {
    type = "recipe",
    name = "explosive-autocannon-shell",
    normal =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {"steel-plate", 2},
        {"plastic-bar", 2},
        {"explosives", 2}
      },
      result = "explosive-autocannon-shell"
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {"steel-plate", 4},
        {"plastic-bar", 4},
        {"explosives", 2}
      },
      result = "explosive-autocannon-shell"
    }
  },
  {
    type = "recipe",
    name = "explosive-uranium-autocannon-shell",
    enabled = false,
    energy_required = 12,
    ingredients =
    {
      {"explosive-autocannon-shell", 1},
      {"uranium-238", 1}
    },
    result = "explosive-uranium-autocannon-shell"
  },
  -- High Caliber Cannon Shell
  {
    type = "recipe",
    name = "cannon-H1-shell",
    normal =
    {
      enabled = false,
      energy_required = 20, --8,
      ingredients =
      {
        {"steel-plate", 4},
        {"plastic-bar", 4},
        {"explosives", 2}
      },
      result = "cannon-H1-shell"
    },
    expensive =
    {
      enabled = false,
      energy_required = 20, --8,
      ingredients =
      {
        {"steel-plate", 8},
        {"plastic-bar", 8},
        {"explosives", 2}
      },
      result = "cannon-H1-shell"
    }
  },
  {
    type = "recipe",
    name = "cannon-H2-shell",
    normal =
    {
      enabled = false,
      energy_required = 80, --8,
      ingredients =
      {
        {"steel-plate", 12},
        {"plastic-bar", 12},
        {"explosives", 6}
      },
      result = "cannon-H2-shell"
    },
    expensive =
    {
      enabled = false,
      energy_required = 80, --8,
      ingredients =
      {
        {"steel-plate", 24},
        {"plastic-bar", 24},
        {"explosives", 6}
      },
      result = "cannon-H2-shell"
    }
  },
  {
    type = "recipe",
    name = "explosive-cannon-H1-shell",
    normal =
    {
      enabled = false,
      energy_required = 20, --8,
      ingredients =
      {
        {"steel-plate", 4},
        {"plastic-bar", 4},
        {"explosives", 4}
      },
      result = "explosive-cannon-H1-shell"
    },
    expensive =
    {
      enabled = false,
      energy_required = 20, --8,
      ingredients =
      {
        {"steel-plate", 8},
        {"plastic-bar", 8},
        {"explosives", 4}
      },
      result = "explosive-cannon-H1-shell"
    }
  },
  {
    type = "recipe",
    name = "explosive-cannon-H2-shell",
    normal =
    {
      enabled = false,
      energy_required = 80, --8,
      ingredients =
      {
        {"steel-plate", 12},
        {"plastic-bar", 12},
        {"explosives", 12}
      },
      result = "explosive-cannon-H2-shell"
    },
    expensive =
    {
      enabled = false,
      energy_required = 80, --8,
      ingredients =
      {
        {"steel-plate", 24},
        {"plastic-bar", 24},
        {"explosives", 12}
      },
      result = "explosive-cannon-H2-shell"
    }
  },
  {
    type = "recipe",
    name = "uranium-cannon-H1-shell",
    enabled = false,
    energy_required = 30, --12,
    ingredients =
    {
      {"cannon-H1-shell", 1},
      {"uranium-238", 2}
    },
    result = "uranium-cannon-H1-shell"
  },
  {
    type = "recipe",
    name = "uranium-cannon-H2-shell",
    enabled = false,
    energy_required = 120, --12,
    ingredients =
    {
      {"cannon-H2-shell", 1},
      {"uranium-238", 6}
    },
    result = "uranium-cannon-H2-shell"
  },
  {
    type = "recipe",
    name = "explosive-uranium-cannon-H1-shell",
    enabled = false,
    energy_required = 30, --12,
    ingredients =
    {
      {"explosive-cannon-H1-shell", 1},
      {"uranium-238", 2}
    },
    result = "explosive-uranium-cannon-H1-shell"
  },
  {
    type = "recipe",
    name = "explosive-uranium-cannon-H2-shell",
    enabled = false,
    energy_required = 120, --12,
    ingredients =
    {
      {"explosive-cannon-H2-shell", 1},
      {"uranium-238", 6}
    },
    result = "explosive-uranium-cannon-H2-shell"
  },
  -- Incendiary Autocannon Shell
  {
    type = "recipe",
    name = "incendiary-autocannon-shell",
    category = "chemistry",
    normal =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {type="item", name="steel-plate", amount=2},
        {type="fluid", name="light-oil", amount=100},
        {type="fluid", name="heavy-oil", amount=100}
      },
      result = "incendiary-autocannon-shell"
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {type="item", name="steel-plate", amount=4},
        {type="fluid", name="light-oil", amount=100},
        {type="fluid", name="heavy-oil", amount=100}
      },
      result = "incendiary-autocannon-shell"
    }
  },
  -- Rocket Pack
  {
    type = "recipe",
    name = "Schall-explosive-rocket-pack",
    enabled = false,
    energy_required = 8,
    ingredients =
    {
      {"explosive-rocket", 5},
    },
    result = "Schall-explosive-rocket-pack"
  },
  -- Incendiary Rocket
  {
    type = "recipe",
    name = "Schall-incendiary-rocket",
    category = "chemistry",
    enabled = false,
    energy_required = 40,--8,
    ingredients =
    {
      {type="item", name="rocket", amount=5},
      {type="item", name="steel-plate", amount=2},
      {type="fluid", name="light-oil", amount=100},
      {type="fluid", name="heavy-oil", amount=100}
    },
    result = "Schall-incendiary-rocket",
    result_count = 5
  },
  -- Napalm Bomb
  {
    type = "recipe",
    name = "Schall-napalm-bomb",
    category = "chemistry",
    enabled = false,
    energy_required = 40,
    ingredients =
    {
      {type="item", name="advanced-circuit", amount=20},
      {type="item", name="steel-plate", amount=10},
      {type="item", name="explosives", amount=10},
      {type="fluid", name="light-oil", amount=500},
      {type="fluid", name="heavy-oil", amount=500}
    },
    result = "Schall-napalm-bomb"
  },
  -- Poison Bomb
  {
    type = "recipe",
    name = "Schall-poison-bomb",
    enabled = false,
    energy_required = 40,
    ingredients =
    {
      {"rocket", 2},
      {"steel-plate", 18}, --3
      {"electronic-circuit", 6}, --3
      {"coal", 60} --10
    },
    result = "Schall-poison-bomb"
  },
  -- Fusion Reactor
  {
    type = "recipe",
    name = "fusion-reactor-2-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"processing-unit", 60},
      {"low-density-structure", 15}
    },
    result = "fusion-reactor-2-equipment"
  },
  {
    type = "recipe",
    name = "fusion-reactor-3-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"processing-unit", 120},
      {"low-density-structure", 30}
    },
    result = "fusion-reactor-3-equipment"
  },
  -- Vehicle Energy Shield
  {
    type = "recipe",
    name = "vehicle-energy-shield-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"energy-shield-equipment", 5},
      {"electric-engine-unit", 10}
    },
    result = "vehicle-energy-shield-equipment"
  },
  {
    type = "recipe",
    name = "vehicle-energy-shield-mk2-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"vehicle-energy-shield-equipment", 10},
      {"processing-unit", 10}
    },
    result = "vehicle-energy-shield-mk2-equipment"
  },
  -- Vehicle Battery
  {
    type = "recipe",
    name = "vehicle-battery-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"battery-equipment", 5},
      {"electric-engine-unit", 10}
    },
    result = "vehicle-battery-equipment"
  },
  {
    type = "recipe",
    name = "vehicle-battery-mk2-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"vehicle-battery-equipment", 10},
      {"processing-unit", 20}
    },
    result = "vehicle-battery-mk2-equipment"
  },
  -- Vehicle Fuel Cell
  {
    type = "recipe",
    name = "vehicle-fuel-cell-2-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"steam-engine", 1},
      {"electric-engine-unit", 10}
    },
    result = "vehicle-fuel-cell-2-equipment"
  },
  {
    type = "recipe",
    name = "vehicle-fuel-cell-3-equipment",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
      {"vehicle-fuel-cell-2-equipment", 4}
    },
    result = "vehicle-fuel-cell-3-equipment"
  },
  {
    type = "recipe",
    name = "vehicle-fuel-cell-4-equipment",
    enabled = false,
    energy_required = 30,
    ingredients =
    {
      {"vehicle-fuel-cell-3-equipment", 3}
    },
    result = "vehicle-fuel-cell-4-equipment"
  },
  {
    type = "recipe",
    name = "vehicle-nuclear-reactor-equipment",
    enabled = false,
    energy_required = 60,
    ingredients =
    {
      {"nuclear-reactor", 1}
    },
    result = "vehicle-nuclear-reactor-equipment"
  },
  -- Guns
  {
    type = "recipe",
    name = "Schall-sniper-rifle",
    normal =
    {
      enabled = false,
      energy_required = 30, --10,
      ingredients =
      {
        {"iron-gear-wheel", 10},
        {"copper-plate", 5},
        {"steel-plate", 10}
      },
      result = "Schall-sniper-rifle"
    },
    expensive =
    {
      enabled = false,
      energy_required = 30, --10,
      ingredients =
      {
        {"iron-gear-wheel", 15},
        {"copper-plate", 20},
        {"steel-plate", 30}
      },
      result = "Schall-sniper-rifle"
    }
  },
  -- Sniper Ammo
  {
    type = "recipe",
    name = "Schall-sniper-firearm-magazine",
    enabled = false,
    energy_required = 1,
    ingredients = {{"iron-plate", 4}},
    result = "Schall-sniper-firearm-magazine",
    result_count = 1
  },
  {
    type = "recipe",
    name = "Schall-sniper-piercing-rounds-magazine",
    enabled = false,
    energy_required = 3,
    ingredients =
    {
      {"Schall-sniper-firearm-magazine", 1},
      {"steel-plate", 1},
      {"copper-plate", 5}
    },
    result = "Schall-sniper-piercing-rounds-magazine"
  },
  {
    type = "recipe",
    name = "Schall-sniper-uranium-rounds-magazine",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"Schall-sniper-piercing-rounds-magazine", 1},
      {"uranium-238", 1}
    },
    result = "Schall-sniper-uranium-rounds-magazine"
  },
  -- Nightvision
  {
    type = "recipe",
    name = "Schall-night-vision-mk1-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"night-vision-equipment", 1},
      {"processing-unit", 5}
    },
    result = "Schall-night-vision-mk1-equipment"
  },
  {
    type = "recipe",
    name = "Schall-night-vision-mk2-equipment",
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {"Schall-night-vision-mk1-equipment", 1},
      {"speed-module-3", 1}
    },
    result = "Schall-night-vision-mk2-equipment"
  },
  -- Concrete wall
  {
    type = "recipe",
    name = "Schall-concrete-wall",
    enabled = false,
    energy_required = 2,
    ingredients = {{"concrete", 5}, {"steel-plate", 1}},
    result = "Schall-concrete-wall"
  },
  {
    type = "recipe",
    name = "Schall-concrete-gate",
    enabled = false,
    energy_required = 2,
    ingredients = {{"Schall-concrete-wall", 1}, {"steel-plate", 2}, {"electronic-circuit", 2}},
    result = "Schall-concrete-gate"
  },
  -- Repair Packs
  {
    type = "recipe",
    name = "Schall-repair-pack-mk1",
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {"repair-pack", 1},
      {"advanced-circuit", 2}
    },
    result = "Schall-repair-pack-mk1"
  },
  {
    type = "recipe",
    name = "Schall-repair-pack-mk2",
    enabled = false,
    energy_required = 2,
    ingredients =
    {
      {"Schall-repair-pack-mk1", 1},
      {"processing-unit", 2}
    },
    result = "Schall-repair-pack-mk2"
  }
}



-- Chemical Recipes for Chemical Weapons
if settings.startup["tankplatoon-chemical-weapon-chemical-recipes"].value then
  data.raw["recipe"]["poison-capsule"].category = "chemistry"
  data.raw["recipe"]["poison-capsule"].ingredients =
  {
    {type="item", name="electronic-circuit", amount=1},
    {type="item", name="coal", amount=10},
    {type="fluid", name="sulfuric-acid", amount=50}
  }
  data.raw["recipe"]["Schall-poison-bomb"].category = "chemistry"
  data.raw["recipe"]["Schall-poison-bomb"].ingredients =
  {
    {type="item", name="rocket", amount=2},
    {type="item", name="electronic-circuit", amount=2},
    {type="item", name="coal", amount=60},
    {type="fluid", name="sulfuric-acid", amount=300}
  }
end
