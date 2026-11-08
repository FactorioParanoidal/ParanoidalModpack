if mods["PlanetsLib"] then
  if (data.raw["planet"]["nauvis"] and data.raw["planet"]["nauvis"].surface_properties and data.raw["planet"]["nauvis"].surface_properties.temperature) then
    data.raw["planet"]["moshine"].surface_properties.temperature = 371
  end
end

function prevent_from_moshine(entity)
  if not entity.surface_conditions then
    entity.surface_conditions = {}
  end
  table.insert(entity.surface_conditions, { property = "temperature-celcius", min = -273, max = 96 })
end

for _, entity in pairs(data.raw["accumulator"]) do
  if not (entity.name == "ring-teleporter") and not (entity.name == "kr-planetary-teleporter") then
    prevent_from_moshine(entity)
  end
end
for _, entity in pairs(data.raw["lightning-attractor"]) do
  if not (entity.name == "sun_heat_cooler_1") and not (entity.name == "sun_heat_cooler_2") then
    prevent_from_moshine(entity)
  end
end

--if data.raw["reactor"]["nuclear-reactor"] then
--  prevent_from_moshine(data.raw["reactor"]["nuclear-reactor"])
--end

--if data.raw["fusion-reactor"]["fusion-reactor"] then
--  prevent_from_moshine(data.raw["fusion-reactor"]["fusion-reactor"])
--end
if data.raw["item"]["foundation"] then
  if data.raw["item"]["foundation"].place_as_tile then
    if data.raw["item"]["foundation"].place_as_tile.tile_condition then
      table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "moshine-lava")
    end
  end
end


local recycling = require("__recycler__.recycling")

