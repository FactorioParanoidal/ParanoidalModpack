
return function(center, surface) --rough perimeter
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral

    ce{name = "rock-big", position = {center.x + (-5.5), center.y + (-5.5)}, force = fN}
    ce{name = "rock-big", position = {center.x + (5.5), center.y + (-5.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-5.0)}, force = fN}
    ce{name = "rock-big", position = {center.x + (-1.5), center.y + (-4.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-5.0)}, force = fN}
    ce{name = "rock-big", position = {center.x + (2.5), center.y + (-4.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-4.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-5.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-3.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-5.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (0.0)}, force = fN}
    ce{name = "rock-big", position = {center.x + (6.5), center.y + (-0.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (1.0)}, force = fN}
    ce{name = "gate", position = {center.x + (6.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (1.0)}, force = fN}
    ce{name = "rock-big", position = {center.x + (-5.5), center.y + (3.5)}, force = fN}
    ce{name = "rock-big", position = {center.x + (3.5), center.y + (4.5)}, force = fN}
    ce{name = "gate", position = {center.x + (6.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (6.0)}, force = fN}
    ce{name = "rock-big", position = {center.x + (-0.5), center.y + (6.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (5.0)}, force = fN}
end
