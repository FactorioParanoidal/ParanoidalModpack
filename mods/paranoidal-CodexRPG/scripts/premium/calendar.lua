-- Calendar of Premium BnL: pure date arithmetic, no game state.
-- Day index 0 is 1 January of year 1 (the landing day); every midnight is the next day. Years have
-- 365 days, leap years 366 by the Gregorian rule. 1 January of year 1 is a Monday, as in the
-- proleptic Gregorian calendar, so weekdays come straight from the index.
local C = {}

local MONTH_DAYS = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

function C.is_leap(y)
	return (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0
end

function C.year_days(y)
	return C.is_leap(y) and 366 or 365
end

function C.month_days(y, m)
	if m == 2 and C.is_leap(y) then return 29 end
	return MONTH_DAYS[m]
end

-- Day index -> year, month, day of month, day of year (all 1-based).
function C.date(n)
	n = math.max(0, math.floor(n or 0))
	local y = 1
	while n >= C.year_days(y) do
		n = n - C.year_days(y)
		y = y + 1
	end
	local doy = n + 1
	local m = 1
	while n >= C.month_days(y, m) do
		n = n - C.month_days(y, m)
		m = m + 1
	end
	return y, m, n + 1, doy
end

-- Year, month, day -> day index.
function C.index(y, m, d)
	local n = 0
	for yy = 1, y - 1 do n = n + C.year_days(yy) end
	for mm = 1, m - 1 do n = n + C.month_days(y, mm) end
	return n + d - 1
end

-- 1 = Monday ... 7 = Sunday.
function C.weekday(n)
	return n % 7 + 1
end

-- Month m of year y moved by delta months.
function C.shift_month(y, m, delta)
	local k = (y - 1) * 12 + (m - 1) + delta
	if k < 0 then k = 0 end
	return math.floor(k / 12) + 1, k % 12 + 1
end

-- Day of month of the BnL Black Friday: the Friday after the fourth Thursday of November.
function C.black_friday(y)
	local wd = C.weekday(C.index(y, 11, 1))
	local first_thursday = 1 + (4 - wd) % 7
	return first_thursday + 21 + 1
end

-- Fixed BnL holidays: {month, day, id}.
C.HOLIDAYS = {
	{1, 1, "landing"},
	{1, 13, "a113"},
	{7, 15, "yogurt"},
	{9, 9, "costs"},
}

-- Holidays of month m in year y: day of month -> holiday id.
function C.holidays(y, m)
	local out = {}
	for _, h in ipairs(C.HOLIDAYS) do
		if h[1] == m then out[h[2]] = h[3] end
	end
	if m == 11 then out[C.black_friday(y)] = "black-friday" end
	return out
end

return C