if mods["se-space-trains"] then
  --if settings.startup["moshine-se-space-trains"].value then
    if data.raw["technology"]["tech-space-trains"] then
      table.insert(data.raw["technology"]["tech-space-trains"].prerequisites, "moshine-tech-magnet")
    end
    if data.raw["recipe"]["space-locomotive"] then
      table.insert(data.raw["recipe"]["space-locomotive"].ingredients, {type = "item", name = "magnet", amount = 5})
    end
    if data.raw["recipe"]["space-fluid-wagon"] then
      table.insert(data.raw["recipe"]["space-fluid-wagon"].ingredients, {type = "item", name = "magnet", amount = 5})
    end
    if data.raw["recipe"]["space-cargo-wagon"] then
      table.insert(data.raw["recipe"]["space-cargo-wagon"].ingredients, {type = "item", name = "magnet", amount = 5})
    end
    if data.raw["item-with-entity-data"]["space-locomotive"] then
      data.raw["item-with-entity-data"]["space-locomotive"].order = "c[rolling-stock]-e[space-locomotive]"
    end
    if data.raw["item-with-entity-data"]["space-cargo-wagon"] then
      data.raw["item-with-entity-data"]["space-cargo-wagon"].order = "c[rolling-stock]-f[space-cargo-wagon]"
    end
    if data.raw["item-with-entity-data"]["space-fluid-wagon"] then
      data.raw["item-with-entity-data"]["space-fluid-wagon"].order = "c[rolling-stock]-g[space-fluid-wagon]"
    end

    recycling.generate_recycling_recipe(data.raw["recipe"]["space-locomotive"])
    recycling.generate_recycling_recipe(data.raw["recipe"]["space-cargo-wagon"])
    recycling.generate_recycling_recipe(data.raw["recipe"]["space-fluid-wagon"])
    recycling.generate_recycling_recipe(data.raw["recipe"]["space-train-battery-charging-station"])
    recycling.generate_recycling_recipe(data.raw["recipe"]["space-train-battery-pack"])

    --if data.raw["item"]["space-train-battery-charging-station"] then data.raw["item"]["space-train-battery-charging-station"].default_import_location = "moshine" end
    --if data.raw["item"]["space-train-battery-pack"] then data.raw["item"]["space-train-battery-pack"].default_import_location = "moshine" end
    --if data.raw["item"]["space-train-destroyed-battery-pack"] then data.raw["item"]["space-train-destroyed-battery-pack"].default_import_location = "moshine" end
    --if data.raw["item"]["space-train-discharged-battery-pack"] then data.raw["item"]["space-train-discharged-battery-pack"].default_import_location = "moshine" end
    if data.raw["item-with-entity-data"]["space-locomotive"] then data.raw["item-with-entity-data"]["space-locomotive"].default_import_location = "moshine" end
    if data.raw["item-with-entity-data"]["space-cargo-wagon"] then data.raw["item-with-entity-data"]["space-cargo-wagon"].default_import_location = "moshine" end
    if data.raw["item-with-entity-data"]["space-fluid-wagon"] then data.raw["item-with-entity-data"]["space-fluid-wagon"].default_import_location = "moshine" end

  --[[else
    -- mod is disabled, disable everything
    if data.raw.technology["tech-space-trains"] then
      data.raw.technology["tech-space-trains"].enabled = false
      data.raw.technology["tech-space-trains"].hidden = true
    end

    if data.raw["locomotive"]["space-locomotive"] then data.raw["locomotive"]["space-locomotive"].hidden = true end
    if data.raw["cargo-wagon"]["space-cargo-wagon"] then data.raw["cargo-wagon"]["space-cargo-wagon"].hidden = true end
    if data.raw["fluid-wagon"]["space-fluid-wagon"] then data.raw["fluid-wagon"]["space-fluid-wagon"].hidden = true end
    if data.raw["assembling-machine"]["space-train-battery-charging-station"] then data.raw["assembling-machine"]["space-train-battery-charging-station"].hidden = true end

    if data.raw.recipe["space-locomotive"] then data.raw.recipe["space-locomotive"].hidden = true end
    if data.raw.recipe["space-cargo-wagon"] then data.raw.recipe["space-cargo-wagon"].hidden = true end
    if data.raw.recipe["space-fluid-wagon"] then data.raw.recipe["space-fluid-wagon"].hidden = true end
    if data.raw.recipe["space-train-battery-charging-station"] then data.raw.recipe["space-train-battery-charging-station"].hidden = true end
    if data.raw.recipe["space-train-battery-pack"] then data.raw.recipe["space-train-battery-pack"].hidden = true end
    if data.raw.recipe["space-train-battery-pack-refurbish"] then data.raw.recipe["space-train-battery-pack-refurbish"].hidden = true end
    if data.raw.recipe["space-train-battery-pack-recharge"] then data.raw.recipe["space-train-battery-pack-recharge"].hidden = true end
    
    if data.raw["item"]["space-train-battery-charging-station"] then data.raw["item"]["space-train-battery-charging-station"].hidden = true end
    if data.raw["item"]["space-train-battery-pack"] then data.raw["item"]["space-train-battery-pack"].hidden = true end
    if data.raw["item"]["space-train-destroyed-battery-pack"] then data.raw["item"]["space-train-destroyed-battery-pack"].hidden = true end
    if data.raw["item"]["space-train-discharged-battery-pack"] then data.raw["item"]["space-train-discharged-battery-pack"].hidden = true end
    if data.raw["item-with-entity-data"]["space-locomotive"] then data.raw["item-with-entity-data"]["space-locomotive"].hidden = true end
    if data.raw["item-with-entity-data"]["space-cargo-wagon"] then data.raw["item-with-entity-data"]["space-cargo-wagon"].hidden = true end
    if data.raw["item-with-entity-data"]["space-fluid-wagon"] then data.raw["item-with-entity-data"]["space-fluid-wagon"].hidden = true end
  end]]
end

if mods["maraxsis"] or mods["maraxsis-classic"] then
  if data.raw.item["maraxsis-glass-panes"] then
    data.raw.item["maraxsis-glass-panes"].localised_name = {"item-name.maraxsis-reinforced-glass"}
  end
end

