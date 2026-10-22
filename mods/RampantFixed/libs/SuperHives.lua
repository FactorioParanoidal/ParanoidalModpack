-- Reforged Paranoidal: super-hives ("супер-ульи").
--
-- In Beta 8 the "Super Hive" was the Bob super spawner (10000 health, 1 health per tick) that kept a share of its
-- autoplaced nests through the Rampant replacement. Now it is a building of every Rampant faction with a hive
-- (libs/Constants.lua, prototypes/SwarmUtils.lua buildSuperHive): tiers 1-10, 3x the health of the hive (at least 10000: 10000-270000), 60-120 health per
-- second, spawns about one level above a hive, faction resistances plus a bonus, a blue glow, a brood on death and
-- Bob artifacts as loot.
--  * origin: a nest placed by Rampant (a new chunk, an expansion or the growth of a base) becomes a super-hive with a
--    chance from the start of the game: 50% with a resource (ore, oil...) within RESOURCE_RADIUS, else 0.4% at 0%
--    evolution and 1.2% at 100%;
--    a hive chosen by the base evolution grows into one with EVOLVE_CHANCE. Always: not near the map centre early
--    (START_DISTANCE shrinks with the evolution), no player entity within PLAYER_RADIUS, MIN_SPACING from another
--    super-hive of the surface and at most LIMIT_BASE + LIMIT_EVO x evolution of them per surface;
--  * it is a nest of its base for the AI (squads, activeness, champions), changes its faction with the base mutations
--    and its level with the base level, as the other buildings do;
--  * looks: bigger than a hive of its level (prototype), a blue glow and a ring around it drawn by this script, a
--    blue light at night and a blue map colour (prototype);
--  * heart of the nest: every PULSE_TICKS it heals the damaged nests and worms of its force around it;
--  * the lair of the champions (libs/Champions.lua): an hour boss always, a champion with 50% leaves from a random
--    super-hive within reach of its target and comes back to it to regenerate; its unit and faction come from a random
--    ordinary nest around, as without a super-hive. Without a super-hive near the target 3 of 4 hour bosses do not
--    come;
--  * death: a brood of units one tier up (prototype), Bob artifacts, AI points for revenge, a chat line with the
--    place and an avenger: a champion (an hour boss for tier 7+) from the nests near the base (control.lua).
-- Map setting rampantFixed--superHives switches new super-hives; living ones keep working.
-- Data: universe.superHives, created on first use.

if superHivesG then
    return superHivesG
end
local superHives = {}

local constants = require("Constants")
local foreignEnemies = require("ForeignEnemies")

local isForeign = foreignEnemies.isForeign

local mRandom = math.random
local mMin = math.min
local mMax = math.max
local mFloor = math.floor

superHives.SETTING = "rampantFixed--superHives"

local BASE_CHANCE = 0.004           -- per nest placed by Rampant, at 0% evolution
local EVO_CHANCE = 0.008            -- added at 100% evolution
local RESOURCE_CHANCE = 0.5         -- with a resource within RESOURCE_RADIUS of the nest
local RESOURCE_RADIUS = 40
local EVOLVE_CHANCE = 0.3           -- a hive picked by the base evolution grows into a super-hive
local MIN_SPACING = 224             -- tiles between super-hives of a surface
local START_DISTANCE = 320          -- from the map centre at 0% evolution...
local MIN_START_DISTANCE = 96       -- ...down to this at 100%
local PLAYER_RADIUS = 96            -- no entity of a force at war with the enemy within
local LIMIT_BASE = 6                -- super-hives per surface at 0% evolution...
local LIMIT_EVO = 36                -- ...plus this at 100%
local PULSE_TICKS = 300             -- heart of the nest: every 5 seconds per super-hive
local HEART_RADIUS = 28
local HEAL_SHARE = 0.025            -- of the max health of a nest or worm per pulse...
local HEAL_FLAT = 25                -- ...plus this
local HEAL_TARGETS = 40             -- per pulse
local PULSES_PER_UPDATE = 4         -- superHives.update runs every 30 ticks (control.lua)
local STEPS_PER_UPDATE = 12
local DEATH_POINTS = constants.RECOVER_NEST_COST * 3
local HOUR_BOSS_TIER = 7            -- the avenger of a super-hive of this tier and above is an hour boss
local PULSE_COLOR = {r = 0.15, g = 0.35, b = 0.75, a = 0.35}
local FALLEN_COLOR = {r = 0.45, g = 0.75, b = 1}
local AURA_COLOR = {r = 0.3, g = 0.55, b = 1}
local AURA_GLOW_SPRITE = "rampantFixed-champion-glow"     -- 128 px (4 tiles) at scale 1 (prototypes/Champions.lua)
local AURA_GLOW_K = 1.5                                    -- glow width / selection width
local AURA_RING_K = 0.8                                    -- ring radius / selection width
local HEALED_TYPES = {"unit-spawner", "turret"}

