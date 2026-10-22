------------------------------------------------------------------------------------
-- Trees growing from seedlings
-- storage.bi.tree_growing[tick]             seedlings that sprout at that tick
-- storage.bi.tree_growing_stage_N[tick]     young trees (stage N) that grow at that tick
-- Entries: {position, time, surface, seed_bomb} / {tree_name, final_tree, position, time, surface}
-- storage.bi.tree_tick                      last tick that has been processed
------------------------------------------------------------------------------------
local M = {}

local terrains = require("libs/trees-and-terrains")

-- Fertility of tiles (1..100). Unlisted tiles count as 1 and are not "fertile".
M.fertility = {
    ["vegetation-green-grass-1"] = 100,
    ["grass-1"] = 100,
    ["grass-3"] = 85,
    ["grass-2"] = 70,
    ["grass-4"] = 60,
    ["red-desert-0"] = 50,
    ["dirt-3"] = 40,
    ["dirt-5"] = 37,
    ["dirt-6"] = 34,
    ["dirt-7"] = 31,
    ["dirt-4"] = 28,
    ["dry-dirt"] = 25,
    ["dirt-2"] = 22,
    ["dirt-1"] = 19,
    ["red-desert-2"] = 16,
    ["red-desert-3"] = 13,
    ["sand-3"] = 10,
    ["sand-2"] = 7,
    ["sand-1"] = 4,
    ["red-desert-1"] = 1,
    ["frozen-snow-0"] = 1,
    ["frozen-snow-1"] = 1,
    ["frozen-snow-2"] = 1,
    ["frozen-snow-3"] = 1,
    ["frozen-snow-4"] = 1,
    ["frozen-snow-5"] = 1,
    ["frozen-snow-6"] = 1,
    ["frozen-snow-7"] = 1,
    ["frozen-snow-8"] = 1,
    ["frozen-snow-9"] = 1,
    ["mineral-aubergine-dirt-1"] = 45,
    ["mineral-aubergine-dirt-2"] = 45,
    ["mineral-aubergine-dirt-3"] = 25,
    ["mineral-aubergine-dirt-4"] = 25,
    ["mineral-aubergine-dirt-5"] = 25,
    ["mineral-aubergine-dirt-6"] = 25,
    ["mineral-aubergine-dirt-7"] = 25,
    ["mineral-aubergine-dirt-8"] = 25,
    ["mineral-aubergine-dirt-9"] = 25,
    ["mineral-aubergine-sand-1"] = 15,
    ["mineral-aubergine-sand-2"] = 15,
    ["mineral-aubergine-sand-3"] = 10,
    ["mineral-beige-dirt-1"] = 45,
    ["mineral-beige-dirt-2"] = 45,
    ["mineral-beige-dirt-3"] = 25,
    ["mineral-beige-dirt-4"] = 25,
    ["mineral-beige-dirt-5"] = 25,
    ["mineral-beige-dirt-6"] = 25,
    ["mineral-beige-dirt-7"] = 25,
    ["mineral-beige-dirt-8"] = 25,
    ["mineral-beige-dirt-9"] = 25,
    ["mineral-beige-sand-1"] = 10,
    ["mineral-beige-sand-2"] = 10,
    ["mineral-beige-sand-3"] = 10,
    ["mineral-black-dirt-1"] = 45,
    ["mineral-black-dirt-2"] = 45,
    ["mineral-black-dirt-3"] = 25,
    ["mineral-black-dirt-4"] = 25,
    ["mineral-black-dirt-5"] = 25,
    ["mineral-black-dirt-6"] = 25,
    ["mineral-black-dirt-7"] = 25,
    ["mineral-black-dirt-8"] = 25,
    ["mineral-black-dirt-9"] = 25,
    ["mineral-black-sand-1"] = 10,
    ["mineral-black-sand-2"] = 10,
    ["mineral-black-sand-3"] = 10,
    ["mineral-brown-dirt-1"] = 25,
    ["mineral-brown-dirt-2"] = 25,
    ["mineral-brown-dirt-3"] = 25,
    ["mineral-brown-dirt-4"] = 25,
    ["mineral-brown-dirt-5"] = 25,
    ["mineral-brown-dirt-6"] = 25,
    ["mineral-brown-dirt-7"] = 25,
    ["mineral-brown-dirt-8"] = 25,
    ["mineral-brown-dirt-9"] = 25,
    ["mineral-brown-sand-1"] = 10,
    ["mineral-brown-sand-2"] = 10,
    ["mineral-brown-sand-3"] = 10,
    ["mineral-cream-dirt-1"] = 25,
    ["mineral-cream-dirt-2"] = 25,
    ["mineral-cream-dirt-3"] = 25,
    ["mineral-cream-dirt-4"] = 25,
    ["mineral-cream-dirt-5"] = 25,
    ["mineral-cream-dirt-6"] = 25,
    ["mineral-cream-dirt-7"] = 25,
    ["mineral-cream-dirt-8"] = 25,
    ["mineral-cream-dirt-9"] = 25,
    ["mineral-cream-sand-1"] = 10,
    ["mineral-cream-sand-2"] = 10,
    ["mineral-cream-sand-3"] = 10,
    ["mineral-dustyrose-dirt-1"] = 25,
    ["mineral-dustyrose-dirt-2"] = 25,
    ["mineral-dustyrose-dirt-3"] = 25,
    ["mineral-dustyrose-dirt-4"] = 25,
    ["mineral-dustyrose-dirt-5"] = 25,
    ["mineral-dustyrose-dirt-6"] = 25,
    ["mineral-dustyrose-dirt-7"] = 25,
    ["mineral-dustyrose-dirt-8"] = 25,
    ["mineral-dustyrose-dirt-9"] = 25,
    ["mineral-dustyrose-sand-1"] = 10,
    ["mineral-dustyrose-sand-2"] = 10,
    ["mineral-dustyrose-sand-3"] = 10,
    ["mineral-grey-dirt-1"] = 25,
    ["mineral-grey-dirt-2"] = 25,
    ["mineral-grey-dirt-3"] = 25,
    ["mineral-grey-dirt-4"] = 25,
    ["mineral-grey-dirt-5"] = 25,
    ["mineral-grey-dirt-6"] = 25,
    ["mineral-grey-dirt-7"] = 25,
    ["mineral-grey-dirt-8"] = 25,
    ["mineral-grey-dirt-9"] = 25,
    ["mineral-grey-sand-1"] = 10,
    ["mineral-grey-sand-2"] = 10,
    ["mineral-grey-sand-3"] = 10,
    ["mineral-purple-dirt-1"] = 25,
    ["mineral-purple-dirt-2"] = 25,
    ["mineral-purple-dirt-3"] = 25,
    ["mineral-purple-dirt-4"] = 25,
    ["mineral-purple-dirt-5"] = 25,
    ["mineral-purple-dirt-6"] = 25,
    ["mineral-purple-dirt-7"] = 25,
    ["mineral-purple-dirt-8"] = 25,
    ["mineral-purple-dirt-9"] = 25,
    ["mineral-purple-sand-1"] = 10,
    ["mineral-purple-sand-2"] = 10,
    ["mineral-purple-sand-3"] = 10,
    ["mineral-red-dirt-1"] = 25,
    ["mineral-red-dirt-2"] = 25,
    ["mineral-red-dirt-3"] = 25,
    ["mineral-red-dirt-4"] = 25,
    ["mineral-red-dirt-5"] = 25,
    ["mineral-red-dirt-6"] = 25,
    ["mineral-red-dirt-7"] = 25,
    ["mineral-red-dirt-8"] = 25,
    ["mineral-red-dirt-9"] = 25,
    ["mineral-red-sand-1"] = 10,
    ["mineral-red-sand-2"] = 10,
    ["mineral-red-sand-3"] = 10,
    ["mineral-tan-dirt-1"] = 25,
    ["mineral-tan-dirt-2"] = 25,
    ["mineral-tan-dirt-3"] = 25,
    ["mineral-tan-dirt-4"] = 25,
    ["mineral-tan-dirt-5"] = 25,
    ["mineral-tan-dirt-6"] = 25,
    ["mineral-tan-dirt-7"] = 25,
    ["mineral-tan-dirt-8"] = 25,
    ["mineral-tan-dirt-9"] = 25,
    ["mineral-tan-sand-1"] = 10,
    ["mineral-tan-sand-2"] = 10,
    ["mineral-tan-sand-3"] = 10,
    ["mineral-violet-dirt-1"] = 25,
    ["mineral-violet-dirt-2"] = 25,
    ["mineral-violet-dirt-3"] = 25,
    ["mineral-violet-dirt-4"] = 25,
    ["mineral-violet-dirt-5"] = 25,
    ["mineral-violet-dirt-6"] = 25,
    ["mineral-violet-dirt-7"] = 25,
    ["mineral-violet-dirt-8"] = 25,
    ["mineral-violet-dirt-9"] = 25,
    ["mineral-violet-sand-1"] = 10,
    ["mineral-violet-sand-2"] = 10,
    ["mineral-violet-sand-3"] = 10,
    ["mineral-white-dirt-1"] = 25,
    ["mineral-white-dirt-2"] = 25,
    ["mineral-white-dirt-3"] = 25,
    ["mineral-white-dirt-4"] = 25,
    ["mineral-white-dirt-5"] = 25,
    ["mineral-white-dirt-6"] = 25,
    ["mineral-white-dirt-7"] = 25,
    ["mineral-white-dirt-8"] = 25,
    ["mineral-white-dirt-9"] = 25,
    ["mineral-white-sand-1"] = 10,
    ["mineral-white-sand-2"] = 10,
    ["mineral-white-sand-3"] = 10,
    ["vegetation-blue-grass-1"] = 70,
    ["vegetation-blue-grass-2"] = 70,
    ["vegetation-green-grass-2"] = 75,
    ["vegetation-green-grass-3"] = 85,
    ["vegetation-green-grass-4"] = 70,
    ["vegetation-mauve-grass-1"] = 70,
    ["vegetation-mauve-grass-2"] = 70,
    ["vegetation-olive-grass-1"] = 70,
    ["vegetation-olive-grass-2"] = 70,
    ["vegetation-orange-grass-1"] = 70,
    ["vegetation-orange-grass-2"] = 70,
    ["vegetation-purple-grass-1"] = 70,
    ["vegetation-purple-grass-2"] = 70,
    ["vegetation-red-grass-1"] = 70,
    ["vegetation-red-grass-2"] = 70,
    ["vegetation-turquoise-grass-1"] = 70,
    ["vegetation-turquoise-grass-2"] = 70,
    ["vegetation-violet-grass-1"] = 70,
    ["vegetation-violet-grass-2"] = 70,
    ["vegetation-yellow-grass-1"] = 70,
    ["vegetation-yellow-grass-2"] = 70,
    ["volcanic-blue-heat-1"] = 1,
    ["volcanic-blue-heat-2"] = 1,
    ["volcanic-blue-heat-3"] = 1,
    ["volcanic-blue-heat-4"] = 1,
    ["volcanic-green-heat-1"] = 1,
    ["volcanic-green-heat-2"] = 1,
    ["volcanic-green-heat-3"] = 1,
    ["volcanic-green-heat-4"] = 1,
    ["volcanic-orange-heat-1"] = 1,
    ["volcanic-orange-heat-2"] = 1,
    ["volcanic-orange-heat-3"] = 1,
    ["volcanic-orange-heat-4"] = 1,
    ["volcanic-purple-heat-1"] = 1,
    ["volcanic-purple-heat-2"] = 1,
    ["volcanic-purple-heat-3"] = 1,
    ["volcanic-purple-heat-4"] = 1,
    ["landfill"] = 1,
}
local fertility = M.fertility

