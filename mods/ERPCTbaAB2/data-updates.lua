local recipe = data.raw.recipe
local technology = data.raw.technology

local stack_inserter = data.raw.item["bulk-inserter"] and "bulk-inserter" or "stack-inserter"
local refurbish_probability = settings.startup["ERPCTbaAB2-refurbish-not-guaranteed"].value
  and settings.startup["ERPCTbaAB2-refurbish-chance"].value or 1

local function add_delivery(name, material)
  local delivery = util.table.deepcopy(recipe["iron-delivery"])
  delivery.name = name .. "-delivery"
  delivery.results = { { type = "item", name = material, amount = 100 } }
  data:extend({ delivery })
end

local function add_science_ingredient(tech_name, pack)
  local tech = technology[tech_name]
  if not (tech and tech.unit and tech.unit.ingredients) then return end
  for _, ingredient in pairs(tech.unit.ingredients) do
    if (ingredient.name or ingredient[1]) == pack then return end
  end
  table.insert(tech.unit.ingredients, { pack, 1 })
end

recipe["advanced-assembler"].ingredients = {
  { type = "item", name = "bob-assembling-machine-6", amount = 50 },
  { type = "item", name = "bob-advanced-processing-unit", amount = 200 },
  { type = "item", name = "bob-nitinol-alloy", amount = 200 },
  { type = "item", name = "bob-titanium-plate", amount = 400 },
  { type = "item", name = stack_inserter, amount = 10 },
}

recipe["autonomous-space-mining-drone"].ingredients = {
  { type = "item", name = "bob-assembling-machine-6", amount = 100 },
  { type = "item", name = "bob-mining-drill-4", amount = 1000 },
  { type = "item", name = "rocket-fuel", amount = 200 },
  { type = "item", name = "radioisotope-thermoelectric-generator", amount = 100 },
  { type = "item", name = "satellite-bus", amount = 30 },
  { type = "item", name = "satellite-communications", amount = 1 },
  { type = "item", name = "satellite-flight-computer", amount = 50 },
  { type = "item", name = "satellite-radar", amount = 10 },
  { type = "item", name = "satellite-thruster", amount = 10 },
  { type = "item", name = stack_inserter, amount = 100 },
}

recipe["ground-auto-fabricator"].ingredients = {
  { type = "item", name = "ground-fabricator-component", amount = 10 },
}

recipe["ground-telescope"].ingredients = {
  { type = "item", name = "electric-engine-unit", amount = 1000 },
  { type = "item", name = "bob-nitinol-alloy", amount = 1000 },
  { type = "item", name = "processing-unit", amount = 500 },
  { type = "item", name = "telescope-components", amount = 1 },
  { type = "item", name = "bob-titanium-plate", amount = 1000 },
  { type = "item", name = "bob-tungsten-pipe", amount = 1000 },
}

recipe["orbital-fabricator-component"].ingredients = {
  { type = "item", name = "advanced-assembler", amount = 100 },
  { type = "item", name = "autonomous-space-mining-drone", amount = 10 },
  { type = "item", name = "bob-electric-furnace-3", amount = 500 },
  { type = "item", name = "angels-oil-refinery-4", amount = 50 },
  { type = "item", name = "satellite-bus", amount = 200 },
  { type = "item", name = "satellite-communications", amount = 500 },
  { type = "item", name = "satellite-flight-computer", amount = 250 },
  { type = "item", name = stack_inserter, amount = 500 },
}

recipe["radioisotope-thermoelectric-generator"].ingredients = {
  { type = "item", name = "bob-insulated-cable", amount = 500 },
  { type = "item", name = "processing-unit", amount = 100 },
  { type = "item", name = "bob-titanium-plate", amount = 100 },
  { type = "item", name = "uranium-fuel-cell", amount = 100 },
}

recipe["refurbish-fabricator-shuttle"].ingredients = {
  { type = "fluid", name = "water", amount = 20000 },
  { type = "item", name = "landed-fabricator-shuttle", amount = 1 },
  { type = "item", name = "orbital-fabricator-component", amount = 1 },
  { type = "item", name = "rocket-fuel", amount = 2000 },
}
recipe["refurbish-fabricator-shuttle"].results = {
  { type = "item", name = "fabricator-shuttle", amount = 1, probability = refurbish_probability },
  { type = "item", name = "ground-fabricator-component", amount = 1 },
}

