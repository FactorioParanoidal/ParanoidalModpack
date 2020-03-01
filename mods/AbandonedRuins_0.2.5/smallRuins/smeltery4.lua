
return function(center, surface) --smeltery
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="medium-electric-pole", position={center.x + (-3.0), center.y + (-2.0)}, force=game.forces.neutral}
    ce{name="medium-electric-pole", position={center.x + (-3.0), center.y + (4.0)}, force=game.forces.neutral}.damage(30,"neutral","physical")
    ce{name="stone-furnace", position={center.x + (1.5), center.y + (-2.5)}, force=game.forces.neutral}
    ce{name="stone-furnace", position={center.x + (-1.5), center.y + (4.5)}, force=game.forces.neutral}.damage(15,"neutral","physical")
    ce{name="wooden-chest", position = {center.x + (-3.0), center.y + (-3.0)}, force = game.forces.neutral}.insert{name = "copper-plate", count = math.random(1, 40)}
    ce{name="inserter", position={center.x + (-1.0), center.y + (-1.0)}, force=game.forces.neutral}.damage(60,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (0.0)}, direction=defines.direction.south, force=game.forces.neutral}.damage(45,"neutral","physical")
    ce{name="inserter", position={center.x + (2.0), center.y + (-1.0)}, force=game.forces.neutral}.damage(45,"neutral","physical")
    ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (-3.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(75,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (2.0)}, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (0.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(30,"neutral","physical")
    ce{name="transport-belt", position={center.x + (2.0), center.y + (2.0)}, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (3.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="inserter", position={center.x + (-1.0), center.y + (3.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="inserter", position={center.x + (2.0), center.y + (3.0)}, direction=defines.direction.south, force=game.forces.neutral}
end
