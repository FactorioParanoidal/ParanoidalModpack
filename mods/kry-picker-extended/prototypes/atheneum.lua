-- this was originally part of the Picker Atheneum's data.lua
-- some part of these lines were needed to for Belt Brush functionality

-- An empty picture, the same table the kry_stdlib Data.Sprites.empty_pictures helper returned.
local function empty_pictures()
    return {
        filename = '__core__/graphics/empty.png',
        width = 1,
        height = 1,
        line_length = 1,
        frame_count = 1,
        shift = {0, 0},
        animation_speed = 1,
        direction_count = 1
    }
end

data:extend {
    {
        type = 'highlight-box',
        name = 'picker-highlight-box'
    },
    {
        name = 'picker-buffer-corpse-instant',
        type = 'character-corpse',
        picture = empty_pictures(),
        selection_priority = 0,
        time_to_live = 1
    },
    {
        name = 'picker-buffer-corpse-inf',
        type = 'character-corpse',
        picture = empty_pictures(),
        selection_priority = 0,
        time_to_live = 2147483647
    }
}