if mods["bzsilicon"] then

  local util = require("__bzsilicon__.data-util")
  
  if data.raw["recipe"]["optical-cable"] and data.raw["item"]["optical-fiber"] then
    data.raw["recipe"]["optical-cable"].ingredients = {
      {type = "item", name = "optical-fiber", amount = 1},
      {type = "item", name = "silicon-carbide", amount = 1},
      {type = "item", name = "glass", amount = 1},
    }
  end

  data.extend({
    {
      type = "recipe",
      name = "advanced-silicon",
      categories = {"smelting"},
      energy_required = 5,
      ingredients = {
        {type = "item", name = "silica", amount = 5}
      },
      results = {{type = "item", name = "hot-silicon", amount = 1}},
      allow_productivity = true,
      enabled = false,
    },
    {
      type = "technology",
      name = "moshine-tech-silicon",
      icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon.png",
      icon_size = 256,
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "advanced-silicon"
        },
      },
      prerequisites = {"planet-discovery-moshine"},
      unit =
      {
        count = 50,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"utility-science-pack", 1},
        },
        time = 60
      }
    },
    {
      type = "recipe",
      name = "optical-fiber",
      enabled = false,
      allow_productivity = true,
      ingredients = {util.item("silica", 1)},
      results = {util.item("optical-fiber",  1)},
      -- expensive =
      -- {
      --   enabled = false,
      --   ingredients = {{"silica", 2}},
      --   results = {util.item("optical-fiber",  1)},
      -- },
    },
    {
      type = "item",
      name = "optical-fiber",
      icon = "__bzsilicon__/graphics/icons/optical-fiber.png",
      icon_size = 64, icon_mipmaps = 3,
      subgroup = util.cablesg,
      order = "a[optical-fiber]",
      stack_size = util.get_stack_size(200),
      weight = 1*kg,
    },
    {
      type = "technology",
      name = "moshine-tech-data-extractor",
      icon = "__Moshine-assets__/graphics/technology/moshine-tech-data-extractor.png",
      icon_size = 256,
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "data-extractor"
        },
        {
          type = "unlock-recipe",
          recipe = "optical-cable"
        },
      },
      prerequisites = {"moshine-tech-neural_computer"},
      unit =
      {
        count = 10,
        ingredients =
        {
          {"datacell-equation", 1},
        },
        time = 60
      }
    },
  })

  if mods["hot-metals"] then 
    data:extend({
      {
        type = "recipe",
        name = "advanced-silicon",
        categories = {"smelting"},
        icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon.png",
        icon_size = 256,
        energy_required = 5,
        ingredients = {
          {type = "item", name = "silica", amount = 5}
        },
        results = {{type = "item", name = "hot-silicon", amount = 1}},
        allow_productivity = true,
        enabled = false,
      },
      {
        type = "recipe",
        name = "silicon",
        categories = {"smelting"},
        icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon.png",
        icon_size = 256,
        energy_required = 5,
        ingredients = {
          {type = "item", name = "silica", amount = 10}
        },
        results = {{type = "item", name = "hot-silicon", amount = 1}},
        allow_productivity = true,
        enabled = false,
      },
    })
  else
    data:extend({
      {
        type = "recipe",
        name = "advanced-silicon",
        categories = {"chemistry"},
        energy_required = 5,
        ingredients = {
          {type = "item", name = "silica", amount = 10},
          {type = "item", name = "coal", amount = 1}
        },
        results = {{type = "item", name = "silicon", amount = 1}},
        allow_productivity = true,
        enabled = false,
      },
      {
        type = "recipe",
        name = "silicon",
        categories = {"chemistry"},
        icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon.png",
        icon_size = 256,
        energy_required = 5,
        ingredients = {
          {type = "item", name = "silica", amount = 10},
          {type = "item", name = "coal", amount = 1}
        },
        results = {{type = "item", name = "silicon", amount = 1}},
        allow_productivity = true,
        enabled = false,
      },
    })
  end
end

if data.raw["agricultural-tower"]["agricultural-tower"] and not data.raw["agricultural-tower"]["agricultural-tower"].accepted_seeds then
  data.raw["agricultural-tower"]["agricultural-tower"].accepted_seeds = {}
  for _, seed in pairs(data.raw.item) do
    if seed.plant_result then
      if seed.name ~= "datacell-equation" and seed.name ~= "datacell-dna-raw" then
        table.insert(data.raw["agricultural-tower"]["agricultural-tower"].accepted_seeds, seed.name)
      end
    end
  end
  --for _, seed in pairs(data.raw.tool) do
  --  if seed.plant_result then
  --    if seed.name ~= "datacell-equation" and seed.name ~= "datacell-dna-raw" then
  --      table.insert(data.raw["agricultural-tower"]["agricultural-tower"].accepted_seeds, seed.name)
  --    end
  --  end
  --end
  for _, seed in pairs(data.raw.module) do
    if seed.plant_result then
      if seed.name ~= "datacell-equation" and seed.name ~= "datacell-dna-raw" then
        table.insert(data.raw["agricultural-tower"]["agricultural-tower"].accepted_seeds, seed.name)
      end
    end
  end
  for _, seed in pairs(data.raw.capsule) do
    if seed.plant_result then
      if seed.name ~= "datacell-equation" and seed.name ~= "datacell-dna-raw" then
        table.insert(data.raw["agricultural-tower"]["agricultural-tower"].accepted_seeds, seed.name)
      end
    end
  end