----------------------------------------------------------------------------------------------------------------------
-- data

local function getData(universe)
    local data = universe.superHives
    if not data then
        data = {records = {}, counts = {}}
        universe.superHives = data
    end
    return data
end

function superHives.isSuperHive(universe, name)
    local lookup = universe.buildingHiveTypeLookup
    return (lookup ~= nil) and (lookup[name] == "super-hive")
end
local isSuperHive = superHives.isSuperHive

-- the super-hive prototype of the faction at the level, nil if the faction has none
function superHives.prototypeName(universe, faction, lvl)
    local name = faction .. "-super-hive-v1-t" .. mMax(1, mMin(10, lvl or 1)) .. "-rampant"
    if universe.enemyAlignmentLookup and universe.enemyAlignmentLookup[name] then
        return name
    end
    return nil
end

local function forget(data, unitNumber)
    local record = data.records[unitNumber]
    if record then
        data.records[unitNumber] = nil
        local index = record.surfaceIndex
        data.counts[index] = mMax(0, (data.counts[index] or 1) - 1)
    end
end

-- the aura (like the glow of the champions): a blue glow under it and a ring on the ground; both are attached to the
-- entity, so they go with it
local function drawAura(record)
    local entity = record.entity
    local box = entity.prototype.selection_box
    local width = mMax(1, box.right_bottom.x - box.left_top.x)
    local glowScale = width * AURA_GLOW_K / 4
    local alpha = 0.5
    rendering.draw_sprite({
        sprite = AURA_GLOW_SPRITE,
        surface = entity.surface,
        target = entity,
        tint = {r = AURA_COLOR.r * alpha, g = AURA_COLOR.g * alpha, b = AURA_COLOR.b * alpha, a = alpha},
        x_scale = glowScale,
        y_scale = glowScale * 0.75,
        render_layer = "lower-object",
    })
    rendering.draw_circle({
        color = {r = AURA_COLOR.r * 0.6, g = AURA_COLOR.g * 0.6, b = AURA_COLOR.b * 0.6, a = 0.6},
        radius = width * AURA_RING_K,
        width = 4,
        filled = false,
        target = entity,
        surface = entity.surface,
        draw_on_ground = true,
    })
    record.aura = true
end

-- every creation path of Rampant structures (libs/BaseUtils.lua) calls this with the new entity
function superHives.register(universe, entity)
    if not (entity and entity.valid and isSuperHive(universe, entity.name)) then
        return
    end
    local unitNumber = entity.unit_number
    local data = getData(universe)
    if (not unitNumber) or data.records[unitNumber] then
        return
    end
    local index = entity.surface.index
    local position = entity.position
    data.records[unitNumber] = {
        entity = entity,
        surfaceIndex = index,
        x = position.x,
        y = position.y,
        nextPulse = game.tick + mRandom(PULSE_TICKS)
    }
    data.counts[index] = (data.counts[index] or 0) + 1
    drawAura(data.records[unitNumber])
end

----------------------------------------------------------------------------------------------------------------------
-- placement

