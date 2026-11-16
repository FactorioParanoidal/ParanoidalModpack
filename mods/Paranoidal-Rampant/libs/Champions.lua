-- Reforged Paranoidal: champions ("вожаки") and hour bosses.
--
-- Every 7-11 minutes a champion, every 50-70 minutes a bigger hour boss leaves a random nest within reach of the
-- player base and attacks its most defended spot (the player chunk with most turrets in the 3x3 around). A super-hive
-- near the target is its lair (spawnFromSuperHive); without one 3 of 4 hour bosses do not come.
--  * unit: the champion copy (prototypes/ChampionUnits.lua, constants.championUnitName; the unit itself if
--    there is no copy) of a unit of the nest's faction one tier (hour boss: two tiers) above the units it spawns now
--    (capped at tier 10); ground biters below 10%
--    evolution, biters/spitters 50/50 from 10%, biters/spitters/flyers by a third from 30% (fallback to what the
--    faction has). Non-Rampant nests (vanilla, Bob) give their next stronger unit of the same kind (hour boss: the
--    one after it). Units whose
--    attack damages themselves (suicide and nuclear biters) are never chosen: they would blow their pool up;
--  * health: x10 (champion) / x50 (hour boss) of the ordinary unit of that kind, at least the floor of the building
--    level (constants.CHAMPION_HEALTH_FLOOR: 500 / 5000 at the start, then a hive / a super-hive of the level). The
--    copy is bigger than its unit (an hour boss clearly). The copy has this max_health, so the
--    health bar and the tooltip show the real health; the script pool equals the engine health then (it is only a
--    share of it for a unit without a copy). A champion moves at half the speed of those units;
--  * looks: a random colour (one of the six Bob artifact colours) as a glow (+ light at night), a silver / bigger
--    gold star above it. The body colour cannot be changed at runtime;
--  * below 35% of the pool it walks back to a nest ignoring enemies (an own command of the unit: a new command of
--    its group does not stop the fight the unit is in) and takes 4 times less damage on the way (a glowing shield
--    is drawn over it meanwhile; a blocked way ends within 32 tiles of the nest or is retried around it),
--    regenerates there, gets one of 200 names (shown under the star) and attacks again;
--  * death: the loot is one big artifact of its colour; the corpse stays 3 minutes and keeps the glow;
--  * only the hour boss is announced ("You hear a strange sound in the distance...");
--  * other Rampant scripts skip champions (libs/UnitUtils.championUnits): no packing, digging in, enrage or speed
--    stickers, bridgehead settlers, builder nests or flights; they live in their own script-driven group (no group
--    while retreating).
--  * the target and the nests are found from the strongpoints of the AI and on the chunk grid around the target, not
--    by a scan of every turret or nest chunk of the map.
-- Map setting rampantFixed--champions switches new spawns and kills living champions when disabled.
-- Data: universe.champions, created on first use.

if championsG then
    return championsG
end
local champions = {}

local constants = require("Constants")
local aiBrain = require("AIBrain")
local engineGroupHelpers = require("EngineGroupHelpers")
local superHives = require("SuperHives")

local CHUNK_SIZE = constants.CHUNK_SIZE
local AI_STATE_PEACEFUL = constants.AI_STATE_PEACEFUL

local turretsAround = aiBrain.turretsAround
local chunkIsLive = aiBrain.chunkIsLive
local inPlayerBase = engineGroupHelpers.inPlayerBase
local championUnitName = constants.championUnitName
local CHAMPION_KINDS = constants.CHAMPION_KINDS

local mRandom = math.random
local mMin = math.min
local mMax = math.max
local mFloor = math.floor
local mCeil = math.ceil
local sFind = string.find
local sMatch = string.match
local sFormat = string.format

champions.SETTING = "rampantFixed--champions"

local UPDATE_TICKS = 60             -- champions.update runs every 60 ticks (control.lua)
local RETRY_TICKS = 3600            -- nothing could be spawned: try again in a minute
local RETREAT_SHARE = 0.35          -- of the health pool
local RETREAT_DAMAGE_K = 0.25       -- damage taken while retreating
local REGEN_TICKS = 90 * 60         -- full pool regenerated at a nest in 90 seconds
local RETREAT_TIMEOUT = 5 * 3600    -- regenerates where it is if it cannot reach a nest
local HOME_RADIUS = 12
local HOME_NEAR = 32                -- near enough to the nest once the way there ends or is blocked
local RETREAT_DETOUR = 12           -- a stuck champion tries a free point this far around the nest
local ATTACK_RADIUS = 24
local NEST_RANGE = 12 * CHUNK_SIZE  -- nests within this distance from the target
local FALLBACK_NESTS = 6            -- otherwise the nearest ones
local HOME_SEARCH_RINGS = 16        -- chunk rings searched for the nearest nest before a scan of all nests
local SPAWN_TRIES = 12
local CORPSE_TICKS = 3 * 3600
local NAME_COUNT = 200
local NAME_LIFT = 0.35              -- name centre above the selection box top

local GLOW_SPRITE = "rampantFixed-champion-glow"
local SHIELD_SPRITE = "rampantFixed-champion-shield"
local SHIELD_COLOR = {r = 0.55, g = 0.8, b = 1, a = 0.9}