-- Due ticks are processed every PROCESS_INTERVAL ticks. A larger gap since the last run
-- (old save, missing marker) makes one pass over all due ticks instead of a tick loop.
local PROCESS_INTERVAL = 60
M.PROCESS_INTERVAL = PROCESS_INTERVAL
local MAX_TICK_LOOP = 600

-- Settings used for the different grow stages
local stage_settings = {
    [1] = {
        fertilizer = { max = 1500, penalty = 3000, factor = 30 },
        default = { max = 1500, penalty = 6000, factor = 30 },
    },
    [2] = {
        fertilizer = { max = 1000, penalty = 2000, factor = 20 },
        default = { max = 1500, penalty = 6000, factor = 30 },
    },
    [3] = {
        fertilizer = { max = 1000, penalty = 2000, factor = 20 },
        default = { max = 1500, penalty = 6000, factor = 30 },
    },
}


------------------------------------------------------------------------------------
-- Prototype-derived look-ups (identical on every client)
------------------------------------------------------------------------------------
-- Our growing trees: name -> grow stage
M.bio_trees = {}
for name in pairs(prototypes.get_entity_filtered({ { filter = "type", type = "tree" } })) do
    local stage = name:match("^bio%-tree%-.+%-(%d)$")
    if stage then
        M.bio_trees[name] = tonumber(stage)
    end
