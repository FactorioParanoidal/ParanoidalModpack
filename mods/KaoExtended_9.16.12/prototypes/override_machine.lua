data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 4
data.raw["assembling-machine"]["assembling-machine-2"].ingredient_count = 7
data.raw["assembling-machine"]["assembling-machine-3"].ingredient_count = 9
data.raw["assembling-machine"]["assembling-machine-4"].ingredient_count = 12
data.raw["assembling-machine"]["assembling-machine-5"].ingredient_count = 15
data.raw["assembling-machine"]["assembling-machine-6"].ingredient_count = 20

data.raw["assembling-machine"]["electronics-machine-1"].ingredient_count = 5
data.raw["assembling-machine"]["electronics-machine-2"].ingredient_count = 10
data.raw["assembling-machine"]["electronics-machine-3"].ingredient_count = 16

--if data.raw["item"]["slag"] and data.raw["fluid"]["gas-butane"] then
--  data.raw["assembling-machine"]["liquifier"].crafting_speed = 1.5
--end



-- ENERGY USAGE

data.raw["assembling-machine"]["liquifier"].energy_usage= "200kW" --from 125

data.raw["assembling-machine"]["angels-electrolyser"].energy_usage= "1500kW"
data.raw["assembling-machine"]["angels-electrolyser-2"].energy_usage= "2000kW"
data.raw["assembling-machine"]["angels-electrolyser-3"].energy_usage= "2500kW"
data.raw["assembling-machine"]["angels-electrolyser-4"].energy_usage= "3000kW"

data.raw["assembling-machine"]["casting-machine-4"].energy_usage= "350kW"
-- data.raw["assembling-machine"]["strand-casting-machine-4"].energy_usage= "350kW"
data.raw["assembling-machine"]["sintering-oven-4"].energy_usage= "350kW"

data.raw["electric-turret"]["bob-plasma-turret-1"].health = 2000
data.raw["electric-turret"]["bob-plasma-turret-1"].drain = "4800kW"
data.raw["electric-turret"]["bob-plasma-turret-1"].buffer_capacity = "420000kJ"
data.raw["electric-turret"]["bob-plasma-turret-1"].input_flow_limit = "20000kW"
data.raw["electric-turret"]["bob-plasma-turret-1"].energy_consumption = "400000kJ"
	
	data.raw["electric-turret"]["bob-plasma-turret-2"].health = 2200
    data.raw["electric-turret"]["bob-plasma-turret-2"].drain = "6000kW"
    data.raw["electric-turret"]["bob-plasma-turret-2"].buffer_capacity = "1020000kJ"
    data.raw["electric-turret"]["bob-plasma-turret-2"].input_flow_limit = "66667kW"
    data.raw["electric-turret"]["bob-plasma-turret-2"].energy_consumption = "500000kJ"

    data.raw["electric-turret"]["bob-plasma-turret-3"].health = 2400
    data.raw["electric-turret"]["bob-plasma-turret-3"].drain = "7200kW"
    data.raw["electric-turret"]["bob-plasma-turret-3"].buffer_capacity = "1820000kJ"
    data.raw["electric-turret"]["bob-plasma-turret-3"].input_flow_limit = "150000kW"
    data.raw["electric-turret"]["bob-plasma-turret-3"].energy_consumption = "600000kJ"
	
    data.raw["electric-turret"]["bob-plasma-turret-4"].health = 2600
    data.raw["electric-turret"]["bob-plasma-turret-4"].drain = "8400kW"
    data.raw["electric-turret"]["bob-plasma-turret-4"].buffer_capacity = "2820000kJ"
    data.raw["electric-turret"]["bob-plasma-turret-4"].input_flow_limit = "280000kW"
    data.raw["electric-turret"]["bob-plasma-turret-4"].energy_consumption = "700000kJ"
	
    data.raw["electric-turret"]["bob-plasma-turret-5"].health = 4000
    data.raw["electric-turret"]["bob-plasma-turret-5"].drain = "9600kW"
    data.raw["electric-turret"]["bob-plasma-turret-5"].buffer_capacity = "4020000kJ"
    data.raw["electric-turret"]["bob-plasma-turret-5"].input_flow_limit = "400000kW"
    data.raw["electric-turret"]["bob-plasma-turret-5"].energy_consumption = "800000kJ"



--     M O D U L E S

data.raw["assembling-machine"]["assembling-machine-2"].module_specification = {module_slots = 1}

