local PLANETS = {
    maraxsis_constants.MARAXSIS_SURFACE_NAME,
    maraxsis_constants.TRENCH_SURFACE_NAME
}

for _, planet_name in pairs(PLANETS) do
    local pressure = data.raw.planet[planet_name].surface_properties.pressure
    -- Same deal as Vulcanus: nukes make lava.
    data:extend {maraxsis.merge(data.raw.explosion["nuke-effects-vulcanus"], {
        name = "nuke-effects-" .. planet_name,
        surface_conditions = {{property = "pressure", min = pressure, max = pressure}},
        created_effect = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {type = "script", effect_id = "maraxsis-nuke-effects"},
                },
            },
        },
    })}
end

local NUKES = {
    data.raw["projectile"]["atomic-rocket"],
    data.raw["artillery-projectile"]["maraxsis-nuclear-artillery-projectile"]
}

for _, nuke in pairs(NUKES) do
    local target_effects = nuke.action.action_delivery.target_effects
    -- Destroy cliffs before any tile changes so the "destroy cliffs with a
    -- nuke" achievement still works here too. Vulcanus' nuke script does the
    -- same thing.
    local index = maraxsis.index_after_destroy_cliffs(target_effects)
    for _, planet_name in pairs(PLANETS) do
        table.insert(target_effects, index, {
            type = "create-entity",
            check_buildability = true,
            entity_name = "nuke-effects-" .. planet_name,
        })
    end
end
