-- Reviewed normal Beta 8 fields; adapted IDs and liquid fuel rules (energy decisions 2026-10-09).
return {
  migration_recipes = {
    ["uranium-fuel-cell"] = {["ingredients"] = {{["type"] = "item", ["name"] = "35pc-uranium", ["amount"] = 1}, {["type"] = "item", ["name"] = "uranium-238", ["amount"] = 29}, {["type"] = "item", ["name"] = "iron-plate", ["amount"] = 15}}, ["results"] = {{["name"] = "uranium-fuel-cell", ["type"] = "item", ["amount"] = 15}}, ["category"] = "centrifuging", ["energy_required"] = 10},
    ["angels-uranium-fuel-cell"] = {["ingredients"] = {{["type"] = "item", ["name"] = "angels-uranium-234", ["amount"] = 1}, {["type"] = "item", ["name"] = "uranium-238", ["amount"] = 199}, {["type"] = "item", ["name"] = "iron-plate", ["amount"] = 100}}, ["results"] = {{["type"] = "item", ["name"] = "angels-uranium-fuel-cell", ["amount"] = 100}}, ["category"] = "centrifuging", ["energy_required"] = 700},
  },
  items = {
    ["angels-wood-bricks"] = {["fuel_value"] = "20MJ", ["fuel_category"] = "chemical", ["stack_size"] = 200, ["fuel_emissions_multiplier"] = 1.05, ["fuel_acceleration_multiplier"] = 1, ["fuel_top_speed_multiplier"] = 1},
    ["angels-pellet-coke"] = {["fuel_value"] = "15MJ", ["fuel_category"] = "chemical", ["stack_size"] = 400, ["fuel_emissions_multiplier"] = 1.05, ["fuel_acceleration_multiplier"] = 1.1, ["fuel_top_speed_multiplier"] = 1.2},
    ["angels-wood-charcoal"] = {["fuel_value"] = "5MJ", ["fuel_category"] = "chemical", ["stack_size"] = 200, ["fuel_emissions_multiplier"] = 1.25, ["fuel_acceleration_multiplier"] = 1, ["fuel_top_speed_multiplier"] = 1},
    ["coal"] = {["stack_size"] = 400},
    ["uranium-fuel-cell"] = {["fuel_value"] = "8GJ"},
    ["angels-mixed-oxide-cell"] = {["fuel_value"] = "40GJ"},
    ["angels-thorium-fuel-cell"] = {["fuel_value"] = "12GJ"},
    ["angels-deuterium-fuel-cell"] = {["fuel_value"] = "80GJ"},
  },
  recipes = {
    ["angels-wood-bricks"] = {["ingredients"] = {{["type"] = "item", ["name"] = "angels-wood-pellets", ["amount"] = 8}}, ["energy_required"] = 2, ["results"] = {{["type"] = "item", ["name"] = "angels-wood-bricks", ["amount"] = 4}}, ["category"] = "crafting"},
    ["bi-wood-fuel-brick"] = {["ingredients"] = {{["type"] = "item", ["name"] = "bi-woodpulp", ["amount"] = 40}}, ["energy_required"] = 2, ["results"] = {{["type"] = "item", ["name"] = "angels-wood-bricks", ["amount"] = 1}}, ["category"] = "crafting"},
    ["angels-pellet-coke"] = {["ingredients"] = {{["type"] = "item", ["name"] = "angels-solid-coke", ["amount"] = 5}}, ["energy_required"] = 1, ["results"] = {{["type"] = "item", ["name"] = "angels-pellet-coke", ["amount"] = 1}}, ["category"] = "biofarm-mod-smelting"},
    ["bi-pellet-coke"] = {["ingredients"] = {{["name"] = "solid-fuel", ["type"] = "item", ["amount"] = 5}}, ["energy_required"] = 4, ["results"] = {{["type"] = "item", ["name"] = "angels-pellet-coke", ["amount"] = 4}}, ["category"] = "biofarm-mod-smelting"},
    ["bi-coke-coal"] = {["ingredients"] = {{["name"] = "coal", ["type"] = "item", ["amount"] = 12}}, ["energy_required"] = 20, ["results"] = {{["type"] = "item", ["name"] = "angels-pellet-coke", ["amount"] = 2}}, ["category"] = "biofarm-mod-smelting"},
    ["bi-pellet-coke-2"] = {["ingredients"] = {{["name"] = "angels-solid-carbon", ["amount"] = 5, ["type"] = "item"}}, ["energy_required"] = 4, ["results"] = {{["type"] = "item", ["name"] = "angels-pellet-coke", ["amount"] = 1}}, ["category"] = "biofarm-mod-smelting"},
    ["angels-wood-charcoal"] = {["ingredients"] = {{["type"] = "item", ["name"] = "angels-wood-pellets", ["amount"] = 2}}, ["energy_required"] = 2, ["results"] = {{["type"] = "item", ["name"] = "angels-wood-charcoal", ["amount"] = 3}}, ["category"] = "biofarm-mod-smelting"},
    ["bi-charcoal-1"] = {["ingredients"] = {{["name"] = "bi-woodpulp", ["type"] = "item", ["amount"] = 24}}, ["energy_required"] = 15, ["results"] = {{["type"] = "item", ["name"] = "angels-wood-charcoal", ["amount"] = 5}}, ["category"] = "biofarm-mod-smelting"},
    ["bi-charcoal-2"] = {["ingredients"] = {{["name"] = "wood", ["type"] = "item", ["amount"] = 20}}, ["energy_required"] = 20, ["results"] = {{["type"] = "item", ["name"] = "angels-wood-charcoal", ["amount"] = 8}}, ["category"] = "biofarm-mod-smelting"},
    ["uranium-fuel-cell"] = {["ingredients"] = {{["type"] = "item", ["name"] = "bob-lead-plate", ["amount"] = 10}, {["type"] = "item", ["name"] = "35pc-uranium", ["amount"] = 20}}, ["energy_required"] = 10, ["results"] = {{["type"] = "item", ["name"] = "uranium-fuel-cell", ["amount"] = 5}}},
    ["bi-bio-boiler"] = {["ingredients"] = {{["name"] = "boiler", ["type"] = "item", ["amount"] = 2}, {["name"] = "steel-plate", ["type"] = "item", ["amount"] = 20}, {["name"] = "concrete", ["type"] = "item", ["amount"] = 20}, {["name"] = "electronic-circuit", ["type"] = "item", ["amount"] = 5}}, ["energy_required"] = 10},
    ["bi-solar-boiler-hidden-panel"] = {["ingredients"] = {{["name"] = "solar-panel", ["type"] = "item", ["amount"] = 30}, {["name"] = "storage-tank", ["type"] = "item", ["amount"] = 4}, {["name"] = "angels-electric-boiler", ["amount"] = 1, ["type"] = "item"}}, ["energy_required"] = 15},
    ["bob-boiler-2"] = {["ingredients"] = {{["name"] = "bob-steel-pipe", ["amount"] = 15, ["type"] = "item"}, {["name"] = "boiler", ["amount"] = 2, ["type"] = "item"}, {["name"] = "steel-plate", ["amount"] = 20, ["type"] = "item"}}, ["energy_required"] = 10},
    ["bob-boiler-3"] = {["ingredients"] = {{["name"] = "bob-brass-pipe", ["amount"] = 15, ["type"] = "item"}, {["name"] = "bob-boiler-2", ["amount"] = 2, ["type"] = "item"}, {["name"] = "bob-invar-alloy", ["amount"] = 20, ["type"] = "item"}}, ["energy_required"] = 15},
    ["bob-boiler-4"] = {["ingredients"] = {{["name"] = "bob-ceramic-pipe", ["amount"] = 15, ["type"] = "item"}, {["name"] = "bob-boiler-3", ["amount"] = 2, ["type"] = "item"}, {["name"] = "tungsten-plate", ["amount"] = 20, ["type"] = "item"}}, ["energy_required"] = 20},
    ["bob-boiler-5"] = {["ingredients"] = {{["name"] = "bob-copper-tungsten-pipe", ["amount"] = 15, ["type"] = "item"}, {["name"] = "bob-boiler-4", ["amount"] = 2, ["type"] = "item"}, {["name"] = "bob-copper-tungsten-alloy", ["amount"] = 20, ["type"] = "item"}}, ["energy_required"] = 30},
    ["heat-exchanger"] = {["ingredients"] = {{["name"] = "bob-boiler-2", ["type"] = "item", ["amount"] = 1}, {["name"] = "heat-pipe", ["type"] = "item", ["amount"] = 4}}, ["energy_required"] = 10},
    ["bob-heat-exchanger-2"] = {["ingredients"] = {{["name"] = "heat-exchanger", ["type"] = "item", ["amount"] = 1}, {["name"] = "bob-heat-pipe-2", ["type"] = "item", ["amount"] = 8}, {["name"] = "bob-invar-alloy", ["amount"] = 10, ["type"] = "item"}, {["name"] = "bob-brass-pipe", ["amount"] = 4, ["type"] = "item"}}, ["energy_required"] = 20},
    ["bob-heat-exchanger-3"] = {["ingredients"] = {{["name"] = "bob-heat-exchanger-2", ["type"] = "item", ["amount"] = 1}, {["name"] = "bob-heat-pipe-3", ["type"] = "item", ["amount"] = 8}, {["name"] = "tungsten-plate", ["amount"] = 10, ["type"] = "item"}, {["name"] = "bob-ceramic-pipe", ["amount"] = 4, ["type"] = "item"}}, ["energy_required"] = 30},
    ["bob-heat-exchanger-4"] = {["ingredients"] = {{["name"] = "bob-heat-exchanger-3", ["type"] = "item", ["amount"] = 1}, {["name"] = "bob-heat-pipe-4", ["type"] = "item", ["amount"] = 8}, {["name"] = "bob-copper-tungsten-alloy", ["amount"] = 10, ["type"] = "item"}, {["name"] = "bob-copper-tungsten-pipe", ["amount"] = 4, ["type"] = "item"}}, ["energy_required"] = 0.5},
    ["steam-turbine"] = {["ingredients"] = {{["name"] = "bob-cobalt-steel-bearing", ["amount"] = 10, ["type"] = "item"}, {["name"] = "bob-cobalt-steel-gear-wheel", ["amount"] = 20, ["type"] = "item"}, {["name"] = "bob-aluminium-plate", ["amount"] = 25, ["type"] = "item"}, {["name"] = "advanced-circuit", ["amount"] = 5, ["type"] = "item"}, {["name"] = "advanced-structure-components", ["amount"] = 3, ["type"] = "item"}, {["name"] = "bob-steam-engine-3", ["amount"] = 2, ["type"] = "item"}}, ["energy_required"] = 120},
    ["bob-steam-turbine-2"] = {["ingredients"] = {{["name"] = "bob-titanium-bearing", ["amount"] = 15, ["type"] = "item"}, {["name"] = "bob-titanium-gear-wheel", ["amount"] = 25, ["type"] = "item"}, {["name"] = "bob-titanium-plate", ["amount"] = 25, ["type"] = "item"}, {["name"] = "bob-titanium-pipe", ["amount"] = 5, ["type"] = "item"}, {["name"] = "processing-unit", ["amount"] = 5, ["type"] = "item"}, {["name"] = "advanced-structure-components", ["amount"] = 5, ["type"] = "item"}, {["name"] = "steam-turbine", ["amount"] = 2, ["type"] = "item"}}, ["energy_required"] = 90},
    ["bob-steam-turbine-3"] = {["ingredients"] = {{["name"] = "bob-nitinol-bearing", ["amount"] = 15, ["type"] = "item"}, {["name"] = "bob-nitinol-gear-wheel", ["amount"] = 25, ["type"] = "item"}, {["name"] = "bob-nitinol-alloy", ["amount"] = 25, ["type"] = "item"}, {["name"] = "bob-copper-tungsten-pipe", ["amount"] = 5, ["type"] = "item"}, {["name"] = "bob-advanced-processing-unit", ["amount"] = 5, ["type"] = "item"}, {["name"] = "anotherworld-structure-components", ["amount"] = 1, ["type"] = "item"}, {["name"] = "bob-steam-turbine-2", ["amount"] = 2, ["type"] = "item"}}, ["energy_required"] = 60},
    ["burner-turbine"] = {["ingredients"] = {{["type"] = "item", ["name"] = "electric-motor", ["amount"] = 8}, {["type"] = "item", ["name"] = "iron-gear-wheel", ["amount"] = 10}, {["type"] = "item", ["name"] = "stone-furnace", ["amount"] = 2}}, ["energy_required"] = 5},
    -- Beta 8 diesel recipe (KS_Power fork of that build), IDs adapted (2026-10-15 user decision).
    ["diesel-fuel"] = {["ingredients"] = {{["type"] = "fluid", ["name"] = "angels-gas-methane", ["amount"] = 20}, {["type"] = "fluid", ["name"] = "bob-liquid-fuel", ["amount"] = 20}, {["type"] = "item", ["name"] = "angels-catalysator-brown", ["amount"] = 1}}, ["results"] = {{["type"] = "fluid", ["name"] = "diesel-fuel", ["amount"] = 25, ["temperature"] = 25}}, ["energy_required"] = 5},
  },
  entities = {
    {["type"] = "boiler", ["name"] = "bi-bio-boiler", ["fields"] = {["energy_consumption"] = "3.6MW", ["target_temperature"] = 165}},
    {["type"] = "boiler", ["name"] = "bi-solar-boiler", ["fields"] = {["energy_consumption"] = "950kW", ["target_temperature"] = 165}},
    {["type"] = "rocket-silo", ["name"] = "rocket-silo", ["fields"] = {["energy_usage"] = "250000kW"}},
    {["type"] = "lab", ["name"] = "erp-lab", ["fields"] = {["energy_usage"] = "10000kW"}},
    {["type"] = "roboport", ["name"] = "roboport", ["fields"] = {["charging_energy"] = "1000kW"}},
  },
  cranes = {
    ["nco-wide-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.05750000000000001, ["extension_speed"] = 0.05750000000000001, ["energy_per_movement"] = "584350J", ["energy_per_rotation"] = "584350J", ["bulk"] = false, ["drain"] = "1.2kW"},
    ["nco-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.0161, ["extension_speed"] = 0.0161, ["energy_per_movement"] = "586960J", ["energy_per_rotation"] = "586960J", ["bulk"] = false, ["drain"] = "1.2kW"},
    ["nco-red-wide-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.0384, ["extension_speed"] = 0.0384, ["energy_per_movement"] = "510420J", ["energy_per_rotation"] = "510420J", ["bulk"] = false, ["drain"] = "1kW"},
    ["nco-red-crane"] = {["stack_size_bonus"] = 122, ["rotation_speed"] = 0.017199999999999997, ["extension_speed"] = 0.017199999999999997, ["energy_per_movement"] = "200310J", ["energy_per_rotation"] = "200310J", ["bulk"] = false, ["drain"] = "1kW"},
    ["nco-wide-turbo-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.0768, ["extension_speed"] = 0.0768, ["energy_per_movement"] = "656250J", ["energy_per_rotation"] = "656250J", ["bulk"] = false, ["drain"] = "1.4kW"},
    ["nco-turbo-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.0216, ["extension_speed"] = 0.0216, ["energy_per_movement"] = "656250J", ["energy_per_rotation"] = "656250J", ["bulk"] = false, ["drain"] = "1.4kW"},
    ["nco-wide-express-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.096, ["extension_speed"] = 0.096, ["energy_per_movement"] = "729170J", ["energy_per_rotation"] = "729170J", ["bulk"] = false, ["drain"] = "1.6kW"},
    ["nco-express-crane"] = {["stack_size_bonus"] = 197, ["rotation_speed"] = 0.096, ["extension_speed"] = 0.096, ["energy_per_movement"] = "729170J", ["energy_per_rotation"] = "729170J", ["bulk"] = false, ["drain"] = "1.6kW"},
  },
  fluids = {
    -- 2026-10-25 user decision: corrected Beta 8 (KS_Power) table at Beta 8 scale. Ladder: well products
    -- weak and dirty, each refining step gains energy and loses emissions. No fluid has exactly 100%
    -- emissions (the engine hides x1). Source: review/fuel-compare-20261025/build_fluids.py.
    -- Oil chain: multi-phase -> crude -> naphtha/fuel oil -> liquid fuel -> diesel
    ["angels-liquid-multi-phase-oil"] = {["fuel_value"] = "360kJ", ["emissions_multiplier"] = 15},
    ["crude-oil"] = {["fuel_value"] = "560kJ", ["emissions_multiplier"] = 10}, -- B8 734: refining lost energy (x0.92); wet well crude
    ["angels-liquid-naphtha"] = {["fuel_value"] = "660kJ", ["emissions_multiplier"] = 3},
    ["heavy-oil"] = {["fuel_value"] = "660kJ", ["emissions_multiplier"] = 3}, -- hidden, = naphtha
    ["angels-liquid-fuel-oil"] = {["fuel_value"] = "890kJ", ["emissions_multiplier"] = 1.2},
    ["light-oil"] = {["fuel_value"] = "890kJ", ["emissions_multiplier"] = 1.2}, -- hidden, = fuel oil
    ["bob-liquid-fuel"] = {["fuel_value"] = "1140kJ", ["emissions_multiplier"] = 0.95}, -- B8 default 1
    ["diesel-fuel"] = {["fuel_value"] = "2250kJ", ["emissions_multiplier"] = 0.9}, -- B8 1.5 was dirtier than its input
    ["angels-gas-residual"] = {["fuel_value"] = "700kJ", ["emissions_multiplier"] = 4.5},
    -- Gas chain: free gas -> natural gas -> NGL -> methane/ethane/butane
    ["angels-gas-natural-1"] = {["fuel_value"] = "250kJ", ["emissions_multiplier"] = 10}, -- B8 560/1: separation lost energy (x0.54)
    ["angels-gas-raw-1"] = {["fuel_value"] = "500kJ", ["emissions_multiplier"] = 4}, -- B8 default 1; contains acid gas
    ["angels-gas-acid"] = {["fuel_value"] = "304kJ", ["emissions_multiplier"] = 7},
    ["angels-liquid-ngl"] = {["fuel_value"] = "780kJ", ["emissions_multiplier"] = 1.2},
    ["angels-gas-methane"] = {["fuel_value"] = "558kJ", ["emissions_multiplier"] = 1.1},
    ["petroleum-gas"] = {["fuel_value"] = "558kJ", ["emissions_multiplier"] = 1.1}, -- hidden, = methane
    ["angels-gas-ethane"] = {["fuel_value"] = "1000kJ", ["emissions_multiplier"] = 1.5},
    ["angels-gas-butane"] = {["fuel_value"] = "1900kJ", ["emissions_multiplier"] = 1.8},
    ["angels-gas-propene"] = {["fuel_value"] = "920kJ", ["emissions_multiplier"] = 5}, -- unit fix 760->1380 (MJ/m3), then /1.5 (synthesis gain)
    ["angels-gas-ethylene"] = {["fuel_value"] = "930kJ", ["emissions_multiplier"] = 2.8}, -- unit fix 800->930 (MJ/m3)
    ["angels-gas-synthesis"] = {["fuel_value"] = "240kJ", ["emissions_multiplier"] = 0.8},
    ["angels-gas-hydrogen"] = {["fuel_value"] = "150kJ", ["emissions_multiplier"] = 0.1},
    ["bob-hydrogen"] = {["fuel_value"] = "150kJ", ["emissions_multiplier"] = 0.1}, -- hidden, = hydrogen
    ["angels-gas-deuterium"] = {["fuel_value"] = "150kJ", ["emissions_multiplier"] = 0.1},
    ["bob-deuterium"] = {["fuel_value"] = "150kJ", ["emissions_multiplier"] = 0.1}, -- hidden, = deuterium
    ["angels-gas-hydrazine"] = {["fuel_value"] = "760kJ", ["emissions_multiplier"] = 0.2},
    ["bob-hydrazine"] = {["fuel_value"] = "760kJ", ["emissions_multiplier"] = 0.2}, -- hidden, = hydrazine
    -- Aromatics and dienes (liquids per kg, gases per m3)
    ["angels-gas-benzene"] = {["fuel_value"] = "1615kJ", ["emissions_multiplier"] = 6.5}, -- B8 2420 /1.5 (synthesis gain)
    ["angels-gas-butadiene"] = {["fuel_value"] = "1265kJ", ["emissions_multiplier"] = 3}, -- B8 1896 /1.5 (synthesis gain)
    ["angels-liquid-toluene"] = {["fuel_value"] = "680kJ", ["emissions_multiplier"] = 6.5}, -- B8 2616 counted per m3 of vapour
    ["angels-liquid-ethylbenzene"] = {["fuel_value"] = "685kJ", ["emissions_multiplier"] = 6.5}, -- B8 2616 per m3 of vapour
    ["angels-liquid-styrene"] = {["fuel_value"] = "710kJ", ["emissions_multiplier"] = 6.5}, -- B8 2600 per m3 of vapour
    ["angels-liquid-phenol"] = {["fuel_value"] = "540kJ", ["emissions_multiplier"] = 6.5}, -- B8 1716 per m3 of vapour
    ["gas-vinyl-acetylene"] = {["fuel_value"] = "550kJ", ["emissions_multiplier"] = 3}, -- B8 default 1
    -- Polymers
    ["angels-liquid-polyethylene"] = {["fuel_value"] = "1796kJ", ["emissions_multiplier"] = 6.5},
    ["angels-liquid-plastic"] = {["fuel_value"] = "1280kJ", ["emissions_multiplier"] = 8}, -- B8 1920 /1.5 (synthesis gain)
    ["angels-liquid-resin"] = {["fuel_value"] = "1896kJ", ["emissions_multiplier"] = 6.5},
    ["liquid-rubber-masterbatch"] = {["fuel_value"] = "1850kJ", ["emissions_multiplier"] = 7},
    ["liquid-rubber-pre"] = {["fuel_value"] = "2150kJ", ["emissions_multiplier"] = 9},
    ["angels-liquid-rubber"] = {["fuel_value"] = "2450kJ", ["emissions_multiplier"] = 15},
    -- Alcohols and oxygenates (B8 default 1)
    ["angels-gas-methanol"] = {["fuel_value"] = "240kJ", ["emissions_multiplier"] = 0.95}, -- B8 360 /1.5 (synthesis gain)
    ["angels-gas-ethanol"] = {["fuel_value"] = "510kJ", ["emissions_multiplier"] = 0.7},
    ["angels-gas-acetone"] = {["fuel_value"] = "524kJ", ["emissions_multiplier"] = 1.05},
    ["angels-gas-formaldehyde"] = {["fuel_value"] = "280kJ", ["emissions_multiplier"] = 1.05},
    ["angels-liquid-acetic-anhydride"] = {["fuel_value"] = "255kJ", ["emissions_multiplier"] = 1.05},
    ["angels-liquid-cellulose-acetate"] = {["fuel_value"] = "310kJ", ["emissions_multiplier"] = 1.05},
    ["angels-liquid-glycerol"] = {["fuel_value"] = "310kJ", ["emissions_multiplier"] = 0.95},
    ["bob-glycerol"] = {["fuel_value"] = "310kJ", ["emissions_multiplier"] = 0.95}, -- hidden, = glycerol
    ["liquid-methyl-methacrylate"] = {["fuel_value"] = "450kJ", ["emissions_multiplier"] = 1.5},
    ["angels-liquid-bisphenol-a"] = {["fuel_value"] = "505kJ", ["emissions_multiplier"] = 4}, -- aromatic
    -- Nitrogen compounds (B8 default 1)
    ["angels-gas-ammonia"] = {["fuel_value"] = "155kJ", ["emissions_multiplier"] = 2}, -- unit fix 310->230 (MJ/m3), then /1.5 (synthesis gain)
    ["angels-gas-methylamine"] = {["fuel_value"] = "575kJ", ["emissions_multiplier"] = 2},
    ["angels-gas-dimethylamine"] = {["fuel_value"] = "620kJ", ["emissions_multiplier"] = 2},
    ["angels-gas-dimethylhydrazine"] = {["fuel_value"] = "550kJ", ["emissions_multiplier"] = 2},
    ["angels-gas-urea"] = {["fuel_value"] = "167kJ", ["emissions_multiplier"] = 2},
    ["angels-gas-melamine"] = {["fuel_value"] = "262kJ", ["emissions_multiplier"] = 2},
    ["gas-hydrogen-cyanide"] = {["fuel_value"] = "410kJ", ["emissions_multiplier"] = 4},
    ["liquid-acrylonitrile"] = {["fuel_value"] = "550kJ", ["emissions_multiplier"] = 4},
    ["liquid-acetone-cyanohydrin"] = {["fuel_value"] = "300kJ", ["emissions_multiplier"] = 4},
    ["bob-nitroglycerin"] = {["fuel_value"] = "730kJ", ["emissions_multiplier"] = 3},
    -- Chlorinated (B8 default 1)
    ["angels-gas-chlor-methane"] = {["fuel_value"] = "432kJ", ["emissions_multiplier"] = 6},
    ["gas-chloroethane"] = {["fuel_value"] = "155kJ", ["emissions_multiplier"] = 6},
    ["gas-vinyl-chloride"] = {["fuel_value"] = "310kJ", ["emissions_multiplier"] = 6},
    ["angels-gas-allylchlorid"] = {["fuel_value"] = "360kJ", ["emissions_multiplier"] = 6},
    ["liquid-dichlorobutene"] = {["fuel_value"] = "500kJ", ["emissions_multiplier"] = 6},
    -- Sulphur (B8 default 1)
    ["angels-gas-hydrogen-sulfide"] = {["fuel_value"] = "364kJ", ["emissions_multiplier"] = 8},
    ["angels-gas-enriched-hydrogen-sulfide"] = {["fuel_value"] = "364kJ", ["emissions_multiplier"] = 8},
    -- Bio oils (B8 default 1)
    ["angels-liquid-vegetable-oil"] = {["fuel_value"] = "2100kJ", ["emissions_multiplier"] = 0.95},
    ["angels-liquid-raw-vegetable-oil"] = {["fuel_value"] = "1600kJ", ["emissions_multiplier"] = 1.5},
    ["angels-liquid-fish-oil"] = {["fuel_value"] = "1900kJ", ["emissions_multiplier"] = 0.95},
    ["angels-liquid-raw-fish-oil"] = {["fuel_value"] = "1400kJ", ["emissions_multiplier"] = 1.5},
    -- 2.0 only
    ["bob-alien-fire"] = {["fuel_value"] = "2600kJ", ["emissions_multiplier"] = 1.05}, -- 2.0 value, emissions not 100%
  },
  barrels = {
    ["diesel-fuel"] = {"diesel-fuel-barrel"},
    ["bob-nitroglycerin"] = {"bob-nitroglycerin-barrel"},
    ["angels-gas-deuterium"] = {"angels-gas-deuterium-barrel", "bob-deuterium-barrel"},
    ["angels-gas-benzene"] = {"angels-gas-benzene-barrel"},
    ["angels-gas-synthesis"] = {"angels-gas-synthesis-barrel"},
    ["angels-liquid-toluene"] = {"angels-liquid-toluene-barrel"},
    ["angels-gas-butadiene"] = {"angels-gas-butadiene-barrel"},
    ["angels-liquid-phenol"] = {"angels-liquid-phenol-barrel"},
    ["angels-liquid-ethylbenzene"] = {"angels-liquid-ethylbenzene-barrel"},
    ["angels-liquid-styrene"] = {"angels-liquid-styrene-barrel"},
    ["angels-gas-formaldehyde"] = {"angels-gas-formaldehyde-barrel"},
    ["angels-liquid-polyethylene"] = {"angels-liquid-polyethylene-barrel"},
    ["angels-liquid-glycerol"] = {"angels-liquid-glycerol-barrel", "bob-glycerol-barrel"},
    ["angels-liquid-bisphenol-a"] = {"angels-liquid-bisphenol-a-barrel"},
    ["angels-gas-acetone"] = {"angels-gas-acetone-barrel"},
    ["angels-gas-allylchlorid"] = {"angels-gas-allylchlorid-barrel"},
    ["angels-gas-chlor-methane"] = {"angels-gas-chlor-methane-barrel"},
    ["angels-gas-ammonia"] = {"ammonia-barrel", "angels-gas-ammonia-barrel"},
    ["angels-gas-urea"] = {"angels-gas-urea-barrel"},
    ["angels-gas-melamine"] = {"angels-gas-melamine-barrel"},
    ["angels-gas-methylamine"] = {"angels-gas-methylamine-barrel"},
    ["angels-gas-dimethylamine"] = {"angels-gas-dimethylamine-barrel"},
    ["angels-gas-dimethylhydrazine"] = {"angels-gas-dimethylhydrazine-barrel"},
    ["angels-gas-natural-1"] = {"angels-gas-natural-1-barrel"},
    ["angels-gas-methane"] = {},
    ["crude-oil"] = {},
    ["angels-liquid-naphtha"] = {},
    ["angels-liquid-fuel-oil"] = {},
    ["bob-liquid-fuel"] = {},
    ["angels-liquid-multi-phase-oil"] = {"angels-liquid-multi-phase-oil-barrel"},
    ["angels-gas-raw-1"] = {"angels-gas-raw-1-barrel"},
    ["angels-gas-acid"] = {"angels-gas-acid-barrel"},
    ["angels-liquid-ngl"] = {"angels-liquid-ngl-barrel"},
    ["angels-gas-residual"] = {"angels-gas-residual-barrel"},
    ["angels-liquid-plastic"] = {"angels-liquid-plastic-barrel"},
    ["angels-liquid-resin"] = {"angels-liquid-resin-barrel"},
    ["angels-liquid-rubber"] = {"angels-liquid-rubber-barrel"},
    ["angels-gas-hydrogen-sulfide"] = {"angels-gas-hydrogen-sulfide-barrel", "bob-hydrogen-sulfide-barrel"},
    ["angels-gas-enriched-hydrogen-sulfide"] = {},
    ["angels-liquid-raw-vegetable-oil"] = {"angels-liquid-raw-vegetable-oil-barrel"},
    ["angels-liquid-vegetable-oil"] = {"angels-liquid-vegetable-oil-barrel"},
    ["angels-liquid-acetic-anhydride"] = {"angels-liquid-acetic-anhydride-barrel"},
    ["angels-liquid-cellulose-acetate"] = {"angels-liquid-cellulose-acetate-barrel"},
    ["angels-liquid-raw-fish-oil"] = {"angels-liquid-raw-fish-oil-barrel"},
    ["angels-liquid-fish-oil"] = {"angels-liquid-fish-oil-barrel"},
    ["gas-chloroethane"] = {"gas-chloroethane-barrel"},
    ["liquid-dichlorobutene"] = {"liquid-dichlorobutene-barrel"},
    ["gas-hydrogen-cyanide"] = {"gas-hydrogen-cyanide-barrel"},
    ["liquid-acetone-cyanohydrin"] = {"liquid-acetone-cyanohydrin-barrel"},
    ["liquid-acrylonitrile"] = {"liquid-acrylonitrile-barrel"},
    ["liquid-methyl-methacrylate"] = {"liquid-methyl-methacrylate-barrel"},
    ["gas-vinyl-chloride"] = {"gas-vinyl-chloride-barrel"},
    ["gas-vinyl-acetylene"] = {"gas-vinyl-acetylene-barrel"},
    ["gas-nitrous-oxide"] = {"gas-nitrous-oxide-barrel"},
    ["liquid-rubber-pre"] = {"liquid-rubber-pre-barrel"},
    ["liquid-rubber-masterbatch"] = {"liquid-rubber-masterbatch-barrel"},
  },
  voids = {
    ["angels-chemical-void"] = {"angels-liquid-plastic", "angels-liquid-resin", "angels-liquid-rubber", "liquid-rubber-masterbatch", "liquid-rubber-pre", "angels-liquid-cellulose-acetate", "liquid-methyl-methacrylate", "gas-vinyl-acetylene", "liquid-chlorobutadiene", "bob-nitroglycerin", "fluid-tetraethyllead", "gas-phosgene", "clowns-liquid-dimethylmercury", "diesel-fuel", "angels-gas-argon", "angels-gas-deuterium", "clowns-gas-fluorine", "angels-gas-tungsten-hexachloride"},
    ["angels-water-void"] = {"angels-liquid-green-liquor", "clowns-liquid-phosphoric-acid", "clowns-liquid-thorium-solution", "angels-liquid-concrete", "clowns-liquid-mercury"},
  },
  bio_effectivity = 0.75,
}
