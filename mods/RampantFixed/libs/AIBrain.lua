-- Reforged Paranoidal: learning layer of the Rampant AI.
--
-- Cheap by design: everything here works on data Rampant already keeps per chunk (pheromones, player turret and
-- building counts) and on a few counters updated by events. No entity searches. Data lives in map.ai (created
-- on first use, so old saves need no migration) and in squad fields.
--
-- What it does:
--  * tactics: every attack squad gets a tactic (assault, flank, probe, feint, raider, sapper, counter-battery and,
--    with heavy models, pincer, ambush, sabotage). A tactic keeps a running value from the outcomes of its squads
--    (kills against losses); tactics are picked by softmax over these values plus faction/state priors, with some
--    exploration, so a tactic the player has learned to beat is dropped and others are tried;
--  * approach memory: losses and kills per approach sector of every 8x8 chunk region of nests; flanking squads go
--    to a waypoint in front of the least lethal / least defended sector first;
--  * targets: weak spots (valuable player chunks with few turrets around) and strongpoints (turret clusters) are
--    kept in small reservoirs updated when Rampant rescans a player chunk;
--  * state planner: an AI state whose squads keep failing is often replaced; a losing streak makes the AI rethink
--    (sooner state change, more exploration), a winning streak makes it press harder;
--  * mutations: nests shift towards factions that resist the damage type killing them.
--
-- Settings: universe.classicAI (rampantFixed--classicBehavior) turns all of it off; universe.heavyAI
-- (rampantFixed--heavyBehavior) enables the heavier tactics in HeavyTactics.lua.

if aiBrainG then
    return aiBrainG
end
local aiBrain = {}

local constants = require("Constants")
local mapUtils = require("MapUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")

local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local MAX_DETECTION = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK
local CHUNK_SIZE = constants.CHUNK_SIZE

local AI_STATE_AGGRESSIVE = constants.AI_STATE_AGGRESSIVE
local AI_STATE_RAIDING = constants.AI_STATE_RAIDING
local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_ONSLAUGHT = constants.AI_STATE_ONSLAUGHT

local getChunkByXY = mapUtils.getChunkByXY
local getPlayerTurretCount = chunkPropertyUtils.getPlayerTurretCount
local getPathRating = chunkPropertyUtils.getPathRating

local mRandom = math.random
local mExp = math.exp
local mMin = math.min
local mMax = math.max
local mFloor = math.floor
local mAbs = math.abs
local mSqrt = math.sqrt

aiBrain.BEHAVIOR_VERSION = 1

-- optional modules register themselves here (HeavyTactics, FlyerAI)
aiBrain.heavy = nil
aiBrain.flyers = nil

----------------------------------------------------------------------------------------------------------------------
-- settings

-- a game started before these settings existed (mod files replaced while it runs) gets the defaults
local function globalSetting(name, default)
    local setting = settings.global[name]
    if setting == nil then
        return default
    end
    return setting.value
end

function aiBrain.refreshSettings(universe)
    universe.classicAI = globalSetting("rampantFixed--classicBehavior", false)
    universe.heavyAI = globalSetting("rampantFixed--heavyBehavior", true)
    -- runtime settings read on hot paths elsewhere
    universe.settlementsProbability = settings.global["rampantFixed--settlementsProbability"].value
    universe.allowDaytimePlayerHunting = settings.global["rampantFixed--allowDaytimePlayerHunting"].value
    universe.vengenceProbabilityPercent = settings.global["rampantFixed--vengenceProbabilityPercent"].value
    universe.aiBehaviorVersion = aiBrain.BEHAVIOR_VERSION
end

-- nil (before the first refresh) counts as the default: new behaviour on, heavy models on
local function brainActive(universe)
    return universe.classicAI ~= true
end
aiBrain.active = brainActive

local function heavyActive(universe)
    return (universe.heavyAI ~= false) and (universe.classicAI ~= true)
end
aiBrain.heavyActive = heavyActive

-- heavy scripts that existed before (underground attacks, enrage, bridgeheads) stay controlled by the heavy
-- setting also in classic mode
function aiBrain.heavyScriptsAllowed(universe)
    return universe.heavyAI ~= false
end

local function debugPrint(map, text)
    if map.universe.printAIStateChanges then
        game.print(map.surface.name .. ": [AI] " .. text)
    end
end
aiBrain.debugPrint = debugPrint

----------------------------------------------------------------------------------------------------------------------
-- per map data

function aiBrain.getMapAI(map)
    local ai = map.ai
    if not ai then
        ai = {
            tactics = {},       -- [tactic] = {v = value 0..1, n = samples, t = last tick}
            states = {},        -- [AI state] = same
            flight = {},        -- [flight kind] = same
            regions = {},       -- [region key] = approach memory
            dmg = {},           -- [damage type] = enemy units killed by it
            dmgTotal = 0,
            weak = {},          -- weak spot reservoir
            strong = {},        -- strongpoint reservoir
            infra = {},         -- infrastructure reservoir (heavy)
            heat = {},          -- [chunk] = {v, t} player/train presence (heavy)
            heatTop = {},       -- hottest chunks (heavy)
            artillery = {},     -- recent artillery positions
            followUps = {},     -- delayed main strikes of probe/feint tactics
            waves = {},         -- pincer waves (heavy)
            nextWaveId = 1,
            failStreak = 0,
            winStreak = 0,
            exploreUntil = 0,
            pressUntil = 0,
            nextFlightTick = 0,
            escortUntil = 0,
            outcomes = 0,
            lastTactic = nil
        }
        map.ai = ai
    end
    return ai
end
local getMapAI = aiBrain.getMapAI

local function chunkIsLive(map, chunk)
    local xChunks = map[chunk.x]
    return xChunks and (xChunks[chunk.y] == chunk)
end
aiBrain.chunkIsLive = chunkIsLive

