-- Sort petrochem buildings into more rows
local petrochem_buildings = {
    ["angels-air-filter"] = "petrochem-buildings-air-filter",
    ["angels-air-filter-2"] = "petrochem-buildings-air-filter",
    ["angels-air-filter-3"] = "petrochem-buildings-air-filter",
    ["angels-air-filter-4"] = "petrochem-buildings-air-filter",
    ["liquifier"] = "petrochem-buildings-liquifier",
    ["liquifier-2"] = "petrochem-buildings-liquifier",
    ["liquifier-3"] = "petrochem-buildings-liquifier",
    ["liquifier-4"] = "petrochem-buildings-liquifier",
    ["advanced-chemical-plant"] = "petrochem-buildings-advanced-chemical-plant",
    ["advanced-chemical-plant-2"] = "petrochem-buildings-advanced-chemical-plant",
    ["advanced-chemical-plant-3"] = "petrochem-buildings-advanced-chemical-plant",
    ["gas-refinery"] = "petrochem-buildings-advanced-gas-refinery",
    ["gas-refinery-2"] = "petrochem-buildings-advanced-gas-refinery",
    ["gas-refinery-3"] = "petrochem-buildings-advanced-gas-refinery",
    ["gas-refinery-4"] = "petrochem-buildings-advanced-gas-refinery",
    ["separator"] = "petrochem-buildings-separator",
    ["separator-2"] = "petrochem-buildings-separator",
    ["separator-3"] = "petrochem-buildings-separator",
    ["separator-4"] = "petrochem-buildings-separator",
}

if settings.startup["extangels-adjust-ordering"].value then
    for name, subgroup in pairs(petrochem_buildings) do
        local item = data.raw.item[name]
        local entity = data.raw["assembling-machine"][name]
        local recipe = data.raw.recipe[name]

        if item then item.subgroup = subgroup end

        -- Clear entity/recipe subgroups for proper inheritance from item
        if entity then entity.subgroup = nil end
        if recipe then recipe.subgroup = nil end
    end
end