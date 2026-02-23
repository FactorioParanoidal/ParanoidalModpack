-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- The intention of this script is to determine belt tints, and make them available to anything using belt tints.

-- The following functions are adapted from work done by Maxreader, and implement the formulas for HSV/HSL to RGB and
-- vice versa from https://en.wikipedia.org/wiki/HSL_and_HSV

function reskins.lib.RGBtoHSV(tint)
	local r, g, b = tint.r, tint.g, tint.b
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
		a = tint.a or 1,
	}
end

function reskins.lib.RGBtoHSL(tint)
	local r, g, b = tint.r, tint.g, tint.b
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
		a = tint.a or 1,
	}
end

function reskins.lib.HSVtoRGB(tint)
	local h, s, v = tint.h, tint.s, tint.v

	local function f(n)
		local k = (n + h / 60) % 6
		return v - v * s * math.max(math.min(k, 4 - k, 1), 0)
	end
	return {
		r = f(5),
		g = f(3),
		b = f(1),
		a = tint.a or 1,
	}
end

function reskins.lib.HSLtoRGB(tint)
	local h, s, l = tint.h, tint.s, tint.l

	local function f(n)
		local k = (n + h / 30) % 12
		local x = s * math.min(l, 1 - l)
		return l - x * math.max(math.min(k - 3, 9 - k, 1), -1)
	end

	return {
		r = f(0),
		g = f(8),
		b = f(4),
		a = tint.a or 1,
	}
end
