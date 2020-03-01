
return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (1.0), center.y + (-6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (0.0), center.y + (-6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (-6.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (-4.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-0.5), center.y + (-3.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (4.5), center.y + (-1.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-6.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (0.0)}, force = game.forces.neutral}
    local chest = ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-1.0)}, force = game.forces.neutral}
    chest.insert{name = "iron-plate", count = math.random(10, 200)}
    chest.insert{name = "copper-plate", count = math.random(10, 200)}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (2.5), center.y + (-0.5)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (6.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (6.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-4.5), center.y + (2.5)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-6.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-1.5), center.y + (1.5)}, force = game.forces.neutral}
    ce{name = "gun-turret", position = {center.x + (1.5), center.y + (1.5)}, direction = defines.direction.east, force = game.forces.enemy}.insert{name = "firearm-magazine", count = 5}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (4.5), center.y + (2.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-0.5), center.y + (4.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-2.0), center.y + (6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (6.0)}, force = game.forces.neutral}

end
