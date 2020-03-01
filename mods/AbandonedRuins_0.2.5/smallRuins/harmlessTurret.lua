
return function(center, surface) --harmless turret
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    ce{name = "gun-turret", position = {center.x + 1, center.y}, force = game.forces.enemy}.damage(math.random(250, 390),"neutral","physical")
end
