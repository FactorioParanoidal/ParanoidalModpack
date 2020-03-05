local merge = _G.util.merge
local base_entity = {
    type = 'corpse',
    name = 'fillerstuff',
    flags = {'placeable-neutral', 'not-on-map'},
    subgroup = 'remnants',
    order = 'd[remnants]-c[wall]',
    icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlightergood.png',
    icon_size = 32,
    time_before_removed = 2000000000,
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selectable_in_game = false,
    final_render_layer = 'selection-box',
    animation = {
        width = 32,
        height = 32,
        frame_count = 1,
        direction_count = 1,
        shift = {-0.5,-0.6},
        filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlightergood.png'
    }
}

--[[local pipe_sprite_prototypes = {}
do
    local i = 1
        for x = 0, 160 - 32, 32 do
            pipe_sprite_prototypes[i] = {
                type = 'sprite',
                name = 'picker-pipe-marker-' .. i,
                width = 32,
                height = 32,
                x = x,
                y = 0,
                filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrows.png'
            }
            i = i + 1
        end
end
data:extend(pipe_sprite_prototypes)]]--



local dot_table = {
    ['picker-pipe-dot'] = 'pipe-marker-dot',
    ['picker-pipe-dot-good'] = 'pipe-marker-dot-good',
    ['picker-pipe-dot-bad'] = 'pipe-marker-dot-bad'
}
local not_needed_bad_dots = {
    [21] = '-nse',
    [69] = '-new',
    [81] = '-nsw',
    [84] = '-sew',
    [85] = '-nsew'
}
local directional_table = {
    ['0'] = '',
    [1] = '-n',
    [4] = '-e',
    [5] = '-ne',
    [16] = '-s',
    [17] = '-ns',
    [20] = '-se',
    [21] = '-nse',
    [64] = '-w',
    [65] = '-nw',
    [68] = '-ew',
    [69] = '-new',
    [80] = '-sw',
    [81] = '-nsw',
    [84] = '-sew',
    [85] = '-nsew'
}
local new_dots = {}
for dots, images in pairs(dot_table) do
    for direction_index, directions in pairs(directional_table) do
        if not (dots == 'picker-pipe-dot-bad' and not_needed_bad_dots[direction_index]) then
            local current_entity = util.table.deepcopy(base_entity)
            current_entity.type = 'corpse'
            current_entity.name = dots .. directions
            --current_entity.animation.shift = {0, -0.1}
            if direction_index == '0' then
                current_entity.final_render_layer = 'light-effect'
                current_entity.animation.scale = 0.5
            else
              current_entity.animation.width = 32
              current_entity.animation.height = 32
            end
            current_entity.animation.filename = '__PickerPipeTools__/graphics/entity/markers/' .. images .. directions .. '.png'
            new_dots[#new_dots + 1] = current_entity
        end
    end
end

local pump_marker_table = {
    ['picker-pump-marker'] = 'pump-marker',
    ['picker-pump-marker-good'] = 'pump-marker-good'
}
local pump_directions = {
    '-n',
    '-e',
    '-s',
    '-w'
}

for pump_marker_name, images in pairs(pump_marker_table) do
    for _, directions in pairs(pump_directions) do
        local current_entity = util.table.deepcopy(base_entity)
        current_entity.type = 'corpse'
        current_entity.name = pump_marker_name .. directions
        current_entity.animation.shift = {0, -0.1}
        if directions == '-n' or directions == '-s' then
            current_entity.animation.width = 32
            current_entity.animation.height = 64
            current_entity.animation.shift = {-0.5, -0.1}
        else
            current_entity.animation.width = 64
            current_entity.animation.height = 32
            current_entity.animation.shift = {0, -0.6}
        end
        current_entity.animation.filename = '__PickerPipeTools__/graphics/entity/markers/' .. images .. directions .. '.png'
        new_dots[#new_dots + 1] = current_entity
    end
end
local red_pump_marker_names = {
    ['-n'] = {
        '',
        '-n',
        '-s',
        '-ns'
    },
    ['-e'] = {
        '',
        '-e',
        '-w',
        '-ew'
    },
    ['-s'] = {
        '',
        '-n',
        '-s',
        '-ns'
    },
    ['-w'] = {
        '',
        '-e',
        '-w',
        '-ew'
    }
}
for direction, sub_directions in pairs(red_pump_marker_names) do
    for _, sub_direction in pairs(sub_directions) do
        local current_entity = util.table.deepcopy(base_entity)
        current_entity.type = 'corpse'
        current_entity.name = 'picker-pump-marker-bad' .. direction .. sub_direction
        current_entity.animation.shift = {0, -0.1}
        if direction == '-n' or direction == '-s' then
            current_entity.animation.width = 32
            current_entity.animation.height = 64
            current_entity.animation.shift = {-0.5, -0.1}
        else
            current_entity.animation.width = 64
            current_entity.animation.height = 32
            current_entity.animation.shift = {0, -0.6}
        end
        current_entity.animation.filename = '__PickerPipeTools__/graphics/entity/markers/pump-marker-bad' .. direction .. sub_direction .. '.png'
        new_dots[#new_dots + 1] = current_entity
    end
end

for _, stuff in pairs(new_dots) do
    data:extend {
        merge {
            base_entity,
            stuff
        }
    }
end

local underground_marker_beam_table = {
    ['picker-pipe-marker-beam'] = {
        dash = 'pipe-marker-horizontal'
        --TODO 0.17--box = 'pipe-marker-dot',
    },
    ['picker-pipe-marker-beam-good'] = {
        dash = 'pipe-marker-horizontal-good'
        --TODO 0.17--box = 'pipe-marker-dot-good',
    },
    ['picker-pipe-marker-beam-bad'] = {
        dash = 'pipe-marker-horizontal-bad'
        --TODO 0.17--box = 'pipe-marker-dot-bad',
    },
    ['picker-underground-marker-beam'] = {
        dash = 'underground-lines-single-horizontal'
        --TODO 0.17-- box = 'pipe-marker-dot-bad',
    }
}
local underground_marker_beams = {}
for beam_type, marker_name in pairs(underground_marker_beam_table) do
    local marker_beams = util.table.deepcopy(data.raw['beam']['electric-beam-no-sound'])
    marker_beams.name = beam_type
    marker_beams.width = 1.0
    marker_beams.damage_interval = 2000000000
    marker_beams.action = nil
    marker_beams.start = {
        filename = '__core__/graphics/empty.png',
        line_length = 1,
        width = 1,
        height = 1,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        hr_version = {
            filename = '__core__/graphics/empty.png',
            line_length = 1,
            width = 1,
            height = 1,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1
        }
    }
    marker_beams.head_light = nil
    marker_beams.tail_light = nil
    marker_beams.body_light = nil
    marker_beams.start_light = nil
    marker_beams.ending_light = nil
    marker_beams.ending = {
        filename = '__core__/graphics/empty.png',
        line_length = 1,
        width = 1,
        height = 1,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        hr_version = {
            filename = '__core__/graphics/empty.png',
            line_length = 1,
            width = 1,
            height = 1,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1
        }
    }
     --
    -- TODO 0.17 version
    --[[marker_beams.ending = {
        filename = "__PickerPipeTools__/graphics/entity/markers/" .. marker_name.box .. ".png",
        line_length = 1,
        width = 64,
        height = 64,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        --shift = {-0.03125, 0},
        scale = 0.5,
        hr_version =
        {
            filename = "__PickerPipeTools__/graphics/entity/markers/" .. marker_name.box .. ".png",
            line_length = 1,
            width = 64,
            height = 64,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            --shift = {0.53125, 0},
            scale = 0.5
        }
    }]] if
        beam_type == 'picker-underground-marker-beam'
     then
        marker_beams.head = {
            filename = '__PickerPipeTools__/graphics/entity/markers/' .. marker_name.dash .. '.png',
            line_length = 1,
            width = 64,
            height = 64,
            frame_count = 1,
            animation_speed = 1,
            scale = 0.5
        }
        marker_beams.tail = {
            filename = '__PickerPipeTools__/graphics/entity/markers/' .. marker_name.dash .. '.png',
            line_length = 1,
            width = 64,
            height = 64,
            frame_count = 1,
            animation_speed = 1,
            scale = 0.5
        }
        marker_beams.body = {
            {
                filename = '__PickerPipeTools__/graphics/entity/markers/' .. marker_name.dash .. '.png',
                line_length = 1,
                width = 64,
                height = 64,
                frame_count = 1,
                scale = 0.5
            }
        }
    else
        marker_beams.head = {
            filename = '__PickerPipeTools__/graphics/entity/markers/' .. marker_name.dash .. '.png',
            line_length = 1,
            width = 64,
            height = 64,
            frame_count = 1,
            animation_speed = 1,
            scale = 0.5
        }
        marker_beams.tail = {
            filename = '__PickerPipeTools__/graphics/entity/markers/' .. marker_name.dash .. '.png',
            line_length = 1,
            width = 64,
            height = 64,
            frame_count = 1,
            animation_speed = 1,
            scale = 0.5
        }
        marker_beams.body = {
            {
                filename = '__PickerPipeTools__/graphics/entity/markers/' .. marker_name.dash .. '.png',
                line_length = 1,
                width = 64,
                height = 64,
                frame_count = 1,
                scale = 0.5
            }
        }
    end
    marker_beams.light_animations = nil
    underground_marker_beams[#underground_marker_beams + 1] = marker_beams
end

data:extend(underground_marker_beams)
data:extend {
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-box-bad',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-orphan-pipe-marker-box-bad',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            time_before_removed = 60 * 10,
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-box-good',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlightergood.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlightergood.png'
            }
        }
    }
}
