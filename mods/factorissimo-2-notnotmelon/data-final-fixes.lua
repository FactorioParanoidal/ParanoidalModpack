require "compat.efficient-smelting"
require "prototypes.quality-tooltips"

-- Paranoidal: factories are immune to quality and defects. Their recipes never make quality buildings
-- (quality modules have no effect, ingredients must be standard). Defects: ic-more-qualities exempt list.
for _, name in pairs {"factory-1", "factory-2", "factory-3", "space-factory-1", "space-factory-2", "space-factory-3"} do
    local recipe = data.raw.recipe[name]
    if recipe then recipe.allow_quality = false end
end
require "compat.gregtorio"
require "prototypes.hull-icons"

data.raw.item["factory-hidden-construction-robot"].stack_size = 1000

-- Auto-rebalance the roboport upgrade tech such that it costs the same packs as the construction-robotics tech.
local construction_robotics = data.raw.technology["construction-robotics"]
local roboport_upgrade = data.raw.technology["factory-interior-upgrade-roboport"]
local architecture_2 = data.raw.technology["factory-architecture-t2"]
if construction_robotics and roboport_upgrade and architecture_2 then
    local construction_robotics = construction_robotics.unit
    local roboport_upgrade = roboport_upgrade.unit
    local architecture_2 = architecture_2.unit
    if construction_robotics and roboport_upgrade and architecture_2 then
        roboport_upgrade.count = math.max(construction_robotics.count or 0, architecture_2.count or 0) + 15
        roboport_upgrade.time = math.max(construction_robotics.time or 0, architecture_2.time or 0) + 15
        local ingredients = {}
        for _, tech in pairs {construction_robotics, architecture_2} do
            for _, ingredient in pairs(tech.ingredients) do
                if type(ingredient) == "table" and type(ingredient[1]) == "string" then
                    for _, existing in pairs(ingredients) do
                        if existing[1] == ingredient[1] then
                            goto dedupe
                        end
                    end
                    ingredients[#ingredients + 1] = ingredient
                    ::dedupe::
                end
            end
        end
        roboport_upgrade.ingredients = ingredients
    end
end
