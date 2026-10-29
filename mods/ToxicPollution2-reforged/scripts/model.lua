-- Pure intoxication model (no game objects): numbers in, numbers out. Covered by tests/model.lua.
local C = require("shared.config")

local M = {}
local P = C.MODEL

local function clamp(value, low, high)
	if value < low then return low end
	if value > high then return high end
	return value
end
M.clamp = clamp

-- Pollution a body tolerates without getting worse (research raises it).
function M.tolerance(base, level)
	return base * (1 + P.tolerance_per_level * level)
end

-- Layers filter one after another: what passes one reaches the next.
function M.total_filtration(shares)
	local pass = 1
	for _, share in ipairs(shares) do
		pass = pass * (1 - clamp(share, 0, 1))
	end
	return 1 - pass
end

-- Highest pollution that stays harmless with the given total filtration.
function M.safe_level(tolerance, filtration)
	if filtration >= 1 then return math.huge end
	return tolerance / (1 - filtration)
end

-- Intoxication change in %/s. Positive while inhaling over the tolerance; negative otherwise,
-- faster in cleaner air and near a working air cleaner.
function M.rate(inhaled, tolerance, clean_zone)
	local excess = inhaled - tolerance
	if excess > 0 then
		return P.rate_max * excess / (excess + P.rate_half)
	end
	local share = tolerance > 0 and math.min(1, -excess / tolerance) or 1
	local decay = P.decay_min + (P.decay_max - P.decay_min) * share
	return -decay * (clean_zone and P.zone_factor or 1)
end

function M.step(intoxication, rate, seconds)
	return clamp(intoxication + rate * seconds, 0, 100)
end

-- Health damage per second. Only while inhaling over the tolerance: leaving the smog stops it.
function M.damage(intoxication, max_health, inhaled, tolerance)
	if inhaled <= tolerance or intoxication <= P.damage_from then return 0 end
	return max_health * P.damage_share * (intoxication - P.damage_from) / (100 - P.damage_from)
end

-- Filter resource spent per second by a layer that filters `share` of the air reaching it.
-- Nothing is spent at or below the tolerance.
function M.wear(reaching, tolerance, share, level)
	local harmful = reaching - tolerance
	if harmful <= 0 or share <= 0 then return 0 end
	return harmful * share / P.wear_div / (1 + P.resource_per_level * level)
end

-- 0 norm, 1 poisoning, 2 heavy, 3 critical.
function M.tier(intoxication)
	local tier = 0
	for index, border in ipairs(C.TIERS) do
		if intoxication >= border then tier = index end
	end
	return tier
end

-- Seconds until damage starts (rising) or until clean (falling); nil when nothing changes.
function M.eta(intoxication, rate)
	if rate > 0 and intoxication < P.damage_from then
		return (P.damage_from - intoxication) / rate
	end
	if rate < 0 and intoxication > 0 then
		return intoxication / -rate
	end
	return nil
end

return M