end

-- Name of the tree used for a grow stage; the final tree if there is no such stage.
local stage_names = {}
local function stage_name(final_tree, stage)
    local names = stage_names[final_tree]
    if not names then
        names = {}
        for i = 1, 4 do
            local name = "bio-tree-" .. final_tree .. "-" .. i
            names[i] = prototypes.entity[name] and name or false
        end
        stage_names[final_tree] = names
    end
    return names[stage] or final_tree
end

-- Weighted choice of the tree that grows on a tile. Only trees that exist in the game
-- take part; the probability of a tree is its weight / the sum of these weights.
local choices = {}
local function random_tree(tile_name)
    local choice = choices[tile_name]
    if choice == nil then
        choice = false
        local weights = terrains[tile_name]
        if weights then
            local names = {}
            for tree in pairs(weights) do
                if prototypes.entity[tree] then
                    names[#names + 1] = tree
                end
            end
            table.sort(names)
            if names[1] then
                local cumulative, total = {}, 0
                for i, tree in ipairs(names) do
                    total = total + weights[tree]
                    cumulative[i] = total
                end
                choice = { names = names, cumulative = cumulative, total = total }
            end
        end
        choices[tile_name] = choice
    end
    if not choice then
        return
    end

    local roll = math.random(choice.total)
    local cumulative = choice.cumulative
    for i = 1, #cumulative do
        if roll <= cumulative[i] then
            return choice.names[i]
        end
    end
end
M.random_tree = random_tree

-- Tiles that can't be changed by fertilizer. Value: products of mining the tile (the
-- player/robot got them back when fertilizer was placed on it) or true.
local barren_tile_patterns = {
    ".*concrete.*",
    ".*stone%-path.*",
    "^bi%-solar%-mat$",
    "^bi%-wood%-floor$",
}
local barren_tiles
function M.get_barren_tiles()
    if not barren_tiles then
        barren_tiles = {}
        for tile_name, tile in pairs(prototypes.tile) do
            for _, pattern in ipairs(barren_tile_patterns) do
                if tile_name:match(pattern) then
                    barren_tiles[tile_name] = tile.mineable_properties.products or true
                    break
                end
            end
        end
    end
    return barren_tiles
