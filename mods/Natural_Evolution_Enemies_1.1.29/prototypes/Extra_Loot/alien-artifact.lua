local ICONPATH = NE_Common.iconpath

if settings.startup["NE_Alien_Artifacts"].value == true then

    data:extend({{
        type = "item",
        name = "alien-artifact",
        icon = ICONPATH .. "alien-artifact.png",
        icon_size = 64,
        icons = {{
            icon = ICONPATH .. "alien-artifact.png",
            icon_size = 64
        }},
        subgroup = "raw-material",
        order = "g[alien-artifact]-a[pink]-a[small]",
        fuel_value = "250MJ",
        fuel_category = "chemical",
        fuel_emissions_multiplier = 0.05,
        fuel_acceleration_multiplier = 1.25,
        fuel_top_speed_multiplier = 1.25,
        stack_size = 500,
        default_request_amount = 10
    }})
end

