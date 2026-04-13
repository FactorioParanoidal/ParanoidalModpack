require("__zzzparanoidal__.paralib")
-- подкрутка чтобы сборщик1 мог собирать сам себя
data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 5
-- Добавление нужных для крафта конденсаторов категорий в сборочники
local function AssemblerTweak(name)
    if(data.raw["assembling-machine"][name]) then
        table.insert(data.raw["assembling-machine"][name].crafting_categories, "electronics")
        table.insert(data.raw["assembling-machine"][name].crafting_categories, "electronics-with-fluid")
    end
end

AssemblerTweak("burner-assembling-machine")
AssemblerTweak("assembling-machine-1")
AssemblerTweak("assembling-machine-2")
AssemblerTweak("assembling-machine-3")
AssemblerTweak("bob-assembling-machine-4")
AssemblerTweak("bob-assembling-machine-5")
AssemblerTweak("bob-assembling-machine-6")

-- from KaoExtended
data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 4
data.raw["assembling-machine"]["assembling-machine-2"].ingredient_count = 7
data.raw["assembling-machine"]["assembling-machine-3"].ingredient_count = 9
data.raw["assembling-machine"]["bob-assembling-machine-4"].ingredient_count = 12
data.raw["assembling-machine"]["bob-assembling-machine-5"].ingredient_count = 15
data.raw["assembling-machine"]["bob-assembling-machine-6"].ingredient_count = 20

data.raw["assembling-machine"]["bob-electronics-machine-1"].ingredient_count = 5
data.raw["assembling-machine"]["bob-electronics-machine-2"].ingredient_count = 10
data.raw["assembling-machine"]["bob-electronics-machine-3"].ingredient_count = 16

-- ENERGY USAGE

data.raw["assembling-machine"]["angels-liquifier"].energy_usage= "200kW" --from 125
data.raw["assembling-machine"]["angels-liquifier-2"].energy_usage= "225kW" --from 150
data.raw["assembling-machine"]["angels-liquifier-3"].energy_usage= "275kW" --from 200
data.raw["assembling-machine"]["angels-liquifier-4"].energy_usage= "375kW" --from 300

data.raw["assembling-machine"]["angels-electrolyser"].energy_usage= "1500kW"
data.raw["assembling-machine"]["angels-electrolyser-2"].energy_usage= "2000kW"
data.raw["assembling-machine"]["angels-electrolyser-3"].energy_usage= "2500kW"
data.raw["assembling-machine"]["angels-electrolyser-4"].energy_usage= "3000kW"

data.raw["assembling-machine"]["angels-casting-machine-4"].energy_usage= "350kW"
data.raw["assembling-machine"]["angels-sintering-oven-4"].energy_usage= "350kW"



--     M O D U L E S

data.raw["assembling-machine"]["assembling-machine-2"].module_slots = 1

data.raw["mining-drill"]["electric-mining-drill"].module_slots = 2
data.raw["mining-drill"]["bob-mining-drill-1"].module_slots = 3

data.raw["assembling-machine"]["angels-ore-sorting-facility"].module_slots = 1
data.raw["assembling-machine"]["angels-ore-sorting-facility-2"].module_slots = 2
data.raw["assembling-machine"]["angels-ore-sorting-facility-3"].module_slots = 3
data.raw["assembling-machine"]["angels-ore-sorting-facility-4"].module_slots = 4


-- MODULE SLOTS ANGELS SMELTING

data.raw["assembling-machine"]["angels-ore-processing-machine"].module_slots = 0
data.raw["assembling-machine"]["angels-ore-processing-machine-2"].module_slots = 1
data.raw["assembling-machine"]["angels-ore-processing-machine-3"].module_slots = 2
data.raw["assembling-machine"]["angels-ore-processing-machine-4"].module_slots = 3

data.raw["assembling-machine"]["angels-pellet-press"].module_slots = 0
data.raw["assembling-machine"]["angels-pellet-press-2"].module_slots = 1
data.raw["assembling-machine"]["angels-pellet-press-3"].module_slots = 2
data.raw["assembling-machine"]["angels-pellet-press-4"].module_slots = 3

data.raw["assembling-machine"]["angels-powder-mixer"].module_slots = 0
data.raw["assembling-machine"]["angels-powder-mixer-2"].module_slots = 1
data.raw["assembling-machine"]["angels-powder-mixer-3"].module_slots = 2
data.raw["assembling-machine"]["angels-powder-mixer-4"].module_slots = 3

data.raw["assembling-machine"]["angels-blast-furnace"].module_slots = 1
data.raw["assembling-machine"]["angels-blast-furnace-2"].module_slots = 2
data.raw["assembling-machine"]["angels-blast-furnace-3"].module_slots = 2
data.raw["assembling-machine"]["angels-blast-furnace-4"].module_slots = 3

data.raw["assembling-machine"]["angels-chemical-furnace"].module_slots = 1
data.raw["assembling-machine"]["angels-chemical-furnace-2"].module_slots = 2
data.raw["assembling-machine"]["angels-chemical-furnace-3"].module_slots = 2
data.raw["assembling-machine"]["angels-chemical-furnace-4"].module_slots = 3

data.raw["assembling-machine"]["angels-induction-furnace"].module_slots = 1
data.raw["assembling-machine"]["angels-induction-furnace-2"].module_slots = 2
data.raw["assembling-machine"]["angels-induction-furnace-3"].module_slots = 2
data.raw["assembling-machine"]["angels-induction-furnace-4"].module_slots = 3

