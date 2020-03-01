
return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (-5.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (-6.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (-6.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (-4.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (-4.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (-3.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (-1.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (-2.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (-2.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (-1.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (-6.0), center.y + (0.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (-4.0), center.y + (0.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-1.5), center.y + (0.5)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-1.5), center.y + (-0.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (-2.0), center.y + (0.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (0.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (1.5), center.y + (0.5)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (1.5), center.y + (-0.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (2.0), center.y + (0.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (6.0), center.y + (0.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (2.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (1.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (1.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (2.5)}, force = game.forces.neutral}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (4.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (6.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.5), center.y + (5.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (5.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.5), center.y + (6.5)}, force = game.forces.neutral}

end
