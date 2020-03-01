return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end

    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-14.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-12.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-11.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-8.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (8.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (13.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-15.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-13.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-11.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-12.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-7.5), center.y + (-10.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-1.5), center.y + (-10.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (8.5), center.y + (-11.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-12.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-11.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-9.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (1.5), center.y + (-8.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (4.5), center.y + (-9.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-10.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-8.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (8.5), center.y + (-6.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-8.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-7.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-5.5), center.y + (-5.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (11.5), center.y + (-5.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-12.5), center.y + (-3.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-11.5), center.y + (-0.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (8.5), center.y + (-1.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (10.5), center.y + (0.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (8.5), center.y + (2.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (11.5), center.y + (3.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-12.5), center.y + (4.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-6.5), center.y + (4.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (9.5), center.y + (5.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (7.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-0.5), center.y + (6.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (5.5), center.y + (7.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (7.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (9.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-4.5), center.y + (9.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (8.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (9.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (11.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-10.5), center.y + (10.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (1.5), center.y + (10.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (5.5), center.y + (11.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (10.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (11.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (13.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (12.0)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (-4.5), center.y + (12.5)}, force = game.forces.neutral}
    ce{name = "tree-04", position = {center.x + (8.5), center.y + (12.5)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (12.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (13.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-13.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-14.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-12.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-8.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (7.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (8.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (11.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (10.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (13.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (12.0), center.y + (14.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (14.0)}, force = game.forces.neutral}

    surface.set_tiles({
            {name = "water", position = {center.x + (-4.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (-3.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (-3.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (-2.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (-1.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (0.0), center.y + (3.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (1.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (2.0), center.y + (3.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (-5.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (-4.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (3.0)}},
            {name = "water", position = {center.x + (3.0), center.y + (4.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (-4.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (-3.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (-2.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (-1.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (0.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (1.0)}},
            {name = "water", position = {center.x + (4.0), center.y + (2.0)}},
            {name = "water", position = {center.x + (5.0), center.y + (-3.0)}},
                               }, true)

end
