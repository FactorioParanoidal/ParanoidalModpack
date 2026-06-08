--- Provides color tools for use with Artisanal Reskins: Sprite Utils.
---
---### Examples
---```lua
---local _colors = require("__reskins-sprite-utils__.colors")
---```
---@class Reskins.SpriteUtils.Colors
local _colors = {}

---Table of hue, saturation, vibrance and alpha values between 0 and 1.
---@class HsvColor
---@field h float
---@field s float
---@field v float
---@field a float

---Table of hue, saturation, luminance and alpha values between 0 and 1.
---@class HslColor
---@field h float
---@field s float
---@field l float
---@field a float

local function clamp(v)
	return math.max(0, math.min(v, 1))
end

---Converts an ARGB hex code to an RGBA color vector compatible with Factorio prototypes.
---
---This method is to facilitate compatibility between the [Factorio Modding Tool Kit](https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug)
---and Visual Studio Code's native color picker in a lua workspace. Leading hash (`"#"`) characters are not supported;
---
---Visual Studio Code will remove them anyways on interacting with the color picker.
---
---### Parameters
---@param hex string # An 8-character ARGB color hex code.
---@return data.Color
---
---### Examples
---Import the colors module and then use it to create a tint. If working with the Factorio Modding Tool Kit and Visual
---Studio Code, once the Lua workspace has loaded the color picker will be interactive and render correctly in game.
---```lua
---local colors = require("__reskins-sprites-utils__.colors")
---
---local tahiti_blue = colors.from_argb("FF00C1DF")
---```
---Use anywhere you would use a tint.
---
---### Exceptions
---*@throws* - `string` When `hex` is not a string.</br>
---*@throws* - `string` When `hex` is not 8 characters.
function _colors.from_argb(hex)
	if type(hex) ~= "string" then
		error("Invalid type: 'hex' must be a string.")
	elseif #hex ~= 8 then
		error("Invalid format: 'hex' must have 8 characters.")
	end
	return util.color(hex:sub(3, 8) .. hex:sub(1, 2))
end

-- The following functions are adapted from work done by Maxreader, and implement the formulas for HSV/HSL to RGB and
-- vice versa from https://en.wikipedia.org/wiki/HSL_and_HSV

---
---Converts the provided `tint` from RGBA to HSVA color space.
---
---`tint` is not required to be normalized beforehand.
---
---### Returns
---@return HsvColor # An HSVA color with `h` in degrees (0–360) and `s`, `v`, `a` between 0 and 1.
---
---### Examples
---```lua
---local hsva = _colors.rgba_to_hsva({ r = 0, g = 0.753, b = 0.871, a = 1 })
---```
---
---### Parameters
---@param tint data.Color # The RGBA color to convert.
function _colors.rgba_to_hsva(tint)
	local n = _colors.normalize(tint)
	local r, g, b, a = n.r, n.g, n.b, n.a

	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local range = max - min

	local h
	if range == 0 then
		h = 0
	elseif max == r then
		h = (g - b) / range * 60
	elseif max == g then
		h = (2 + (b - r) / range) * 60
	elseif max == b then
		h = (4 + (r - g) / range) * 60
	end

	if h < 0 then
		h = h + 360
	end

	local v = max
	local s = range / max

	return {
		h = h,
		s = s,
		v = v,
		a = a,
	}
end

---
---Converts the provided `tint` from RGBA to HSLA color space.
---
---`tint` is not required to be normalized beforehand.
---
---### Returns
---@return HslColor # An HSLA color with `h` in degrees (0–360) and `s`, `l`, `a` between 0 and 1.
---
---### Examples
---```lua
---local hsla = _colors.rgba_to_hsla({ r = 0, g = 0.753, b = 0.871, a = 1 })
---```
---
---### Parameters
---@param tint data.Color # The RGBA color to convert.
function _colors.rgba_to_hsla(tint)
	local n = _colors.normalize(tint)
	local r, g, b, a = n.r, n.g, n.b, n.a

	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local range = max - min

	local h
	if max == min then
		h = 0
	elseif max == r then
		h = (g - b) / range * 60
	elseif max == g then
		h = (2 + (b - r) / range) * 60
	elseif max == b then
		h = (4 + (r - g) / range) * 60
	end

	if h < 0 then
		h = h + 360
	end

	local l = (min + max) / 2
	local s = 0

	if not (min == 1 or max == 0) then
		s = (max - l) / math.min(l, 1 - l)
	end

	return {
		h = h,
		s = s,
		l = l,
		a = a,
	}
