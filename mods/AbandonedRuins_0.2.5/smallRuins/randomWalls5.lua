return function(center, surface) --random walls
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "wooden-chest", position = {center.x, center.y}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y-1.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 2.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 2.5, center.y-1.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-1.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 1.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-1.5, center.y + 2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-0.5, center.y + 2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 1.5, center.y + 2.5}, force = fN}
end
