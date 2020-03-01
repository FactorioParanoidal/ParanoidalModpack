return function(center, surface) -- small mining
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="burner-mining-drill", position={center.x + (-1.5), center.y + (-0.5)}, direction=defines.direction.south, force=game.forces.neutral}
    ce{name="burner-mining-drill", position={center.x + (0.5), center.y + (-0.5)}, direction=defines.direction.south, force=game.forces.neutral}.damage(99,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(112,"neutral","physical")
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(138,"neutral","physical")
end
