local attackBall = require("prototypes/utils/AttackBall")
local constants = require("libs/Constants")

-- Factorio 2.1 runs a module required under two different relative names once; 2.0 ran prototypes/utils/FireUtils
-- twice (data.lua through SwarmUtils, data-updates through AttackBall), and the second run made the safe fires
-- again from the fire-flame of that moment (bobenemies: lifetime 300, damage multiplier 20). Keep the 2.0 values.
do
    local flame = data.raw.fire["fire-flame"]
    for _, name in pairs({"safe-fire-flame-rampant", "biters-safe-fire-rampant"}) do
        local fire = data.raw.fire[name]
        if flame and fire then
            fire.initial_lifetime = flame.initial_lifetime
            fire.maximum_damage_multiplier = flame.maximum_damage_multiplier
        end
    end
    -- The tree fire of the safe fires came from that second run too: a copy of fire-flame-on-tree after Noxys Trees
    -- data-updates (tree_dying_factor 0.98 in the 2.0 build; the first run copies the vanilla 0.8). Paranoidal decision G24.
    local tree_flame = data.raw.fire["fire-flame-on-tree"]
    local safe_tree = data.raw.fire["safe-fire-flame-on-tree-rampant"]
    if tree_flame and safe_tree then
        safe_tree.tree_dying_factor = tree_flame.tree_dying_factor
    end
end

for _, robot in pairs(data.raw["logistic-robot"]) do
    -- if not robot.collision_mask then
    --     robot.collision_mask = {}
    -- end
    -- robot.collision_mask[#robot.collision_mask+1] = "layer-13"

    if (settings.startup["rampantFixed--unkillableLogisticRobots"].value) then
        robot.resistances = {}
        for damageType, _ in pairs(data.raw["damage-type"]) do
            robot.resistances[damageType] = {
                type = damageType,
                percent = 100
            }
        end
    end
end

for _, robot in pairs(data.raw["construction-robot"]) do
    -- if not robot.collision_mask then
    --     robot.collision_mask = {}
    -- end
    -- robot.collision_mask[#robot.collision_mask+1] = "layer-13"

    if (settings.startup["rampantFixed--unkillableConstructionRobots"].value) then
        robot.resistances = {}
        for damageType, _ in pairs(data.raw["damage-type"]) do
            robot.resistances[damageType] = {
                type = damageType,
                percent = 100
            }
        end
    end
end


-- for _, robot in pairs(data.raw["combat-robot"]) do
--     if not robot.collision_mask then
--         robot.collision_mask = {}
--     end
--     robot.collision_mask[#robot.collision_mask+1] = "layer-13"
-- end

--[[
    try to make sure new maps use the correct map settings without having to completely load the mod.
    done because seeing desync issues with dynamic map-settings changes before re-saving the map.
--]]
local mapSettings = data.raw["map-settings"]["map-settings"]

mapSettings.max_failed_behavior_count = 3 -- constants.MAX_FAILED_BEHAVIORS

mapSettings.unit_group.member_disown_distance = constants.UNIT_GROUP_DISOWN_DISTANCE
mapSettings.unit_group.tick_tolerance_when_member_arrives = constants.UNIT_GROUP_TICK_TOLERANCE

mapSettings.unit_group.max_group_radius = constants.UNIT_GROUP_MAX_RADIUS
mapSettings.unit_group.max_member_speedup_when_behind = constants.UNIT_GROUP_MAX_SPEED_UP
mapSettings.unit_group.max_member_slowdown_when_ahead = constants.UNIT_GROUP_MAX_SLOWDOWN
mapSettings.unit_group.max_group_slowdown_factor = constants.UNIT_GROUP_SLOWDOWN_FACTOR


-- data.raw["utility-constants"]["default"].unit_group_pathfinding_resolution = -5
