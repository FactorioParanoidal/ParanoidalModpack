require "compat.efficient-smelting"
require "compat.gregtorio"

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
