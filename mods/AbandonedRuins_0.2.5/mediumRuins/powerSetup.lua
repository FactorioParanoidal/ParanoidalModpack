return function(center, surface) --power setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "medium-electric-pole", position = {center.x + (3.0), center.y + (-6.0)}, force = fN}
    ce{name = "steam-engine", position = {center.x + (-4.0), center.y + (0.0)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (-1.0), center.y + (-3.0)}, force = fN}
    ce{name = "steam-engine", position = {center.x + (-1.0), center.y + (0.0)}, force = fN}
    ce{name = "steam-engine", position = {center.x + (2.0), center.y + (0.0)}, force = fN}
    ce{name = "boiler", position = {center.x + (-4.0), center.y + (3.5)}, force = fN}
    ce{name = "boiler", position = {center.x + (-1.0), center.y + (3.5)}, force = fN}
    ce{name = "boiler", position = {center.x + (2.0), center.y + (3.5)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-5.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "burner-inserter", position = {center.x + (-4.0), center.y + (5.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-3.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "burner-inserter", position = {center.x + (-1.0), center.y + (5.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-1.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-2.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (0.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "burner-inserter", position = {center.x + (2.0), center.y + (5.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (2.0), center.y + (6.0)}, direction = direct.east, force = fN}
end
