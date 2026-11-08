local secretas_surface = table.deepcopy(data.raw["tile"]["empty-space"])

secretas_surface.name = "secretas-surface"
secretas_surface.effect = nil
secretas_surface.map_color = {
    0.13, 0.32, 0.48, 1.0
}
secretas_surface.fluid = "steam"

secretas_surface.collision_mask = {
    layers = {
        floor = true,
        player = true,
        water_tile = true,
        rail = true,
        rail_support = true,
        -- this layer is from dea dia.
        ["gas-giant-surface"] = true
    }
}

secretas_surface.destroys_dropped_items = true
secretas_surface.variants = {
    empty_transitions = true,
    main = {
        {
            count = 1,
            picture = "__secretas__/graphics/terrain/secretas-surface.png",
            size = 1
        }
    }
}

data:extend{
    secretas_surface
}