----------------------------------------------------------------------------------------------------------------------
-- geometry: 8 sectors around a point, 1 = north, clockwise (map y grows southwards)

local SECTOR_VECTORS = {
    {0, -1}, {0.7071, -0.7071}, {1, 0}, {0.7071, 0.7071},
    {0, 1}, {-0.7071, 0.7071}, {-1, 0}, {-0.7071, -0.7071}
}
aiBrain.SECTOR_VECTORS = SECTOR_VECTORS

local function sectorOf(dx, dy)
    local ax = mAbs(dx)
    local ay = mAbs(dy)
    if ax > 2.4142 * ay then
        return (dx > 0) and 3 or 7
    elseif ay > 2.4142 * ax then
        return (dy > 0) and 5 or 1
    elseif dx > 0 then
        return (dy > 0) and 4 or 2
    else
        return (dy > 0) and 6 or 8
    end
end
aiBrain.sectorOf = sectorOf

local function sectorDistance(a, b)
    local d = mAbs(a - b)
    if d > 4 then
        d = 8 - d
    end
    return d
end
aiBrain.sectorDistance = sectorDistance

local function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return mSqrt(dx * dx + dy * dy)
end
aiBrain.distance = distance

-- player turrets in the 3x3 chunks around a chunk
local function turretsAround(map, chunk)
    local x = chunk.x
    local y = chunk.y
    local total = 0
    for dx = -CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE do
        local xChunks = map[x + dx]
        if xChunks then
            for dy = -CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE do
                local c = xChunks[y + dy]
                if c then
                    total = total + getPlayerTurretCount(map, c)
                end
            end
        end
    end
    return total
end
aiBrain.turretsAround = turretsAround

----------------------------------------------------------------------------------------------------------------------
-- running values

-- Each outcome moves its record towards the reward (recent outcomes weigh most) and lets the other records forget a
-- little: old verdicts fade towards neutral, so a tactic dropped long ago is tried again once the defence changes.
local FORGET_RATE = 0.03
local NEUTRAL_VALUE = 0.45
local function updateValue(records, key, reward, tick)
    local record = records[key]
    if not record then
        record = {v = 0.5, n = 0, t = tick}
        records[key] = record
    end
    local alpha = mMax(0.25, 1 / (record.n + 1))
    record.v = record.v + alpha * (reward - record.v)
    record.n = record.n + 1
    record.t = tick
    for otherKey, other in pairs(records) do
        if otherKey ~= key then
            other.v = other.v + FORGET_RATE * (NEUTRAL_VALUE - other.v)
        end
    end
    return record
end
aiBrain.updateValue = updateValue

local function valueOf(records, key, tick)
    local record = records[key]
    if not record then
        return 0.5, 0
    end
    local v = record.v
    -- not used for an hour: worth another try
    if (tick - (record.t or 0)) > 216000 then
        v = v + 0.1
    end
    return v, record.n
end
aiBrain.valueOf = valueOf

-- softmax pick over parallel arrays names/scores (count entries); returns the picked name
local function softmaxPick(names, scores, count, temperature, epsilon)
    if count == 0 then
        return nil
    end
    if count == 1 then
        return names[1]
    end
    if mRandom() < epsilon then
        return names[mRandom(count)]
    end
    local best = scores[1]
    for i = 2, count do
        if scores[i] > best then
            best = scores[i]
        end
    end
    local total = 0
    for i = 1, count do
        local w = mExp((scores[i] - best) / temperature)
        scores[i] = w
        total = total + w
    end
    local roll = mRandom() * total
    for i = 1, count do
        roll = roll - scores[i]
        if roll <= 0 then
            return names[i]
        end
    end
    return names[count]
end
aiBrain.softmaxPick = softmaxPick

-- squad outcome 0..1: kills against the squad size, survival
local function squadReward(kills, losses, size)
    local lossRatio = mMin(1, losses / mMax(1, size))
    if kills > 0 then
        return 0.55 * mMin(1, kills / (3 + size * 0.1)) + 0.45 * (1 - lossRatio), lossRatio
    end
    return 0.25 * (1 - lossRatio), lossRatio
end
aiBrain.squadReward = squadReward

----------------------------------------------------------------------------------------------------------------------
-- approach memory per 8x8 chunk region of nests

local REGION_SIZE = 256

local function regionKey(x, y)
    return (mFloor(x / REGION_SIZE) + 50000) * 100000 + (mFloor(y / REGION_SIZE) + 50000)
end

local function getRegion(ai, x, y)
    local key = regionKey(x, y)
    local region = ai.regions[key]
    if not region then
        region = {
            cx = mFloor(x / REGION_SIZE) * REGION_SIZE + REGION_SIZE * 0.5,
            cy = mFloor(y / REGION_SIZE) * REGION_SIZE + REGION_SIZE * 0.5,
            l = {0, 0, 0, 0, 0, 0, 0, 0},   -- lethality: share of the squad lost
            y = {0, 0, 0, 0, 0, 0, 0, 0},   -- yield: kills relative to the squad
            n = {0, 0, 0, 0, 0, 0, 0, 0},   -- samples
            dist = nil                      -- typical distance from the nests to the fighting
        }
        ai.regions[key] = region
    end
    return region, key
end
aiBrain.getRegion = getRegion

local function sectorScore(region, sector)
    if region.n[sector] == 0 then
        return 0.15     -- optimistic: untested approaches are worth a look
    end
    return region.y[sector] - region.l[sector]
end

local function updateRegion(region, squad, lossRatio, kills, size)
    local sector = sectorOf(squad.engageX - region.cx, squad.engageY - region.cy)
    local n = region.n[sector]
    local alpha = mMax(0.25, 1 / (n + 1))
    region.l[sector] = region.l[sector] + alpha * (lossRatio - region.l[sector])
    region.y[sector] = region.y[sector] + alpha * (mMin(1, kills / (3 + size * 0.1)) - region.y[sector])
    region.n[sector] = n + 1
    if squad.originX then
        local d = distance(squad.originX, squad.originY, squad.engageX, squad.engageY)
        if (d > 64) and (d < 1600) then
            region.dist = (region.dist and (region.dist * 0.7 + d * 0.3)) or d
        end
    end
    return sector
