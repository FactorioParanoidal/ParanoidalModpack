--- A defines module for retrieving colors by name.
-- Extends the Factorio defines table.
-- @usage require('__Kux-CoreLib__/stdlib/utils/defines/anticolor')
-- @module defines.anticolor
-- @see Color

--- Returns white for dark colors or black for lighter colors.
-- @table anticolor
-- @tfield Color green defines.color.black
-- @tfield Color grey defines.color.black
-- @tfield Color lightblue defines.color.black
-- @tfield Color lightgreen defines.color.black
-- @tfield Color lightgrey defines.color.black
-- @tfield Color lightred defines.color.black
-- @tfield Color orange defines.color.black
-- @tfield Color white defines.color.black
-- @tfield Color yellow defines.color.black
-- @tfield Color black defines.color.white
-- @tfield Color blue defines.color.white
-- @tfield Color brown defines.color.white
-- @tfield Color darkblue defines.color.white
-- @tfield Color darkgreen defines.color.white
-- @tfield Color darkgrey defines.color.white
-- @tfield Color darkred defines.color.white
-- @tfield Color pink defines.color.white
-- @tfield Color purple defines.color.white
-- @tfield Color red defines.color.white
local anticolor = {}
local colors = require('__Kux-CoreLib__/stdlib/utils/defines/color_list')

local anticolors = {
    green = colors.black,
    grey = colors.black,
    lightblue = colors.black,
    lightgreen = colors.black,
    lightgrey = colors.black,
    lightred = colors.black,
    orange = colors.black,
    white = colors.black,
    yellow = colors.black,
    black = colors.white,
    blue = colors.white,
    brown = colors.white,
    darkblue = colors.white,
    darkgreen = colors.white,
    darkgrey = colors.white,
    darkred = colors.white,
    pink = colors.white,
    purple = colors.white,
    red = colors.white
}

local _mt = {
    __index = function(_, c)
        return anticolors[c] and { r = anticolors[c]['r'], g = anticolors[c]['g'], b = anticolors[c]['b'], a = anticolors[c]['a'] or 1 } or
            { r = 1, g = 1, b = 1, a = 1 }
    end,
    __pairs = function()
        local k = nil
        local c = anticolors
        return function()
            local v
            k, v = next(c, k)
            return k, (v and { r = v['r'], g = v['g'], b = v['b'], a = v['a'] or 1 }) or nil
        end
    end
}

setmetatable(anticolor, _mt)

_G.defines = _G.defines or {}
_G.defines.anticolor = anticolor

return anticolor