data.raw["assembling-machine"]["angels-casting-machine"].module_slots = 1
data.raw["assembling-machine"]["angels-casting-machine-2"].module_slots = 2
data.raw["assembling-machine"]["angels-casting-machine-3"].module_slots = 3
data.raw["assembling-machine"]["angels-casting-machine-4"].module_slots = 4

data.raw["assembling-machine"]["angels-strand-casting-machine"].module_slots = 1
data.raw["assembling-machine"]["angels-strand-casting-machine-2"].module_slots = 2
data.raw["assembling-machine"]["angels-strand-casting-machine-3"].module_slots = 2
data.raw["assembling-machine"]["angels-strand-casting-machine-4"].module_slots = 3

data.raw["assembling-machine"]["angels-sintering-oven"].module_slots = 1
data.raw["assembling-machine"]["angels-sintering-oven-2"].module_slots = 2
data.raw["assembling-machine"]["angels-sintering-oven-3"].module_slots = 2
data.raw["assembling-machine"]["angels-sintering-oven-4"].module_slots = 3

-- MODULE SLOTS ANGELS PETROCHEM

data.raw["assembling-machine"]["angels-electrolyser"].module_slots = 0
data.raw["assembling-machine"]["angels-electrolyser-2"].module_slots = 1
data.raw["assembling-machine"]["angels-electrolyser-3"].module_slots = 2
data.raw["assembling-machine"]["angels-electrolyser-4"].module_slots = 3

data.raw["assembling-machine"]["angels-air-filter"].module_slots = 1
data.raw["assembling-machine"]["angels-air-filter-2"].module_slots = 2

data.raw["assembling-machine"]["angels-separator"].module_slots = 1
data.raw["assembling-machine"]["angels-separator-2"].module_slots = 2
data.raw["assembling-machine"]["angels-separator-3"].module_slots = 2
data.raw["assembling-machine"]["angels-separator-4"].module_slots = 3

data.raw["assembling-machine"]["angels-gas-refinery-small"].module_slots = 1
data.raw["assembling-machine"]["angels-gas-refinery-small-2"].module_slots = 2
data.raw["assembling-machine"]["angels-gas-refinery-small-3"].module_slots = 2
data.raw["assembling-machine"]["angels-gas-refinery-small-4"].module_slots = 3

data.raw["assembling-machine"]["angels-gas-refinery"].module_slots = 1
data.raw["assembling-machine"]["angels-gas-refinery-2"].module_slots = 2
data.raw["assembling-machine"]["angels-gas-refinery-3"].module_slots = 3
data.raw["assembling-machine"]["angels-gas-refinery-4"].module_slots = 3

data.raw["assembling-machine"]["angels-steam-cracker"].module_slots = 1
data.raw["assembling-machine"]["angels-steam-cracker-2"].module_slots = 2
data.raw["assembling-machine"]["angels-steam-cracker-3"].module_slots = 2
data.raw["assembling-machine"]["angels-steam-cracker-4"].module_slots = 3

data.raw["assembling-machine"]["angels-advanced-chemical-plant"].module_slots = 2
data.raw["assembling-machine"]["angels-advanced-chemical-plant-2"].module_slots = 3

data.raw["assembling-machine"]["chemical-plant"].module_slots = 1
data.raw["assembling-machine"]["angels-chemical-plant-2"].module_slots = 2
data.raw["assembling-machine"]["angels-chemical-plant-3"].module_slots = 3
data.raw["assembling-machine"]["angels-chemical-plant-4"].module_slots = 4

data.raw["assembling-machine"]["oil-refinery"].module_slots = 1
data.raw["assembling-machine"]["angels-oil-refinery-2"].module_slots = 2
data.raw["assembling-machine"]["angels-oil-refinery-3"].module_slots = 3
data.raw["assembling-machine"]["angels-oil-refinery-4"].module_slots = 4

data.raw["furnace"]["angels-flare-stack"].module_slots = 1

-- MODULE SLOTS CENTRIFUGE

data.raw["assembling-machine"]["centrifuge"].module_slots = 1
data.raw["assembling-machine"]["centrifuge"].allowed_effects = {"consumption", "speed", "pollution"}
data.raw["assembling-machine"]["centrifuge"].energy_usage = "950kW"

data.raw["assembling-machine"]["bob-centrifuge-2"].module_slots = 2
data.raw["assembling-machine"]["bob-centrifuge-2"].allowed_effects = {"consumption", "speed", "pollution"}

data.raw["assembling-machine"]["bob-centrifuge-3"].module_slots = 3
data.raw["assembling-machine"]["bob-centrifuge-3"].allowed_effects = {"consumption", "speed", "pollution"}

-- MODULE SLOTS BIO-INDUSTRIES

data.raw["assembling-machine"]["bi-bio-farm"].module_slots = 1
data.raw["assembling-machine"]["bi-bio-farm-2"].module_slots = 2
data.raw["assembling-machine"]["bi-bio-farm-3"].module_slots = 3
data.raw["assembling-machine"]["bi-bio-greenhouse"].module_slots = 1
data.raw["assembling-machine"]["bi-bio-greenhouse-2"].module_slots = 2
data.raw["assembling-machine"]["bi-bio-greenhouse-3"].module_slots = 3