recipe["refurbish-mining-shuttle"].ingredients = {
  { type = "fluid", name = "water", amount = 20000 },
  { type = "item", name = "landed-mining-shuttle", amount = 1 },
  { type = "item", name = "rocket-fuel", amount = 2000 },
}
recipe["refurbish-mining-shuttle"].results = {
  { type = "item", name = "mining-shuttle", amount = 1, probability = refurbish_probability },
  { type = "item", name = "random-dropship", amount = 20000 },
}

recipe["refurbish-space-shuttle"].ingredients = {
  { type = "fluid", name = "water", amount = 20000 },
  { type = "item", name = "landed-shuttle", amount = 1 },
  { type = "item", name = "rocket-fuel", amount = 1000 },
  { type = "item", name = "space-lab-payload", amount = 1 },
}
recipe["refurbish-space-shuttle"].results = {
  { type = "item", name = "station-science", amount = 2 },
  { type = "item", name = "space-shuttle", amount = 1, probability = refurbish_probability },
}

recipe["refurbish-spy-shuttle"].ingredients = {
  { type = "fluid", name = "water", amount = 20000 },
  { type = "item", name = "landed-spy-shuttle", amount = 1 },
  { type = "item", name = "rocket-fuel", amount = 1000 },
}
recipe["refurbish-spy-shuttle"].results = {
  { type = "item", name = "spy-shuttle", amount = 1, probability = refurbish_probability },
  { type = "item", name = "planetary-data", amount = 2 },
}

recipe["satellite-battery"].ingredients = {
  { type = "item", name = "bob-insulated-cable", amount = 100 },
  { type = "item", name = "bob-large-accumulator-3", amount = 150 },
  { type = "item", name = "processing-unit", amount = 10 },
  { type = "item", name = "power-switch", amount = 1 },
}

recipe["satellite-bus"].ingredients = {
  { type = "item", name = "electric-engine-unit", amount = 50 },
  { type = "item", name = "bob-gilded-copper-cable", amount = 1000 },
  { type = "item", name = "low-density-structure", amount = 200 },
}

recipe["satellite-communications"].ingredients = {
  { type = "item", name = "electric-engine-unit", amount = 10 },
  { type = "item", name = "low-density-structure", amount = 20 },
  { type = "item", name = "processing-unit", amount = 10 },
}

recipe["satellite-flight-computer"].ingredients = {
  { type = "item", name = "bob-advanced-processing-unit", amount = 300 },
  { type = "item", name = "green-wire", amount = 500 },
  { type = "item", name = "red-wire", amount = 500 },
  { type = "item", name = "processing-unit", amount = 100 },
}

recipe["satellite-radar"].ingredients = {
  { type = "item", name = "electric-engine-unit", amount = 10 },
  { type = "item", name = "low-density-structure", amount = 20 },
  { type = "item", name = "processing-unit", amount = 30 },
}

recipe["satellite-solar-array"].ingredients = {
  { type = "item", name = "electric-engine-unit", amount = 10 },
  { type = "item", name = "bob-gilded-copper-cable", amount = 400 },
  { type = "item", name = "bob-insulated-cable", amount = 500 },
  { type = "item", name = "low-density-structure", amount = 10 },
  { type = "item", name = "power-switch", amount = 1 },
  { type = "item", name = "bob-solar-panel-3", amount = 10 },
}

recipe["satellite-thruster"].ingredients = {
  { type = "item", name = "low-density-structure", amount = 50 },
  { type = "item", name = "processing-unit", amount = 10 },
  { type = "item", name = "rocket-fuel", amount = 200 },
  { type = "item", name = "engine-unit", amount = 150 },
  { type = "item", name = "electric-engine-unit", amount = 150 },
}

recipe["shuttle-hull-recipe"].ingredients = {
  { type = "item", name = "satellite-battery", amount = 40 },
  { type = "item", name = "satellite-bus", amount = 70 },
  { type = "item", name = "satellite-communications", amount = 20 },
  { type = "item", name = "satellite-flight-computer", amount = 50 },
  { type = "item", name = "satellite-radar", amount = 30 },
  { type = "item", name = "satellite-solar-array", amount = 50 },
  { type = "item", name = "plastic-bar", amount = 10000 },
}

