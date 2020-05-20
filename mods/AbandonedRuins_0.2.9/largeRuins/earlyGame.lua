
return function(center, surface) --early game setups
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "lab", position = {center.x + (-7.0), center.y + (-10.0)}, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (-5.0), center.y + (-10.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-5.0), center.y + (-11.0)}, direction = direct.west, force = fN}
    ce{name = "lab", position = {center.x + (-3.0), center.y + (-10.0)}, force = fN}
    ce{name = "lab", position = {center.x + (1.0), center.y + (-10.0)}, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (3.0), center.y + (-10.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (3.0), center.y + (-11.0)}, direction = direct.west, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-1.0), center.y + (-9.0)}, direction = direct.west, force = fN}
    ce{name = "fast-inserter", position = {center.x + (4.0), center.y + (-8.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (3.0), center.y + (-9.0)}, direction = direct.west, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (5.0), center.y + (-8.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (6.0), center.y + (-8.0)}, force = fN}
    ce{name = "lab", position = {center.x + (-7.0), center.y + (-6.0)}, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (-5.0), center.y + (-6.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-5.0), center.y + (-7.0)}, direction = direct.east, force = fN}
    ce{name = "lab", position = {center.x + (-3.0), center.y + (-6.0)}, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (-1.0), center.y + (-6.0)}, force = fN}
    ce{name = "lab", position = {center.x + (1.0), center.y + (-6.0)}, force = fN}
    ce{name = "lab", position = {center.x + (5.0), center.y + (-6.0)}, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (3.0), center.y + (-6.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (3.0), center.y + (-7.0)}, direction = direct.east, force = fN}
    ce{name = "fast-inserter", position = {center.x + (3.0), center.y + (-5.0)}, direction = direct.east, force = fN}
    ce{name = "radar", position = {center.x + (7.0), center.y + (0.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-7.0), center.y + (2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (2.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-5.0), center.y + (2.0)}, direction = direct.east, force = fN}
    ce{name = "stone-furnace", position = {center.x + (-1.5), center.y + (1.5)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (0.0), center.y + (2.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (4.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (3.0)}, direction = direct.south, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-3.0), center.y + (4.0)}, direction = direct.west, force = fN}
    ce{name = "stone-furnace", position = {center.x + (-1.5), center.y + (3.5)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (0.0), center.y + (4.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (4.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (3.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (6.0)}, direction = direct.south, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-3.0), center.y + (6.0)}, direction = direct.west, force = fN}
    ce{name = "stone-furnace", position = {center.x + (-1.5), center.y + (5.5)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (5.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (8.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (7.0)}, direction = direct.south, force = fN}
    ce{name = "stone-furnace", position = {center.x + (-1.5), center.y + (7.5)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (0.0), center.y + (8.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (8.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (7.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (10.0)}, direction = direct.south, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-3.0), center.y + (10.0)}, direction = direct.west, force = fN}
    ce{name = "stone-furnace", position = {center.x + (-1.5), center.y + (9.5)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (9.0)}, direction = direct.south, force = fN}

end
