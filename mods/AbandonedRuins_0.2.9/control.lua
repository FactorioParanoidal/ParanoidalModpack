local util = require("utilities")
local small_ruins = require("smallRuins")
local medium_ruins = require("mediumRuins")
local large_ruins = require("largeRuins")

local DEBUG = false -- used for debug, users should not enable

local function spawn_chances()
    local smallChance = settings.global["ruins-small-ruin-chance"].value
    local mediumChance = settings.global["ruins-medium-ruin-chance"].value
    local largeChance = settings.global["ruins-large-ruin-chance"].value
    local sumChance = smallChance + mediumChance + largeChance
    local totalChance = math.min(sumChance, 1)
    -- now compute cumulative distribution of conditional probabilities for
    -- spawn_type given a spawn occurs.
    local smallThreshold = smallChance / sumChance * totalChance
    local mediumThreshold = mediumChance / sumChance * totalChance + smallThreshold
    local largeThreshold = largeChance / sumChance * totalChance + mediumThreshold

    global.spawn_table = {small = smallThreshold, medium = mediumThreshold, large = largeThreshold}
end

script.on_init(spawn_chances)
script.on_configuration_changed(spawn_chances)
script.on_event(defines.events.on_runtime_mod_setting_changed, spawn_chances)

script.on_event(defines.events.on_chunk_generated,
    function (e)
        local center = {x=(e.area.left_top.x+e.area.right_bottom.x)/2, y=(e.area.left_top.y+e.area.right_bottom.y)/2}
        if math.abs(center.x) < settings.global["ruins-min-distance-from-spawn"].value and math.abs(center.y) < settings.global["ruins-min-distance-from-spawn"].value then return end --too close to spawn

        local spawn_type = math.random()
        if spawn_type <= global.spawn_table.small then
            --spawn small ruin
            if DEBUG then
                game.print("A small ruin was spawned at " .. center.x .. "," .. center.y)
            end

            --random variance so they aren't always chunk aligned
            center.x = center.x + math.random(-10,10)
            center.y = center.y + math.random(-10,10)

            util.spawn_ruin(small_ruins, util.SMALL_RUIN_HALF_SIZE, center, e.surface)
        elseif spawn_type <= global.spawn_table.medium then
            --spawn medium ruin
            if DEBUG then
                game.print("A medium ruin was spawned at " .. center.x .. "," .. center.y)
            end

            --random variance so they aren't always chunk aligned
            center.x = center.x + math.random(-5,5)
            center.y = center.y + math.random(-5,5)

            util.spawn_ruin(medium_ruins, util.MEDIUM_RUIN_HALF_SIZE, center, e.surface)
        elseif spawn_type <= global.spawn_table.large then
            --spawn large ruin
            if DEBUG then
                game.print("A large ruin was spawned at " .. center.x .. "," .. center.y)
            end
            util.spawn_ruin(large_ruins, util.LARGE_RUIN_HALF_SIZE, center, e.surface)
        end
    end
)
