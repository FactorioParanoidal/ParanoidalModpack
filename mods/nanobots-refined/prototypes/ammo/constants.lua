local constants = {}
constants.projectile_animation = {
    layers = {
        {
            filename = '__nanobots-refined__/graphics/entity/nano-projectile.png',
            priority = 'high',
            line_length = 4,
            width = 70,
            height = 70,
            frame_count = 8,
            frame_sequence = { 1, 3, 4, 2, 5, 7, 8, 6 },
            scale = 0.25
        },
        {
            filename = '__nanobots-refined__/graphics/entity/nano-projectile-shadow.png',
            priority = 'high',
            line_length = 4,
            width = 70,
            height = 45,
            frame_count = 8,
            frame_sequence = { 1, 3, 4, 2, 5, 7, 8, 6 },
            shift = {0.859375, 0.609375},
            scale = 0.25,
            draw_as_shadow = true
        }
    }
}

function constants.cloud_animation(scale)
    scale = scale or .4
    return {
        filename = '__nanobots-refined__/graphics/entity/cloud/cloud-45-frames.png',
        --flags = {'compressed'},
        priority = 'low',
        width = 256,
        height = 256,
        frame_count = 45,
        animation_speed = 0.5,
        line_length = 7,
        scale = scale,
        shift = {0.0, 0.75}
    }
end

constants.impact_splat = {
    type = 'play-sound',
    play_on_target_position = true,
    max_distance = 100,
    sound = {
        priority = 100,
        audible_distance_modifier = 0.5,
        variations = { { filename = '__nanobots-refined__/sounds/splat1.ogg', volume = 0.2 },
                       { filename = '__nanobots-refined__/sounds/splat2.ogg', volume = 0.3 },
                       { filename = '__nanobots-refined__/sounds/splat3.ogg', volume = 0.5 },
                       { filename = '__nanobots-refined__/sounds/splat4.ogg', volume = 0.4 }},
        allow_random_repeat = true,
        aggregation = {max_count = 5, remove = true, count_already_playing = true, priority = "newest"}
    }
}

return constants
