
return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-4.0), center.y + (-6.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-4.5), center.y + (-4.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-5.0)}, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (-1.0), center.y + (-4.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-3.0)}, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (-1.0), center.y + (-3.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-1.5), center.y + (-1.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-3.0)}, force = fN}
    ce{name = "land-mine", position = {center.x + (2.44921875), center.y + (-1.72265625)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-3.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (4.5), center.y + (-1.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-1.0)}, force = fN}
    ce{name = "land-mine", position = {center.x + (-4.3359375), center.y + (2.50390625)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (1.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (1.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (1.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (2.5), center.y + (2.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (5.0)}, force = fN}
    ce{name = "gate", position = {center.x + (1.0), center.y + (5.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (5.0)}, force = fN}
    ce{name = "gate", position = {center.x + (5.0), center.y + (5.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (5.0)}, force = fN}
end