local function enabled()
    return settings.global[superHives.SETTING].value
end

local resourceQuery = {position = {x = 0, y = 0}, radius = RESOURCE_RADIUS, type = "resource", limit = 1}

-- a resource near the position (searched directly: on the first scan of a chunk Rampant knows no resources yet)
local function resourceNear(surface, position)
    resourceQuery.position.x = position.x
    resourceQuery.position.y = position.y
    return surface.count_entities_filtered(resourceQuery) > 0
end

-- forces at war with the enemy force (players), nil if none
local function hostileForces()
    local enemy = game.forces.enemy
    local result
    for _, force in pairs(game.forces) do
        if (force ~= enemy) and force.is_enemy(enemy) then
            result = result or {}
            result[#result + 1] = force
        end
    end
    return result
end

-- the cheap conditions first: limit, distance from the centre, spacing
local function placeAvailable(universe, map, position, evo)
    local surface = map.surface
    if not surface.valid then
        return false
    end
    local index = surface.index
    local data = getData(universe)
    if (data.counts[index] or 0) >= (LIMIT_BASE + mFloor(LIMIT_EVO * evo)) then
        return false
    end
    local startDistance = START_DISTANCE - (START_DISTANCE - MIN_START_DISTANCE) * evo
    if ((position.x * position.x) + (position.y * position.y)) < (startDistance * startDistance) then
        return false
    end
    local spacing2 = MIN_SPACING * MIN_SPACING
    for _, record in pairs(data.records) do
        if record.surfaceIndex == index then
            local dx = record.x - position.x
            local dy = record.y - position.y
            if ((dx * dx) + (dy * dy)) < spacing2 then
                if record.entity.valid then
                    return false
                end
            end
        end
    end
    return true
end

-- no entity of a force at war with the enemy around
local function farFromPlayers(surface, position)
    local forces = hostileForces()
    if forces and (surface.count_entities_filtered({position = position, radius = PLAYER_RADIUS, force = forces,
                                                    limit = 1}) > 0) then
        return false
    end
    return true
end

-- a nest that Rampant places now (new chunk, expansion, growth) becomes a super-hive?
function superHives.rollPlacement(universe, map, position)
    if not enabled() then
        return false
    end
    local surface = map.surface
    local evo = game.forces.enemy.get_evolution_factor(surface)
    if not placeAvailable(universe, map, position, evo) then
        return false
    end
    local chance
    if resourceNear(surface, position) then
        chance = RESOURCE_CHANCE
    else
        chance = BASE_CHANCE + EVO_CHANCE * evo
    end
    if mRandom() >= chance then
        return false
    end
    return farFromPlayers(surface, position)
end

-- a hive chosen by the base evolution grows into a super-hive?
function superHives.allowEvolve(universe, map, position)
    if (not enabled()) or (mRandom() >= EVOLVE_CHANCE) then
        return false
    end
    local evo = game.forces.enemy.get_evolution_factor(map.surface)
    return placeAvailable(universe, map, position, evo) and farFromPlayers(map.surface, position)
end

----------------------------------------------------------------------------------------------------------------------
-- heart of the nest

local healQuery = {position = {x = 0, y = 0}, radius = HEART_RADIUS, force = "enemy", type = HEALED_TYPES}

local function pulse(record, tick)
    record.nextPulse = tick + PULSE_TICKS
    local entity = record.entity
    local surface = entity.surface
    healQuery.position.x = record.x
    healQuery.position.y = record.y
    local found = surface.find_entities_filtered(healQuery)
    local healed = 0
    for i = 1, #found do
        local target = found[i]
        if (target ~= entity) and target.valid and (not isForeign(target.name)) then
            local maxHealth = target.max_health
            local health = target.health
            if health < maxHealth then
                target.health = mMin(maxHealth, health + maxHealth * HEAL_SHARE + HEAL_FLAT)
                healed = healed + 1
                if healed >= HEAL_TARGETS then
                    break
                end
            end
        end
    end
    if healed > 0 then
        rendering.draw_circle({
            color = PULSE_COLOR,
            radius = HEART_RADIUS,
            width = 3,
            filled = false,
            target = entity,
            surface = surface,
            time_to_live = 45,
            draw_on_ground = true
        })
    end
end

-- every 30 ticks (control.lua): a few records per call, dead ones are dropped
function superHives.update(universe, tick)
    local data = universe.superHives
    if not data then
        return
    end
    local records = data.records
    local key = data.iterator
    if (key ~= nil) and (records[key] == nil) then
        key = nil
    end
    local pulses = 0
    for _ = 1, STEPS_PER_UPDATE do
        local nextKey, record = next(records, key)
        if nextKey == nil then
            key = nil
            break
        end
        if not record.entity.valid then
            forget(data, nextKey)       -- removed by a script without a death event (a mutation replaces it)
        else
            key = nextKey
            if not record.aura then
                drawAura(record)            -- a super-hive registered before the aura existed
            end
            if tick >= record.nextPulse then
                pulse(record, tick)
                pulses = pulses + 1
                if pulses >= PULSES_PER_UPDATE then
                    break
                end
            end
        end
    end
    data.iterator = key
end

----------------------------------------------------------------------------------------------------------------------
-- death and champions

-- on_entity_died of an enemy structure killed by another force (control.lua onDeath). Returns the kind of the avenger
-- ("champion" or "hourBoss") for a super-hive, nil otherwise.
function superHives.onDied(universe, map, entity)
    if not isSuperHive(universe, entity.name) then
        return nil
    end
    local data = universe.superHives
    if data and entity.unit_number then
        forget(data, entity.unit_number)
    end
    map.points = map.points + DEATH_POINTS
    if universe.aiPointsPrintGainsToChat then
        game.print(map.surface.name .. ": Points: +" .. DEATH_POINTS .. ". [Super-hive Lost] Total: "
            .. string.format("%.2f", map.points))
    end
    local surface = entity.surface
    local position = entity.position
    local gps = " [gps=" .. mFloor(position.x) .. "," .. mFloor(position.y) .. "," .. surface.name .. "]"
    for _, player in pairs(game.connected_players) do
        if player.surface.index == surface.index then
            player.print({"", {"description.rampantFixed--superHiveFallen"}, gps}, {color = FALLEN_COLOR})
        end
    end
    local tier = universe.buildingTierLookup and universe.buildingTierLookup[entity.name] or 1
    if tier >= HOUR_BOSS_TIER then
        return "hourBoss"
    end
    return "champion"
end

-- a random living super-hive of the map within range of the position, nil if none (the lair of the champions)
function superHives.randomNear(universe, map, position, range)
    local data = universe.superHives
    if not data then
        return nil
    end
    local index = map.surface.index
    if (data.counts[index] or 0) == 0 then
        return nil
    end
    local found
    local range2 = range * range
    for _, record in pairs(data.records) do
        if (record.surfaceIndex == index) and record.entity.valid then
            local dx = record.x - position.x
            local dy = record.y - position.y
            if ((dx * dx) + (dy * dy)) <= range2 then
                found = found or {}
                found[#found + 1] = record.entity
            end
        end
    end
    return found and found[mRandom(#found)]
end

-- read-only snapshot; surfaceIndex optional
function superHives.report(universe, surfaceIndex)
    local result = {}
    local data = universe.superHives
    if not data then
        return result
    end
    for unitNumber, record in pairs(data.records) do
        local entity = record.entity
        if entity.valid and ((not surfaceIndex) or (record.surfaceIndex == surfaceIndex)) then
            result[#result + 1] = {
                unitNumber = unitNumber, name = entity.name, surfaceIndex = record.surfaceIndex,
                position = {x = record.x, y = record.y}, health = entity.health, maxHealth = entity.max_health
            }
        end
    end
    return result
end

function superHives.limit(evo)
    return LIMIT_BASE + mFloor(LIMIT_EVO * evo)
end

superHivesG = superHives
return superHives
