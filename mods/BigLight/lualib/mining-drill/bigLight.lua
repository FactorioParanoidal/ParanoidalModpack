function electric_mining_drill(name)
    local LuaEntityPrototype = data.raw["mining-drill"][name]
    local graphics_set = LuaEntityPrototype.graphics_set.working_visualisations
    local wet_mining_graphics_set = LuaEntityPrototype.wet_mining_graphics_set.working_visualisations

    local value = settings.startup["ritnmods-bl-01"].value / 2

    graphics_set[8].north_animation.scale = value
    --graphics_set[8].north_animation.hr_version.scale = value / 2
    graphics_set[8].east_animation.scale = value
    --graphics_set[8].east_animation.hr_version.scale = value / 2
    graphics_set[8].south_animation.scale = value
    --graphics_set[8].south_animation.hr_version.scale = value / 2
    graphics_set[8].west_animation.scale = value
    --graphics_set[8].west_animation.hr_version.scale = value / 2

    wet_mining_graphics_set[14].north_animation.scale = value
    --wet_mining_graphics_set[14].north_animation.hr_version.scale = value / 2
    wet_mining_graphics_set[14].east_animation.scale = value
    --wet_mining_graphics_set[14].east_animation.hr_version.scale = value / 2
    wet_mining_graphics_set[14].south_animation.scale = value
    --wet_mining_graphics_set[14].south_animation.hr_version.scale = value / 2
    wet_mining_graphics_set[14].west_animation.scale = value
    --wet_mining_graphics_set[14].west_animation.hr_version.scale = value / 2

    return LuaEntityPrototype
end