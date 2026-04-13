--- A defines module for retrieving colors by name.
-- Extends the Factorio defines table.
-- @usage require('__Kux-CoreLib__/stdlib/utils/defines/color')
-- @module defines.color
-- @see Color

-- defines table is automatically required in all mod loading stages.

--- A table of colors allowing retrieval by color name.
-- @table color
-- @usage color = defines.color.red
-- @tfield Color white
-- @tfield Color black
-- @tfield Color darkgrey
-- @tfield Color grey
-- @tfield Color lightgrey
-- @tfield Color red
-- @tfield Color darkred
-- @tfield Color lightred
-- @tfield Color green
-- @tfield Color darkgreen
-- @tfield Color lightgreen
-- @tfield Color blue
-- @tfield Color darkblue
-- @tfield Color lightblue
-- @tfield Color orange
-- @tfield Color yellow
-- @tfield Color pink
-- @tfield Color purple
-- @tfield Color brown
local color = {}
local colors = require('__Kux-CoreLib__/stdlib/utils/defines/color_list')

local _mt = {
    __index = function(_, c)
        return colors[c] and { r = colors[c]['r'], g = colors[c]['g'], b = colors[c]['b'], a = colors[c]['a'] or 1 } or { r = 1, g = 1, b = 1, a = 1 }
    end,
    __pairs = function()
        local k = nil
        local c = colors
        return function()
            local v
            k, v = next(c, k)
            return k, (v and { r = v['r'], g = v['g'], b = v['b'], a = v['a'] or 1 }) or nil
        end
    end
}
setmetatable(color, _mt)

_G.defines = _G.defines or {}
_G.defines.color = color

return color
