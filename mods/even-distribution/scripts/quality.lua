-- Paranoidal: quality helpers for logistic filters and inventory contents.
-- Rank: positive tiers by their level, normal 0, the defect qualities of ic-more-qualities below normal
-- (ic-defect-1 = -1 ... ic-defect-5 = -5; their prototype level is 0 like normal, so the name decides).
local this = {}

local GE = "\226\137\165" -- U+2265, returned by the API for ">="
local LE = "\226\137\164" -- U+2264, returned by the API for "<="
local NE = "\226\137\160" -- U+2260, returned by the API for "!="

local ranks = {}

function this.rank(quality)
	quality = quality or "normal"
	local rank = ranks[quality]
	if rank == nil then
		local grade = string.match(quality, "^ic%-defect%-(%d+)$")
		if grade then
			rank = -tonumber(grade)
		else
			local prototype = prototypes.quality[quality]
			rank = prototype and prototype.level or 0
		end
		ranks[quality] = rank
	end
	return rank
end

-- Does a logistic filter (CompiledLogisticFilter: quality/comparator nil = any quality) take `quality`?
function this.matches(filter, quality)
	local wanted = filter.quality
	if wanted == nil then return true end
	quality = quality or "normal"
	local comparator = filter.comparator or "="
	if comparator == "=" then return quality == wanted end
	if comparator == "!=" or comparator == NE then return quality ~= wanted end
	local a, b = this.rank(quality), this.rank(wanted)
	if comparator == ">" then return a > b end
	if comparator == "<" then return a < b end
	if comparator == ">=" or comparator == GE then return a >= b end
	if comparator == "<=" or comparator == LE then return a <= b end
	return quality == wanted
end

function this.key(name, quality)
	return name .. "|" .. (quality or "normal")
end

return this
