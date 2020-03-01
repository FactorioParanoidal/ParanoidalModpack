return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral

    ce{name = "tree-05", position = {center.x + (-2.5), center.y + (-5.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (0.5), center.y + (-6.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (3.5), center.y + (-5.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-4.5), center.y + (-3.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (-2.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-6.5), center.y + (-0.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (6.5), center.y + (0.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (2.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (3.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (-3.5), center.y + (5.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (0.5), center.y + (6.5)}, force = game.forces.neutral}
    ce{name = "tree-05", position = {center.x + (3.5), center.y + (5.5)}, force = game.forces.neutral}

    surface.set_tiles({
            {name = "water", position = {center.x + (-2.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (0.0)}},
                               }, true)


end
