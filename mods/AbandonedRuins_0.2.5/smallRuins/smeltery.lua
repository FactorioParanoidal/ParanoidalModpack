
return function(center, surface) --smeltery
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="small-electric-pole", position={center.x + (-3.0), center.y + (-2.0)}, force=game.forces.neutral}
    ce{name="stone-furnace", position={center.x + (-1.5), center.y + (-2.5)}, force=game.forces.neutral}.damage(12,"neutral","physical")
    ce{name="stone-furnace", position={center.x + (1.5), center.y + (-2.5)}, force=game.forces.neutral}.damage(19,"neutral","physical")
    ce{name="small-electric-pole", position={center.x + (3.0), center.y + (-2.0)}, force=game.forces.neutral}.damage(38,"neutral","physical")
    ce{name="small-lamp", position={center.x + (-3.0), center.y + (0.0)}, force=game.forces.neutral}.damage(62,"neutral","physical")
    ce{name="wooden-chest", position = {center.x + (-3.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name="inserter", position={center.x + (-1.0), center.y + (-1.0)}, force=game.forces.neutral}.damage(9,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (0.0)}, direction=defines.direction.south, force=game.forces.neutral}.damage(15,"neutral","physical")
    ce{name="inserter", position={center.x + (2.0), center.y + (-1.0)}, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction=defines.direction.south, force=game.forces.neutral}.damage(33,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-3.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(54,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(20,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (2.0)}, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (0.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (2.0)}, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (3.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="inserter", position={center.x + (-1.0), center.y + (3.0)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="inserter", position={center.x + (2.0), center.y + (3.0)}, direction=defines.direction.south, force=game.forces.neutral}
end
