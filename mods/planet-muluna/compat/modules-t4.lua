if false and mods["modules-t4"] then
local rro = Muluna.rro
    -- table.insert(data.raw["technology"]["productivity-module-4"].prerequisites,
    -- "hydraulic-science-pack"
    -- )
    -- table.insert(data.raw["technology"]["productivity-module-4"].unit.ingredients,
    -- {"hydraulic-science-pack",1}
    -- )

    table.insert(data.raw["recipe"]["productivity-module-4"].ingredients, 

        {type = "item", name = "aluminum-plate", amount = 1})
    rro.remove(data.raw["recipe"]["productivity-module-4"].ingredients,
    {type = "item", name = "biter-egg", amount = 1}
)
    -- data.raw["recipe"]["productivity-module-4"].ingredients = {
    --     {type = "item", name = "aluminum-plate", amount = 1},
    --     {type = "item", name = "quantum-processor", amount = 5},
    --     {type = "item", name = "productivity-module-3", amount = 5},
    -- }
end