require('init')
require('data_init')

require('prototypes.custom_input')
require('prototypes.groups')
require('prototypes.item')
require('prototypes.shortcuts')

--- @type segments_data
MergingChests.steel_chest_segments = {
    wide_segments = {
        entity = {
            filename = '__WideChests__/graphics/entity/steel-chest/wide-chest/wide-chest.png',
            top_left = { x = 0, y = 0 },
            top = { x = 32, y = 0 },
            top_right = { x = 64, y = 0 },

            widths = { left = 64, middle = 64, right = 64 },
            heights = {
                top = 80,
                middle = 0,
                bottom = 0
            },
            shift = { x = -0.25, y = -4.5 },
            scale = 0.5
        },
        shadow = {
            filename = '__WideChests__/graphics/entity/steel-chest/wide-chest/wide-chest-shadow.png',
            top_right = { x = 60, y = 0, shift = { x = 30 } },

            widths = { left = 0, middle = 0, right = 50 },
            heights = {
                top = 46,
                middle = 0,
                bottom = 0
            },
            shift = { x = 0.75, y = 12.5 },
            scale = 0.5,
            shadow = true
        }
    },
    high_segments = {
        entity = {
            filename = '__WideChests__/graphics/entity/steel-chest/high-chest/high-chest.png',
            top_left = { x = 0, y = 0, shift = { y = 5 } },
            left = { x = 0, y = 22 },
            bottom_left = { x = 0, y = 54 },

            widths = { left = 64, middle = 0, right = 0 },
            heights = {
                top = 54,
                middle = 64,
                bottom = 90
            },
            shift = { x = -0.25, y = -9.5 },
            scale = 0.5
        },
        shadow = {
            filename = '__WideChests__/graphics/entity/steel-chest/high-chest/high-chest-shadow.png',
            top_right = { x = 0, y = 0, shift = { y = 6.5 } },
            right = { x = 0, y = 18 },
            bottom_right = { x = 0, y = 45 },

            widths = { left = 0, middle = 0, right = 110 },
            heights = {
                top = 55,
                middle = 64,
                bottom = 55
            },
            shift = { x = 0.75, y = 6 },
            scale = 0.5,
            shadow = true
        }
    },
    warehouse_segments = {
        entity = {
            filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse.png',

            top_left = { x = 0, y = 0, shift = { y = 7 } },
            top = { x = 66, y = 0, shift = { y = 7 } },
            top_right = { x = 130, y = 0, shift = { y = 7 } },

            left = {
                { x = 0, y = 75 },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-2.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-3.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-4.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-5.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-6.png',
                    y = 57
                }
            },
            middle = {
                { x = 66, y = 75 },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-2.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-3.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-4.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-5.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-6.png',
                    y = 57
                }
            },
            right = {
                { x = 130, y = 75 },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-2.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-3.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-4.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-5.png',
                    y = 57
                },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-6.png',
                    y = 57
                }
            },

            bottom_left = { x = 0, y = 139 },
            bottom = {
                { x = 66, y = 139 },
                {
                    filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-1.png'
                }
            },
            bottom_right = { x = 130, y = 139 },

            widths = { left = 66, middle = 64, right = 66 },
            heights = {
                top = 50,
                middle = 64,
                bottom = 110
            },
            shift = { x = 0, y = -23 },
            scale = 0.5
        },
        shadow = {
            filename = '__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-shadow.png',

            top_right = { x = 0, y = 0, shift = { x = 32, y = 7 } },

            right = { x = 0, y = 49, shift = { x = 32 } },

            bottom_right = { x = 0, y = 113, shift = { x = 32 } },

            widths = { right = 120 },
            heights = {
                top = 50,
                middle = 64,
                bottom = 50
            },
            shift = { x = -1, y = 6 },
            scale = 0.5,
            shadow = true
        }
    },
    trashdump_segments = {
        entity = {
            filename = '__WideChests__/graphics/entity/steel-chest/trashdump/trashdump-entity.png',

            top_left = { x = 0, y = 0 },
            top = { x = 36, y = 0 },
            top_right = { x = 72, y = 0 },

            left = { x = 0, y = 41 },
            right = { x = 72, y = 41 },

            bottom_left = { x = 0, y = 85, shift = { x = 1 } },
            bottom = { x = 36, y = 85 },
            bottom_right = { x = 72, y = 85 },

            widths = { left = 32, middle = 32, right = 32 },
            heights = {
                top = 37,
                middle = 40,
                bottom = 35
            },
            shift = { x = 0, y = -8 }
        },
        shadow = {
            filename = '__WideChests__/graphics/entity/steel-chest/trashdump/trashdump-shadow.png',

            top_left = { x = 0, y = 0 },
            top = { x = 63, y = 0, shift = { x = -16 } },
            top_right = { x = 136, y = 0, shift = { x = -17 } },

            left = { x = 0, y = 60 },
            right = { x = 0, y = 60 },

            bottom_left = { x = 0, y = 116 },
            bottom = { x = 63, y = 0, shift = { x = -16 } },
            bottom_right = { x = 136, y = 116, shift = { x = -16 } },

            widths = { left = 42, middle = 58, right = 44 },
            heights = {
                top = 50,
                middle = 47,
                bottom = 16
            },
            shift = { x = 18, y = 27 },
            shadow = true
        }
    }
}

MergingChests.create_mergeable_chest(
    {
        chest_name = 'wooden-chest'
    },
    MergingChests.steel_chest_segments
)
MergingChests.create_mergeable_chest(
    {
        chest_name = 'iron-chest'
    },
    MergingChests.steel_chest_segments
)
MergingChests.create_mergeable_chest(
    {
        chest_name = 'steel-chest'
    },
    MergingChests.steel_chest_segments
)

MergingChests.set_next_upgrade_of('container', 'wooden-chest', 'iron-chest')
MergingChests.set_next_upgrade_of('container', 'iron-chest', 'steel-chest')