data.raw["mining-drill"]["electric-mining-drill"].module_specification = {module_slots = 2}
data.raw["mining-drill"]["bob-mining-drill-1"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["ore-sorting-facility"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["ore-sorting-facility-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["ore-sorting-facility-3"].module_specification = {module_slots = 3}
data.raw["assembling-machine"]["ore-sorting-facility-4"].module_specification = {module_slots = 4}


-- MODULE SLOTS ANGELS SMELTING

data.raw["assembling-machine"]["ore-processing-machine"].module_specification = {module_slots = 0}
data.raw["assembling-machine"]["ore-processing-machine-2"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["ore-processing-machine-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["ore-processing-machine-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["pellet-press"].module_specification = {module_slots = 0}
data.raw["assembling-machine"]["pellet-press-2"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["pellet-press-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["pellet-press-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["powder-mixer"].module_specification = {module_slots = 0}
data.raw["assembling-machine"]["powder-mixer-2"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["powder-mixer-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["powder-mixer-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["blast-furnace"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["blast-furnace-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["blast-furnace-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["blast-furnace-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["angels-chemical-furnace"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["angels-chemical-furnace-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["angels-chemical-furnace-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["angels-chemical-furnace-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["induction-furnace"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["induction-furnace-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["induction-furnace-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["induction-furnace-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["casting-machine"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["casting-machine-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["casting-machine-3"].module_specification = {module_slots = 3}
data.raw["assembling-machine"]["casting-machine-4"].module_specification = {module_slots = 4}

data.raw["assembling-machine"]["strand-casting-machine"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["strand-casting-machine-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["strand-casting-machine-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["strand-casting-machine-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["sintering-oven"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["sintering-oven-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["sintering-oven-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["sintering-oven-4"].module_specification = {module_slots = 3}

-- MODULE SLOTS ANGELS PETROCHEM

data.raw["assembling-machine"]["angels-electrolyser"].module_specification = {module_slots = 0}
data.raw["assembling-machine"]["angels-electrolyser-2"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["angels-electrolyser-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["angels-electrolyser-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["angels-air-filter"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["angels-air-filter-2"].module_specification = {module_slots = 2}

data.raw["assembling-machine"]["separator"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["separator-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["separator-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["separator-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["gas-refinery-small"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["gas-refinery-small-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["gas-refinery-small-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["gas-refinery-small-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["gas-refinery"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["gas-refinery-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["gas-refinery-3"].module_specification = {module_slots = 3}
data.raw["assembling-machine"]["gas-refinery-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["steam-cracker"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["steam-cracker-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["steam-cracker-3"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["steam-cracker-4"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["advanced-chemical-plant"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["advanced-chemical-plant-2"].module_specification = {module_slots = 3}

data.raw["assembling-machine"]["angels-chemical-plant"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["angels-chemical-plant-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["angels-chemical-plant-3"].module_specification = {module_slots = 3}
data.raw["assembling-machine"]["angels-chemical-plant-4"].module_specification = {module_slots = 4}

data.raw["assembling-machine"]["oil-refinery"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["oil-refinery-2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["oil-refinery-3"].module_specification = {module_slots = 3}
data.raw["assembling-machine"]["oil-refinery-4"].module_specification = {module_slots = 4}

data.raw["furnace"]["angels-flare-stack"].module_specification = {module_slots = 1}

-- MODULE SLOTS CENTRIFUGE

data.raw["assembling-machine"]["centrifuge"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["centrifuge"].allowed_effects = {"consumption", "speed", "pollution"}
data.raw["assembling-machine"]["centrifuge"].energy_usage = "950kW"

--data.raw["assembling-machine"]["centrifuge-mk2"].crafting_speed = 2.25
--data.raw["assembling-machine"]["centrifuge-mk2"].energy_usage = "2950kW"
data.raw["assembling-machine"]["centrifuge-mk2"].module_specification = {module_slots = 2}
data.raw["assembling-machine"]["centrifuge-mk2"].allowed_effects = {"consumption", "speed", "pollution"}

--data.raw["assembling-machine"]["centrifuge-mk3"].crafting_speed = 3.5
--data.raw["assembling-machine"]["centrifuge-mk3"].energy_usage = "7550kW"
data.raw["assembling-machine"]["centrifuge-mk3"].module_specification = {module_slots = 3}
data.raw["assembling-machine"]["centrifuge-mk3"].allowed_effects = {"consumption", "speed", "pollution"}

-- MODULE SLOTS BIO-INDUSTRIES

data.raw["assembling-machine"]["bi-bio-farm"].module_specification = {module_slots = 1}
data.raw["assembling-machine"]["bi-bio-greenhouse"].module_specification = {module_slots = 1}
