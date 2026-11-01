-------------------------------------------------------------------------------
--[[Sounds]] --
-------------------------------------------------------------------------------
local setup_animation = function(entity)
    for _, animation in pairs(entity.animations) do
        animation.scale = .5
    end
    for _, variation in pairs(entity.sound.variations) do
        variation.filename = '__base__/sound/fight/laser-1.ogg'
        variation.volume = .5
    end
end

local drop_planner = table.deepcopy(data.raw['explosion']['explosion'])
drop_planner.name = 'drop-planner'
setup_animation(drop_planner)
data:extend {drop_planner}

-- item zapper is currently disabled
--[[
data:extend {
    type = 'custom-input',
    name = 'picker-zapper',
    key_sequence = 'ALT + Z'
}
]]--