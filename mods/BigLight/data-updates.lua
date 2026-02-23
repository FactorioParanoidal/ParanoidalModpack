require("lualib/mining-drill/bigLight")
require("lualib/power-switch/bigLight")
local lib_rail_signal = require("lualib/rail-signal/bigLight")

----------------------------------- ELECTRIC MINING DRILL

-- Vanilla
electric_mining_drill("electric-mining-drill")

-- Cursed Filter Mining Drill
if mods["ev-mining-drills"] then 
    electric_mining_drill("electric-mining-drill-mk2")
    electric_mining_drill("electric-mining-drill-mk3")
    electric_mining_drill("electric-mining-drill-mk4")
    electric_mining_drill("electric-mining-drill-mk5")
end

-- Krastorio
if mods["Krastorio2"] then
    local graphics = require("mods/krastorio2/electric-mining-drill")

    data.raw["mining-drill"]["kr-electric-mining-drill-mk2"].graphics_set = graphics.graphics_set("mk2")
    data.raw["mining-drill"]["kr-electric-mining-drill-mk2"].wet_mining_graphics_set = graphics.wet_mining_graphics_set("mk2")
    data.raw["mining-drill"]["kr-electric-mining-drill-mk2"].integration_patch = graphics.integration_patch("mk2")
    data.raw["mining-drill"]["kr-electric-mining-drill-mk3"].graphics_set = graphics.graphics_set("mk3")
    data.raw["mining-drill"]["kr-electric-mining-drill-mk3"].wet_mining_graphics_set = graphics.wet_mining_graphics_set("mk3")
    data.raw["mining-drill"]["kr-electric-mining-drill-mk3"].integration_patch = graphics.integration_patch("mk3")

    electric_mining_drill("kr-electric-mining-drill-mk2")
    electric_mining_drill("kr-electric-mining-drill-mk3")
end

-- Hiladdar Mining
if mods["Hiladdar_Mining"] then 
    electric_mining_drill("hsmd-electric-mining-drill-mk2")
    electric_mining_drill("hsmd-electric-mining-drill-mk3")
    electric_mining_drill("hsmd-electric-mining-drill-mk4")
    electric_mining_drill("hsmd-electric-mining-drill-mk5")
    electric_mining_drill("hsmd-electric-mining-drill-mk6")
end

-- Bob Mining
if mods["bobmining"] then 
    electric_mining_drill("bob-mining-drill-1")
    electric_mining_drill("bob-mining-drill-2")
    electric_mining_drill("bob-mining-drill-3")
    electric_mining_drill("bob-mining-drill-4")
    electric_mining_drill("bob-area-mining-drill-1")
    electric_mining_drill("bob-area-mining-drill-2")
    electric_mining_drill("bob-area-mining-drill-3")
    electric_mining_drill("bob-area-mining-drill-4")
end


----------------------------------- POWER SWITCH

-- Vanilla
power_switch("power-switch")


----------------------------------- RAIL SIGNAL

-- Vanilla
--lib_rail_signal.rail_signal("rail-signal")
--lib_rail_signal.rail_signal_chain("rail-chain-signal")
