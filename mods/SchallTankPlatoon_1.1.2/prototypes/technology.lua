local cfg1 = require("config.config-1")



local tech = data.raw.technology

local tech_tank = tech["tank"]
if tech_tank then
	if not settings.startup["tankplatoon-tank-to-recipe-keep"].value then
	    for i, v in pairs(tech_tank.effects) do
	      if (v.recipe=="tank") then table.remove(tech_tank.effects, i) end
	    end
	end
  table.insert(tech_tank.effects, {type="unlock-recipe", recipe="explosive-autocannon-shell"})
	table.insert(tech_tank.effects, {type="unlock-recipe", recipe="Schall-tank-L"})
	table.insert(tech_tank.effects, {type="unlock-recipe", recipe="Schall-tank-M"})
end

local tech_uranammo = tech["uranium-ammo"]
if tech_uranammo then
  table.insert(tech_uranammo.effects, 2, {type="unlock-recipe", recipe="Schall-sniper-uranium-rounds-magazine"})
  table.insert(tech_uranammo.effects, 4, {type="unlock-recipe", recipe="uranium-cannon-H1-shell"})
  table.insert(tech_uranammo.effects, 5, {type="unlock-recipe", recipe="uranium-cannon-H2-shell"})
  table.insert(tech_uranammo.effects, 7, {type="unlock-recipe", recipe="explosive-uranium-cannon-H1-shell"})
  table.insert(tech_uranammo.effects, 8, {type="unlock-recipe", recipe="explosive-uranium-cannon-H2-shell"})
  table.insert(tech_uranammo.effects, {type="unlock-recipe", recipe="explosive-uranium-autocannon-shell"})
end

local tech_rocketry = tech["rocketry"]
if tech_rocketry then
  table.insert(tech_rocketry.effects, {type="unlock-recipe", recipe="Schall-incendiary-rocket"})
end


