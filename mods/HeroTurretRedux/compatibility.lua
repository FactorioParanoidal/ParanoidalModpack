local lib = {}

local starts_with  = heroturrets.util.starts_with
local ends_with  = heroturrets.util.ends_with
local has_pattern = string.find

-- Honktown -- pixel is more familiar with start/end so I am including these
local turret_exclude_start = {
	["creative-mod"] = true,
	["WT-water-turret"] = true,
	["WT-steam-turret"] = true,
	["se-meteor"] = true,
	["vehicle-gun-turret"] = true,
	["vehicle-rocket-turret"] = true,
	["man-big-artillery-turret"] = true,
	["big-artillery-turret"] = true
--	["obelisk-"] = true, --[[ Obelisk-of-light turrets ]]
}

local turret_exclude_end = {
	["shield-dome"] = true,
}

-- Honktown -- I am more familiar with patterns
local turret_exclude_patterns = {
}

local turret_exclude_exact = {
}


lib.turret_name_is_excluded = function(name)
	--indentation provided to permit logging why a turret is excluded
	for beginning in pairs(turret_exclude_start) do
		if starts_with(name, beginning) then
			return true
		end
	end

	for ending in pairs(turret_exclude_end) do
		if ends_with(name, ending) then
			return true
		end
	end

	for pattern in pairs(turret_exclude_patterns) do
		if has_pattern(name, pattern) then
			return true
		end
	end

	for exact in pairs(turret_exclude_exact) do
		if exact == name then
			return true
		end
	end
end

return lib