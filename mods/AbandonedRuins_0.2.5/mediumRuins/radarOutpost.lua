
return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral

    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "radar", position = {center.x + (0.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (4.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "gun-turret", position = {center.x + (-3.5), center.y + (0.5)}, force = game.forces.enemy}.insert{name = "firearm-magazine", count = 5}
    ce{name = "medium-electric-pole", position = {center.x + (-2.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (4.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "medium-electric-pole", position = {center.x + (4.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (2.0)}, force = game.forces.neutral}
end
