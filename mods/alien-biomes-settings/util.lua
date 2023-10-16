local util = {}


local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

util.deepcopy = deepcopy

local function endswith(String, ending)
    return ending == "" or string.sub(String,-#ending) == ending
end

util.endswith = endswith

local function startsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

util.startsWith = startsWith

local function getColor(r, g, b)
    return { r = math.floor(r), g = math.floor(g), b = math.floor(b) }
end

util.getColor = getColor

local function HSLtoRGB(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local r, g, b;

    if s == 0 then
        r, g, b = l, l, l; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p;
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s;
        local p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    return getColor(r * 255, g * 255, b * 255)
end

util.HSLtoRGB = HSLtoRGB

local function HSVtoRGB(h, s, v)
    local min = math.min
    local max = math.max
    local abs = math.abs
    local k1 = v * (1 - s)
    local k2 = v - k1
    local r = min(max(3 * abs(((h) / 180) % 2 - 1) - 1, 0), 1)
    local g = min(max(3 * abs(((h - 120) / 180) % 2 - 1) - 1, 0), 1)
    local b = min(max(3 * abs(((h + 120) / 180) % 2 - 1) - 1, 0), 1)
    return getColor(k1 + k2 * r, k1 + k2 * g, k1 + k2 * b)
end

util.HSVtoRGB = HSVtoRGB

local function RGBtoHEX(rgb)
    local hexadecimal = '#'
    rgb = { rgb.r, rgb.g, rgb.b }
    for key, value in pairs(rgb) do
        local hex = ''

        while (value > 0) do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex
        end

        if (string.len(hex) == 0) then
            hex = '00'

        elseif (string.len(hex) == 1) then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

util.RGBtoHEX = RGBtoHEX

local function generateColor(id)
    local steps=8
    local step=math.floor(256/steps)
    local bias=math.floor((256/steps)/2)
    local r=(math.floor(id/(steps*steps))%steps)*step+bias
    local g=(math.floor(id/steps)%steps)*step+bias
    local b=(math.floor(id)%steps)*step+bias
    return getColor(r,g,b)
end

util.generateColor = generateColor

return util
