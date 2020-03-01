return function(center, surface) --destroyed enemy fort
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-13.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-10.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-8.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (8.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (11.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (13.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-16.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-14.0)}, force = fN}
    ce{name = "gun-turret", position = {center.x + (-12.5), center.y + (-12.5)}, force = game.forces.enemy}.insert{name = "firearm-magazine", count = 2}
    ce{name = "fast-inserter", position = {center.x + (-11.0), center.y + (-13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-9.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-7.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-8.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-5.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-6.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-3.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-2.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (1.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (0.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (3.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (2.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (9.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (8.0), center.y + (-13.0)}, direction = direct.east, force = fN}
    ce{name = "fast-inserter", position = {center.x + (10.0), center.y + (-13.0)}, direction = direct.west, force = fN}
    ce{name = "gun-turret", position = {center.x + (11.5), center.y + (-12.5)}, force = game.forces.enemy}.insert{name = "firearm-magazine", count = 2}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-14.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-13.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-11.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-13.0), center.y + (-11.0)}, direction = direct.south, force = fN}
    ce{name = "underground-belt", position = {center.x + (-11.0), center.y + (-12.0)}, direction = direct.west, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-9.0), center.y + (-11.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-9.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-10.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-8.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-5.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-6.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-4.0), center.y + (-11.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-3.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-2.0), center.y + (-12.0)}, direction = direct.east, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (10.0), center.y + (-11.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (12.0), center.y + (-11.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-11.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-12.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-9.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-10.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-9.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-10.0)}, force = fN}
    ce{name = "assembling-machine-2", position = {center.x + (-8.0), center.y + (-9.0)}, force = fN}
    ce{name = "assembling-machine-2", position = {center.x + (-4.0), center.y + (-9.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-10.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-9.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-9.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-8.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-7.0), center.y + (-7.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-8.0), center.y + (-7.0)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (-6.0), center.y + (-7.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-5.0), center.y + (-7.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-4.0), center.y + (-7.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-8.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-7.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-8.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-5.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-5.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-6.0)}, force = fN}
    ce{name = "assembling-machine-2", position = {center.x + (-9.0), center.y + (-5.0)}, force = fN}
    ce{name = "assembling-machine-2", position = {center.x + (-6.0), center.y + (-5.0)}, force = fN}
    ce{name = "assembling-machine-2", position = {center.x + (-3.0), center.y + (-5.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-6.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-5.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-3.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-3.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-4.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-8.0), center.y + (-3.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-7.0), center.y + (-3.0)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (-6.0), center.y + (-3.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-5.0), center.y + (-3.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-4.0), center.y + (-3.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-3.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (-2.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-1.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (-2.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-9.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-10.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-7.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-8.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-5.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-6.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-3.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (-2.0), center.y + (-2.0)}, direction = direct.east, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (-2.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (0.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (1.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (1.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (2.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (3.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (2.0)}, force = fN}
    ce{name = "lab", position = {center.x + (2.0), center.y + (4.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (2.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (3.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (5.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (4.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (5.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (7.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (7.0)}, force = fN}
    ce{name = "lab", position = {center.x + (2.0), center.y + (7.0)}, force = fN}
    ce{name = "lab", position = {center.x + (5.0), center.y + (7.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (7.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (8.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (9.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (9.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (8.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (8.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (9.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (-13.0), center.y + (10.0)}, force = fN}
    ce{name = "fast-inserter", position = {center.x + (-12.0), center.y + (11.0)}, direction = direct.south, force = fN}
    ce{name = "transport-belt", position = {center.x + (-12.0), center.y + (10.0)}, direction = direct.west, force = fN}
    ce{name = "fast-inserter", position = {center.x + (12.0), center.y + (11.0)}, force = fN}
    ce{name = "transport-belt", position = {center.x + (12.0), center.y + (10.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (11.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (13.0)}, force = fN}
    ce{name = "gun-turret", position = {center.x + (-11.5), center.y + (12.5)}, force = game.forces.enemy}.insert{name = "firearm-magazine", count = 2}
    ce{name = "transport-belt", position = {center.x + (-7.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-8.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-5.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-6.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-3.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-4.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-1.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (-2.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (0.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (4.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (5.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (7.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (6.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (9.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "transport-belt", position = {center.x + (8.0), center.y + (13.0)}, direction = direct.west, force = fN}
    ce{name = "fast-inserter", position = {center.x + (10.0), center.y + (13.0)}, direction = direct.east, force = fN}
    ce{name = "gun-turret", position = {center.x + (11.5), center.y + (12.5)}, force = game.forces.enemy}.insert{name = "firearm-magazine", count = 2}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (12.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-15.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-16.0), center.y + (14.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-13.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-14.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-11.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-10.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (7.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (11.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (10.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (14.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (15.0), center.y + (15.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (14.0), center.y + (15.0)}, force = fN}
end
