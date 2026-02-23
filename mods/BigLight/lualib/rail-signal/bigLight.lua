
-- function rail signal (normal)
function rail_signal(name)

    local value = settings.startup["ritnmods-bl-05"].value

    if value == 0 then return end --light vanilla

    local LuaEntityPrototype = table.deepcopy(data.raw["rail-signal"][name])
    local layers = LuaEntityPrototype.animation.layers
    local size = 1

    local bigLightLayer = {
        [1] = {
            filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-signal-big-light-1.png",
            priority = "high",
            blend_mode = nil,
            width = 192,
            height = 192,
            frame_count = 3,
            direction_count = 8,
            scale = size / 4,
            --[[ hr_version =
            {
                filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-signal-big-light-1.png",
                priority = "high",
                blend_mode = nil,
                width = 192,
                height = 192,
                frame_count = 3,
                direction_count = 8,
                scale = size / 2
            } ]]
        },
        [2] = {
            filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-signal-big-light-2.png",
            priority = "high",
            blend_mode = nil,
            width = 192,
            height = 192,
            frame_count = 3,
            direction_count = 8,
            scale = size / 4,
            --[[ hr_version =
            {
                filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-signal-big-light-2.png",
                priority = "high",
                blend_mode = nil,
                width = 192,
                height = 192,
                frame_count = 3,
                direction_count = 8,
                scale = size / 2
            } ]]
        },
        [3] = {
            filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-signal-big-light-3.png",
            priority = "high",
            blend_mode = nil,
            width = 192,
            height = 192,
            frame_count = 3,
            direction_count = 8,
            scale = size / 4,
            --[[ hr_version =
            {
                filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-signal-big-light-3.png",
                priority = "high",
                blend_mode = nil,
                width = 192,
                height = 192,
                frame_count = 3,
                direction_count = 8,
                scale = size / 2
            } ]]
        }
    }
     
    table.insert(layers, bigLightLayer[value])
    LuaEntityPrototype.animation.layers = layers
    
    LuaEntityPrototype.green_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={g=1}}
    LuaEntityPrototype.orange_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={r=1, g=1}}
    LuaEntityPrototype.red_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={r=1}}


    data.raw["rail-signal"][name] = LuaEntityPrototype

end



-- function rail signal chain
function rail_signal_chain(name)

    local value = settings.startup["ritnmods-bl-05"].value

    if value == 0 then return end --light vanilla

    local LuaEntityPrototype = data.raw["rail-chain-signal"][name]
    local layers = LuaEntityPrototype.animation.layers

    local size = 1
    local shiftVal = 25


    local bigLightLayer = {
        [1] = {
            filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-chain-signal-big-light-1.png",
            priority = "high",
            blend_mode = nil,
            line_length = 5,
            width = 320,
            height = 320,
            frame_count = 5,
            axially_symmetrical = false,
            direction_count = 8,
            scale = size / 4,
            --[[ hr_version =
            {
                filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-chain-signal-big-light-1.png",
                priority = "high",
                blend_mode = nil,
                line_length = 5,
                width = 320,
                height = 320,
                frame_count = 5,
                axially_symmetrical = false,
                direction_count = 8,
                scale = size / 2
            } ]]
        },
        [2] = {
            filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-chain-signal-big-light-2.png",
            priority = "high",
            blend_mode = nil,
            line_length = 5,
            width = 320,
            height = 320,
            frame_count = 5,
            axially_symmetrical = false,
            direction_count = 8,
            scale = size / 4,
            --[[ hr_version =
            {
                filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-chain-signal-big-light-2.png",
                priority = "high",
                blend_mode = nil,
                line_length = 5,
                width = 320,
                height = 320,
                frame_count = 5,
                axially_symmetrical = false,
                direction_count = 8,
                scale = size / 2
            } ]]
        },
        [3] = {
            filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-chain-signal-big-light-3.png",
            priority = "high",
            blend_mode = nil,
            line_length = 5,
            width = 320,
            height = 320,
            frame_count = 5,
            axially_symmetrical = false,
            direction_count = 8,
            scale = size / 4,
            --[[ hr_version =
            {
                filename = "__BigLight__/graphics/entity/rail-signal/hr-rail-chain-signal-big-light-3.png",
                priority = "high",
                blend_mode = nil,
                line_length = 5,
                width = 320,
                height = 320,
                frame_count = 5,
                axially_symmetrical = false,
                direction_count = 8,
                scale = size / 2,
            } ]]
        }
    }

    table.insert(layers, bigLightLayer[value])
    LuaEntityPrototype.animation.layers = layers

    LuaEntityPrototype.green_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={g=1}}
    LuaEntityPrototype.orange_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={r=1, g=1}}
    LuaEntityPrototype.red_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={r=1}}
    LuaEntityPrototype.blue_light = {intensity = (0.2 * (value * 2)), size = 5 + value, color={r=0.4, g=0.4, b=1}}


    data.raw["rail-chain-signal"][name] = LuaEntityPrototype

end





-- return lib function rail signal
local lib = {
    rail_signal = rail_signal,
    rail_signal_chain = rail_signal_chain
}
return lib