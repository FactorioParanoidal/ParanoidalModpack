-- Vanilla Belts
-- Changes Speed 

base_speed = 1/32
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
	
    --Bob Deadlocks
    if mods.DeadlockLoaders then
        data.raw.recipe['deadlock-loader-5'].hidden = true
        data.raw["loader"]["deadlock-loader-4"].speed = 8 * base_speed
        data.raw["loader"]["deadlock-loader-5"].speed = 16 * base_speed
    end
    if mods.DeadlockStacking then
        data.raw.recipe['deadlock-beltbox-recipe-5'].hidden = true
    end
end



--Vanilla Deadlocks
if mods.DeadlockLoaders then
if settings.startup["bobmods-logistics-beltoverhaul"].value then
data.raw["loader"]["deadlock-loader-0"].speed = 0.5 * base_speed
end
data.raw["loader"]["deadlock-loader-1"].speed = 1 * base_speed
data.raw["loader"]["deadlock-loader-2"].speed = 2 * base_speed
data.raw["loader"]["deadlock-loader-3"].speed = 4 * base_speed
end



-- Underground Distances
data.raw["underground-belt"]["basic-underground-belt"].max_distance =   5
data.raw["underground-belt"]["underground-belt"].max_distance =         5
data.raw["underground-belt"]["fast-underground-belt"].max_distance =    11
data.raw["underground-belt"]["express-underground-belt"].max_distance = 17

--[[
if mods.MomoTweak then
data.raw.recipe["a-alt-underground-belt"].hidden = true
data.raw.recipe["fast-alt-underground-belt"].hidden = true
data.raw.recipe["express-alt-underground-belt"].hidden = true

data.raw.recipe["a-alt-underground-belt-backward"].hidden = true
data.raw.recipe["fast-alt-underground-belt-backward"].hidden = true
data.raw.recipe["express-alt-underground-belt-backward"].hidden = true

bobmods.lib.tech.remove_recipe_unlock("logistics", "a-alt-underground-belt")
bobmods.lib.tech.remove_recipe_unlock("logistics-2", "fast-alt-underground-belt")
bobmods.lib.tech.remove_recipe_unlock("logistics-3", "express-alt-underground-belt")

bobmods.lib.tech.remove_recipe_unlock("logistics", "a-alt-underground-belt-backward")
bobmods.lib.tech.remove_recipe_unlock("logistics-2", "fast-alt-underground-belt-backward")
bobmods.lib.tech.remove_recipe_unlock("logistics-3", "express-alt-underground-belt-backward")


if settings.startup["bobmods-logistics-ugdistanceoverhaul"].value then
data.raw.recipe["purple-alt-underground-belt"].hidden = true
data.raw.recipe["green-alt-underground-belt"].hidden = true

data.raw.recipe["purple-alt-underground-belt-backward"].hidden = true
data.raw.recipe["green-alt-underground-belt-backward"].hidden = true

bobmods.lib.tech.remove_recipe_unlock("logistics-4", "purple-alt-underground-belt")
bobmods.lib.tech.remove_recipe_unlock("logistics-5", "green-alt-underground-belt")

bobmods.lib.tech.remove_recipe_unlock("logistics-4", "purple-alt-underground-belt-backward")
bobmods.lib.tech.remove_recipe_unlock("logistics-5", "green-alt-underground-belt-backward")
end
end

]]