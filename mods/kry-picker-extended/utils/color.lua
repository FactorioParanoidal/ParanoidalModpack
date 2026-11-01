-------------------------------------------------------------------------------
--[Colors]-- Named colors (Paranoidal; replaces kry_stdlib defines.color).
-------------------------------------------------------------------------------
-- utils/color-list.lua is the kry_stdlib color list unchanged, so the setting values and their
-- order stay the same.
local colors = require('utils/color-list')

local color = {}

--- A new color table for `name`; white for an unknown name (also for 'default'), as before.
function color.get(name)
    local c = colors[name]
    if c then
        return {r = c.r, g = c.g, b = c.b, a = c.a or 1}
    end
    return {r = 1, g = 1, b = 1, a = 1}
end

--- All color names, in the order the old color table listed them.
function color.names()
    local names = {}
    for name in pairs(colors) do
        names[#names + 1] = name
    end
    return names
end

return color
