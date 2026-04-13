-- Sort petrochem buildings into more rows
local petrochem_buildings = {
  ["angels-air-filter"] = "angels-petrochem-buildings-air-filter",
  ["angels-air-filter-2"] = "angels-petrochem-buildings-air-filter",
  ["angels-air-filter-3"] = "angels-petrochem-buildings-air-filter",
  ["angels-air-filter-4"] = "angels-petrochem-buildings-air-filter",
  ["angels-liquifier"] = "angels-petrochem-buildings-liquifier",
  ["angels-liquifier-2"] = "angels-petrochem-buildings-liquifier",
  ["angels-liquifier-3"] = "angels-petrochem-buildings-liquifier",
  ["angels-liquifier-4"] = "angels-petrochem-buildings-liquifier",
  ["angels-advanced-chemical-plant"] = "angels-petrochem-buildings-advanced-chemical-plant",
  ["angels-advanced-chemical-plant-2"] = "angels-petrochem-buildings-advanced-chemical-plant",
  ["angels-advanced-chemical-plant-3"] = "angels-petrochem-buildings-advanced-chemical-plant",
  ["angels-gas-refinery"] = "angels-petrochem-buildings-advanced-gas-refinery",
  ["angels-gas-refinery-2"] = "angels-petrochem-buildings-advanced-gas-refinery",
  ["angels-gas-refinery-3"] = "angels-petrochem-buildings-advanced-gas-refinery",
  ["angels-gas-refinery-4"] = "angels-petrochem-buildings-advanced-gas-refinery",
  ["angels-separator"] = "angels-petrochem-buildings-separator",
  ["angels-separator-2"] = "angels-petrochem-buildings-separator",
  ["angels-separator-3"] = "angels-petrochem-buildings-separator",
  ["angels-separator-4"] = "angels-petrochem-buildings-separator",
}

if settings.startup["extangels-adjust-ordering"].value then
  for name, subgroup in pairs(petrochem_buildings) do
    local item = data.raw.item[name]
    local entity = data.raw["assembling-machine"][name]
    local recipe = data.raw.recipe[name]

    if item then
      item.subgroup = subgroup
    end

    -- Clear entity/recipe subgroups for proper inheritance from item
    if entity then
      entity.subgroup = nil
    end
    if recipe then
      recipe.subgroup = nil
    end
  end
end
