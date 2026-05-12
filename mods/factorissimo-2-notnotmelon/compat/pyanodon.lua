if not mods["pyalienlife"] then return end
if not mods["pyhightech"] then return end

data.raw.technology["factory-connection-type-circuit"].prerequisites = {
    "factory-architecture-t1",
    "advanced-combinators",
}
data.raw.technology["factory-connection-type-circuit"].unit.ingredients = {
    {"py-science-pack-1", 1},
}

data.raw.technology["factory-architecture-t2"].unit.ingredients = {
    {"py-science-pack-1", 1},
}

data.raw.technology["factory-interior-upgrade-display"].prerequisites = {
    "factory-architecture-t1"
}
data.raw.technology["factory-interior-upgrade-display"].unit.ingredients = {
    {"automation-science-pack", 1},
}

table.insert(
    data.raw.technology["factory-connection-type-heat"].prerequisites,
    "uranium-processing"
)
data.raw.technology["factory-connection-type-heat"].unit.ingredients = {
    {"chemical-science-pack", 1},
}

data.raw.technology["factory-connection-type-chest"].unit.ingredients = {
    {"py-science-pack-2", 1},
}

data.raw.recipe["factory-1"].ingredients = {
    {type = "item", name = "concrete",     amount = 500},
    {type = "item", name = "steel-plate",  amount = 100},
    {type = "item", name = "tinned-cable", amount = 100},
    {type = "item", name = "treated-wood", amount = 100},
}

data.raw.recipe["factory-2"].ingredients = {
    {type = "item", name = "factory-1",     amount = 1},
    {type = "item", name = "py-asphalt",    amount = 300},
    {type = "item", name = "concrete-wall", amount = 100},
    {type = "item", name = "fiberboard",    amount = 100},
    {type = "item", name = "bolts",         amount = 500},
    {type = "item", name = "tinned-cable",  amount = 100},
}

local heating_unit = mods.pyalternativeenergy and "heating-system" or "simik"
data.raw.recipe["factory-3"].ingredients = {
    {type = "item", name = "factory-2",          amount = 1},
    {type = "item", name = "super-steel",        amount = 500},
    {type = "item", name = "super-alloy",        amount = 500},
    {type = "item", name = heating_unit,         amount = 1},
    {type = "item", name = "tinned-cable",       amount = 100},
    {type = "item", name = "nexelit-substation", amount = 2},
    {type = "item", name = "fiberglass",         amount = 200},
}
