local north = {position = {0, -1}}
local south = {position = {0, 1}}
local west = {position = {-1, 0}}
local east = {position = {1, 0}}

local not_clampable = require('utils/not-clampable')

local clamped_layer = {
    straight_vertical = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical.png'
    },
    straight_horizontal = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-horizontal.png'
    },
    corner_up_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-right.png'
    },
    corner_up_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-left.png'
    },
    corner_down_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-right.png'
    },
    corner_down_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-left.png'
    },
    t_up = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-up.png'
    },
    t_down = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-down.png'
    },
    t_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-right.png'
    },
    t_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-left.png'
    },
    ending_up = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-up.png'
    },
    ending_down = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-down.png'
    },
    ending_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-right.png'
    },
    ending_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-left.png'
    },
    cross = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-cross.png'
    }
}

local pipe_make_table = {
    ['single'] = {
        locale = '[Single]',
        positions = {north},
        pictures = {
            up = 'ending_up',
            left = 'ending_left',
            down = 'ending_down',
            right = 'ending_right'
        }
    },
    ['l'] = {
        locale = '[Elbow]',
        positions = {north, west},
        pictures = {
            up = 'corner_up_left',
            right = 'corner_up_right',
            down = 'corner_down_right',
            left = 'corner_down_left'
        }
    },
    ['i'] = {
        locale = '[Straight]',
        positions = {north, south},
        pictures = {
            up = 'straight_vertical',
            right = 'straight_horizontal',
            down = 'straight_vertical',
            left = 'straight_horizontal'
        }
    },
    ['t'] = {
        locale = '[T junction]',
        positions = {north, east, west},
        pictures = {
            up = 't_up',
            right = 't_right',
            down = 't_down',
            left = 't_left'
        }
    },
    ['x'] = {
        locale = '[Cross junction]',
        positions = {north, east, south, west},
        pictures = {
            up = 'cross',
            right = 'cross',
            down = 'cross',
            left = 'cross'
        }
    }
}

--local file_path = "__PickerPipeTools__/graphics/entity/pipe/hr-pipe-"

local function build_picture_table(current_picture_table, current_name)
    return {
        up = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.up],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.up].hr_image_path,
                    priority = 'high',
                    width = 128,
                    height = 128,
                    scale = 0.5
                }
            }
        },
        down = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.down],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.down].hr_image_path,
                    priority = 'high',
                    width = 128,
                    height = 128,
                    scale = 0.5
                }
            }
        },
        left = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.left],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.left].hr_image_path,
                    priority = 'high',
                    width = 128,
                    height = 128,
                    scale = 0.5
                }
            }
        },
        right = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.right],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.right].hr_image_path,
                    priority = 'high',
                    width = 128,
                    height = 128,
                    scale = 0.5
                }
            }
        }
    }
end

local function build_composite_icon(entity, layers_to_add, layer_shift, layer_scale)
    local icon_layers = {}

    if entity.icons then
        for _, icon in pairs(entity.icons) do
            local working_icon_size = icon.icon_size or entity.icon_size
            icon_layers[#icon_layers + 1] = {
                icon = icon.icon,
                icon_size = working_icon_size,
                icon_mipmaps = icon.icon_mipmaps or entity.icon_mipmaps,
                tint = icon.tint,
                scale = icon.scale or (32 / working_icon_size),
                shift = icon.shift
            }
        end
    else
        icon_layers = {
            {
                icon = entity.icon,
                icon_size = entity.icon_size,
                icon_mipmaps = entity.icon_mipmaps,
                scale = (32 / entity.icon_size)
            }
        }
    end

    if layers_to_add[1] then
        for _, layer_to_add in pairs(layers_to_add) do
            icon_layers[#icon_layers + 1] = {
                icon = layer_to_add.icon,
                icon_size = layer_to_add.icon_size,
                icon_mipmaps = layer_to_add.icon_mipmaps,
                tint = layer_to_add.tint,
                scale = (layer_to_add.scale or (32 / layer_to_add.icon_size)) * (layer_scale or 1),
                shift = {
                    (layer_to_add.shift and (layer_to_add.shift[1] or layer_to_add.shift.x) or 0) * (layer_scale or 1) + (layer_shift and (layer_shift[1] or layer_shift.x) or 0),
                    (layer_to_add.shift and (layer_to_add.shift[2] or layer_to_add.shift.y) or 0) * (layer_scale or 1) + (layer_shift and (layer_shift[2] or layer_shift.y) or 0)
                }
            }
        end
    else
        icon_layers[#icon_layers + 1] = {
            icon = layers_to_add.icon,
            icon_size = layers_to_add.icon_size,
            icon_mipmaps = layers_to_add.icon_mipmaps,
            tint = layers_to_add.tint,
            scale = (layers_to_add.scale or (32 / layers_to_add.icon_size)) * (layer_scale or 1),
            shift = {
                (layers_to_add.shift and (layers_to_add.shift[1] or layers_to_add.shift.x) or 0) * (layer_scale or 1) + (layer_shift and (layer_shift[1] or layer_shift.x) or 0),
                (layers_to_add.shift and (layers_to_add.shift[2] or layers_to_add.shift.y) or 0) * (layer_scale or 1) + (layer_shift and (layer_shift[2] or layer_shift.y) or 0)
            }
        }
    end

    return icon_layers
end

if settings.startup['picker-tool-pipe-clamps'].value then
    local pipeEntities = {}
    for i, pipe in pairs(data.raw['pipe']) do
        for names, pipe_data in pairs(pipe_make_table) do
            if not pipe.clamped and not not_clampable(pipe.name) then
                local current_entity = table.deepcopy(pipe)
                current_entity.type = 'pipe-to-ground'
                current_entity.name = pipe.name .. '-clamped-' .. names
                current_entity.clamped = true
                current_entity.fast_replaceable_group = 'pipe'
                current_entity.localised_name = {'pipe-tools.clamped-name', pipe.name, pipe_data.locale}
                current_entity.placeable_by = {item = pipe.minable and pipe.minable.result or pipe.name, count = pipe.minable and pipe.minable.count or 1}
                current_entity.underground_sprite = table.deepcopy(data.raw['pipe-to-ground']['pipe-to-ground'].underground_sprite)
                current_entity.icons =
                    build_composite_icon(
                    current_entity,
                    {
                        icon = '__PickerPipeTools__/graphics/icons/lock.png',
                        icon_size = 32,
                        icon_mipmaps = 1
                    }
                )
                current_entity.flags = {'placeable-neutral', 'player-creation', 'fast-replaceable-no-build-while-moving'}
                current_entity.fluid_box.pipe_connections = pipe_data.positions
                current_entity.fluid_box.pipe_covers = _ENV.pipecoverspictures()
                current_entity.pictures = build_picture_table(current_entity.pictures, names)

                pipeEntities[#pipeEntities + 1] = current_entity
            end
        end
    end

    data:extend(pipeEntities)
end