end

---
---Converts the provided `tint` from HSVA to RGBA color space.
---
---### Returns
---@return data.Color # An RGBA color with channel values clamped between 0 and 1.
---
---### Examples
---```lua
---local rgba = _colors.hsva_to_rgba({ h = 191, s = 1, v = 0.871, a = 1 })
---```
---
---### Parameters
---@param tint HsvColor # The HSVA color to convert, with `h` in degrees (0–360) and `s`, `v`, `a` between 0 and 1.
function _colors.hsva_to_rgba(tint)
	local h, s, v, a = tint.h, tint.s, tint.v, tint.a

	local function f(n)
		local k = (n + h / 60) % 6
		return v - v * s * math.max(math.min(k, 4 - k, 1), 0)
	end
	return {
		r = clamp(f(5)),
		g = clamp(f(3)),
		b = clamp(f(1)),
		a = clamp(a),
	}
end

---
---Converts the provided `tint` from HSLA to RGBA color space.
---
---### Returns
---@return data.Color # An RGBA color with channel values clamped between 0 and 1.
---
---### Examples
---```lua
---local rgba = _colors.hsla_to_rgba({ h = 191, s = 1, l = 0.435, a = 1 })
---```
---
---### Parameters
---@param tint HslColor # The HSLA color to convert, with `h` in degrees (0–360) and `s`, `l`, `a` between 0 and 1.
function _colors.hsla_to_rgba(tint)
	local h, s, l, a = tint.h, tint.s, tint.l, tint.a

	local function f(n)
		local k = (n + h / 30) % 12
		local x = s * math.min(l, 1 - l)
		return l - x * math.max(math.min(k - 3, 9 - k, 1), -1)
	end

	return {
		r = clamp(f(0)),
		g = clamp(f(8)),
		b = clamp(f(4)),
		a = clamp(a),
	}
end

---
---Normalizes the values in the provided `tint` to between 0 and 1, and ensures
---`r`, `g`, `b`, and `a` are all defined.
---
---`tint` may use either named fields (`r`, `g`, `b`, `a`) or positional fields (`[1]`, `[2]`, `[3]`, `[4]`).
---If any channel value exceeds 1, all channels are divided by 255.
---
---### Returns
---@return data.Color # A copy of `tint` with all channels normalized and defined.
---
---### Examples
---```lua
---local normalized = _colors.normalize({ r = 128, g = 191, b = 222, a = 255 })
----- Returns { r ≈ 0.502, g ≈ 0.749, b ≈ 0.871, a = 1.0 }
---```
---
---### Parameters
---@param tint data.Color # The color to normalize.
function _colors.normalize(tint)
	local n = {
		r = math.max(tint.r or tint[1] or 0, 0),
		g = math.max(tint.g or tint[2] or 0, 0),
		b = math.max(tint.b or tint[3] or 0, 0),
		a = math.max(tint.a or tint[4] or 1, 0),
	}

	if math.max(n.r, n.g, n.b, n.a) > 1 then
		for key, value in pairs(n) do
			n[key] = clamp(value / 255)
		end
	end
	return n
end

local function srgb_to_linear(channel)
	if channel <= 0.04045 then
		return channel / 12.92
	else
		return ((channel + 0.055) / 1.055) ^ 2.4
	end
end

local function linear_to_srgb(channel)
	channel = math.max(0, math.min(1, channel))
	if channel <= 0.0031308 then
		return 12.92 * channel
	else
		return 1.055 * channel ^ (1 / 2.4) - 0.055
	end
end