recipe["space-lab-payload"].ingredients = {
  { type = "item", name = "satellite-bus", amount = 1 },
  { type = "item", name = "satellite-battery", amount = 1 },
  { type = "item", name = "satellite-communications", amount = 1 },
  { type = "item", name = "satellite-flight-computer", amount = 1 },
  { type = "item", name = "satellite-solar-array", amount = 1 },
}

recipe["telescope-components"].ingredients = {
  { type = "item", name = "electric-engine-unit", amount = 50 },
  { type = "item", name = "low-density-structure", amount = 100 },
  { type = "item", name = "satellite-flight-computer", amount = 10 },
}

bobmods.lib.tech.add_recipe_unlock("asteroid-mining", "random-dropship-unboxing")
bobmods.lib.tech.remove_recipe_unlock("asteroid-mining", "copper-dropship-unboxing")
bobmods.lib.tech.remove_recipe_unlock("asteroid-mining", "iron-dropship-unboxing")

data.raw["assembling-machine"]["advanced-assembler"].crafting_categories = { "satellite-crafting" }
data.raw["assembling-machine"]["ground-auto-fabricator"].energy_usage = "1GW"

add_delivery("aluminium-plate", "bob-aluminium-plate")
add_delivery("titanium-plate", "bob-titanium-plate")

bobmods.lib.tech.add_recipe_unlock("orbital-autonomous-fabricators", "aluminium-plate-delivery")
bobmods.lib.tech.add_recipe_unlock("orbital-autonomous-fabricators", "titanium-plate-delivery")

recipe["aluminium-plate-delivery"].order = "b1"
recipe["copper-delivery"].order = "b2"
recipe["iron-delivery"].order = "b3"
recipe["steel-delivery"].order = "b4"
recipe["stone-delivery"].order = "b5"
recipe["titanium-plate-delivery"].order = "b6"
recipe["uranium-delivery"].order = "b7"

if mods["angelspetrochem"] and settings.startup["ERPCTbaAB2-use-petrochem-buildings"].value then
  table.insert(recipe["orbital-fabricator-component"].ingredients, { type = "item", name = "angels-chemical-plant-4", amount = 100 })
else
  table.insert(recipe["orbital-fabricator-component"].ingredients, { type = "item", name = "chemical-plant", amount = 10 })
end