end


if mods["snouz-big-solar-panel"] then
  table.insert(data.raw["recipe"]["big-solar-panel"].ingredients, {type = "item", name = "silicon-cell", amount = 10})
  data.raw["item"]["big-solar-panel"].weight = 200*kg
  data.raw["item"]["big-solar-panel"].default_import_location = "moshine"
  table.insert(data.raw["technology"]["big-solar-energy"].prerequisites, "moshine-tech-ai-tier-2")
  recycling.generate_recycling_recipe(data.raw["recipe"]["big-solar-panel"])
end

if mods["snouz-big-accumulator"] then
  table.insert(data.raw["recipe"]["big-accumulator"].ingredients, {type = "item", name = "magnet", amount = 10})
  data.raw["item"]["big-accumulator"].weight = 200*kg
  data.raw["item"]["big-accumulator"].default_import_location = "moshine"
  table.insert(data.raw["technology"]["electric-energy-big-accumulators"].prerequisites, "moshine-tech-ai-tier-6")
  recycling.generate_recycling_recipe(data.raw["recipe"]["big-accumulator"])
end

if mods["snouz_better_substation"] then
  data.raw["recipe"]["snouz_better_substation"].ingredients = {
    
      {type = "item", name = "substation", amount = 4},
      {type = "item", name = "silicon-cell", amount = 15},
      {type = "item", name = "magnet", amount = 4}
  }
  data.raw["item"]["snouz_better_substation"].default_import_location = "moshine"
  data.raw["technology"]["snouz_better_substation_tech"].prerequisites = {"electric-energy-distribution-2", "moshine-tech-ai-tier-4"}
  recycling.generate_recycling_recipe(data.raw["recipe"]["snouz_better_substation"])
end


if data.raw["technology"]["moshine-tech-silicon"] then
  table.insert(data.raw["technology"]["moshine-tech-cosmicscanner-construction1"].prerequisites, "moshine-tech-silicon")
end