---
---Simulates placing a semi-transparent `overlay` color on top of a `base` color using
---alpha compositing in linear light (sRGB gamma).
---
---`base` and `overlay` are not required to be normalized beforehand.
---
---### Returns
---@return data.Color # The composited RGBA color, with channel values clamped between 0 and 1.
---
---### Examples
---```lua
---local result = _colors.overlay(
---    { r = 0.2, g = 0.2, b = 0.2, a = 1 },
---    { r = 0, g = 0.753, b = 0.871, a = 0.5 }
---)
---```
---
---### Parameters
---@param base data.Color # The base color to composite over.
---@param overlay data.Color # The overlay color to composite on top.
function _colors.overlay(base, overlay)
	local b = _colors.normalize(base)
	local o = _colors.normalize(overlay)

	local result = {}
	for _, c in pairs({ "r", "g", "b" }) do
		local b_lin = srgb_to_linear(b[c])
		local o_lin = srgb_to_linear(o[c])

		result[c] = clamp(linear_to_srgb(o_lin * o.a + b_lin * (1 - o.a)))
	end
	result.a = clamp(o.a + b.a * (1 - o.a))
	return result
end

---comment
---@param r float
---@param g float
---@param b float
---@return float
---@return float
---@return float
local function linear_rgb_to_oklab(r, g, b)
	local l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ^ (1 / 3)
	local m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ^ (1 / 3)
	local s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ^ (1 / 3)

	return 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
		1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
		0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
end

---comment
---@param L float
---@param a float
---@param b float
---@return float
---@return float
---@return float
local function oklab_to_linear_rgb(L, a, b)
	local l = (L + 0.3963377774 * a + 0.2158037573 * b) ^ 3
	local m = (L - 0.1055613458 * a - 0.0638541728 * b) ^ 3
	local s = (L - 0.0894841775 * a - 1.2914855480 * b) ^ 3

	return 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
		-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
		-0.0041960863 * l - 0.7034186147 * m + 1.6076099658 * s
end

---
---Blends the provided colors `c1` and `c2` uniformly in perceptual color space
---using the provided `weight`, using Oklab.
---
---`c1` and `c2` are not required to be normalized beforehand.
---
---### Returns
---@return data.Color # The blended RGBA color, with channel values clamped between 0 and 1.
---
---### Examples
---```lua
---local blended = _colors.blend(
---    { r = 1, g = 0, b = 0, a = 1 },
---    { r = 0, g = 0, b = 1, a = 1 },
---    0.5
---)
---```
---
---### Parameters
---@param c1 data.Color # The first color.
---@param c2 data.Color # The second color.
---@param weight? float # A fractional weight between 0 and 1 that determines the proportional color mix. When `0`, `c1` is returned, when `1`, `c2` is returned. Default `0.5`.
function _colors.blend(c1, c2, weight)
	if weight == 0 then
		return _colors.normalize(c1)
	elseif weight == 1 then
		return _colors.normalize(c2)
	end

	weight = weight or 0.5
	c1 = _colors.normalize(c1)
	c2 = _colors.normalize(c2)

	local r1, g1, b1 = srgb_to_linear(c1.r), srgb_to_linear(c1.g), srgb_to_linear(c1.b)
	local r2, g2, b2 = srgb_to_linear(c2.r), srgb_to_linear(c2.g), srgb_to_linear(c2.b)
	local L1, a1, b1_ = linear_rgb_to_oklab(r1, g1, b1)
	local L2, a2, b2_ = linear_rgb_to_oklab(r2, g2, b2)
	local Lm = L1 + (L2 - L1) * weight
	local am = a1 + (a2 - a1) * weight
	local bm = b1_ + (b2_ - b1_) * weight
	local r, g, b = oklab_to_linear_rgb(Lm, am, bm)
	return {
		r = clamp(linear_to_srgb(r)),
		g = clamp(linear_to_srgb(g)),
		b = clamp(linear_to_srgb(b)),
		a = clamp(c1.a + (c2.a - c1.a) * weight),
	}
end

return _colors