-- log("=== Debug ---")
for _, tech in pairs(tech) do
  -- log(tech.name)
  if tech.name:match("^physical%-projectile%-") and tech.effects then
    -- log(#tech.effects)
    for _, eff in pairs(tech.effects) do
      -- log(tech.name)
      if eff.type == "ammo-damage" and eff.ammo_category == "bullet" then
        table.insert(tech.effects, {type="ammo-damage", ammo_category = "Schall-sniper-bullet", modifier = eff.modifier})
      end
      if eff.type == "ammo-damage" and eff.ammo_category == "cannon-shell" then
        table.insert(tech.effects, {type="ammo-damage", ammo_category = "cannon-H1-shell", modifier = eff.modifier})
        table.insert(tech.effects, {type="ammo-damage", ammo_category = "cannon-H2-shell", modifier = eff.modifier})
        table.insert(tech.effects, {type="ammo-damage", ammo_category = "autocannon-shell", modifier = eff.modifier})
      end
    end
  end
end

for _, tech in pairs(tech) do
  if tech.name:match("^weapon%-shooting%-") and tech.effects then
    for _, eff in pairs(tech.effects) do
      if eff.type == "gun-speed" and eff.ammo_category == "bullet" then
        table.insert(tech.effects, {type="gun-speed", ammo_category = "Schall-sniper-bullet", modifier = eff.modifier})
      end
      if eff.type == "gun-speed" and eff.ammo_category == "cannon-shell" then
        table.insert(tech.effects, {type="gun-speed", ammo_category = "cannon-H1-shell", modifier = eff.modifier})
        table.insert(tech.effects, {type="gun-speed", ammo_category = "cannon-H2-shell", modifier = eff.modifier})
        table.insert(tech.effects, {type="gun-speed", ammo_category = "autocannon-shell", modifier = eff.modifier})
      end
    end
  end
end


local tech_fusion = tech["fusion-reactor-equipment"]
if tech_fusion then
  table.insert(tech_fusion.effects, 1, {type="unlock-recipe", recipe="fusion-reactor-2-equipment"})
  table.insert(tech_fusion.effects, 2, {type="unlock-recipe", recipe="fusion-reactor-3-equipment"})
end

local tech_shield = tech["energy-shield-equipment"]
if tech_shield and settings.startup["tankplatoon-vehicle-energy-shield-enable"].value then
  table.insert(tech_shield.effects, {type="unlock-recipe", recipe="vehicle-energy-shield-equipment"})
end

local tech_shield2 = tech["energy-shield-mk2-equipment"]
if tech_shield2 and settings.startup["tankplatoon-vehicle-energy-shield-enable"].value then
  table.insert(tech_shield2.effects, {type="unlock-recipe", recipe="vehicle-energy-shield-mk2-equipment"})
end

local tech_bat = tech["battery-equipment"]
if tech_bat and settings.startup["tankplatoon-vehicle-battery-enable"].value then
  table.insert(tech_bat.effects, {type="unlock-recipe", recipe="vehicle-battery-equipment"})
end

local tech_bat2 = tech["battery-mk2-equipment"]
if tech_bat2 and settings.startup["tankplatoon-vehicle-battery-enable"].value then
  table.insert(tech_bat2.effects, {type="unlock-recipe", recipe="vehicle-battery-mk2-equipment"})
end

local tech_eleng = tech["electric-engine"]
if tech_eleng and settings.startup["tankplatoon-vehicle-fuel-cell-enable"].value then
  table.insert(tech_eleng.effects, {type="unlock-recipe", recipe="vehicle-fuel-cell-2-equipment"})
  table.insert(tech_eleng.effects, {type="unlock-recipe", recipe="vehicle-fuel-cell-3-equipment"})
  table.insert(tech_eleng.effects, {type="unlock-recipe", recipe="vehicle-fuel-cell-4-equipment"})
end

local tech_nuclear = tech["nuclear-power"]
if tech_nuclear and settings.startup["tankplatoon-vehicle-nuclear-reactor-enable"].value then
  table.insert(tech_nuclear.effects, {type="unlock-recipe", recipe="vehicle-nuclear-reactor-equipment"})
end



data:extend
{
  {
    type = "technology",
    name = "Schall-tank-H-0",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-H.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-H"
      },
      {
        type = "unlock-recipe",
        recipe = "cannon-H1-shell"
      },
      {
        type = "unlock-recipe",
        recipe = "explosive-cannon-H1-shell"
      }
    },
    prerequisites = {"tank"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-d"
  },
  {
    type = "technology",
    name = "Schall-tank-SH-0",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-SH.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-SH"
      },
      {
        type = "unlock-recipe",
        recipe = "cannon-H2-shell"
      },
      {
        type = "unlock-recipe",
        recipe = "explosive-cannon-H2-shell"
      }
    },
    prerequisites = {"Schall-tank-H-0", "modular-armor"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-e"
  },
  {
    type = "technology",
    name = "Schall-tank-1",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"} },
    -- localised_name = {"technology-name.tank"},
    -- localised_description = {"technology-description.tank"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-L-mk1"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-M-mk1"
      }
    },
    prerequisites = {"tank", "power-armor"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-c-1"
  },
  {
    type = "technology",
    name = "Schall-tank-H-1",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-H.png"} },
    -- localised_description = {"technology-description.tank-H"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-H-mk1"
      }
    },
    prerequisites = {"Schall-tank-H-0", "Schall-tank-1"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-d-1"
  },
  {
    type = "technology",
    name = "Schall-tank-SH-1",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-SH.png"} },
    -- localised_description = {"technology-description.tank-SH"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-SH-mk1"
      }
    },
    prerequisites = {"Schall-tank-SH-0", "Schall-tank-H-1"},
    unit =
    {
      count = 600,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-e-1"
  },
  {
    type = "technology",
    name = "Schall-tank-2",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"} },
    -- localised_description = {"technology-description.tank"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-L-mk2"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-M-mk2"
      }
    },
    prerequisites = {"Schall-tank-1", "power-armor-mk2"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-c-2"
  },
  {
    type = "technology",
    name = "Schall-tank-H-2",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-H.png"} },
    -- localised_description = {"technology-description.tank-H"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-H-mk2"
      }
    },
    prerequisites = {"Schall-tank-H-1", "Schall-tank-2"},
    unit =
    {
      count = 600,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-d-2"
  },
  {
    type = "technology",
    name = "Schall-tank-SH-2",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-SH.png"} },
    -- localised_description = {"technology-description.tank-SH"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-SH-mk2"
      }
    },
    prerequisites = {"Schall-tank-SH-1", "Schall-tank-H-2"},
    unit =
    {
      count = 1200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-e-2"
  },
  {
    type = "technology",
    name = "Schall-tank-F-0",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-F.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-F"
      },
      {
        type = "unlock-recipe",
        recipe = "incendiary-autocannon-shell"
      }
    },
    prerequisites = {"tank", "flamethrower"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-f"
  },
  {
    type = "technology",
    name = "Schall-tank-F-1",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-F.png"} },
    -- localised_description = {"technology-description.tank-F"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-F-mk1"
      }
    },
    prerequisites = {"Schall-tank-F-0", "Schall-tank-1"},
    unit =
    {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-f-1"
  },
  {
    type = "technology",
    name = "Schall-tank-F-2",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-F.png"} },
    -- localised_description = {"technology-description.tank-F"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-F-mk2"
      }
    },
    prerequisites = {"Schall-tank-F-1", "Schall-tank-2"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-f-2"
  },
  {
    type = "technology",
    name = "Schall-ht-RA-0",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/ht-RA.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-ht-RA"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-explosive-rocket-pack"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-napalm-bomb"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-poison-bomb"
      }
    },
    prerequisites = {"tank", "explosive-rocketry"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-h"
  },
  {
    type = "technology",
    name = "Schall-ht-RA-1",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/ht-RA.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-ht-RA-mk1"
      }
    },
    prerequisites = {"Schall-ht-RA-0", "Schall-tank-1"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-h-1"
  },
  {
    type = "technology",
    name = "Schall-ht-RA-2",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/ht-RA.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-ht-RA-mk2"
      }
    },
    prerequisites = {"Schall-ht-RA-1", "Schall-tank-2"},
    unit =
    {
      count = 400,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-h-2"
  },
  {
    type = "technology",
    name = "Schall-tank-3",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-L-mk3"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-M-mk3"
      }
    },
    prerequisites = {"Schall-tank-2", "Schall-power-armor-3", "nuclear-power"},
    unit =
    {
      count = 600,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"alien-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-c-3"
  },
  {
    type = "technology",
    name = "Schall-tank-H-3",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-H.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-H-mk3"
      }
    },
    prerequisites = {"Schall-tank-H-2", "Schall-tank-3"},
    unit =
    {
      count = 1200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"alien-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-d-3"
  },
  {
    type = "technology",
    name = "Schall-tank-SH-3",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-SH.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-SH-mk3"
      }
    },
    prerequisites = {"Schall-tank-SH-2", "Schall-tank-H-3"},
    unit =
    {
      count = 2400,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"alien-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-e-3"
  },
  {
    type = "technology",
    name = "Schall-tank-F-3",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/tank-F.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-tank-F-mk3"
      }
    },
    prerequisites = {"Schall-tank-F-2", "Schall-tank-3"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"alien-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-f-3"
  },
  {
    type = "technology",
    name = "Schall-ht-RA-3",
    icon_size = 256, icon_mipmaps = 4,
    icons = { {icon = "__base__/graphics/technology/tank.png"},
              {icon = "__SchallTankPlatoon__/graphics/technology/ht-RA.png"} },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-ht-RA-mk3"
      }
    },
    prerequisites = {"Schall-ht-RA-2", "Schall-tank-3"},
    unit =
    {
      count = 800,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"alien-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "e-c-h-3"
  },
  {
    type = "technology",
    name = "Schall-sniper-rifle",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__SchallTankPlatoon__/graphics/technology/sniper-rifle.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-sniper-rifle"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-sniper-firearm-magazine"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-sniper-piercing-rounds-magazine"
      }
    },
    prerequisites = {"military-2"},
    unit =
    {
      count = 20,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    },
    order = "m-g-b"
  },
  -- Nightvision
  {
    type = "technology",
    name = "Schall-night-vision-equipment-1",
    localised_description = {"technology-description.night-vision-equipment"},
    icon_size = 256, icon_mipmaps = 4,
    icons = util.technology_icon_constant_equipment("__base__/graphics/technology/night-vision-equipment.png"),
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-night-vision-mk1-equipment"
      }
    },
    prerequisites = {"night-vision-equipment", "power-armor"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 15
    },
    upgrade = true,
    order = "g-g-1"
  },
  {
    type = "technology",
    name = "Schall-night-vision-equipment-2",
    localised_description = {"technology-description.night-vision-equipment"},
    icon_size = 256, icon_mipmaps = 4,
    icons = util.technology_icon_constant_equipment("__base__/graphics/technology/night-vision-equipment.png"),
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-night-vision-mk2-equipment"
      }
    },
    prerequisites = {"Schall-night-vision-equipment-1", "power-armor-mk2"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 15
    },
    upgrade = true,
    order = "g-g-2"
  },
  -- Concrete walls
  {
    type = "technology",
    name = "Schall-concrete-wall",
    localised_description = {"technology-description.stone-wall"},
    icon_size = 256, icon_mipmaps = 4,
    icon = "__SchallTankPlatoon__/graphics/technology/concrete-wall.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-concrete-wall"
      },
      {
        type = "unlock-recipe",
        recipe = "Schall-concrete-gate"
      }
    },
    prerequisites = {"gate", "concrete", "military-3"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "a-k-a"
  },
  -- Repair Packs
  {
    type = "technology",
    name = "Schall-repair-pack-1",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__SchallTankPlatoon__/graphics/technology/repair-pack.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-repair-pack-mk1"
      }
    },
    prerequisites = {"advanced-electronics"},
    unit =
    {
      count = 40,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    },
    upgrade = true,
    order = "a-d-b"
  },
  {
    type = "technology",
    name = "Schall-repair-pack-2",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__SchallTankPlatoon__/graphics/technology/repair-pack.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-repair-pack-mk2"
      }
    },
    prerequisites = {"Schall-repair-pack-1", "advanced-electronics-2"},
    unit =
    {
      count = 60,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "a-d-c"
  },
}



for tier = 1, cfg1.tier_max, 1 do -- Notice it starts from 1, as tier 0 is always on
  if not cfg1.tier_on[tier] then
    tech["Schall-tank-" .. tier] = nil
    tech["Schall-tank-H-" .. tier] = nil
    tech["Schall-tank-SH-" .. tier] = nil
    tech["Schall-tank-F-" .. tier] = nil
    tech["Schall-ht-RA-" .. tier] = nil
  elseif not cfg1.class_on["ht-RA"] then
    tech["Schall-ht-RA-" .. tier] = nil
  end
end

if not cfg1.class_on["ht-RA"] then
  tech["Schall-ht-RA-0"] = nil  -- Capture the case for tier 0
end

if not settings.startup["tankplatoon-night-vision-enable"].value then
  tech["Schall-night-vision-equipment-1"] = nil
  tech["Schall-night-vision-equipment-2"] = nil
end

if not settings.startup["tankplatoon-repair-pack-enable"].value then
  tech["Schall-repair-pack-1"] = nil
  tech["Schall-repair-pack-2"] = nil
end

-- Moved to data-final-fixes.lua
-- if not cfg1.class_on["concrete-wall"] then
--   tech["Schall-concrete-wall"] = nil
-- end
