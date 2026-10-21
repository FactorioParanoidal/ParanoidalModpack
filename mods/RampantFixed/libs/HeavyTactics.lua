-- Reforged Paranoidal: heavy tactics of the Rampant AI (map setting rampantFixed--heavyBehavior, on by default).
--
-- Heavier than AIBrain because they cost an extra engine query per rescanned player chunk, a train scan every
-- 10 seconds, or keep unit groups waiting for minutes:
--  * pincer: two squads go to staging points on both sides of a weak spot, wait for each other and strike together;
--  * ambush: a squad waits outside turret cover on a chunk the player or trains pass often (presence heat map);
--  * sabotage: a small squad attacks poles, pipes and belts outside turret cover.
-- Older heavy scripts (underground attacks, enrage, bridgeheads) are switched by the same setting at their call sites.

if heavyTacticsG then
    return heavyTacticsG
end
local heavyTactics = {}

local constants = require("Constants")
local aiBrain = require("AIBrain")
local mapUtils = require("MapUtils")

local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local MAX_DETECTION = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK
local CHUNK_SIZE = constants.CHUNK_SIZE

local getChunkByPosition = mapUtils.getChunkByPosition

local mRandom = math.random
local mFloor = math.floor
local mMin = math.min
local mSqrt = math.sqrt

local TACTICS = aiBrain.TACTICS
local reservoirOffer = aiBrain.reservoirOffer
local reservoirFind = aiBrain.reservoirFind
local reservoirRemove = aiBrain.reservoirRemove
local turretsAround = aiBrain.turretsAround

local INFRA_SIZE = 12
local HEAT_TOP_SIZE = 12
local HEAT_HALF_LIFE = 20 * 3600
local AMBUSH_RANGE = 24 * CHUNK_SIZE
local SABOTAGE_RANGE = 26 * CHUNK_SIZE
local PINCER_RADIUS = 128
local TRAINS_PER_SCAN = 40
local HEAT_PRUNE_PER_SCAN = 200

aiBrain.heavy = heavyTactics

----------------------------------------------------------------------------------------------------------------------
-- infrastructure outside turret cover (from chunkUtils.scorePlayerBuildings)

-- rails, lamps and big poles are left out: Paranoidal makes them indestructible by default
local INFRA_TYPES = {"electric-pole", "pipe", "pipe-to-ground", "transport-belt", "underground-belt", "splitter",
                     "pump", "offshore-pump"}
local infraQuery
local function getInfraQuery(universe)
    if (not infraQuery) or (infraQuery.area ~= universe.area) or (infraQuery.force ~= universe.activePlayerForces) then
        infraQuery = {area = universe.area, force = universe.activePlayerForces, type = INFRA_TYPES, limit = 60}
    end
    return infraQuery
end

local function outOfCover(chunk, turrets, share)
    return (turrets == 0) and (chunk[BASE_DETECTION_PHEROMONE] < MAX_DETECTION * share)
end

-- called while universe.area still holds the scanned chunk
function heavyTactics.onPlayerChunkScored(map, ai, chunk, turrets, tick)
    if outOfCover(chunk, turrets, 0.85) then
        local count = map.surface.count_entities_filtered(getInfraQuery(map.universe))
        if count >= 4 then
            reservoirOffer(ai.infra, INFRA_SIZE, chunk, count, tick, 0, false)
            return
        end
    end
    local i = reservoirFind(ai.infra, chunk)
    if i then
        reservoirRemove(ai.infra, i)
    end
end

----------------------------------------------------------------------------------------------------------------------
-- presence heat map (players every 16 ticks, moving trains every 10 seconds)

local function decayed(value, since, tick)
    return value * 0.5 ^ ((tick - since) / HEAT_HALF_LIFE)
end

function heavyTactics.recordPresence(map, chunk, tick, amount)
    local ai = aiBrain.getMapAI(map)
    local heat = ai.heat
    local record = heat[chunk]
    if record then
        record.v = decayed(record.v, record.t, tick) + amount
        record.t = tick
    else
        record = {v = amount, t = tick}
        heat[chunk] = record
    end
    if record.v >= 3 then
        if outOfCover(chunk, turretsAround(map, chunk), 0.8) then
            reservoirOffer(ai.heatTop, HEAT_TOP_SIZE, chunk, record.v, tick, 0, false)
        else
            local i = reservoirFind(ai.heatTop, chunk)
            if i then
                reservoirRemove(ai.heatTop, i)
            end
        end
    end