end

-- Waypoint in front of the player defence seen from the chunk. mode:
--  "best"      least lethal / least defended sector (learned), unknown sectors are tried
--  "explore"   least tested sector
--  "strongest" most defended sector (feints)
--  "opposite"  away from refSector
-- Returns goal position {x, y} and its sector, or nil.
local APPROACH_RADII = {0.75, 1.0, 1.3}
local candidateChunks = {}
local candidateSectors = {}
local candidateScores = {}
function aiBrain.pickApproach(map, chunk, mode, refSector, excludeSector)
    local ai = getMapAI(map)
    local ox = chunk.x + 16
    local oy = chunk.y + 16
    local region = getRegion(ai, ox, oy)
    local baseDistance = mMin(mMax(region.dist or 256, 128), 640)
    local count = 0
    for r = 1, #APPROACH_RADII do
        local d = baseDistance * APPROACH_RADII[r]
        for s = 1, 8 do
            if s ~= excludeSector then
                local vector = SECTOR_VECTORS[s]
                local x = mFloor((ox + vector[1] * d) / CHUNK_SIZE) * CHUNK_SIZE
                local y = mFloor((oy + vector[2] * d) / CHUNK_SIZE) * CHUNK_SIZE
                local c = getChunkByXY(map, x, y)
                if c ~= -1 then
                    local detection = c[BASE_DETECTION_PHEROMONE]
                    if (detection > 0) and (detection < MAX_DETECTION * 0.97) then
                        local danger = turretsAround(map, c)
                        local score
                        if mode == "explore" then
                            score = -region.n[s] * 0.2 - danger * 0.05 + mRandom() * 0.2
                        elseif mode == "strongest" then
                            score = danger * 0.1 + mRandom() * 0.05
                        elseif mode == "opposite" then
                            score = -sectorDistance(s, ((refSector or 1) + 3) % 8 + 1) * 0.3
                                + sectorScore(region, s) * 0.5 - danger * 0.05 + mRandom() * 0.1
                        else
                            score = sectorScore(region, s) - danger * 0.08 + mRandom() * 0.1
                        end
                        -- prefer the belt 2-5 chunks in front of the turrets
                        if (detection >= MAX_DETECTION * 0.55) and (detection <= MAX_DETECTION * 0.92) then
                            score = score + 0.1
                        end
                        count = count + 1
                        candidateChunks[count] = c
                        candidateSectors[count] = s
                        candidateScores[count] = score
                    end
                end
            end
        end
    end
    if count == 0 then
        return nil
    end
    local bestIndex = 1
    for i = 2, count do
        if candidateScores[i] > candidateScores[bestIndex] then
            bestIndex = i
        end
    end
    local c = candidateChunks[bestIndex]
    return {x = c.x + 16, y = c.y + 16}, candidateSectors[bestIndex]
end

----------------------------------------------------------------------------------------------------------------------
-- target reservoirs, updated from chunkUtils.scorePlayerBuildings

local WEAK_SIZE = 16
local STRONG_SIZE = 8
local WEAK_MIN_VALUE = 500

local function reservoirFind(list, chunk)
    for i = 1, #list do
        if list[i].chunk == chunk then
            return i
        end
    end
end

local function reservoirRemove(list, i)
    local last = #list
    list[i] = list[last]
    list[last] = nil
end

