if mods["modules-t4"] then
    table.insert(data.raw["technology"]["quality-module-4"].prerequisites,
        "hydraulic-science-pack"
    )
    table.insert(data.raw["technology"]["quality-module-4"].unit.ingredients,
        {"hydraulic-science-pack",1}
    )
    data.raw["recipe"]["quality-module-4"].ingredients = {
        {type = "item", name = "salt", amount = 1},
        {type = "item", name = "quantum-processor", amount = 5},
        {type = "item", name = "quality-module-3", amount = 5},
    }
end