-- healthK and tierUp: constants.CHAMPION_KINDS (the data stage makes the copies with them)
local KINDS = {
    champion = {healthK = CHAMPION_KINDS.champion.healthK, speedK = 0.5, tierUp = CHAMPION_KINDS.champion.tierUp,
                intervalMin = 7 * 3600, intervalMax = 11 * 3600, maxAlive = 3,
                star = "rampantFixed-champion-star-silver", starScale = 0.35, starLift = 1.0,
                glowScale = 0.9, lightScale = 1.5, warning = false},
    hourBoss = {healthK = CHAMPION_KINDS.hourBoss.healthK, tierUp = CHAMPION_KINDS.hourBoss.tierUp,
                intervalMin = 50 * 3600, intervalMax = 70 * 3600, maxAlive = 1,
                star = "rampantFixed-champion-star-gold", starScale = 0.5, starLift = 1.2,
                glowScale = 1.3, lightScale = 2.5, warning = true},
}
local KIND_ORDER = {"champion", "hourBoss"}
champions.KINDS = KINDS

-- the six Bob artifact colours: the loot is the big artifact of the same colour
local COLORS = {
    {name = "red", color = {r = 1, g = 0.2, b = 0.15}, item = "bob-alien-artifact-red"},
    {name = "orange", color = {r = 1, g = 0.55, b = 0.1}, item = "bob-alien-artifact-orange"},
    {name = "yellow", color = {r = 1, g = 0.92, b = 0.2}, item = "bob-alien-artifact-yellow"},
    {name = "green", color = {r = 0.3, g = 1, b = 0.25}, item = "bob-alien-artifact-green"},
    {name = "blue", color = {r = 0.25, g = 0.55, b = 1}, item = "bob-alien-artifact-blue"},
    {name = "purple", color = {r = 0.75, g = 0.3, b = 1}, item = "bob-alien-artifact-purple"},
}
local FALLBACK_ITEM = "bob-alien-artifact"

local TYPES = {biter = true, spitter = true, flyer = true}
local RAMPANT_UNIT = "^(.+)%-(%a+)%-v(%d+)%-t(%d+)%-rampant$"
local MAX_TIER = 10

-- set by control.lua: re-registers the dynamic events (on_entity_damaged, on_post_entity_died)
champions.onTrackedChanged = nil

----------------------------------------------------------------------------------------------------------------------
-- data

local function getData(universe)
    local data = universe.champions
    if not data then
        data = {units = {}, corpses = {}, nextTick = {}, usedNames = {}, usedCount = 0}
        universe.champions = data
    end
    return data
end

local function notifyChanged()
    if champions.onTrackedChanged then
        champions.onTrackedChanged()
    end
end

-- read-only (also used in on_load): the record of a tracked champion entity
function champions.recordOf(universe, entity)
    local data = universe and universe.champions
    local unitNumber = data and entity.unit_number
    return unitNumber and data.units[unitNumber]
end

