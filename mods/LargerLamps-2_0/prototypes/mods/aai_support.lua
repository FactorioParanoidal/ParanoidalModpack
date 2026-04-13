local DLL = require("prototypes.globals")

-- Check if AAI Industrial mod is present
if mods["aai-industries"] then
    -- Modify Large Lamp Recipe for AAI
    if data.raw["recipe"][DLL.name] then
        data.raw["recipe"][DLL.name].category = "aai-production" -- Use AAI production category for compatibility
        data.raw["recipe"][DLL.name].ingredients = {
            { type = "item", name = "copper-plate", amount = 6 },
            { type = "item", name = "glass", amount = 4 }, -- Increased to reflect AAI's reliance on glass
            { type = "item", name = "electronic-circuit", amount = 4 } -- More circuits for complexity
        }
        data.raw["recipe"][DLL.name].enabled = false -- Require research if needed
    end

    -- Modify Copper Lamp Recipe for AAI
    if data.raw["recipe"][DLL.copper_name] then
        data.raw["recipe"][DLL.copper_name].category = "aai-production"
        data.raw["recipe"][DLL.copper_name].ingredients = {
            { type = "item", name = "copper-plate", amount = 10 }, -- Increased to emphasize copper usage
            { type = "item", name = "glass", amount = 3 },
            { type = "item", name = "stone-tablet", amount = 4 }
        }
        data.raw["recipe"][DLL.copper_name].enabled = false
    end

    -- Modify Electric Copper Lamp Recipe for AAI
    if data.raw["recipe"][DLL.electric_copper_name] then
        data.raw["recipe"][DLL.electric_copper_name].category = "aai-production"
        data.raw["recipe"][DLL.electric_copper_name].ingredients = {
            { type = "item", name = "copper-plate", amount = 12 },
            { type = "item", name = "glass", amount = 6 },
            { type = "item", name = "electric-motor", amount = 2 }, -- Requires electric motors for more advanced crafting
            { type = "item", name = "electronic-circuit", amount = 6 }
        }
        data.raw["recipe"][DLL.electric_copper_name].enabled = false
    end

    -- Modify Floor Lamp Recipe for AAI
    if data.raw["recipe"][DLL.floor_name] then
        data.raw["recipe"][DLL.floor_name].category = "aai-production"
        data.raw["recipe"][DLL.floor_name].ingredients = {
            { type = "item", name = "electronic-circuit", amount = 2 },
            { type = "item", name = "copper-cable", amount = 8 },
            { type = "item", name = "iron-plate", amount = 6 },
            { type = "item", name = "glass", amount = 5 }
        }
        data.raw["recipe"][DLL.floor_name].enabled = false
    end

    -- Add Fallback Check for Glass-Processing Prerequisite
    if data.raw.technology["glass-processing"] then
        util.tech_add_prerequisites("lamp", "glass-processing")
    end
else
    -- Fallback for vanilla compatibility
    if data.raw["recipe"][DLL.name] then
        data.raw["recipe"][DLL.name].category = "basic-crafting"
    end
    if data.raw["recipe"][DLL.copper_name] then
        data.raw["recipe"][DLL.copper_name].category = "basic-crafting"
    end
    if data.raw["recipe"][DLL.electric_copper_name] then
        data.raw["recipe"][DLL.electric_copper_name].category = "basic-crafting"
    end
    if data.raw["recipe"][DLL.floor_name] then
        data.raw["recipe"][DLL.floor_name].category = "basic-crafting"
    end
end
