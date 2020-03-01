return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end

    local fN = game.forces.neutral
    local direct = defines.direction


    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-2.0), center.y + (-6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (-6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (-4.0)}, force = game.forces.neutral}.insert{name = "iron-plate", count = math.random(10, 200)}
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (-4.0)}, force = game.forces.neutral}.insert{name = "copper-plate", count = math.random(10, 200)}
    ce{name = "wooden-chest", position = {center.x + (2.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (-2.0)}, force = game.forces.neutral}.insert{name = "steel-plate", count = math.random(10, 200)}
    ce{name = "iron-chest", position = {center.x + (-1.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (-3.0)}, force = game.forces.neutral}.insert{name = "transport-belt", count = math.random(10, 70)}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (5.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-7.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-7.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (-6.0), center.y + (-1.0)}, force = game.forces.neutral}.insert{name = "iron-plate", count = math.random(10, 200)}
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-3.0), center.y + (0.0)}, force = game.forces.neutral}.insert{name = "iron-ore", count = math.random(50, 200)}
    ce{name = "wooden-chest", position = {center.x + (-1.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (5.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (2.0)}, force = game.forces.neutral}.insert{name = "coal", count = math.random(10, 200)}
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (-3.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (1.0)}, force = game.forces.neutral}.insert{name = "stone", count = math.random(10, 200)}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (3.0), center.y + (2.0)}, force = game.forces.neutral}.insert{name = "inserter", count = math.random(10, 20)}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (4.0)}, force = game.forces.neutral}.insert{name = "copper-plate", count = math.random(10, 200)}
    ce{name = "iron-chest", position = {center.x + (-4.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-3.0), center.y + (3.0)}, force = game.forces.neutral}.insert{name = "repair-pack", count = math.random(10, 20)}
    ce{name = "wooden-chest", position = {center.x + (-2.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (-1.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (2.0), center.y + (4.0)}, force = game.forces.neutral}.insert{name = "gun-turret", count = math.random(10, 20)}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (3.0)}, force = game.forces.neutral}.insert{name = "firearm-magazine", count = math.random(10, 100)}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (0.0), center.y + (6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (6.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (5.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (6.0)}, force = game.forces.neutral}
end