end

local trainFilter = {surface = nil, is_moving = true}
local function scanTrains(map, ai, tick)
    trainFilter.surface = map.surface
    local trains = game.train_manager.get_trains(trainFilter)
    local count = #trains
    if count == 0 then
        return
    end
    local start = (ai.trainCursor or 0) % count
    for i = 1, mMin(count, TRAINS_PER_SCAN) do
        local train = trains[((start + i - 1) % count) + 1]
        local stock = train.valid and train.front_stock
        if stock and stock.valid then
            local chunk = getChunkByPosition(map, stock.position)
            if chunk ~= -1 then
                heavyTactics.recordPresence(map, chunk, tick, 4)
            end
        end
    end
    ai.trainCursor = start + TRAINS_PER_SCAN
end

-- drops cold entries, HEAT_PRUNE_PER_SCAN per call; the traversal resumes on the next call
local function pruneHeat(map, ai, tick)
    local heat = ai.heat
    local key = ai.heatPruneKey
    if key and (heat[key] == nil) then
        key = nil       -- the stored key was removed (or entries were added since): start over
    end
    for _ = 1, HEAT_PRUNE_PER_SCAN do
        local chunk, record = next(heat, key)
        if not chunk then
            key = nil
            break
        end
        if (decayed(record.v, record.t, tick) < 0.5) or (not aiBrain.chunkIsLive(map, chunk)) then
            heat[chunk] = nil   -- clearing fields during a traversal is allowed
        end
        key = chunk
    end
    ai.heatPruneKey = key
end

-- on_tick every 600 ticks
function heavyTactics.periodic(universe, tick)
    if not aiBrain.heavyActive(universe) then
        return
    end
    for _, map in pairs(universe.maps) do
        local ai = map and map.ai
        if ai and (not map.suspended) and map.surface.valid then
            scanTrains(map, ai, tick)
            pruneHeat(map, ai, tick)
            for id, wave in pairs(ai.waves) do
                if wave.untilTick + 3600 < tick then
                    ai.waves[id] = nil
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------------
-- targets

local function pickAmbushSite(map, ai, x, y, tick)
    return aiBrain.pickFromReservoir(map, ai.heatTop, x, y, AMBUSH_RANGE, function(entry, d)
        local v = decayed(entry.score, entry.tick, tick)
        if (v < 3) or (turretsAround(map, entry.chunk) > 0) then
            return nil
        end
        return v / (1 + d / 480) * (0.8 + mRandom() * 0.4)
    end)
end

local function pickInfraTarget(map, ai, x, y)
    return aiBrain.pickFromReservoir(map, ai.infra, x, y, SABOTAGE_RANGE, function(entry, d)
        if turretsAround(map, entry.chunk) > 0 then
            return nil
        end
        return entry.score / (1 + d / 400) * (0.75 + mRandom() * 0.5)
    end)
end

