-- Vanilla Belts
-- Changes Speed 

base_speed = 1/32
if mods.boblogistics then
	
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