if mods["angelsrefining"] and settings.startup["ERPCTbaAB2-give-refining-ores"].value then
  recipe["random-dropship-unboxing"].results = {
    { type = "item", name = "angels-ore1", amount_min = 10, amount_max = 50, probability = 0.65 },
    { type = "item", name = "angels-ore3", amount_min = 20, amount_max = 50, probability = 0.30 },
    { type = "item", name = "angels-ore6", amount_min = 30, amount_max = 50, probability = 0.22 },
    { type = "item", name = "angels-ore5", amount_min = 20, amount_max = 40, probability = 0.25 },
    { type = "item", name = "angels-ore4", amount_min = 10, amount_max = 30, probability = 0.12 },
    { type = "item", name = "angels-ore2", amount_min = 15, amount_max = 30, probability = 0.13 },
  }
  if mods["angelssmelting"] then
    local results = recipe["random-dropship-unboxing"].results
    results[#results + 1] = { type = "item", name = "angels-platinum-ore", amount_min = 1, amount_max = 5, probability = 0.01 }
  end
end

if not (settings.startup["bobmods-logistics-disableroboports"] and settings.startup["bobmods-logistics-disableroboports"].value) then
  table.insert(recipe["satellite-communications"].ingredients, { type = "item", name = "bob-roboport-4", amount = 5 })
else
  table.insert(recipe["satellite-communications"].ingredients, { type = "item", name = "bob-robochest-4", amount = 4 })
  table.insert(recipe["satellite-communications"].ingredients, { type = "item", name = "bob-logistic-zone-expander-4", amount = 4 })
  table.insert(recipe["satellite-communications"].ingredients, { type = "item", name = "bob-robo-charge-port-large-4", amount = 3 })
end

if mods["bobmodules"] then
  table.insert(recipe["satellite-communications"].ingredients, { type = "item", name = "bob-beacon-3", amount = 5 })
else
  table.insert(recipe["satellite-communications"].ingredients, { type = "item", name = "beacon", amount = 15 })
end

if mods["bobrevamp"] and settings.startup["ERPCTbaAB2-use-heat-shield-tile"].value then
  table.insert(recipe["shuttle-hull-recipe"].ingredients, { type = "item", name = "bob-heat-shield-tile", amount = 25000 })
  table.insert(recipe["refurbish-fabricator-shuttle"].ingredients, { type = "item", name = "bob-heat-shield-tile", amount = 2500 })
  table.insert(recipe["refurbish-mining-shuttle"].ingredients, { type = "item", name = "bob-heat-shield-tile", amount = 1000 })
  table.insert(recipe["refurbish-space-shuttle"].ingredients, { type = "item", name = "bob-heat-shield-tile", amount = 250 })
  table.insert(recipe["refurbish-spy-shuttle"].ingredients, { type = "item", name = "bob-heat-shield-tile", amount = 500 })
else
  table.insert(recipe["shuttle-hull-recipe"].ingredients, { type = "item", name = "stone-brick", amount = 50000 })
  table.insert(recipe["refurbish-mining-shuttle"].ingredients, { type = "item", name = "stone-brick", amount = 2000 })
  table.insert(recipe["refurbish-space-shuttle"].ingredients, { type = "item", name = "stone-brick", amount = 500 })
  table.insert(recipe["refurbish-spy-shuttle"].ingredients, { type = "item", name = "stone-brick", amount = 1000 })
end

if mods["bobtech"] then
  local lab = data.raw["lab"]["bob-lab-2"]
  if lab then
    table.insert(lab.inputs, "planetary-data")
    table.insert(lab.inputs, "station-science")
  end
  table.insert(recipe["space-lab-payload"].ingredients, { type = "item", name = "bob-lab-2", amount = 200 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "bob-lab-2", amount = 100 })
else
  table.insert(recipe["space-lab-payload"].ingredients, { type = "item", name = "lab", amount = 200 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "lab", amount = 100 })
end

if mods["bobwarfare"] and data.raw.item["bob-radar-5"] then
  table.insert(recipe["satellite-radar"].ingredients, { type = "item", name = "bob-radar-5", amount = 100 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "bob-radar-5", amount = 2000 })
else
  table.insert(recipe["satellite-radar"].ingredients, { type = "item", name = "radar", amount = 100 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "radar", amount = 2000 })
end

if mods["Clowns-AngelBob-Nuclear"] then
  local thorium = util.table.deepcopy(recipe["radioisotope-thermoelectric-generator"])
  thorium.name = "radioisotope-thermoelectric-generator-thorium"
  thorium.ingredients = {
    { type = "item", name = "bob-thorium-fuel-cell", amount = 100 },
    { type = "item", name = "bob-insulated-cable", amount = 500 },
    { type = "item", name = "processing-unit", amount = 100 },
    { type = "item", name = "bob-titanium-plate", amount = 100 },
  }
  data:extend({ thorium })
  if technology["extremely-advanced-material-processing"] then
    table.insert(technology["extremely-advanced-material-processing"].effects,
      { type = "unlock-recipe", recipe = "radioisotope-thermoelectric-generator-thorium" })
  end
end

if mods["Clowns-Processing"] then
  table.insert(recipe["orbital-fabricator-component"].ingredients, { type = "item", name = "bob-centrifuge-3", amount = 250 })
else
  table.insert(recipe["orbital-fabricator-component"].ingredients, { type = "item", name = "centrifuge", amount = 250 })
end

if mods["extendedangels"] and settings.startup["ERPCTbaAB2-use-titanium-concrete"].value then
  table.insert(recipe["advanced-assembler"].ingredients, { type = "item", name = "angels-titanium-concrete-brick", amount = 400 })
  table.insert(recipe["ground-telescope"].ingredients, { type = "item", name = "angels-titanium-concrete-brick", amount = 1000 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "angels-titanium-concrete-brick", amount = 10000 })
elseif mods["angelssmelting"] and mods["angelspetrochem"] then
  table.insert(recipe["advanced-assembler"].ingredients, { type = "item", name = "angels-reinforced-concrete-brick", amount = 400 })
  table.insert(recipe["ground-telescope"].ingredients, { type = "item", name = "angels-reinforced-concrete-brick", amount = 1000 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "angels-reinforced-concrete-brick", amount = 10000 })
else
  table.insert(recipe["advanced-assembler"].ingredients, { type = "item", name = "refined-concrete", amount = 400 })
  table.insert(recipe["ground-telescope"].ingredients, { type = "item", name = "refined-concrete", amount = 1000 })
  table.insert(recipe["telescope-components"].ingredients, { type = "item", name = "refined-concrete", amount = 10000 })
end

if mods["Kux-OrbitalIonCannon"] and technology["orbital-ion-cannon"] then
  bobmods.lib.tech.add_prerequisite("orbital-ion-cannon", "robot-global-positioning-system-1")
  bobmods.lib.tech.remove_prerequisite("orbital-ion-cannon", "rocket-silo")
  technology["auto-targeting"].unit.count = 25000
  technology["orbital-ion-cannon"].unit.count = 20000
end

if mods["SpaceModFeorasFork"] and settings.startup["ERPCTbaAB2-integrate-spacex"].value then
  bobmods.lib.tech.add_prerequisite("fusion-reactor", "orbital-assembler-power-problem")
  bobmods.lib.tech.add_prerequisite("orbital-ai-core", "ftl-propulsion")
  bobmods.lib.tech.add_prerequisite("orbital-autonomous-fabricators", "space-station-assembly")
  bobmods.lib.tech.add_prerequisite("space-assembly", "space-assembler-theory")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "astrometrics")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "fuel-cells")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "fusion-reactor")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "habitation")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "life-support-systems")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "protection-fields")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "space-casings")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "space-thrusters")
  bobmods.lib.tech.add_prerequisite("space-station-assembly", "spaceship-command")
  bobmods.lib.tech.add_prerequisite("spy-shuttle", "space-telescope")

  bobmods.lib.tech.remove_prerequisite("space-assembly", "rocket-silo")
  bobmods.lib.tech.remove_prerequisite("space-station-assembly", "extremely-advanced-rocket-payloads")

  add_science_ingredient("space-assembly", "space-science-pack")
  add_science_ingredient("space-assembly", "utility-science-pack")
  add_science_ingredient("space-casings", "space-science-pack")
  add_science_ingredient("space-casings", "utility-science-pack")
  add_science_ingredient("space-construction", "space-science-pack")
  add_science_ingredient("space-construction", "utility-science-pack")
  add_science_ingredient("protection-fields", "space-science-pack")
  add_science_ingredient("fusion-reactor", "space-science-pack")
  add_science_ingredient("space-thrusters", "space-science-pack")
  add_science_ingredient("space-thrusters", "utility-science-pack")
  add_science_ingredient("fuel-cells", "space-science-pack")
  add_science_ingredient("habitation", "space-science-pack")
  add_science_ingredient("life-support-systems", "space-science-pack")
  add_science_ingredient("spaceship-command", "space-science-pack")

  if mods["angelsbioprocessing"] and recipe["life-support"] and recipe["life-support"].ingredients then
    table.insert(recipe["life-support"].ingredients, { type = "item", name = "angels-desert-5-seed", amount = 50 })
    table.insert(recipe["life-support"].ingredients, { type = "item", name = "angels-swamp-5-seed", amount = 50 })
    table.insert(recipe["life-support"].ingredients, { type = "item", name = "angels-temperate-5-seed", amount = 50 })
  end

  if mods["bobrevamp"] and settings.startup["ERPCTbaAB2-use-heat-shield-tile"].value and recipe["hull-component"] then
    local production_setting = settings.startup["SpaceX-production"]
    local production_cost = production_setting and production_setting.value or 1
    recipe["hull-component"].ingredients = {
      { type = "item", name = "low-density-structure", amount = 250 * production_cost },
      { type = "item", name = "bob-heat-shield-tile", amount = 100 * production_cost },
    }
  end
end