function heavyTactics.addTacticCandidates(map, ai, chunk, tick, expectedWave, reserve, addCandidate, count)
    local ox = chunk.x + 16
    local oy = chunk.y + 16
    if reserve and (expectedWave >= TACTICS.pincer.minWave) and (#ai.weak > 0) and aiBrain.pickWeakTarget(map, ox, oy) then
        count = addCandidate(count, "pincer", 0)
    end
    if (#ai.heatTop > 0) and pickAmbushSite(map, ai, ox, oy, tick) then
        count = addCandidate(count, "ambush", 0)
    end
    if (#ai.infra > 0) and pickInfraTarget(map, ai, ox, oy) then
        count = addCandidate(count, "sabotage", 0)
    end
    return count
end

function heavyTactics.makeGoal(map, ai, squad, chunk, target, tick)
    local ox = chunk.x + 16
    local oy = chunk.y + 16
    if target == "ambush" then
        local entry = pickAmbushSite(map, ai, ox, oy, tick)
        if entry then
            return {x = entry.chunk.x + 16, y = entry.chunk.y + 16, kind = "ambush", reach = 24,
                    wait = 3 * 3600 + mFloor(mRandom() * 2 * 3600)}
        end
    elseif target == "infra" then
        local entry = pickInfraTarget(map, ai, ox, oy)
        if entry then
            return {x = entry.chunk.x + 16, y = entry.chunk.y + 16, kind = "strike", reach = 40}
        end
    end
    return nil
end

----------------------------------------------------------------------------------------------------------------------
-- pincer waves

function heavyTactics.preparePincer(map, squads, chunk, tick)
    local ai = aiBrain.getMapAI(map)
    local ox = chunk.x + 16
    local oy = chunk.y + 16
    local entry = aiBrain.pickWeakTarget(map, ox, oy)
    if (not entry) or (#squads < 2) then
        for i = 1, #squads do
            squads[i].tactic = "assault"     -- no wave possible: plain attack
        end
        return
    end
    local tx = entry.chunk.x + 16
    local ty = entry.chunk.y + 16
    local vx = tx - ox
    local vy = ty - oy
    local length = mSqrt(vx * vx + vy * vy)
    if length < 1 then
        vx, vy, length = 0, -1, 1
    end
    vx = vx / length
    vy = vy / length
    local r = mMin(PINCER_RADIUS, length * 0.5)
    local id = ai.nextWaveId
    ai.nextWaveId = id + 1
    local wave = {id = id, x = tx, y = ty, members = {}, untilTick = tick + 4 * 3600}
    for i = 1, #squads do
        local side = ((i % 2) == 1) and 1 or -1
        local squad = squads[i]
        squad.waveId = id
        squad.goal = {x = tx - vx * r - vy * r * side, y = ty - vy * r + vx * r * side, kind = "stage", reach = 40,
                      untilTick = wave.untilTick}
        wave.members[squad.groupNumber] = false
    end
    ai.waves[id] = wave
    aiBrain.debugPrint(map, "pincer: " .. #squads .. " squads close in on [gps=" .. tx .. "," .. ty .. "," .. map.surface.name .. "]")
end

local function releaseWave(map, ai, wave, tick)
    local squads = map.universe.groupNumberToSquad
    for groupNumber in pairs(wave.members) do
        local squad = squads[groupNumber]
        if squad and squad.group.valid then
            squad.goal = {x = wave.x, y = wave.y, kind = "strike", reach = 40, untilTick = tick + 3 * 3600}
        end
    end
    ai.waves[wave.id] = nil
    aiBrain.debugPrint(map, "pincer: strike [gps=" .. wave.x .. "," .. wave.y .. "," .. map.surface.name .. "]")
end

-- a pincer squad reached its staging point: hold until every arm is there (or time is up).
-- Returns true while holding; on release the squad's goal becomes the strike.
function heavyTactics.onStageReached(map, squad, group, tick)
    local ai = map.ai
    local wave = ai and ai.waves[squad.waveId]
    if (not wave) or (not aiBrain.heavyActive(map.universe)) then
        return false
    end
    wave.members[squad.groupNumber] = true
    local squads = map.universe.groupNumberToSquad
    local allReady = true
    for groupNumber, ready in pairs(wave.members) do
        local other = squads[groupNumber]
        if (not ready) and other and other.group.valid then
            allReady = false
            break
        end
    end
    if allReady or (wave.untilTick < tick) then
        releaseWave(map, ai, wave, tick)
        return false
    end
    group.set_command({type = defines.command.stop, ticks_to_wait = 300, distraction = defines.distraction.by_enemy})
    squad.nextCommandTick = tick + 60
    squad.checkTick = tick + 18000
    squad.onTheWay = true
    return true
end

function heavyTactics.onWaveSquadEnd(map, ai, squad)
    local wave = ai.waves[squad.waveId]
    if wave then
        wave.members[squad.groupNumber] = nil
        if next(wave.members) == nil then
            ai.waves[wave.id] = nil
        end
    end
end

heavyTacticsG = heavyTactics
return heavyTactics