-- read-only (also used in on_load): sorted prototype names of tracked champions, nil if none
function champions.trackedNames(universe)
    local data = universe and universe.champions
    if not data then
        return nil
    end
    local names
    local seen = {}
    for _, record in pairs(data.units) do
        local name = record.prototypeName
        -- a prototype removed since the save (its unit is gone with it, champions.update drops the record)
        if (not seen[name]) and prototypes.entity[name] then
            seen[name] = true
            names = names or {}
            names[#names + 1] = name
        end
    end
    if names then
        table.sort(names)
    end
    return names
end

local function premultiplied(color, alpha)
    return {r = color.r * alpha, g = color.g * alpha, b = color.b * alpha, a = alpha}
end

----------------------------------------------------------------------------------------------------------------------
-- unit choice

-- weight of a spawn definition at the evolution (linear between points, edge values outside)
local function weightAt(points, evo)
    local n = #points
    if n == 0 then
        return 0
    end
    if evo <= points[1].evolution_factor then
        return points[1].weight
    end
    for i = 2, n do
        local p = points[i]
        if evo <= p.evolution_factor then
            local q = points[i - 1]
            local span = p.evolution_factor - q.evolution_factor
            if span <= 0 then
                return p.weight
            end
            return q.weight + (p.weight - q.weight) * (evo - q.evolution_factor) / span
        end
    end
    return points[n].weight
end

local function unitKind(name)
    if sFind(name, "flyer", 1, true) then
        return "flyer"
    elseif sFind(name, "spitter", 1, true) then
        return "spitter"
    end
    return "biter"
end

-- Big Monsters / mferrari spawners (libs/ForeignEnemies.lua)
local excludedSpawner = require("ForeignEnemies").isForeign

-- an attack that damages the attacker itself (suicide and nuclear biters); cached per prototype name
local selfDestructCache = {}

local function deliveryHurtsSource(deliveries)
    for _, delivery in pairs(deliveries or {}) do
        for _, effect in pairs(delivery.source_effects or {}) do
            if effect.type == "damage" then
                return true
            end
        end
    end
    return false
end

local function selfDestructs(name)
    local cached = selfDestructCache[name]
    if cached == nil then
        cached = false
        local prototype = prototypes.entity[name]
        local attack = prototype and prototype.attack_parameters
        local ammoType = attack and attack.ammo_type
        for _, trigger in pairs((ammoType and ammoType.action) or {}) do
            if deliveryHurtsSource(trigger.action_delivery) then
                cached = true
                break
            end
        end
        selfDestructCache[name] = cached
    end
    return cached
end

-- boss unit and the ordinary unit it is compared with, or nil if the nest has no unit of that kind.
-- tierUp: tiers above the units the nest spawns now (vanilla / Bob nests: steps up the health ladder of the nest)
local function resolveBoss(spawnerPrototype, desiredType, evo, tierUp)
    local units = spawnerPrototype.result_units
    if (not units) or (#units == 0) then
        return nil
    end
    local best, bestWeight
    for _, definition in pairs(units) do
        local weight = weightAt(definition.spawn_points, evo)
        if (not bestWeight) or (weight > bestWeight) then
            best = definition.unit
            bestWeight = weight
        end
    end
    if not best then
        return nil
    end
    local entityPrototypes = prototypes.entity
    local faction, unitType, variation, tier = sMatch(best, RAMPANT_UNIT)
    if faction then
        if not TYPES[unitType] then
            return nil
        end
        tier = tonumber(tier)
        local prefix = faction .. "-" .. desiredType .. "-v" .. variation .. "-t"
        local bossName = prefix .. mMin(tier + tierUp, MAX_TIER) .. "-rampant"
        local localName = prefix .. tier .. "-rampant"
        if entityPrototypes[bossName] and entityPrototypes[localName] and not selfDestructs(bossName) then
            return bossName, localName
        end
        return nil
    end
    if sFind(best, "rampant", 1, true) or (unitKind(best) ~= desiredType) or (not entityPrototypes[best]) then
        return nil
    end
    -- vanilla / Bob nests: tierUp steps to the next stronger unit of the same kind among the nest's units
    local bossName = best
    local bossHealth = entityPrototypes[best].get_max_health()
    for _ = 1, tierUp do
        local stronger, strongerHealth
        for _, definition in pairs(units) do
            local name = definition.unit
            local prototype = entityPrototypes[name]
            if prototype and (unitKind(name) == desiredType) then
                local health = prototype.get_max_health()
                if (health > bossHealth) and ((not strongerHealth) or (health < strongerHealth)) then
                    stronger = name
                    strongerHealth = health
                end
            end
        end
        if not stronger then
            break
        end
        bossName = stronger
        bossHealth = strongerHealth
    end
    if selfDestructs(bossName) then
        return nil
    end
    return bossName, best
end

local function typesToTry(evo, forced)
    if forced then
        return {forced}
    end
    if evo < 0.1 then
        return {"biter"}
    end
    if evo < 0.3 then
        if mRandom(2) == 1 then
            return {"biter", "spitter"}
        end
        return {"spitter", "biter"}
    end
    local roll = mRandom(3)
    if roll == 1 then
        return {"biter", "spitter", "flyer"}
    elseif roll == 2 then
        return {"spitter", "biter", "flyer"}
    end
    return {"flyer", "biter", "spitter"}
end

----------------------------------------------------------------------------------------------------------------------
-- target and nests

-- the most defended player chunk (most turrets in the 3x3 around), else the most valuable one.
-- The strongpoints the AI keeps (aiBrain, the best turret clusters) are checked first; the scan of every turret
-- chunk is left for maps without them (classic behaviour, scattered turrets).
local function pickTarget(map)
    local best, bestScore
    local ties = 0
    local strong = map.ai and map.ai.strong
    if strong then
        for i = 1, #strong do
            local chunk = strong[i].chunk
            if chunkIsLive(map, chunk) then
                local score = turretsAround(map, chunk)
                if (score > 0) and ((not bestScore) or (score > bestScore)) then
                    best = chunk
                    bestScore = score
                    ties = 1
                elseif score == bestScore then
                    ties = ties + 1
                    if mRandom(ties) == 1 then
                        best = chunk
                    end
                end
            end
        end
    end
    if not best then
        for chunk in pairs(map.chunkToPlayerTurrets) do
            local score = turretsAround(map, chunk)
            if (not bestScore) or (score > bestScore) then
                best = chunk
                bestScore = score
                ties = 1
            elseif score == bestScore then
                ties = ties + 1
                if mRandom(ties) == 1 then
                    best = chunk
                end
            end
        end
    end
    if not best then
        for chunk, value in pairs(map.chunkToPlayerBase) do
            if (not bestScore) or (value > bestScore) then
                best = chunk
                bestScore = value
            end
        end
    end
    if best then
        return {x = best.x + CHUNK_SIZE * 0.5, y = best.y + CHUNK_SIZE * 0.5}
    end
end

local nestCenter = {x = 0, y = 0}

-- a nest chunk a champion may leave from or come back to; sets nestCenter to its centre
local function usableNest(map, chunk)
    local count = map.chunkToNests[chunk]
    if (not count) or (count <= 0) then
        return false
    end
    nestCenter.x = chunk.x + CHUNK_SIZE * 0.5
    nestCenter.y = chunk.y + CHUNK_SIZE * 0.5
    return not inPlayerBase(map, nestCenter)
end

-- nest chunks within NEST_RANGE of the target (a walk over the chunk grid around it, was a scan of every nest of
-- the map), else the FALLBACK_NESTS nearest ones
local function nestCandidates(map, target)
    local inRange = {}
    local range2 = NEST_RANGE * NEST_RANGE
    local x0 = mFloor((target.x - NEST_RANGE) / CHUNK_SIZE) * CHUNK_SIZE
    local x1 = mFloor((target.x + NEST_RANGE) / CHUNK_SIZE) * CHUNK_SIZE
    local y0 = mFloor((target.y - NEST_RANGE) / CHUNK_SIZE) * CHUNK_SIZE
    local y1 = mFloor((target.y + NEST_RANGE) / CHUNK_SIZE) * CHUNK_SIZE
    for x = x0, x1, CHUNK_SIZE do
        local column = map[x]
        if column then
            for y = y0, y1, CHUNK_SIZE do
                local chunk = column[y]
                if chunk and usableNest(map, chunk) then
                    local dx = nestCenter.x - target.x
                    local dy = nestCenter.y - target.y
                    if (dx * dx + dy * dy) <= range2 then
                        inRange[#inRange + 1] = chunk
                    end
                end
            end
        end
    end
    if #inRange > 0 then
        return inRange
    end
    -- the nearest ones, kept sorted by distance (no table of every nest and no sort)
    local nearestD2 = {}
    local count = 0
    for chunk in pairs(map.chunkToNests) do
        if usableNest(map, chunk) then
            local dx = nestCenter.x - target.x
            local dy = nestCenter.y - target.y
            local d2 = dx * dx + dy * dy
            if (count < FALLBACK_NESTS) or (d2 < nearestD2[count]) then
                if count < FALLBACK_NESTS then
                    count = count + 1
                end
                local i = count
                while (i > 1) and (nearestD2[i - 1] > d2) do
                    inRange[i] = inRange[i - 1]
                    nearestD2[i] = nearestD2[i - 1]
                    i = i - 1
                end
                inRange[i] = chunk
                nearestD2[i] = d2
            end
        end
    end
    return inRange
end

-- the nearest usable nest chunk centre: rings of chunks around the position, a full scan only if none is close
local function nearestNest(map, position)
    local cx = mFloor(position.x / CHUNK_SIZE) * CHUNK_SIZE
    local cy = mFloor(position.y / CHUNK_SIZE) * CHUNK_SIZE
    local best, bestD2
    local lastRing = HOME_SEARCH_RINGS
    local function consider(chunk)
        if chunk and usableNest(map, chunk) then
            local dx = nestCenter.x - position.x
            local dy = nestCenter.y - position.y
            local d2 = dx * dx + dy * dy
            if (not bestD2) or (d2 < bestD2) then
                best = {x = nestCenter.x, y = nestCenter.y}
                bestD2 = d2
            end
        end
    end
    local r = 0
    while r <= lastRing do
        local offset = r * CHUNK_SIZE
        for dx = -offset, offset, CHUNK_SIZE do
            local column = map[cx + dx]
            if column then
                if (dx == -offset) or (dx == offset) then
                    for dy = -offset, offset, CHUNK_SIZE do
                        consider(column[cy + dy])
                    end
                else
                    consider(column[cy - offset])
                    if offset > 0 then
                        consider(column[cy + offset])
                    end
                end
            end
        end
        if best and (lastRing == HOME_SEARCH_RINGS) then
            -- a nest on a farther ring can still be nearer (diagonal): look up to sqrt(2) rings further
            lastRing = mMin(HOME_SEARCH_RINGS, mCeil(r * 1.4143) + 1)
        end
        r = r + 1
    end
    if best then
        return best
    end
    for chunk in pairs(map.chunkToNests) do
        consider(chunk)
    end
    return best
end

-- a nest to come back to: the original one if a spawner is still there, else the nearest nest chunk
local function findHome(map, record, position)
    local surface = map.surface
    local home = record.home
    if surface.count_entities_filtered({position = home, radius = 32, force = "enemy", type = "unit-spawner",
                                        limit = 1}) > 0 then
        return home
    end
    return nearestNest(map, position) or home
end

----------------------------------------------------------------------------------------------------------------------
-- looks

local function selectionTop(entity)
    local box = entity.prototype.selection_box
    return box.left_top.y, mMax(1, box.right_bottom.x - box.left_top.x)
end

local function drawName(record)
    local entity = record.entity
    local top = selectionTop(entity)
    local color = COLORS[record.colorIndex].color
    rendering.draw_text({
        text = {"rampant-champion-name." .. sFormat("name-%03d", record.nameIndex)},
        surface = entity.surface,
        target = {entity = entity, offset = {0, top - NAME_LIFT}},
        color = {r = 0.5 + color.r * 0.5, g = 0.5 + color.g * 0.5, b = 0.5 + color.b * 0.5, a = 1},
        scale = 1.1,
        alignment = "center",
        vertical_alignment = "middle",
    })
end

-- glow (visible by day) and light (by night); attached to a unit or a corpse
local function drawAura(spec, color, target, size)
    local surface = target.surface
    rendering.draw_sprite({
        sprite = GLOW_SPRITE,
        surface = surface,
        target = target,
        tint = premultiplied(color, 0.55),
        x_scale = size * spec.glowScale,
        y_scale = size * spec.glowScale * 0.75,
        render_layer = "lower-object",
    })
    rendering.draw_light({
        sprite = "utility/light_medium",
        surface = surface,
        target = target,
        color = color,
        scale = size * spec.lightScale,
        intensity = 0.75,
    })
end

local function drawMarks(record)
    local entity = record.entity
    local spec = KINDS[record.kind]
    local color = COLORS[record.colorIndex].color
    local top, size = selectionTop(entity)
    drawAura(spec, color, entity, size)
    rendering.draw_sprite({
        sprite = spec.star,
        surface = entity.surface,
        target = {entity = entity, offset = {0, top - spec.starLift}},
        x_scale = spec.starScale,
        y_scale = spec.starScale,
        render_layer = "air-entity-info-icon",
    })
    if record.nameIndex then
        drawName(record)
    end
end

-- the shield over a retreating champion (it takes RETREAT_DAMAGE_K of the damage); gone with the unit
local function drawShield(record)
    local entity = record.entity
    local top, size = selectionTop(entity)
    local scale = mMax(0.45, size * 0.5)
    record.shield = rendering.draw_sprite({
        sprite = SHIELD_SPRITE,
        surface = entity.surface,
        target = {entity = entity, offset = {0, top * 0.5}},
        tint = SHIELD_COLOR,
        x_scale = scale,
        y_scale = scale,
        render_layer = "air-entity-info-icon",
    })
    record.shieldLight = rendering.draw_light({
        sprite = "utility/light_small",
        surface = entity.surface,
        target = {entity = entity, offset = {0, top * 0.5}},
        color = SHIELD_COLOR,
        scale = size * 1.5,
        intensity = 0.6,
    })
end

local function removeShield(record)
    for _, key in ipairs({"shield", "shieldLight"}) do
        local object = record[key]
        if object and object.valid then
            object.destroy()
        end
        record[key] = nil
    end
end

local function giveName(data, record)
    if data.usedCount >= NAME_COUNT then
        data.usedNames = {}
        data.usedCount = 0
    end
    local used = data.usedNames
    local k = mRandom(NAME_COUNT - data.usedCount)
    for i = 1, NAME_COUNT do
        if not used[i] then
            k = k - 1
            if k == 0 then
                used[i] = true
                data.usedCount = data.usedCount + 1
                record.nameIndex = i
                break
            end
        end
    end
    if record.nameIndex then
        drawName(record)
    end
end

----------------------------------------------------------------------------------------------------------------------
-- health pool

local function syncHealth(record)
    local entity = record.entity
    local health = entity.max_health * record.pool / record.poolMax
    if health < 0.1 then
        health = 0.1
    end
    entity.health = health
end

----------------------------------------------------------------------------------------------------------------------
-- commands

-- the champion's own script-driven group; recreated if lost, the champion is taken back if someone recruited it
local function ensureGroup(record)
    local entity = record.entity
    local group = record.group
    local commandable = entity.commandable
    local parent = commandable and commandable.parent_group
    if group and group.valid and parent and (parent.unique_id == group.unique_id) then
        return group, false
    end
    if not (group and group.valid) then
        group = entity.surface.create_unit_group({position = entity.position, force = entity.force})
        record.group = group
    end
    group.add_member(entity)
    return group, true
end

local function orderAttack(record)
    local group = ensureGroup(record)
    group.set_command({
        type = defines.command.attack_area,
        destination = record.target,
        radius = ATTACK_RADIUS,
        distraction = defines.distraction.by_enemy,
    })
    group.start_moving()
end

-- an own command of the unit: a new command of its group leaves a member that is fighting where it is. The group
-- is dropped (the unit leaves it with the command anyway); the rest at the nest makes a new one
local function orderRetreat(record, detour)
    local group = record.group
    record.group = nil
    if group and group.valid then
        group.destroy()
    end
    local entity = record.entity
    local destination = record.home
    if detour then
        local point = {x = destination.x + (mRandom() * 2 - 1) * RETREAT_DETOUR,
                       y = destination.y + (mRandom() * 2 - 1) * RETREAT_DETOUR}
        destination = entity.surface.find_non_colliding_position(entity.name, point, 8, 1) or point
    end
    entity.commandable.set_command({
        type = defines.command.go_to_location,
        destination = destination,
        radius = 6,
        distraction = defines.distraction.none,
    })
end

local function orderRest(record)
    local group = ensureGroup(record)
    group.set_command({
        type = defines.command.wander,
        radius = 5,
        ticks_to_wait = REGEN_TICKS,
        distraction = defines.distraction.by_damage,
    })
    group.start_moving()
end

local function attackAgain(map, record, tick)
    record.state = "attack"
    record.stateTick = tick
    record.target = pickTarget(map) or record.target
    orderAttack(record)
end

local function startRetreat(universe, record, tick)
    local map = universe.maps[record.surfaceIndex]
    if not map then
        return
    end
    record.state = "retreat"
    record.stateTick = tick
    record.home = findHome(map, record, record.entity.position)
    orderRetreat(record)
    drawShield(record)
end

----------------------------------------------------------------------------------------------------------------------
-- spawning

-- the champion copy of the unit for the kind and the nest unit (prototypes/ChampionUnits.lua), the unit itself if
-- there is none
local function championPrototype(kind, bossName, localName)
    local name = championUnitName(kind, bossName, localName)
    if prototypes.entity[name] then
        return name
    end
    return bossName
end

local function create(universe, map, kind, bossName, localName, position, home, target, tick)
    local spec = KINDS[kind]
    local surface = map.surface
    local entity = surface.create_entity({name = championPrototype(kind, bossName, localName), position = position,
                                          force = "enemy"})
    if not (entity and entity.valid and entity.unit_number) then
        return nil
    end
    local localPrototype = prototypes.entity[localName]
    if spec.speedK and localPrototype.speed then
        entity.speed = localPrototype.speed * spec.speedK
    end
    -- the floor of the current building level (constants.CHAMPION_HEALTH_FLOOR); above the max health of the copy the
    -- pool keeps the health bar as a share
    local poolMax = mMax(entity.max_health, localPrototype.get_max_health() * spec.healthK,
        constants.championHealthFloor(kind, map.buildingsLvl or 1))
    local _, size = selectionTop(entity)
    local record = {
        size = size,
        entity = entity,
        unitNumber = entity.unit_number,
        prototypeName = entity.name,
        kind = kind,
        colorIndex = mRandom(#COLORS),
        surfaceIndex = surface.index,
        pool = poolMax,
        poolMax = poolMax,
        state = "attack",
        stateTick = tick,
        createdTick = tick,
        home = {x = home.x, y = home.y},
        target = target,
    }
    local data = getData(universe)
    data.units[record.unitNumber] = record
    drawMarks(record)
    orderAttack(record)
    if spec.warning then
        for _, player in pairs(game.connected_players) do
            if player.surface.index == surface.index then
                player.print({"description.rampantFixed--championHourWarning"}, {color = {r = 0.85, g = 0.6, b = 0.35}})
            end
        end
    end
    notifyChanged()
    return entity
end

-- Paranoidal: super-hives (libs/SuperHives.lua) are the lairs of the champions. A random super-hive within NEST_RANGE
-- of the target is where an hour boss always, a champion with SUPER_HIVE_SHARE leaves from and comes back to; its unit
-- and faction still come from a random ordinary nest around (as without a super-hive), so a lair does not make it
-- stronger. Without a super-hive near the target only NO_LAIR_HOUR_BOSS_SHARE of the hour bosses come (not for the
-- avenger of a super-hive and the remote call)
local SUPER_HIVE_SHARE = 0.5
local NO_LAIR_HOUR_BOSS_SHARE = 0.25

local spawnerArea = {{0, 0}, {0, 0}}
local spawnerQuery = {area = spawnerArea, force = "enemy", type = "unit-spawner"}

-- the spawners of a random candidate chunk
local function spawnersOfRandomChunk(surface, candidates)
    local chunk = candidates[mRandom(#candidates)]
    spawnerArea[1][1] = chunk.x
    spawnerArea[1][2] = chunk.y
    spawnerArea[2][1] = chunk.x + CHUNK_SIZE
    spawnerArea[2][2] = chunk.y + CHUNK_SIZE
    return surface.find_entities_filtered(spawnerQuery)
end

-- a random spawner of a random candidate chunk that may give the unit: no super-hive (it breeds stronger units, it is
-- only a lair) and no Big Monsters spawner; nil if the chunk has none
local function randomOrdinarySpawner(universe, surface, candidates)
    local spawners = spawnersOfRandomChunk(surface, candidates)
    local n = #spawners
    if n == 0 then
        return nil
    end
    local first = mRandom(n)
    for i = 0, n - 1 do
        local spawner = spawners[((first + i - 1) % n) + 1]
        if (not excludedSpawner(spawner.name)) and (not superHives.isSuperHive(universe, spawner.name)) then
            return spawner
        end
    end
    return nil
end

-- the prototype that gives the unit and the faction: a random ordinary nest or hive around (no super-hive, no
-- Big Monsters), else an ordinary nest of the faction of the super-hive
local function ordinarySource(universe, map, candidates, hive)
    local count = #candidates
    if count > 0 then
        for _ = 1, mMin(SPAWN_TRIES, count * 2) do
            local spawner = randomOrdinarySpawner(universe, map.surface, candidates)
            if spawner then
                return spawner.prototype
            end
        end
    end
    local faction = universe.enemyAlignmentLookup and universe.enemyAlignmentLookup[hive.name]
    if faction then
        for _, building in ipairs({"biter-spawner", "spitter-spawner", "hive"}) do
            local prototype = prototypes.entity[faction .. "-" .. building .. "-v1-t1-rampant"]
            if prototype then
                return prototype
            end
        end
    end
    return nil
end

local function spawnFromSuperHive(universe, map, kind, tick, forcedType, target, evo, hive, candidates)
    local surface = map.surface
    local origin = hive.position
    for _, desiredType in ipairs(typesToTry(evo, forcedType)) do
        for _ = 1, 4 do
            local source = ordinarySource(universe, map, candidates, hive)
            if not source then
                return nil
            end
            local bossName, localName = resolveBoss(source, desiredType, evo, KINDS[kind].tierUp)
            if bossName then
                local position = surface.find_non_colliding_position(championPrototype(kind, bossName, localName),
                    origin, 24, 0.5)
                if position and not inPlayerBase(map, position) then
                    local entity = create(universe, map, kind, bossName, localName, position, origin, target, tick)
                    if entity then
                        return entity
                    end
                end
                break       -- no place at the lair for this unit: the next unit type
            end
        end
    end
    return nil
end

-- the entity, or nil and true when an hour boss without a lair does not come this time (no retry)
local function spawn(universe, map, kind, tick, forcedType, forced)
    local surface = map.surface
    local target = pickTarget(map)
    if not target then
        return nil
    end
    local evo = game.forces.enemy.get_evolution_factor(surface)
    local candidates = nestCandidates(map, target)
    local hive = superHives.randomNear(universe, map, target, NEST_RANGE)
    if hive then
        if (kind == "hourBoss") or (mRandom() < SUPER_HIVE_SHARE) then
            local entity = spawnFromSuperHive(universe, map, kind, tick, forcedType, target, evo, hive, candidates)
            if entity then
                return entity
            end
        end
    elseif (kind == "hourBoss") and (not forced) and (mRandom() >= NO_LAIR_HOUR_BOSS_SHARE) then
        return nil, true
    end
    local count = #candidates
    if count == 0 then
        return nil
    end
    for _, desiredType in ipairs(typesToTry(evo, forcedType)) do
        for _ = 1, mMin(SPAWN_TRIES, count * 2) do
            local spawner = randomOrdinarySpawner(universe, surface, candidates)
            if spawner then
                local bossName, localName = resolveBoss(spawner.prototype, desiredType, evo, KINDS[kind].tierUp)
                if bossName then
                    local position = surface.find_non_colliding_position(
                        championPrototype(kind, bossName, localName), spawner.position, 24, 0.5)
                    if position and not inPlayerBase(map, position) then
                        local entity = create(universe, map, kind, bossName, localName, position,
                            spawner.position, target, tick)
                        if entity then
                            return entity
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- a surface with a connected player, Rampant AI out of the truce and something to attack
local function pickMap(universe)
    local candidates = {}
    local seen = {}
    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local index = surface.index
        if not seen[index] then
            seen[index] = true
            local map = universe.maps[index]
            if map and (not map.suspended) and map.surface.valid and (not surface.peaceful_mode)
                and (map.state ~= AI_STATE_PEACEFUL) and next(map.chunkToNests)
                and (next(map.chunkToPlayerTurrets) or next(map.chunkToPlayerBase)) then
                candidates[#candidates + 1] = map
            end
        end
    end
    if #candidates > 0 then
        return candidates[mRandom(#candidates)]
    end
end

local function interval(spec)
    return mRandom(spec.intervalMin, spec.intervalMax)
end

local function aliveCount(data, kind)
    local count = 0
    for _, record in pairs(data.units) do
        if (record.kind == kind) and (not record.died) then
            count = count + 1
        end
    end
    return count
end

local function schedule(universe, tick)
    local data = getData(universe)
    local nextTick = data.nextTick
    local enabled = settings.global[champions.SETTING].value
    for _, kind in ipairs(KIND_ORDER) do
        local spec = KINDS[kind]
        local due = nextTick[kind]
        if not due then
            nextTick[kind] = tick + interval(spec)
        elseif tick >= due then
            if (not enabled) or (aliveCount(data, kind) >= spec.maxAlive) then
                nextTick[kind] = tick + interval(spec)
            else
                local map = pickMap(universe)
                local entity, skipped
                if map then
                    entity, skipped = spawn(universe, map, kind, tick)
                end
                if entity or skipped then
                    nextTick[kind] = tick + interval(spec)
                else
                    nextTick[kind] = tick + RETRY_TICKS
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------------
-- life cycle

local function stepRecord(universe, data, record, tick)
    local map = universe.maps[record.surfaceIndex]
    if not map then
        return
    end
    local entity = record.entity
    local state = record.state
    if state == "attack" then
        local group, regrouped = ensureGroup(record)
        if regrouped or not group.has_command then
            attackAgain(map, record, tick)
        end
    elseif state == "retreat" then
        local position = entity.position
        local dx = position.x - record.home.x
        local dy = position.y - record.home.y
        local d2 = dx * dx + dy * dy
        -- its own walk home; a failed or blocked path ends it, the engine or another mod may replace it
        local commandable = entity.commandable
        local command = commandable.command
        local walking = (not commandable.parent_group) and command and (command.type == defines.command.go_to_location)
        local stuck = walking and (commandable.moving_state == defines.moving_state.stuck)
        if (d2 <= HOME_RADIUS * HOME_RADIUS) or ((d2 <= HOME_NEAR * HOME_NEAR) and ((not walking) or stuck))
            or ((tick - record.stateTick) > RETREAT_TIMEOUT) then
            removeShield(record)
            record.state = "regen"
            record.stateTick = tick
            orderRest(record)
        elseif stuck or not walking then
            orderRetreat(record, stuck)     -- stuck: around the nest from another side
        end
    elseif state == "regen" then
        record.pool = mMin(record.poolMax, record.pool + record.poolMax * UPDATE_TICKS / REGEN_TICKS)
        syncHealth(record)
        if record.pool >= record.poolMax then
            if not record.nameIndex then
                giveName(data, record)     -- survived its first attack and came back
            end
            attackAgain(map, record, tick)
        else
            local group, regrouped = ensureGroup(record)
            if regrouped or not group.has_command then
                orderRest(record)
            end
        end
    end
end

-- Runtime setting change and configuration update: existing saves may already have champions disabled.
function champions.onSettingsChanged(universe)
    if settings.global[champions.SETTING].value then
        return
    end
    local data = universe.champions
    if not data then
        return
    end
    local changed = false
    for unitNumber, record in pairs(data.units) do
        if not record.entity.valid then
            data.units[unitNumber] = nil
            changed = true
        elseif not record.died then
            record.entity.die()
        end
    end
    if changed then
        notifyChanged()
    end
end

-- every 60 ticks (control.lua)
function champions.update(universe, tick)
    local data = universe.champions
    if data then
        local changed = false
        for unitNumber, record in pairs(data.units) do
            if not record.entity.valid then
                data.units[unitNumber] = nil    -- removed without on_post_entity_died (destroyed by a script)
                changed = true
            elseif not record.died then
                stepRecord(universe, data, record, tick)
            end
        end
        local corpses = data.corpses
        if corpses[1] then
            local kept = 0
            local count = #corpses
            for i = 1, count do
                local corpse = corpses[i]
                if corpse.entity.valid and (tick < corpse.expire) then
                    kept = kept + 1
                    corpses[kept] = corpse
                elseif corpse.entity.valid then
                    corpse.entity.destroy()
                end
            end
            for i = kept + 1, count do
                corpses[i] = nil
            end
        end
        if changed then
            notifyChanged()
        end
    end
    schedule(universe, tick)
end

-- on_entity_damaged for a tracked champion (control.lua dispatches)
function champions.onDamaged(universe, event, record)
    local entity = event.entity
    local damage = mMax(0, event.final_damage_amount)
    if record.state == "retreat" then
        damage = damage * RETREAT_DAMAGE_K
    end
    record.pool = record.pool - damage
    if record.pool <= 0 then
        record.pool = 0
        if entity.health > 0 then
            local cause = event.cause
            entity.die(event.force, (cause and cause.valid) and cause or nil)
        end
        return
    end
    syncHealth(record)      -- also keeps it alive when the hit took the engine health to 0
    if (record.state == "attack") and (record.pool < record.poolMax * RETREAT_SHARE) then
        startRetreat(universe, record, event.tick)
    end
end

-- on_entity_died / script_raised_destroy (control.lua onDeath): one big artifact of its colour instead of the loot
function champions.onDied(universe, event)
    local data = universe.champions
    if not data then
        return
    end
    local unitNumber = event.entity.unit_number
    local record = unitNumber and data.units[unitNumber]
    if not record then
        return
    end
    record.died = true
    local loot = event.loot
    if loot then
        loot.clear()
        local item = COLORS[record.colorIndex].item
        if not prototypes.item[item] then
            item = prototypes.item[FALLBACK_ITEM] and FALLBACK_ITEM
        end
        if item then
            loot.insert({name = item, count = 1})
        end
    end
end

-- on_post_entity_died (registered only while champions are tracked): the corpse stays 1 minute with the glow
function champions.onPostDied(universe, event)
    local data = universe.champions
    local unitNumber = event.unit_number
    local record = data and unitNumber and data.units[unitNumber]
    if not record then
        return
    end
    data.units[unitNumber] = nil
    local spec = KINDS[record.kind]
    local color = COLORS[record.colorIndex].color
    local marked = false
    for _, corpse in pairs(event.corpses or {}) do
        if corpse.valid and (corpse.type == "corpse") then
            corpse.corpse_expires = false
            if not marked then
                marked = true
                drawAura(spec, color, corpse, record.size or 1)
            end
            data.corpses[#data.corpses + 1] = {entity = corpse, expire = event.tick + CORPSE_TICKS}
        end
    end
    notifyChanged()
end

----------------------------------------------------------------------------------------------------------------------
-- remote

-- spawns now (no timer, no cap); kind "champion" or "hourBoss", unitType optional
function champions.spawnNow(universe, surfaceIndex, kind, unitType)
    local map = universe.maps[surfaceIndex]
    if (not map) or (not KINDS[kind]) or (unitType and not TYPES[unitType]) then
        return nil
    end
    return (spawn(universe, map, kind, game.tick, unitType, true))
end

-- read-only snapshot
function champions.report(universe)
    local data = universe.champions
    local result = {units = {}, corpses = 0, nextTick = {}}
    if not data then
        return result
    end
    for unitNumber, record in pairs(data.units) do
        local entity = record.entity
        result.units[#result.units + 1] = {
            unitNumber = unitNumber, kind = record.kind, name = record.prototypeName, state = record.state,
            pool = record.pool, poolMax = record.poolMax, nameIndex = record.nameIndex,
            color = COLORS[record.colorIndex].name, died = record.died,
            health = entity.valid and entity.health or nil, maxHealth = entity.valid and entity.max_health or nil,
            speed = entity.valid and entity.speed or nil,
            position = entity.valid and entity.position or nil, home = record.home, target = record.target,
        }
    end
    result.corpses = #data.corpses
    for kind, tick in pairs(data.nextTick) do
        result.nextTick[kind] = tick
    end
    return result
end

championsG = champions
return champions
