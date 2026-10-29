-- Number, time and unit formatting for the statistics window.
-- Plain numbers are strings; values with units or decimals are localised strings,
-- so the decimal separator and the unit come from the locale.
local F = {}

-- 1234567 -> "1 234 567"
function F.int(n)
	n = math.floor((n or 0) + 0.5)
	local sign = n < 0 and "-" or ""
	local s = string.format("%d", math.abs(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1 "):reverse()
	return sign .. out:gsub("^ ", "")
end

-- Splits x into the whole part and one rounded decimal digit.
local function split(x)
	local v = math.floor(x * 10 + 0.5)
	return math.floor(v / 10), v % 10
end
F.split = split

-- Large counts: exact below a million, then "34,8 млн" / "34.8 M".
function F.short(n)
	n = n or 0
	if n < 1e6 then return F.int(n) end
	local key, div = "num-m", 1e6
	if n >= 1e12 then key, div = "num-t", 1e12
	elseif n >= 1e9 then key, div = "num-g", 1e9 end
	local a, b = split(n / div)
	return {"rpg-stats." .. key, F.int(a), b}
end

-- Watts.
function F.power(w)
	w = w or 0
	local key, div = "power-kw", 1e3
	if w >= 1e9 then key, div = "power-gw", 1e9
	elseif w >= 1e6 then key, div = "power-mw", 1e6 end
	local a, b = split(w / div)
	return {"rpg-stats." .. key, F.int(a), b}
end

-- Kilometres from metres.
function F.km(m)
	local a, b = split((m or 0) / 1000)
	return {"rpg-stats.km", F.int(a), b}
end

-- Share as a percent: whole numbers from 10%, one decimal below.
function F.pct(part, total)
	if not total or total <= 0 then return {"rpg-stats.dash"} end
	local p = 100 * (part or 0) / total
	if p >= 10 or p == 0 then return {"rpg-stats.percent", F.int(p)} end
	local a, b = split(p)
	return {"rpg-stats.percent-dec", a, b}
end

-- A ratio with one decimal: 7.4 -> "7,4" / "7.4".
function F.dec(x)
	local a, b = split(x or 0)
	return {"rpg-stats.decimal", F.int(a), b}
end

-- Ticks -> "h:mm:ss".
function F.time(ticks)
	local s = math.floor((ticks or 0) / 60)
	return string.format("%d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
end

-- Ticks -> "h:mm".
function F.hm(ticks)
	local m = math.floor((ticks or 0) / 3600)
	return string.format("%d:%02d", math.floor(m / 60), m % 60)
end

return F
