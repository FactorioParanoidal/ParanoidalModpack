-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- When compatibility with ShinyBobGFX is finally dropped, the contents of this file will be moved to data.lua

----------------------------------------------------------------------------------------------------
-- TECHNOLOGIES
----------------------------------------------------------------------------------------------------
require("prototypes.technology.assembly")
-- require("prototypes.technology.electronics")
require("prototypes.technology.greenhouse")
require("prototypes.technology.logistics")
require("prototypes.technology.plates")
require("prototypes.technology.power")

----------------------------------------------------------------------------------------------------
-- ITEMS
----------------------------------------------------------------------------------------------------
require("prototypes.item.electronics")
require("prototypes.item.greenhouse")
require("prototypes.item.logistics")
require("prototypes.item.modules")
require("prototypes.item.ores")
require("prototypes.item.plates")
require("prototypes.item.revamp")
require("prototypes.item.technology")
require("prototypes.item.warfare")

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
-- Bob's Assembly
require("prototypes.entity.assembly.centrifuge")
require("prototypes.entity.assembly.distillery")
require("prototypes.entity.assembly.electrolyser")
require("prototypes.entity.assembly.furnace")

-- Bob's Greenhouse
-- require("prototypes.entity.greenhouse.greenhouse")

-- Bob's Logistics
require("prototypes.entity.logistics.cargo-wagon")
require("prototypes.entity.logistics.chest")
require("prototypes.entity.logistics.construction-robots")
require("prototypes.entity.logistics.fluid-wagon")
require("prototypes.entity.logistics.inserter")
require("prototypes.entity.logistics.inserter-overhaul")
require("prototypes.entity.logistics.locomotive")
require("prototypes.entity.logistics.logistic-robots")
require("prototypes.entity.logistics.logistic-zone-expander")
require("prototypes.entity.logistics.logistic-zone-interface")
require("prototypes.entity.logistics.pipe")
require("prototypes.entity.logistics.pump")
require("prototypes.entity.logistics.robo-charge-port")
require("prototypes.entity.logistics.robochest")
require("prototypes.entity.logistics.roboport")
require("prototypes.entity.logistics.splitter")
require("prototypes.entity.logistics.storage-tank-all-corners")
require("prototypes.entity.logistics.storage-tank")
require("prototypes.entity.logistics.transport-belt")
require("prototypes.entity.logistics.underground-belt")
require("prototypes.entity.logistics.valve")

-- Bob's Mining
require("prototypes.entity.mining.mining-drill")
require("prototypes.entity.mining.pumpjack")

-- Bob's Modules
require("prototypes.entity.modules.beacon")

-- Bob's Metals, Chemicals, and Intermediaries
require("prototypes.entity.plates.air-and-water-pump")
-- require("prototypes.entity.plates.small-storage-tank")
-- require("prototypes.entity.plates.void-pump")

-- Bob's Ores
require("prototypes.entity.ores.ores")
require("prototypes.entity.ores.fluids")

-- Bob's Power
require("prototypes.entity.power.accumulator")
require("prototypes.entity.power.big-electric-pole")
require("prototypes.entity.power.boiler")
require("prototypes.entity.power.burner-electric-generator")
require("prototypes.entity.power.generator")
require("prototypes.entity.power.heat-exchanger")
require("prototypes.entity.power.heat-pipe")
-- require("prototypes.entity.power.heat-source")
require("prototypes.entity.power.medium-electric-pole")
require("prototypes.entity.power.solar-panel")
require("prototypes.entity.power.steam-engine")
require("prototypes.entity.power.steam-turbine")
require("prototypes.entity.power.substation")

-- Bob's Technology
-- require("prototypes.entity.technology.lab") -- Partially implemented, not functional in normal resolution

-- Bob's Warfare
require("prototypes.entity.warfare.artillery-turret")
require("prototypes.entity.warfare.artillery-wagon")
require("prototypes.entity.warfare.beam")
require("prototypes.entity.warfare.gun-turret")
require("prototypes.entity.warfare.laser-turret")
require("prototypes.entity.warfare.plasma-turret")
require("prototypes.entity.warfare.radar")
require("prototypes.entity.warfare.sniper-turret")
require("prototypes.entity.warfare.tank")
require("prototypes.entity.warfare.wall")
require("prototypes.entity.warfare.gate")

----------------------------------------------------------------------------------------------------
-- EQUIPMENT
----------------------------------------------------------------------------------------------------
-- Bob's Personal Equipment
require("prototypes.equipment.equipment.battery")
require("prototypes.equipment.equipment.energy-shield")
require("prototypes.equipment.equipment.fusion-reactor")
require("prototypes.equipment.equipment.laser-defense")
require("prototypes.equipment.equipment.night-vision")
require("prototypes.equipment.equipment.personal-roboport")
require("prototypes.equipment.equipment.solar-panel")

-- Bob's Vehicle Equipment
require("prototypes.equipment.vehicle-equipment.vehicle-battery")
require("prototypes.equipment.vehicle-equipment.vehicle-energy-shield")
require("prototypes.equipment.vehicle-equipment.vehicle-fusion-cell")
require("prototypes.equipment.vehicle-equipment.vehicle-fusion-reactor")
require("prototypes.equipment.vehicle-equipment.vehicle-laser-defense")
require("prototypes.equipment.vehicle-equipment.vehicle-roboport")
require("prototypes.equipment.vehicle-equipment.vehicle-solar-panel")

----------------------------------------------------------------------------------------------------
-- COMPATIBILITY
----------------------------------------------------------------------------------------------------
require("prototypes.compatibility.loaderredux")
require("prototypes.compatibility.miniloader")
require("prototypes.compatibility.vanilla-loaders-hd")
require("prototypes.compatibility.classic-beacon")
require("prototypes.compatibility.classic-mining-drill")
require("prototypes.compatibility.semi-classic-mining-drill")