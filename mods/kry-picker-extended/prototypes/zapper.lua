-------------------------------------------------------------------------------
--[[Sounds]] --
-------------------------------------------------------------------------------
local Entity = require('__kry_stdlib__/stdlib/data/entity')

local setup_animation = function(entity)
    for _, animation in pairs(entity.animations) do
        animation.scale = .5
    end
    for _, variation in pairs(entity.sound.variations) do
        variation.filename = '__base__/sound/fight/laser-1.ogg'
        variation.volume = .5
    end
end

Entity('explosion', 'explosion'):krycopy('drop-planner'):execute(setup_animation)

-- item zapper is currently disabled
--[[
Entity {
    type = 'custom-input',
    name = 'picker-zapper',
    key_sequence = 'ALT + Z'
}
]]--