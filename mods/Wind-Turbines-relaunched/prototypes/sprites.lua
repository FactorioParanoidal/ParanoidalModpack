---
--- Created by xyzzycgn.
--- DateTime: 19.02.25 10:02
---
-- makes defining common file paths much shorter.
local sprites = {}


function sprites.sprite(name)
    return '__Wind-Turbines-relaunched__/graphics/' .. name
end

function sprites.stripe(name, width_in_frames, height_in_frames )
    return {
        filename = sprites.sprite(name),
        width_in_frames = width_in_frames,
        height_in_frames = height_in_frames
    }
end

return sprites