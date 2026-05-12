data:extend {{
    name = "ceiling",
    type = "surface-property",
    default_value = 1,
    is_time = true,
    hidden = true
}}

if not feature_flags.space_travel then return end

local banned_from_being_placed_indoors = {
    "artillery-turret",
    "rocket-silo",
    "cargo-landing-pad",
}

for _, prototype in pairs(banned_from_being_placed_indoors) do
    for _, entity in pairs(data.raw[prototype]) do
        entity.surface_conditions = entity.surface_conditions or {}
        table.insert(entity.surface_conditions, {
            property = "ceiling",
            min = 1,
        })
    end
end

if not mods["space-age"] then return end
if mods["space-is-fake"] then return end

for _, entity in pairs(data.raw["solar-panel"]) do
    entity.surface_conditions = entity.surface_conditions or {}
    table.insert(entity.surface_conditions, {
        property = "solar-power",
        min = 1,
    })
end
