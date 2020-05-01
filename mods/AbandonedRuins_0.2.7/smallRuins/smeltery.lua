
return function(center, surface) --smeltery
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="small-electric-pole", position={center.x + (-3.0), center.y + (-2.0)}, force = fN}
    local e = ce{name="stone-furnace", position={center.x + (-1.5), center.y + (-2.5)}, force = fN}
    if e then
      e.damage(12,"neutral","physical")
    end
    local e = ce{name="stone-furnace", position={center.x + (1.5), center.y + (-2.5)}, force = fN}
    if e then
      e.damage(19,"neutral","physical")
    end
    local e = ce{name="small-electric-pole", position={center.x + (3.0), center.y + (-2.0)}, force = fN}
    if e then
      e.damage(38,"neutral","physical")
    end
    local e = ce{name="small-lamp", position={center.x + (-3.0), center.y + (0.0)}, force = fN}
    if e then
      e.damage(62,"neutral","physical")
    end
    ce{name="wooden-chest", position = {center.x + (-3.0), center.y + (-3.0)}, force = game.forces.neutral}
    local e = ce{name="inserter", position={center.x + (-1.0), center.y + (-1.0)}, force = fN}
    if e then
      e.damage(9,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (-1.0), center.y + (0.0)}, direction = direct.south, force = fN}
    if e then
      e.damage(15,"neutral","physical")
    end
    ce{name="inserter", position={center.x + (2.0), center.y + (-1.0)}, force = fN}
    local e = ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction = direct.south, force = fN}
    if e then
      e.damage(33,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (-3.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(54,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(20,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (2.0)}, force = fN}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (0.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (2.0)}, force = fN}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (3.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="inserter", position={center.x + (-1.0), center.y + (3.0)}, direction = direct.south, force = fN}
    ce{name="inserter", position={center.x + (2.0), center.y + (3.0)}, direction = direct.south, force = fN}
end
