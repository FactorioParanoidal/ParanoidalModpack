return function(center, surface) --small gears setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="fast-transport-belt", position={center.x + (-0.0), center.y + (3.0)}, direction=defines.direction.east, force=game.forces.neutral}
    ce{name="fast-transport-belt", position={center.x + (-0.0), center.y + (2.0)}, force=game.forces.neutral}
    ce{name="fast-transport-belt", position={center.x + (1.0), center.y + (2.0)}, direction=defines.direction.east, force=game.forces.neutral}
    ce{name="fast-transport-belt", position={center.x + (-2.0), center.y + (3.0)}, direction=defines.direction.east, force=game.forces.neutral}.damage(42,"neutral","physical")
    ce{name="fast-transport-belt", position={center.x + (-1.0), center.y + (3.0)}, direction=defines.direction.east, force=game.forces.neutral}.damage(18,"neutral","physical")
    ce{name="fast-transport-belt", position={center.x + (-1.0), center.y + (2.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="fast-transport-belt", position={center.x + (-3.0), center.y + (2.0)}, direction=defines.direction.east, force=game.forces.neutral}
    ce{name="fast-transport-belt", position={center.x + (-3.0), center.y + (3.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="assembling-machine-2", position={center.x + (2.0), center.y + (-1.0)}, force=game.forces.neutral}.damage(98,"neutral","physical")
    ce{name="medium-electric-pole", position={center.x + (-0.0), center.y + (1.0)}, force=game.forces.neutral}
    ce{name="fast-inserter", position={center.x + (1.0), center.y + (1.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="assembling-machine-2", position={center.x + (-1.0), center.y + (-1.0)}, force=game.forces.neutral}
    ce{name="fast-inserter", position={center.x + (-1.0), center.y + (1.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="fast-inserter", position={center.x + (2.0), center.y + (-3.0)}, direction=defines.direction.south, force=game.forces.neutral}.damage(36,"neutral","physical")
    ce{name="fast-inserter", position={center.x + (3.0), center.y + (-3.0)}, direction=defines.direction.south, force=game.forces.neutral}.damage(50,"neutral","physical")
    ce{name="fast-inserter", position={center.x + (-0.0), center.y + (-3.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="medium-electric-pole", position={center.x + (1.0), center.y + (-3.0)}, force=game.forces.neutral}
    ce{name="fast-inserter", position={center.x + (-1.0), center.y + (-3.0)}, direction=defines.direction.south, force=game.forces.neutral}

end
