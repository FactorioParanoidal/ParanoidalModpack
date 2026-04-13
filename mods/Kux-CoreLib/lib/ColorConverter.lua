require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

--'Color' is already used by Factorio as Color Concept

--- ColorConverter module
---@class KuxCoreLib.ColorConverter Provides color conversion
---@field asGlobal fun():KuxCoreLib.ColorConverter
local ColorConverter = {
	__class = "ColorConverter",
	__guid      = "{C29DBDDA-9A65-424D-98F2-45CDBAD8D2A1}",
	__origin    = "Kux-CoreLib/lib/ColorConverter.lua"
}
if not KuxCoreLib.__classUtils.ctor(ColorConverter) then return self end

-- to avoid circular references, the class is defined before require other modules
-- require(KuxCoreLibPath.."Math")

-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c

---Converts an RGB color value to HSL. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSL_color_space.
---Assumes r, g, and b are contained in the set [0, 255] and
---returns h, s, and l in the set [0, 1].
---@param   r  integer       The red color value
---@param   g  integer       The green color value
---@param   b  integer       The blue color value
---@param   a?  integer      The alpha value
---@return  number h         The Hue color value
---@return  number s         The saturation value
---@return  number l         The lightness value
---@return  number a         The alpha value
function ColorConverter.rgbToHsl(r, g, b, a)
    r, g, b, a = r/255, g/255, b/255, (a or 255)/255

    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, l

    l = (max + min) / 2

    if max == min then
        h, s = 0, 0 -- achromatic
        return h, s, l, a
    end

    local d = max - min
    local s
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
        h = (g - b) / d
        if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6

    return h, s, l, a
end

---Converts an HSL color value to RGB. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSL_color_space.
---Assumes h, s, and l are contained in the set [0, 1] and
---returns r, g, and b in the set [0, 255].
---@param  h number        The hue
---@param  s number        The saturation
---@param  l number        The lightness
---@param  a? number       The alpha value
---@return   number  r     The red color value
---@return   number  g     The green color value
---@return   number  b     The blue color value
---@return   number  a     The alpha color value
function ColorConverter.hslToRgb(h, s, l, a)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l -- achromatic
        return r * 255, g * 255, b * 255, a * 255
    end

    local function hue2rgb(p, q, t)
        if t < 0   then t = t + 1 end
        if t > 1   then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)

    return r * 255, g * 255, b * 255, a * 255
end


 ---Converts an RGB color value to HSV. Conversion formula
 ---adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 ---Assumes r, g, and b are contained in the set [0, 255] and
 ---returns h, s, and v in the set [0, 1].
 ---
 ---@param   r  integer       The red color
 ---@param   g  integer       The green color
 ---@param   b  integer       The blue color
 ---@param   a?  integer      The alpha
 ---@return  number h         The Hue
 ---@return  number s         The saturation
 ---@return  number v         The value
 ---@return  number a         The alpha
function ColorConverter.rgbToHsv(r, g, b, a)
    r, g, b, a = r / 255, g / 255, b / 255, (a or 255) / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max

    local d = max - min
    if max == 0 then s = 0 else s = d / max end

    if max == min then
        h = 0 -- achromatic
    else
        if max == r then
        h = (g - b) / d
        if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, v, a
  end


---Converts an HSV color value to RGB. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSV_color_space.
---Assumes h, s, and v are contained in the set [0, 1] and
---returns r, g, and b in the set [0, 255].
---
---@param  h number        The hue
---@param  s number        The saturation
---@param  v number        The value
---@param  a? number       The alpha value
---@return   number  r     The red color value
---@return   number  g     The green color value
---@return   number  b     The blue color value
---@return   number  a     The alpha color value
function ColorConverter.hsvToRgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r * 255, g * 255, b * 255, a * 255
end

---------------------------------------------------------------------------------------------------
return ColorConverter