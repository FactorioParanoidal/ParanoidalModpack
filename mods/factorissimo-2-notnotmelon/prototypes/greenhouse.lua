if not mods["space-age"] then return end
if mods["space-is-fake"] then return end

local F = "__factorissimo-2-notnotmelon__"
local pf = "p-q-"

data:extend {{
    name = "factory-upgrade-greenhouse",
    type = "technology",
    icon = F .. "/graphics/technology/factory-upgrade-greenhouse.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t3", "factory-interior-upgrade-lights"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 2000,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}},
        time = 60
    },
    order = pf .. "a-d",
}}

for _, tower in pairs(data.raw["agricultural-tower"]) do
    tower.surface_conditions = tower.surface_conditions or {}
    table.insert(tower.surface_conditions, {
        property = "solar-power",
        min = 1
    })
end

if not mods["warptorio-space-age"] then -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/255
    for _, plant in pairs {"jellystem", "yumako-tree"} do
        plant = data.raw.plant[plant]
        plant.surface_conditions = plant.surface_conditions or {}
        table.insert(plant.surface_conditions, {
            property = "pressure",
            min = 2000,
            max = 2000
        })
    end
end