if settings.startup["moshine-data-colors"] and settings.startup["moshine-data-colors"].value == false then
  -- technology
  if data.raw.technology["moshine-tech-data-extractor"] then
    data.raw.technology["moshine-tech-data-extractor"].localised_name = {"technology-name.moshine-tech-data-extractor_nocolor"}
  end
  -- entity
  if data.raw["mining-drill"]["data-extractor"] then
    data.raw["mining-drill"]["data-extractor"].localised_name = {"entity-name.data-extractor_nocolor"}
  end
  -- item
  if data.raw.item["data-extractor"] then
    data.raw.item["data-extractor"].localised_name = {"item-name.data-extractor_nocolor"}
  end
  if data.raw.item["ai-tier-1"] then
    data.raw.item["ai-tier-1"].localised_name = {"item-name.ai-tier-1_nocolor"}
  end
  if data.raw.item["ai-tier-2"] then
    data.raw.item["ai-tier-2"].localised_name = {"item-name.ai-tier-2_nocolor"}
  end
  if data.raw.item["ai-tier-3"] then
    data.raw.item["ai-tier-3"].localised_name = {"item-name.ai-tier-3_nocolor"}
  end
  if data.raw.item["ai-tier-4"] then
    data.raw.item["ai-tier-4"].localised_name = {"item-name.ai-tier-4_nocolor"}
  end
  if data.raw.item["ai-tier-5"] then
    data.raw.item["ai-tier-5"].localised_name = {"item-name.ai-tier-5_nocolor"}
  end
  if data.raw.item["ai-tier-6"] then
    data.raw.item["ai-tier-6"].localised_name = {"item-name.ai-tier-6_nocolor"}
  end
  if data.raw.item["ai-tier-7"] then
    data.raw.item["ai-tier-7"].localised_name = {"item-name.ai-tier-7_nocolor"}
  end
  if data.raw.item["ai-tier-8"] then
    data.raw.item["ai-tier-8"].localised_name = {"item-name.ai-tier-8_nocolor"}
  end
  if data.raw.item["ai-tier-9"] then
    data.raw.item["ai-tier-9"].localised_name = {"item-name.ai-tier-9_nocolor"}
  end
  if data.raw.item["ai-tier-10"] then
    data.raw.item["ai-tier-10"].localised_name = {"item-name.ai-tier-10_nocolor"}
  end
  if data.raw.item["datacell-raw-data"] then
    data.raw.item["datacell-raw-data"].localised_name = {"item-name.datacell-raw-data_nocolor"}
  end
  if data.raw.item["datacell-equation"] then
    data.raw.item["datacell-equation"].localised_name = {"item-name.datacell-equation_nocolor"}
  end
  if data.raw.item["datacell-solved-equation"] then
    data.raw.item["datacell-solved-equation"].localised_name = {"item-name.datacell-solved-equation_nocolor"}
  end
  if data.raw.item["datacell-ai-model-data"] then
    data.raw.item["datacell-ai-model-data"].localised_name = {"item-name.datacell-ai-model-data_nocolor"}
  end
  if data.raw.item["datacell-cosmic-data-outsignal"] then
    data.raw.item["datacell-cosmic-data-outsignal"].localised_name = {"item-name.datacell-cosmic-data-outsignal_nocolor"}
  end
  if data.raw.item["datacell-cosmic-data"] then
    data.raw.item["datacell-cosmic-data"].localised_name = {"item-name.datacell-cosmic-data_nocolor"}
  end
  -- fluid
  if data.raw.fluid["raw-data"] then
    data.raw.fluid["raw-data"].localised_name = {"fluid-name.raw-data_nocolor"}
  end
  if data.raw.fluid["solved-equation-data"] then
    data.raw.fluid["solved-equation-data"].localised_name = {"fluid-name.solved-equation-data_nocolor"}
  end
  if data.raw.fluid["cosmic-data-outsignal"] then
    data.raw.fluid["cosmic-data-outsignal"].localised_name = {"fluid-name.cosmic-data-outsignal_nocolor"}
  end
  if data.raw.fluid["cosmic-data"] then
    data.raw.fluid["cosmic-data"].localised_name = {"fluid-name.cosmic-data_nocolor"}
  end
  -- recipe
  if data.raw.recipe["data-extractor"] then
    data.raw.recipe["data-extractor"].localised_name = {"recipe-name.data-extractor_nocolor"}
  end
  if data.raw.recipe["datacell-raw-data"] then
    data.raw.recipe["datacell-raw-data"].localised_name = {"recipe-name.datacell-raw-data_nocolor"}
  end
  if data.raw.recipe["datacell-remove-raw-data"] then
    data.raw.recipe["datacell-remove-raw-data"].localised_name = {"recipe-name.datacell-remove-raw-data_nocolor"}
  end
  if data.raw.recipe["datacell-solved-equation"] then
    data.raw.recipe["datacell-solved-equation"].localised_name = {"recipe-name.datacell-solved-equation_nocolor"}
  end
  if data.raw.recipe["datacell-remove-solved-equation"] then
    data.raw.recipe["datacell-remove-solved-equation"].localised_name = {"recipe-name.datacell-remove-solved-equation_nocolor"}
  end
  if data.raw.recipe["datacell-ai-model-data"] then
    data.raw.recipe["datacell-ai-model-data"].localised_name = {"recipe-name.datacell-ai-model-data_nocolor"}
  end
  if data.raw.recipe["datacell-remove-ai-model-data"] then
    data.raw.recipe["datacell-remove-ai-model-data"].localised_name = {"recipe-name.datacell-remove-ai-model-data_nocolor"}
  end
  if data.raw.recipe["cosmic-data-outsignal-creation"] then
    data.raw.recipe["cosmic-data-outsignal-creation"].localised_name = {"recipe-name.cosmic-data-outsignal-creation_nocolor"}
  end
  if data.raw.recipe["datacell-cosmic-data-outsignal"] then
    data.raw.recipe["datacell-cosmic-data-outsignal"].localised_name = {"recipe-name.datacell-cosmic-data-outsignal_nocolor"}
  end
  if data.raw.recipe["datacell-remove-cosmic-data-outsignal"] then
    data.raw.recipe["datacell-remove-cosmic-data-outsignal"].localised_name = {"recipe-name.datacell-remove-cosmic-data-outsignal_nocolor"}
  end
  if data.raw.recipe["datacell-cosmic-data"] then
    data.raw.recipe["datacell-cosmic-data"].localised_name = {"recipe-name.datacell-cosmic-data_nocolor"}
  end
  if data.raw.recipe["datacell-remove-cosmic-data"] then
    data.raw.recipe["datacell-remove-cosmic-data"].localised_name = {"recipe-name.datacell-remove-cosmic-data_nocolor"}
  end
end