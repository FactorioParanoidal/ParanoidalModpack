local rro = Muluna.rro
local dual_icon = require("lib.dual-item-icon").dual_icon

local one_oxygen_condition = {
    property = "oxygen",
    min = 1,
    }


if mods["aai-industry"] then
    if data.raw["assembling-machine"]["burner-assembling-machine"] then
        PlanetsLib.restrict_surface_conditions(data.raw["assembling-machine"]["burner-assembling-machine"] , one_oxygen_condition)
    end
    
    if data.raw["lab"]["burner-lab"] then
        PlanetsLib.restrict_surface_conditions(data.raw["lab"]["burner-lab"] , one_oxygen_condition)
    end
    
    if data.raw["generator"]["burner-turbine"] then
        PlanetsLib.restrict_surface_conditions(data.raw["generator"]["burner-turbine"] , one_oxygen_condition)
    end

    if data.raw["mining-drill"]["burner-mining-drill"] then
        PlanetsLib.restrict_surface_conditions(data.raw["mining-drill"]["burner-mining-drill"],one_oxygen_condition)
    end

    if data.raw["inserter"]["burner-inserter"] then
        PlanetsLib.restrict_surface_conditions(data.raw["inserter"]["burner-inserter"],one_oxygen_condition)
    end
    -- rro.replace(data.raw["electric-engine-from-carbon"].ingredients ,
    -- {
    --     type = "fluid",
    --     name = "lubricant",
    --     amount = 40
    -- }


-- )

data.raw["recipe"]["electric-engine-unit-from-carbon"].icons = dual_icon("electric-engine-unit","carbon")

local small_electric_motor = table.deepcopy(data.raw["recipe"]["electric-motor"])

-- small_electric_motor = rro.merge(small_electric_motor, 
-- {
--     name = "small-electric-motor-from-aluminum",
--     icon = nil,
--     icons = dual_icon("electric-motor","aluminum-cable"),
--     --localised_name = {"recipe-name.n-from-n",{"item-name.electric-motor"},{"item-name.aluminum-cable"}}
-- })

-- rro.replace(small_electric_motor.ingredients, {type = "item", name = "copper-cable", amount = 6}, {type = "item", name = "aluminum-cable", amount = 6})

-- Muluna:extend{small_electric_motor}

local burner_items = {
    "burner-assembling-machine",
    ""
}





-- table.insert(data.raw["technology"]["anorthite-processing"].effects,
-- {
--     type = "unlock-recipe",
--     recipe = "small-electric-motor-from-aluminum",
-- })
end