end


------------------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------------------
-- Fertility at a position: value (1 for unlisted tiles), whether the tile is listed
local function tile_fertility(surface, position)
    local value = fertility[surface.get_tile(position.x, position.y).name]
    return value or 1, value ~= nil
end

local function schedule(tab, data, create_tree)
    local bucket = tab[data.time]
    if bucket then
        bucket[#bucket + 1] = data
    else
        tab[data.time] = { data }
    end
    if create_tree then
        data.surface.create_entity({ name = data.tree_name, position = data.position, force = "neutral" })
    end
end

local function plant_seed(entity, tick, t_base, t_penalty, seed_bomb)
    local surface = entity.surface
    local p = entity.position
    local position = { x = p.x, y = p.y }
    -- Things will grow faster on fertile than on barren tiles
    -- (No penalty for tiles with maximum fertility)
    local value = tile_fertility(surface, position)
    local grow_time = math.max(1, math.random(t_base) + t_penalty - (40 * value))
    schedule(storage.bi.tree_growing, {
        position = position,
        time = tick + grow_time,
        surface = surface,
        seed_bomb = seed_bomb,
    })
end

-- A seedling was planted by a player or a robot
function M.seed_planted(entity, tick)
    plant_seed(entity, tick, 1000, 4000, false)
end

-- A seedling was created by a seed bomb
function M.seed_planted_trigger(entity, tick)
    plant_seed(entity, tick, 2000, 6000, true)
end

-- A seedling was planted by a terraformer
function M.seed_planted_arboretum(entity, tick)
    plant_seed(entity, tick, 2000, 6000, false)
end


------------------------------------------------------------------------------------
-- Grow stages
------------------------------------------------------------------------------------
local function grow_first_stage(data, tick)
    local surface = data.surface
    if not surface.valid then
        return
    end
    local position = data.position
    local seed_bomb = data.seed_bomb

    local seedling = surface.find_entity("seedling", position)
    -- Seedlings of the standard and advanced seed bombs
    local seedling_2 = seed_bomb and surface.find_entity("seedling-2", position)
    local seedling_3 = seed_bomb and surface.find_entity("seedling-3", position)

    local tile_name = surface.get_tile(position.x, position.y).name
    -- fertility will be 1 if terrain type is not listed above, so very small chance to grow.
    local value = fertility[tile_name]
    local fertile = value ~= nil
    value = value or 1
    -- Random value. Tree will grow if this value is smaller than the 'Fertility' value
    local growth_chance = math.random(100)

    local tree_name
    if seedling or seedling_2 or seedling_3 then
        tree_name = random_tree(tile_name)
    end

    if seedling then
        seedling.destroy()
        if tree_name and fertile and not seed_bomb and
            surface.can_place_entity({ name = tree_name, position = position, force = "neutral" }) and
            growth_chance <= (value + 5) then
            -- Trees will grow faster on fertile than on barren tiles
            local grow_time = math.max(1, math.random(2000) + 4000 - (40 * value))
            schedule(storage.bi.tree_growing_stage_1, {
                tree_name = stage_name(tree_name, 1),
                final_tree = tree_name,
                position = position,
                time = tick + grow_time,
                surface = surface,
            }, true)
        end
    end

    if seed_bomb then
        if seedling_2 then
            seedling_2.destroy()
        end
        if seedling_3 then
            seedling_3.destroy()
        end
        if fertile and tree_name then
            local new_tree = { name = tree_name, position = position, force = "neutral" }
            if surface.can_place_entity(new_tree) and growth_chance <= value then
                surface.create_entity(new_tree)
            end
        end
    end
end

local function grow_last_stage(data)
    local surface = data.surface
    if not surface.valid then
        return
    end
    local position = data.position
    local tree = surface.find_entity(data.tree_name, position)
    if tree then
        tree.destroy()
        -- fertility will be 1 if terrain type not listed above, so very small change to grow.
        local value, fertile = tile_fertility(surface, position)
        -- Random value. Tree will grow if this value is smaller than the 'Fertility' value
        local growth_chance = math.random(100)
        --- Convert growing tree to fully grown tree
        if fertile or growth_chance <= value then
            surface.create_entity({ name = data.final_tree, position = position, force = "neutral" })
        end
    end
end

local function grow_stage(data, stage, tick)
    if stage == 4 then
        return grow_last_stage(data)
    end
    local surface = data.surface
    if not surface.valid then
        return
    end
    local position = data.position
    local tree = surface.find_entity(data.tree_name, position)
    if not tree then
        return
    end
    tree.destroy()

    local final_tree = data.final_tree
    local value, fertile = tile_fertility(surface, position)
    local next_stage = stage + 1
    local next_name = stage_name(final_tree, next_stage)

    if surface.can_place_entity({ name = next_name, position = position, force = "neutral" }) then
        if next_name == final_tree then
            -- Tree reached final stage
            surface.create_entity({ name = final_tree, position = position, force = "neutral" })
        else
            -- Trees will grow faster on fertile than on barren tiles!
            local s = stage_settings[stage][fertile and "fertilizer" or "default"]
            local grow_time = math.max(1, math.random(s.max) + s.penalty - (s.factor * value))
            schedule(storage.bi["tree_growing_stage_" .. next_stage], {
                tree_name = next_name,
                final_tree = final_tree,
                position = position,
                time = (data.time or tick) + grow_time,
                surface = surface,
            }, true)
        end
    end
end


------------------------------------------------------------------------------------
-- Processing of due ticks
------------------------------------------------------------------------------------
-- New entries are always due later than the entry that created them, so processing
-- the ticks in ascending order handles every entry exactly once.
local function process_tick(bi, tick)
    local bucket = bi.tree_growing[tick]
    if bucket then
        bi.tree_growing[tick] = nil
        for _, data in pairs(bucket) do
            grow_first_stage(data, tick)
        end
    end
    for stage = 1, 4 do
        local tab = bi["tree_growing_stage_" .. stage]
        bucket = tab[tick]
        if bucket then
            tab[tick] = nil
            for _, data in pairs(bucket) do
                grow_stage(data, stage, tick)
            end
        end
    end
end

-- All due ticks up to "now", ascending
local function due_ticks(bi, now)
    local ticks, seen = {}, {}
    local function collect(tab)
        for tick in pairs(tab) do
            if tick <= now and not seen[tick] then
                seen[tick] = true
                ticks[#ticks + 1] = tick
            end
        end
    end
    collect(bi.tree_growing)
    for stage = 1, 4 do
        collect(bi["tree_growing_stage_" .. stage])
    end
    table.sort(ticks)
    return ticks
end

function M.process(now)
    local bi = storage.bi
    if not (bi and bi.tree_growing) then
        return
    end
    local last = bi.tree_tick
    bi.tree_tick = now

    if not (next(bi.tree_growing) or next(bi.tree_growing_stage_1) or next(bi.tree_growing_stage_2) or
            next(bi.tree_growing_stage_3) or next(bi.tree_growing_stage_4)) then
        return
    end

    if last and last < now and now - last <= MAX_TICK_LOOP then
        for tick = last + 1, now do
            process_tick(bi, tick)
        end
    else
        -- Entries created while processing may be due already: repeat until none are.
        local ticks = due_ticks(bi, now)
        while ticks[1] do
            for _, tick in ipairs(ticks) do
                process_tick(bi, tick)
            end
            ticks = due_ticks(bi, now)
        end
    end
end

function M.on_nth_tick(event)
    M.process(event.tick)
end


------------------------------------------------------------------------------------
-- A seedling or a growing tree has been removed: forget it.
------------------------------------------------------------------------------------
local function remove_entry(tab, surface_index, x, y)
    for tick, bucket in pairs(tab) do
        for i = #bucket, 1, -1 do
            local data = bucket[i]
            local position = data.position
            if position.x == x and position.y == y then
                local surface = data.surface
                if surface.valid and surface.index == surface_index then
                    table.remove(bucket, i)
                    if not bucket[1] then
                        tab[tick] = nil
                    end
                    return true
                end
            end
        end
    end
    return false
end

function M.removed(entity)
    local bi = storage.bi
    local name = entity.name
    local tab
    if name == "seedling" then
        tab = bi.tree_growing
    else
        local stage = M.bio_trees[name]
        tab = stage and bi["tree_growing_stage_" .. stage]
    end
    if tab then
        local position = entity.position
        return remove_entry(tab, entity.surface.index, position.x, position.y)
    end
    return false
end


------------------------------------------------------------------------------------
-- on_init / on_configuration_changed / migration
------------------------------------------------------------------------------------
-- Entries of deleted surfaces or of removed tree prototypes (e.g. after a tree mod has
-- been removed) are dropped. Returns the number of dropped entries.
function M.setup_storage()
    local bi = storage.bi
    bi.tree_growing = bi.tree_growing or {}
    for stage = 1, 4 do
        bi["tree_growing_stage_" .. stage] = bi["tree_growing_stage_" .. stage] or {}
    end

    local entity_prototypes = prototypes.entity
    local function valid(data, needs_trees)
        if not (data.surface and data.surface.valid and data.position and data.time) then
            return false
        end
        if not needs_trees then
            return true
        end
        return (data.tree_name and entity_prototypes[data.tree_name] and
            data.final_tree and entity_prototypes[data.final_tree]) and true or false
    end

    local removed = 0
    local function clean(tab, needs_trees)
        for tick, bucket in pairs(tab) do
            for i = #bucket, 1, -1 do
                if not valid(bucket[i], needs_trees) then
                    table.remove(bucket, i)
                    removed = removed + 1
                end
            end
            if not bucket[1] then
                tab[tick] = nil
            end
        end
    end
    clean(bi.tree_growing, false)
    for stage = 1, 4 do
        clean(bi["tree_growing_stage_" .. stage], true)
    end
    return removed
end

return M
