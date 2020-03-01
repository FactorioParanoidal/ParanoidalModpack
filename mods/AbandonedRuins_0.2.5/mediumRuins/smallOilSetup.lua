return function(center, surface) --small oil setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-5.0)}, force = fN}
    ce{name = "storage-tank", position = {center.x + (1.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-3.0)}, force = fN}
    ce{name = "storage-tank", position = {center.x + (-2.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-1.0)}, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (1.0), center.y + (0.0)}, force = fN}
    ce{name = "pipe", position = {center.x + (0.0), center.y + (-1.0)}, force = fN}
    ce{name = "pipe", position = {center.x + (1.0), center.y + (-1.0)}, force = fN}
    ce{name = "pipe", position = {center.x + (2.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (3.0)}, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (1.0), center.y + (4.0)}, direction = direct.south, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (3.0)}, force = fN}
end