-- keeps the best entries by score; entry fields are refreshed in place
local function reservoirOffer(list, size, chunk, score, tick, turrets, shore)
    local i = reservoirFind(list, chunk)
    if i then
        local entry = list[i]
        entry.score = score
        entry.tick = tick
        entry.turrets = turrets
        entry.shore = shore
        return
    end
    if #list < size then
        list[#list + 1] = {chunk = chunk, score = score, tick = tick, turrets = turrets, shore = shore}
        return
    end
    local minIndex = 1
    for k = 2, #list do
        if list[k].score < list[minIndex].score then
            minIndex = k
        end
    end
    if list[minIndex].score < score then
        list[minIndex] = {chunk = chunk, score = score, tick = tick, turrets = turrets, shore = shore}
    end
end
aiBrain.reservoirOffer = reservoirOffer
aiBrain.reservoirFind = reservoirFind
aiBrain.reservoirRemove = reservoirRemove

-- water or unscanned land next to the chunk: flyers can come from there
local function isShore(map, chunk)
    local x = chunk.x
    local y = chunk.y
    for dx = -CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE do
        local xChunks = map[x + dx]
        for dy = -CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE do
            if (dx ~= 0) or (dy ~= 0) then
                local c = xChunks and xChunks[y + dy]
                if (not c) or (getPathRating(map, c) < 0.6) then
                    return true
                end
            end
        end
    end
    return false
end
aiBrain.isShore = isShore

function aiBrain.onPlayerChunkScored(map, chunk, baseValue, turretCount)
    local universe = map.universe
    if not brainActive(universe) then
        return
    end
    local ai = getMapAI(map)
    local tick = game.tick
    local turrets = turretsAround(map, chunk)
    -- weak spots: valuable and barely defended
    if (baseValue >= WEAK_MIN_VALUE) and (turrets <= 2) then
        local shore = isShore(map, chunk)
        -- shore spots score a bit higher so that flights keep some targets reachable over water
        reservoirOffer(ai.weak, WEAK_SIZE, chunk, baseValue / (1 + 2 * turrets) * (shore and 1.15 or 1), tick, turrets, shore)
    else
        local i = reservoirFind(ai.weak, chunk)
        if i then
            reservoirRemove(ai.weak, i)
        end
    end
    -- strongpoints: turret clusters
    if turretCount >= 2 and turrets >= 4 then
        reservoirOffer(ai.strong, STRONG_SIZE, chunk, turrets, tick, turrets, false)
    elseif turretCount == 0 then
        local i = reservoirFind(ai.strong, chunk)
        if i then
            reservoirRemove(ai.strong, i)
        end
    end
    if aiBrain.heavy and heavyActive(universe) then
        aiBrain.heavy.onPlayerChunkScored(map, ai, chunk, turrets, tick)
    end
end

-- Fills the reservoirs from the player chunks Rampant already knows (saves from before this version, where the
-- reservoirs would otherwise wait for the slow background rescan). Once per map, SEED_PER_CALL chunks per call.
local SEED_PER_CALL = 100     -- one engine count per uncovered chunk with heavy models: keep the tick short
function aiBrain.seedTargets(universe)
    if not brainActive(universe) then
        return
    end
    for _, map in pairs(universe.maps) do
        local ai = map and (not map.suspended) and map.ai
        if ai and not ai.seeded then
            local list = ai.seedList
            if not list then
                list = {}
                for chunk in pairs(map.chunkToPlayerBase) do
                    list[#list + 1] = chunk
                end
                ai.seedList = list
                ai.seedIndex = 1
            end
            local area = universe.area
            local last = mMin(#list, ai.seedIndex + SEED_PER_CALL - 1)
            for i = ai.seedIndex, last do
                local chunk = list[i]
                local baseValue = map.chunkToPlayerBase[chunk]
                if baseValue and chunkIsLive(map, chunk) then
                    area[1][1] = chunk.x
                    area[1][2] = chunk.y
                    area[2][1] = chunk.x + CHUNK_SIZE
                    area[2][2] = chunk.y + CHUNK_SIZE
                    aiBrain.onPlayerChunkScored(map, chunk, baseValue, getPlayerTurretCount(map, chunk))
                end
            end
            ai.seedIndex = last + 1
            if ai.seedIndex > #list then
                ai.seedList = nil
                ai.seedIndex = nil
                ai.seeded = true
            end
        elseif map and (not map.suspended) and (not ai) and next(map.chunkToPlayerBase) then
            getMapAI(map)   -- seeding starts on the next call
        end
    end
end

-- best reservoir entry for a squad at x, y within maxDistance; scorer(entry, distance, map) -> score or nil
local function pickFromReservoir(map, list, x, y, maxDistance, scorer)
    local bestEntry
    local bestScore
    local i = 1
    while i <= #list do
        local entry = list[i]
        local chunk = entry.chunk
        if not chunkIsLive(map, chunk) then
            reservoirRemove(list, i)
        else
            local d = distance(x, y, chunk.x + 16, chunk.y + 16)
            if d <= maxDistance then
                local score = scorer(entry, d, map)
                if score and ((not bestScore) or (score > bestScore)) then
                    bestScore = score
                    bestEntry = entry
                end
            end
            i = i + 1
        end
    end
    return bestEntry
end
aiBrain.pickFromReservoir = pickFromReservoir

-- live check: turrets built around a weak spot since it was recorded make it no longer weak
local function liveWeakScore(entry, map)
    local baseValue = map.chunkToPlayerBase[entry.chunk]
    if not baseValue then
        return nil
    end
    local turrets = turretsAround(map, entry.chunk)
    if turrets > 2 then
        return nil
    end
    entry.turrets = turrets
    return baseValue / (1 + 2 * turrets) * (entry.shore and 1.15 or 1)
end
aiBrain.liveWeakScore = liveWeakScore

local function weakScorer(entry, d, map)
    local score = liveWeakScore(entry, map)
    return score and (score / (1 + d / 320) * (0.75 + mRandom() * 0.5))
end

local function strongScorer(entry, d, map)
    local turrets = turretsAround(map, entry.chunk)
    if turrets < 4 then
        return nil
    end
    return turrets / (1 + d / 480) * (0.8 + mRandom() * 0.4)
end

local RAID_RANGE = 26 * CHUNK_SIZE
local SAPPER_RANGE = 22 * CHUNK_SIZE
local COUNTER_BATTERY_RANGE = 45 * CHUNK_SIZE
local ARTILLERY_MEMORY = 15 * 3600

function aiBrain.pickWeakTarget(map, x, y, maxDistance)
    return pickFromReservoir(map, getMapAI(map).weak, x, y, maxDistance or RAID_RANGE, weakScorer)
end

function aiBrain.pickStrongTarget(map, x, y, maxDistance)
    return pickFromReservoir(map, getMapAI(map).strong, x, y, maxDistance or SAPPER_RANGE, strongScorer)
end

----------------------------------------------------------------------------------------------------------------------
-- artillery memory (counter-battery)

function aiBrain.recordArtillery(map, cause, tick)
    if not (cause and cause.valid) then
        return
    end
    local ai = getMapAI(map)
    local position = cause.position
    local list = ai.artillery
    for i = 1, #list do
        local entry = list[i]
        if (mAbs(entry.x - position.x) < 24) and (mAbs(entry.y - position.y) < 24) then
            entry.tick = tick
            entry.shots = entry.shots + 1
            return
        end
    end
    if #list >= 4 then
        local oldest = 1
        for i = 2, #list do
            if list[i].tick < list[oldest].tick then
                oldest = i
            end
        end
        reservoirRemove(list, oldest)
    end
    list[#list + 1] = {x = position.x, y = position.y, tick = tick, shots = 1}
end

local function pickArtillery(ai, x, y, tick)
    local best
    local bestScore
    for i = 1, #ai.artillery do
        local entry = ai.artillery[i]
        if (tick - entry.tick) < ARTILLERY_MEMORY then
            local d = distance(x, y, entry.x, entry.y)
            if d <= COUNTER_BATTERY_RANGE then
                local score = entry.shots / (1 + d / 320)
                if (not bestScore) or (score > bestScore) then
                    bestScore = score
                    best = entry
                end
            end
        end
    end
    return best
end

----------------------------------------------------------------------------------------------------------------------
-- damage adaptation of mutations

function aiBrain.recordUnitDamage(map, damageName)
    local ai = getMapAI(map)
    ai.dmg[damageName] = (ai.dmg[damageName] or 0) + 1
    ai.dmgTotal = ai.dmgTotal + 1
    if ai.dmgTotal > 4000 then
        local total = 0
        for name, count in pairs(ai.dmg) do
            local half = mFloor(count * 0.5)
            ai.dmg[name] = (half > 0) and half or nil
            total = total + half
        end
        ai.dmgTotal = total
    end
end

function aiBrain.recordStructureDamage(base, damageName)
    local damagedBy = base.damagedBy
    if not damagedBy then
        damagedBy = {}
        base.damagedBy = damagedBy
    end
    damagedBy[damageName] = (damagedBy[damageName] or 0) + 1
end

-- resistance points per faction and damage type from the faction definitions (same on every peer)
local factionResistance
local function getFactionResistance()
    if factionResistance then
        return factionResistance
    end
    factionResistance = {}
    local function add(list, points, into)
        if list then
            for _, entry in pairs(list) do
                local name = (type(entry) == "table") and entry[1] or entry
                if type(name) == "string" then
                    into[name] = (into[name] or 0) + points
                end
            end
        end
    end
    for _, faction in pairs(constants.FACTION_SET) do
        local sum = {}
        local units = 0
        for _, unit in pairs(faction.units or {}) do
            if (unit.type == "biter") or (unit.type == "spitter") then
                units = units + 1
                add(unit.immunity, 4, sum)
                add(unit.extremeResistances, 3, sum)
                add(unit.majorResistances, 2, sum)
                add(unit.minorResistances, 1, sum)
                add(unit.lesserResistances, 0.5, sum)
                add(unit.majorWeaknesses, -2, sum)
                add(unit.minorWeaknesses, -1, sum)
                if unit.resitancePercent then
                    for _, entry in pairs(unit.resitancePercent) do
                        if (type(entry) == "table") and entry[2] then
                            sum[entry[1]] = (sum[entry[1]] or 0) + ((entry[2] > 100) and 1 or -1)
                        end
                    end
                end
            end
        end
        if units > 0 then
            for name, points in pairs(sum) do
                sum[name] = points / units
            end
        end
        factionResistance[faction.type] = sum
    end
    return factionResistance
end

-- dominant damage type against this base (structure kills count more), or nil
local function dominantDamage(map, base)
    local ai = map.ai
    if not ai then
        return nil
    end
    local bestName
    local bestScore = 0
    local total = 0
    local damagedBy = base and base.damagedBy
    for name, count in pairs(ai.dmg) do
        local score = count + 5 * ((damagedBy and damagedBy[name]) or 0)
        total = total + score
        if score > bestScore then
            bestScore = score
            bestName = name
        end
    end
    if damagedBy then
        for name, count in pairs(damagedBy) do
            if not ai.dmg[name] then
                local score = 5 * count
                total = total + score
                if score > bestScore then
                    bestScore = score
                    bestName = name
                end
            end
        end
    end
    if (total >= 40) and (bestScore >= total * 0.35) then
        return bestName, bestScore / total
    end
    return nil
end
aiBrain.dominantDamage = dominantDamage

-- faction for a mutation of the base, biased towards resisting the dominant damage; nil = keep the normal roll
function aiBrain.mutationBias(map, base, tier)
    local universe = map.universe
    if not brainActive(universe) then
        return nil
    end
    local alignments = universe.evolutionTableAlignment and universe.evolutionTableAlignment[tier]
    if not alignments or (#alignments == 0) then
        return nil
    end
    local damageName, share = dominantDamage(map, base)
    if not damageName or (mRandom() > 0.6) then
        return nil
    end
    local resist = getFactionResistance()
    local total = 0
    for i = 1, #alignments do
        local alignment = alignments[i]
        local points = (resist[alignment[2]] or {})[damageName] or 0
        if points >= 1.5 then
            total = total + alignment[1] * points * points
        end
    end
    if total <= 0 then
        return nil
    end
    local roll = mRandom() * total
    for i = 1, #alignments do
        local alignment = alignments[i]
        local points = (resist[alignment[2]] or {})[damageName] or 0
        if points >= 1.5 then
            roll = roll - alignment[1] * points * points
            if roll <= 0 then
                debugPrint(map, "nests adapt to " .. damageName .. " (" .. mFloor(share * 100) .. "% of kills): mutation to "
                    .. alignment[2] .. " [gps=" .. base.x .. "," .. base.y .. "," .. map.surface.name .. "]")
                return alignment[2]
            end
        end
    end
    return nil
end

----------------------------------------------------------------------------------------------------------------------
-- tactics

-- size/cost multipliers, movement noise (randomised near-best steps), retreat share of losses, goal source.
-- stage1 is the first squad(s) of a two-stage tactic, followUp the delayed main strike.
local TACTICS = {
    assault = {sizeK = 1, costK = 1, noise = 0.2, retreatAt = 0.6},
    flank = {sizeK = 1, costK = 1, noise = 0.15, retreatAt = 0.5, approach = "best"},
    probe = {sizeK = 1, costK = 1, noise = 0.15, retreatAt = 0.5, approach = "best", minWave = 12,
             stage1 = {count = 2, sizeK = 0.18, costK = 0.25, minSize = 3, noise = 0.45, retreatAt = 0.5,
                       approach = "explore", support = true},
             followUp = {delayMin = 3600, delayMax = 7200}},
    feint = {sizeK = 1, costK = 1, noise = 0.15, retreatAt = 0.55, approach = "opposite", minWave = 12,
             stage1 = {count = 1, sizeK = 0.3, costK = 0.3, minSize = 4, noise = 0.3, approach = "strongest",
                       support = true},
             followUp = {delayMin = 1800, delayMax = 3600}},
    raider = {sizeK = 0.7, costK = 0.7, noise = 0.25, retreatAt = 0.35, target = "weak"},
    sapper = {sizeK = 1, costK = 1, noise = 0.1, target = "strong", dash = true},
    counterBattery = {sizeK = 0.8, costK = 0.8, noise = 0.1, target = "artillery", dash = true},
    -- heavy models (HeavyTactics.lua)
    pincer = {heavy = true, sizeK = 1, costK = 1, noise = 0.15, retreatAt = 0.5, minWave = 14,
              stage1 = {count = 2, sizeK = 0.6, costK = 0.6, minSize = 6, noise = 0.15, retreatAt = 0.5,
                        approach = "pincer"}},
    ambush = {heavy = true, sizeK = 0.6, costK = 0.6, noise = 0.2, retreatAt = 0.5, target = "ambush"},
    sabotage = {heavy = true, sizeK = 0.45, costK = 0.45, noise = 0.3, retreatAt = 0.4, target = "infra"}
}
aiBrain.TACTICS = TACTICS

-- faction leanings (multiplied by the faction share of the base)
local FACTION_TACTIC_BONUS = {
    physical = {assault = 0.1, sapper = 0.15},
    troll = {assault = 0.1, sapper = 0.1},
    juggernaut = {assault = 0.1, sapper = 0.15},
    suicide = {sapper = 0.3},
    nuclear = {sapper = 0.3},
    fast = {raider = 0.2, probe = 0.05},
    electric = {raider = 0.1, sabotage = 0.15},
    ["energy-thief"] = {raider = 0.1, sabotage = 0.2},
    acid = {flank = 0.05},
    laser = {flank = 0.05},
    inferno = {flank = 0.05},
    fire = {flank = 0.05},
    wasp = {raider = 0.1},
    spawner = {feint = 0.1},
    poison = {pincer = 0.05},
    arachnids = {ambush = 0.1}
}
local SAPPER_FACTIONS = {suicide = true, nuclear = true, physical = true, troll = true, juggernaut = true}

local STATE_TACTIC_BONUS = {
    [AI_STATE_RAIDING] = {raider = 0.1, sabotage = 0.1},
    [AI_STATE_SIEGE] = {flank = 0.05, probe = 0.05},
    [AI_STATE_ONSLAUGHT] = {assault = 0.1, pincer = 0.1},
}

local tacticNames = {}
local tacticScores = {}
local function addCandidate(count, name, score)
    count = count + 1
    tacticNames[count] = name
    tacticScores[count] = score
    return count
end

-- tactic for a new attack squad from the chunk, or nil (old behaviour)
function aiBrain.chooseTactic(map, chunk, tick, expectedWave)
    local universe = map.universe
    if not brainActive(universe) then
        return nil
    end
    local ai = getMapAI(map)
    local ox = chunk.x + 16
    local oy = chunk.y + 16
    local base = map.chunkToBase and map.chunkToBase[chunk]
    local alignment = base and base.alignment
    local bigEnough = expectedWave or 0
    local count = 0
    count = addCandidate(count, "assault", 0)
    count = addCandidate(count, "flank", 0)
    local reserve = map.points >= (map.finalSquadCost * 1.5)
    if reserve and bigEnough >= TACTICS.probe.minWave then
        count = addCandidate(count, "probe", 0)
        count = addCandidate(count, "feint", 0)
    end
    if #ai.weak > 0 and aiBrain.pickWeakTarget(map, ox, oy) then
        count = addCandidate(count, "raider", 0)
    end
    if alignment then
        local sapperShare = 0
        for faction, rate in pairs(alignment) do
            if SAPPER_FACTIONS[faction] then
                sapperShare = sapperShare + rate
            end
        end
        if (sapperShare >= 0.2) and (#ai.strong > 0) and aiBrain.pickStrongTarget(map, ox, oy) then
            count = addCandidate(count, "sapper", 0)
        end
    end
    if pickArtillery(ai, ox, oy, tick) then
        count = addCandidate(count, "counterBattery", 0.25)
    end
    if aiBrain.heavy and heavyActive(universe) then
        count = aiBrain.heavy.addTacticCandidates(map, ai, chunk, tick, bigEnough, reserve, addCandidate, count)
    end
    -- scores: learned value + leanings + optimism for the untried
    local stateBonus = STATE_TACTIC_BONUS[map.state]
    for i = 1, count do
        local name = tacticNames[i]
        local value, samples = valueOf(ai.tactics, name, tick)
        local score = value + tacticScores[i]
        if samples < 2 then
            score = score + 0.15
        end
        if stateBonus and stateBonus[name] then
            score = score + stateBonus[name]
        end
        if alignment then
            for faction, rate in pairs(alignment) do
                local bonus = FACTION_TACTIC_BONUS[faction]
                if bonus and bonus[name] then
                    score = score + bonus[name] * rate
                end
            end
        end
        tacticScores[i] = score
    end
    local exploring = ai.exploreUntil > tick
    return softmaxPick(tacticNames, tacticScores, count, exploring and 0.3 or 0.15, exploring and 0.15 or 0.06)
end

-- goal for a squad: approach waypoint or target, nil when nothing suits
local function makeGoal(map, squad, chunk, spec, plan, tick)
    local ai = getMapAI(map)
    local ox = chunk.x + 16
    local oy = chunk.y + 16
    local mode = (plan and plan.approach) or spec.approach
    if mode == "pincer" then
        return nil     -- set by HeavyTactics for the whole wave
    end
    if mode then
        local goal, sector = aiBrain.pickApproach(map, chunk, mode, plan and plan.refSector, plan and plan.excludeSector)
        if goal then
            goal.kind = "approach"
            goal.reach = 48
            squad.goalSector = sector
            return goal
        end
        return nil
    end
    local target = spec.target
    if target == "weak" then
        local entry = aiBrain.pickWeakTarget(map, ox, oy)
        if entry then
            return {x = entry.chunk.x + 16, y = entry.chunk.y + 16, kind = "strike", reach = 40}
        end
    elseif target == "strong" then
        local entry = aiBrain.pickStrongTarget(map, ox, oy)
        if entry then
            return {x = entry.chunk.x + 16, y = entry.chunk.y + 16, kind = "strike", reach = 48}
        end
    elseif target == "artillery" then
        local entry = pickArtillery(ai, ox, oy, tick)
        if entry then
            return {x = entry.x, y = entry.y, kind = "strike", reach = 32}
        end
    elseif aiBrain.heavy and heavyActive(map.universe) then
        return aiBrain.heavy.makeGoal(map, ai, squad, chunk, target, tick)
    end
    return nil
end

-- Sets the doctrine of a freshly formed attack squad. spec = TACTICS[tactic] or its stage1.
-- plan: follow-up data (approach mode, reference sector). Returns false if the tactic found no goal.
function aiBrain.prepareSquad(map, squad, chunk, tactic, spec, plan, tick)
    local ai = getMapAI(map)
    squad.learn = true
    squad.tactic = tactic
    squad.support = spec.support
    squad.noise = spec.noise
    squad.retreatAt = spec.retreatAt
    squad.aiState = map.state
    squad.originX = chunk.x + 16
    squad.originY = chunk.y + 16
    squad.losses = squad.losses or 0
    local goal = makeGoal(map, squad, chunk, spec, plan, tick)
    if goal then
        goal.untilTick = tick + 5 * 3600
        goal.dash = spec.dash
        squad.goal = goal
    end
    ai.lastTactic = tactic
    local needsGoal = spec.target or (spec.approach and (spec.approach ~= "pincer"))
    if needsGoal and not goal then
        if not spec.support then
            -- nothing to go to: plain assault (probes and feints just attack along the scent)
            squad.tactic = "assault"
            squad.noise = TACTICS.assault.noise
            squad.retreatAt = TACTICS.assault.retreatAt
        end
        return false
    end
    return true
end

function aiBrain.describeSquad(map, squad, label, size, position)
    if map.universe.printAIStateChanges then
        local goal = squad.goal
        local text = (label or "squad") .. " " .. tostring(squad.tactic) .. (squad.support and " (support)" or "")
            .. ", " .. tostring(size) .. " units"
        if goal then
            text = text .. ", " .. goal.kind .. " [gps=" .. mFloor(goal.x) .. "," .. mFloor(goal.y) .. "," .. map.surface.name .. "]"
        end
        if position then
            text = text .. " from [gps=" .. mFloor(position.x) .. "," .. mFloor(position.y) .. "," .. map.surface.name .. "]"
        end
        debugPrint(map, text)
    end
end

----------------------------------------------------------------------------------------------------------------------
-- follow-up strikes of two-stage tactics

function aiBrain.scheduleFollowUp(map, chunk, tactic, tick, plan)
    local ai = getMapAI(map)
    local spec = TACTICS[tactic]
    local followUp = spec and spec.followUp
    if not followUp then
        return
    end
    if #ai.followUps >= 6 then
        return
    end
    plan = plan or {}
    plan.chunk = chunk
    plan.tactic = tactic
    plan.tick = tick + followUp.delayMin + mFloor(mRandom() * (followUp.delayMax - followUp.delayMin))
    plan.expires = plan.tick + 4 * 3600
    ai.followUps[#ai.followUps + 1] = plan
end

-- removes and returns the first due follow-up (drops expired or dead ones)
function aiBrain.popDueFollowUp(map, tick)
    local ai = map.ai
    if not ai then
        return nil
    end
    local list = ai.followUps
    local i = 1
    while i <= #list do
        local plan = list[i]
        if (plan.expires < tick) or (not chunkIsLive(map, plan.chunk)) then
            table.remove(list, i)
        elseif plan.tick <= tick then
            table.remove(list, i)
            return plan
        else
            i = i + 1
        end
    end
    return nil
end

----------------------------------------------------------------------------------------------------------------------
-- squad events

-- a unit of the squad was killed by the player; returns true if the squad should retreat now
function aiBrain.onSquadUnitLost(map, squad, entity)
    squad.losses = (squad.losses or 0) + 1
    if not squad.engageX then
        local position = entity.position
        squad.engageX = position.x
        squad.engageY = position.y
    end
    local retreatAt = squad.retreatAt
    local size = squad.startSize
    if retreatAt and size and (size >= 6) and (not squad.retreated) and (not squad.kamikaze) and (not squad.rabid)
        and (squad.losses >= size * retreatAt) then
        return true
    end
    return false
end

-- the squad destroyed a player entity (kills are counted by the caller)
function aiBrain.onSquadKill(squad, entity)
    if not squad.engageX then
        local position = entity.position
        squad.engageX = position.x
        squad.engageY = position.y
    end
end

-- learning from a finished squad (disbanded, wiped out or merged)
function aiBrain.onSquadEnd(map, squad, tick)
    if squad.flight then
        if aiBrain.flyers then
            aiBrain.flyers.onFlightEnd(map, squad, tick)
        end
        return
    end
    if not squad.learn then
        return
    end
    squad.learn = nil
    local kills = squad.kills or 0
    local losses = squad.losses or 0
    if (kills == 0) and (losses == 0) and (not squad.engageX) then
        return      -- never met the player: nothing learned
    end
    local size = mMax(1, squad.startSize or 1)
    local reward, lossRatio = squadReward(kills, losses, size)
    local ai = getMapAI(map)
    if squad.engageX and squad.originX then
        updateRegion(getRegion(ai, squad.originX, squad.originY), squad, lossRatio, kills, size)
    end
    if squad.waveId and aiBrain.heavy then
        aiBrain.heavy.onWaveSquadEnd(map, ai, squad)
    end
    ai.outcomes = ai.outcomes + 1
    if squad.support then
        return      -- probes and feints only teach the approach memory
    end
    if squad.tactic then
        updateValue(ai.tactics, squad.tactic, reward, tick)
    end
    if squad.aiState then
        updateValue(ai.states, squad.aiState, reward, tick)
    end
    debugPrint(map, string.format("%s squad ended: %d kills, %d/%d lost, outcome %.2f, %s value %.2f",
        tostring(squad.tactic), kills, losses, size, reward, tostring(squad.tactic),
        (squad.tactic and ai.tactics[squad.tactic] and ai.tactics[squad.tactic].v) or 0))
    if reward < 0.2 then
        ai.failStreak = ai.failStreak + 1
        ai.winStreak = 0
        if ai.failStreak >= 4 then
            ai.failStreak = 0
            ai.exploreUntil = tick + 20 * 3600
            -- rethink: change the AI state soon and try other tactics
            if map.stateTick and (map.stateTick > tick + 3600) then
                map.stateTick = tick + 3600
            end
            debugPrint(map, "losing streak: the AI rethinks its tactics")
        end
    elseif reward > 0.6 then
        ai.winStreak = ai.winStreak + 1
        ai.failStreak = 0
        if ai.winStreak >= 4 then
            ai.winStreak = 0
            ai.pressUntil = tick + 15 * 3600
            debugPrint(map, "winning streak: the AI presses the attack")
        end
    end
end

----------------------------------------------------------------------------------------------------------------------
-- state planner

local stateCandidates = {}
function aiBrain.adjustPlannedState(map, state, ctx, tick)
    if (state ~= AI_STATE_AGGRESSIVE) and (state ~= AI_STATE_RAIDING) and (state ~= AI_STATE_SIEGE)
        and (state ~= AI_STATE_ONSLAUGHT) then
        return state
    end
    local ai = getMapAI(map)
    if (ai.pressUntil > tick) and (state == AI_STATE_AGGRESSIVE) and (mRandom() < 0.35) then
        state = AI_STATE_ONSLAUGHT  -- the planner demotes it if there are too few active nests
    end
    local record = ai.states[state]
    if not record or (record.n < 3) or (record.v >= 0.3) then
        return state
    end
    local count = 0
    stateCandidates[1] = nil
    count = count + 1
    stateCandidates[count] = AI_STATE_AGGRESSIVE
    if ctx.raid then
        count = count + 1
        stateCandidates[count] = AI_STATE_RAIDING
    end
    if ctx.siege then
        count = count + 1
        stateCandidates[count] = AI_STATE_SIEGE
    end
    if ctx.strong then
        count = count + 1
        stateCandidates[count] = AI_STATE_ONSLAUGHT
    end
    local best
    local bestValue = record.v + 0.15
    for i = 1, count do
        local candidate = stateCandidates[i]
        if candidate ~= state then
            local value = valueOf(ai.states, candidate, tick)
            if value > bestValue then
                bestValue = value
                best = candidate
            end
        end
    end
    if best and (mRandom() < 0.5) then
        debugPrint(map, constants.stateEnglish[state] .. " keeps failing (" .. string.format("%.2f", record.v)
            .. "), switching to " .. constants.stateEnglish[best])
        return best
    end
    return state
end

----------------------------------------------------------------------------------------------------------------------
-- report (command /rampantAIReport, remote getAILearning)

function aiBrain.report(map)
    local ai = map.ai
    local tick = game.tick
    if not ai then
        return {"no learning data yet"}
    end
    local lines = {}
    local function records(title, list, names)
        local parts = {}
        for key, record in pairs(list) do
            parts[#parts + 1] = string.format("%s %.2f/%d", (names and names[key]) or tostring(key), record.v, record.n)
        end
        table.sort(parts)
        lines[#lines + 1] = title .. ": " .. ((#parts > 0) and table.concat(parts, ", ") or "-")
    end
    records("tactics (value/samples)", ai.tactics)
    records("states", ai.states, constants.stateEnglish)
    records("flights", ai.flight)
    local damageName, share = dominantDamage(map, nil)
    lines[#lines + 1] = string.format("outcomes %d, last tactic %s, losing streak %d, winning streak %d, rethinking %s, pressing %s",
        ai.outcomes, tostring(ai.lastTactic), ai.failStreak, ai.winStreak, tostring(ai.exploreUntil > tick),
        tostring(ai.pressUntil > tick))
    lines[#lines + 1] = string.format("targets: weak %d, strong %d, infrastructure %d, ambush %d, artillery %d, follow-ups %d; dominant damage %s",
        #ai.weak, #ai.strong, #ai.infra, #ai.heatTop, #ai.artillery, #ai.followUps,
        damageName and (damageName .. " " .. mFloor(share * 100) .. "%") or "-")
    local regions = 0
    for _ in pairs(ai.regions) do
        regions = regions + 1
    end
    lines[#lines + 1] = "approach memory regions: " .. regions
    return lines
end

function aiBrain.learningData(map)
    local ai = map.ai
    if not ai then
        return nil
    end
    local function copy(list)
        local result = {}
        for key, record in pairs(list) do
            result[key] = {value = record.v, samples = record.n}
        end
        return result
    end
    return {
        tactics = copy(ai.tactics),
        states = copy(ai.states),
        flights = copy(ai.flight),
        outcomes = ai.outcomes,
        failStreak = ai.failStreak,
        winStreak = ai.winStreak,
        rethinking = ai.exploreUntil > game.tick,
        pressing = ai.pressUntil > game.tick,
        weakTargets = #ai.weak,
        strongTargets = #ai.strong,
        dominantDamage = dominantDamage(map, nil)
    }
end

aiBrainG = aiBrain
return aiBrain
