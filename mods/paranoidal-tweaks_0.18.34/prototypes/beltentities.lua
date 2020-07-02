-- Vanilla Belts
-- Changes Speed 

local base_speed = 1/32
if settings.startup["bobmods-logistics-beltoverhaul"].value then
-- 0.5x Belt

	data.raw["transport-belt"]["basic-transport-belt"].speed = 0.5 * base_speed
data.raw["underground-belt"]["basic-underground-belt"].speed = 0.5 * base_speed
				data.raw["splitter"]["basic-splitter"].speed = 0.5 * base_speed
end
-- 1x Belt

				data.raw["transport-belt"]["transport-belt"].speed = base_speed
			data.raw["underground-belt"]["underground-belt"].speed = base_speed
							data.raw["splitter"]["splitter"].speed = base_speed

-- 2x Belt

		data.raw["transport-belt"]["fast-transport-belt"].speed = 2 * base_speed
	data.raw["underground-belt"]["fast-underground-belt"].speed = 2 * base_speed
					data.raw["splitter"]["fast-splitter"].speed = 2 * base_speed

-- 4x Belt

	data.raw["transport-belt"]["express-transport-belt"].speed = 4 * base_speed
data.raw["underground-belt"]["express-underground-belt"].speed = 4 * base_speed
				data.raw["splitter"]["express-splitter"].speed = 4 * base_speed


if mods.boblogistics then
    -- 8x Purple Belt
		data.raw["transport-belt"]["turbo-transport-belt"].speed = 6 * base_speed
    data.raw["underground-belt"]["turbo-underground-belt"].speed = 6 * base_speed
					data.raw["splitter"]["turbo-splitter"].speed = 6 * base_speed
	
    data.raw["underground-belt"]["turbo-underground-belt"].max_distance = 23
	
    -- 16x Green Belt
		data.raw["transport-belt"]['ultimate-transport-belt'].speed = 12 * base_speed
    data.raw["underground-belt"]['ultimate-underground-belt'].speed = 12 * base_speed
					data.raw["splitter"]['ultimate-splitter'].speed = 12 * base_speed
	
    data.raw["underground-belt"]['ultimate-underground-belt'].max_distance = 27
    -- Green belt is very buggy at 16x speed
	--[[
    data.raw.technology["bob-logistics-5"].enabled =        false
    data.raw.recipe['ultimate-transport-belt'].hidden =     true
    data.raw.recipe['ultimate-underground-belt'].hidden =   true
    data.raw.recipe['ultimate-splitter'].hidden =           true
	
    --Bob Miniloader
    if mods.miniloader then
        data.raw.technology["ultimate-miniloader"].enabled = false
    end
	]]
end

