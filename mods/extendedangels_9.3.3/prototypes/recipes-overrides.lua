
data.raw.recipe["hydro-plant"].order="a"
data.raw.recipe["hydro-plant-2"].order="b"
data.raw.recipe["clarifier"].order="e"
data.raw.recipe["salination-plant"].order="f"
data.raw.recipe["salination-plant-2"].order="g"
data.raw.recipe["cooling-tower"].order="i"
if angelsmods.refining then
    table.insert(data.raw["assembling-machine"]["advanced-chemical-plant-3"].crafting_categories, "liquifying")
end
