-- Optional, bounded doctrine state. Only callers in the new AI mode use it.
local field = {}
local live = require("ChunkQueue").isLive
local getPlayerTurretCount = require("ChunkPropertyUtils").getPlayerTurretCount
local floor, abs = math.floor, math.abs
local constants = require("Constants")
local truceInfo = require("AIPredicates").truceInfo
local frontRegion = require("FrontTargets").region
local CHUNK = constants.CHUNK_SIZE
local EDGE_TTL, BREACH_TTL, RESPITE_TTL = 7200, 10800, 5400

local function event(map, text, tick)
    local report = map.fieldReport or {next = 1, items = {}}
    map.fieldReport = report
    report.items[report.next] = {tick = tick, text = text}
    report.next = report.next % 8 + 1
end

-- Two rings share the same entries: evicting from either cap drops the lookup.
-- Slots in the other ring are then lightweight keys, not stale LuaObjects.
local function lookup(map, name, key)
    local index = map.universe[name]
    local entry = index and index.values[key]
    return entry and entry.map == map and entry or nil
end

local function store(map, name, key, entry, localLimit, globalLimit)
    local index = map.universe[name]
    if not index then
        index = {values = {}, slots = {}, next = 1}
        map.universe[name] = index
    end
    local ring = map[name]
    if not ring then
        ring = {slots = {}, next = 1}
        map[name] = ring
    end
    local function add(r, limit)
        local previous = r.slots[r.next]
        if previous and index.values[previous.key] and index.values[previous.key].slot == previous then
            index.values[previous.key] = nil
        end
        r.slots[r.next] = entry.slot
        r.next = r.next % limit + 1
    end
    entry.map = map
    entry.slot = {key = key}
    add(ring, localLimit)
    add(index, globalLimit)
    index.values[key] = entry
end

function field.forgetMap(map)
    for _, name in ipairs({"fieldEdges", "fieldTargets", "fieldSources", "frontFailures"}) do
        local index = map.universe[name]
        local ring = map[name]
        if index and ring then
            for _, slot in pairs(ring.slots) do
                local entry = index.values[slot.key]
                if entry and entry.map == map then index.values[slot.key] = nil end
            end
        end
    end
end

local function keyAt(map, chunk)
    return map.surface.index .. ":" .. chunk.x .. ":" .. chunk.y
end

-- A single failed placement can be temporary occupancy. Share a repeated
-- refusal only if the pre-override strip scans already found no straight
-- passage in this cardinal direction. This is a soft cost, not a proof that
-- all routes through the two chunks are blocked.
local function corroborated(a, b)
    local rawA, rawB = a.terrainPass, b.terrainPass
    if not rawA or not rawB then return false end
    local required
    if a.x == b.x and abs(a.y - b.y) == CHUNK then
        required = constants.CHUNK_NORTH_SOUTH
    elseif a.y == b.y and abs(a.x - b.x) == CHUNK then
        required = constants.CHUNK_EAST_WEST
    else
        return false
    end
    local all = constants.CHUNK_ALL_DIRECTIONS
    return (rawA ~= all and rawA ~= required) or (rawB ~= all and rawB ~= required)
end

local function edge(map, a, b)
    return keyAt(map, a) .. ":" .. b.x .. ":" .. b.y .. ":"
end

local function sameEdge(e, a, b, tick)
    return e and e.a == a and e.b == b and e.untilTick > tick
        and e.aRevision == a.passRevision and e.bRevision == b.passRevision
end

function field.edgeRefused(map, squad, a, b, tick)
    if not (live(map, a) and live(map, b)) then return end
    local shared = corroborated(a, b)
    local key = edge(map, a, b) .. (shared and "terrain" or squad.groupNumber)
    local e = lookup(map, "fieldEdges", key)
    if not sameEdge(e, a, b, tick) then
        e = {a = a, b = b, aRevision = a.passRevision, bRevision = b.passRevision, count = 0}
        store(map, "fieldEdges", key, e, 32, 256)
    end
    if e.count == 1 then
        event(map, shared and "Скан не нашёл прямого прохода: отряды ищут обход"
            or "Повторный отказ на переходе: отряд ищет обход", tick)
    end
    e.count = e.count + 1
    e.untilTick = tick + EDGE_TTL
end

function field.edgeScore(map, squad, a, b, score, tick)
    if a == -1 or b == -1 or not map.fieldEdges then return score end
    local prefix = edge(map, a, b)
    local e = corroborated(a, b) and lookup(map, "fieldEdges", prefix .. "terrain")
    if not (sameEdge(e, a, b, tick) and e.count >= 2) then
        e = lookup(map, "fieldEdges", prefix .. squad.groupNumber)
    end
    if sameEdge(e, a, b, tick) and e.count >= 2 then return score - (abs(score) * 0.65 + 1) end
    return score
end

local infrastructure = {
    ["electric-pole"] = 1, radar = 2, ["train-stop"] = 2,
    ["solar-panel"] = 1, accumulator = 1, ["assembling-machine"] = 1, ["mining-drill"] = 1,
    ["roboport"] = 3
}

local function hostile(map, entity)
    local universe = map.universe
    return universe.activePlayerForceSet and universe.activePlayerForceSet[entity.force.name]
end

function field.observe(map, entity)
    local weight = infrastructure[entity.type]
    if not (weight and entity.valid and entity.unit_number and entity.destructible and hostile(map, entity)) then return end
    local key = entity.unit_number
    if lookup(map, "fieldTargets", key) then return end
    store(map, "fieldTargets", key, {entity = entity, weight = weight}, 16, 128)
end

function field.validObjective(map, target)
    return target and target.valid and target.surface == map.surface and target.destructible and hostile(map, target)
end

function field.objective(map, targetChunk, tick)
    local old = map.objectiveRaid
    if old then
        if old.untilTick >= tick and not old.done and field.validObjective(map, old.entity) then return nil end
        field.closeObjective(map, old, false, tick)
    end
    local ring = map.fieldTargets
    if not ring then return nil end
    local best
    for i = 1, #ring.slots do
        local e = lookup(map, "fieldTargets", ring.slots[i].key)
        if e and e.slot == ring.slots[i] and field.validObjective(map, e.entity) then
            local p = e.entity.position
            if floor(p.x / CHUNK) * CHUNK == targetChunk.x and floor(p.y / CHUNK) * CHUNK == targetChunk.y
                    and (not best or e.weight > best.weight) then
                best = e
            end
        end
    end
    if best then
        local p = best.entity.position
        local goal = {x = p.x, y = p.y, entity = best.entity, unit = best.entity.unit_number,
            kind = "objective", targetChunk = targetChunk, reach = 40, untilTick = tick + 7200}
        map.objectiveRaid = goal
        return goal
    end
end

function field.closeObjective(map, goal, success, tick)
    if goal.done then return end
    goal.done = true
    if map.objectiveRaid == goal then map.objectiveRaid = nil end
end

function field.modeCurrent(map, squad)
    local u = map.universe
    return not u.classicAI and (squad.doctrineEpoch or 0) == (u.doctrineEpoch or 0)
end

function field.note(map, key, tick)
    event(map, {"rampant-fronts." .. key}, tick)
end

local function failureKey(map, x, y, chunk, flight)
    return keyAt(map, chunk) .. ":" .. frontRegion(x, y) .. (flight and ":air" or ":ground")
end

function field.frontPenalty(map, x, y, chunk, flight, defence, tick)
    if not map.frontFailures then return 1 end
    local entry = lookup(map, "frontFailures", failureKey(map, x, y, chunk, flight))
    if entry and entry.chunk == chunk and entry.revision == chunk.passRevision and entry.defence == defence
            and entry.defenceRevision == chunk.frontDefenceRevision and entry.epoch == map.universe.frontRevision and tick < entry.untilTick then
        return entry.count >= 2 and 0.4 or 0.8
    end
    return 1
end

function field.beginRaid(map, squad, goal, tick)
    if not (goal and goal.targetChunk) or not field.modeCurrent(map, squad) then return end
    if squad.localRaid and squad.localRaid.goal == goal then return end
    field.finishRaid(map, squad, "unconfirmed", tick)
    goal.issued = true
    squad.localRaid = {goal = goal, group = squad.groupNumber, flight = squad.flight == true}
    field.note(map, squad.flight and "air-issued" or "ground-issued", tick)
end

function field.finishRaid(map, squad, outcome, tick)
    local raid = squad.localRaid
    if not raid then return end
    squad.localRaid = nil
    local goal = raid.goal
    if goal.kind == "objective" then field.closeObjective(map, goal, outcome == "success", tick) end
    if not field.modeCurrent(map, squad) then return end
    if outcome == "unconfirmed" and raid.hit then outcome = "area-contact" end
    field.note(map, outcome, tick)
    local c = goal.targetChunk
    local origin = goal.origin or squad.originPosition
    if outcome ~= "repelled" or not origin or not live(map, c) or goal.defence == nil
            or goal.revision ~= c.passRevision or goal.defenceRevision ~= c.frontDefenceRevision
            or goal.epoch ~= map.universe.frontRevision then return end
    local key = failureKey(map, origin.x, origin.y, c, raid.flight)
    local entry = lookup(map, "frontFailures", key)
    if not entry or entry.chunk ~= c or entry.revision ~= goal.revision or entry.defence ~= goal.defence
            or entry.defenceRevision ~= goal.defenceRevision or entry.epoch ~= goal.epoch or entry.untilTick <= tick then
        entry = {chunk = c, defence = goal.defence, defenceRevision = goal.defenceRevision,
            revision = goal.revision, epoch = goal.epoch, count = 0}
        store(map, "frontFailures", key, entry, 32, 256)
    end
    if entry.group ~= raid.group then
        entry.group, entry.count = raid.group, math.min(2, entry.count + 1)
        entry.untilTick = tick + 5400
    end
end

function field.recordRaidLoss(map, squad, threshold, tick)
    local raid = squad.localRaid
    if not raid or not field.modeCurrent(map, squad) then return end
    raid.hostileLosses = (raid.hostileLosses or 0) + 1
    if threshold and raid.hostileLosses >= threshold then
        field.finishRaid(map, squad, "repelled", tick)
    end
end

function field.confirmObjective(map, squad, entity, tick)
    local raid = squad.localRaid
    local goal = raid and raid.goal
    if not goal or not field.modeCurrent(map, squad) then return end
    if goal.kind == "objective" then
        if not goal.done and goal.untilTick >= tick and goal.unit == entity.unit_number and goal.entity == entity then
            goal.confirmed = true
            field.finishRaid(map, squad, "success", tick)
        end
    else
        local p, c = entity.position, goal.targetChunk
        if floor(p.x / CHUNK) * CHUNK == c.x and floor(p.y / CHUNK) * CHUNK == c.y then raid.hit = true end
    end
end

function field.cancelBreach(map, tick)
    local breach = map.fieldBreach
    if breach then
        map.fieldBreach = nil
        if breach.ready then event(map, "Повторный удар отменён: перемирие", tick) end
    end
end

function field.breachTruce(map, tick)
    return map.surface.peaceful_mode or map.state == constants.AI_STATE_PEACEFUL or truceInfo(map, tick)
end

function field.syncTruce(map, tick, closed)
    if closed == nil then closed = field.breachTruce(map, tick) end
    if not closed then map.pendingTruce = nil; return end
    if not map.pendingTruce then
        map.pendingTruce = true
        map.orderEpoch = (map.orderEpoch or 0) + 1
        if map.objectiveRaid and not map.objectiveRaid.issued then
            field.closeObjective(map, map.objectiveRaid, false, tick)
        end
        if map.ai then map.ai.followUps, map.ai.waves = {}, {} end
    end
    field.cancelBreach(map, tick)
end

-- Two distinct ordinary squads must each prove a local success. Counting the
-- same group's kills twice would turn an isolated skirmish into a campaign.
function field.recordBreach(map, squad, chunk, tick)
    if squad.flight or squad.external or squad.support or squad.fieldBreach or squad.fieldOutcome
            or not squad.learn or not live(map, chunk) then return end
    if field.breachTruce(map, tick) then
        field.cancelBreach(map, tick)
        return
    end
    if squad.breachKillChunk ~= chunk then
        squad.breachKillChunk, squad.breachLocalKills = chunk, 0
    end
    squad.breachLocalKills = (squad.breachLocalKills or 0) + 1
    if squad.breachLocalKills < 2 or not map.chunkToPlayerBase[chunk] or getPlayerTurretCount(map, chunk) > 1
            or (squad.losses or 0) > (squad.startSize or 0) * 0.3 then return end
    local old = map.fieldBreach
    if old and (old.untilTick < tick or not live(map, old.chunk)) then old = nil end
    if not old then
        squad.fieldOutcome = true
        map.fieldBreach = {chunk = chunk, source = squad.groupNumber, untilTick = tick + BREACH_TTL}
    elseif not old.ready and old.source ~= squad.groupNumber and abs(old.chunk.x - chunk.x) <= CHUNK
            and abs(old.chunk.y - chunk.y) <= CHUNK then
        squad.fieldOutcome = true
        old.ready = true
        event(map, "Два отряда подтвердили брешь: следующий удар может её использовать", tick)
    end
end

function field.breachFor(map, source, tick)
    local e = map.fieldBreach
    if not e then return end
    if field.breachTruce(map, tick) then
        field.cancelBreach(map, tick)
        return
    end
    local target = e.chunk
    if e.untilTick < tick or not live(map, target) or not map.chunkToPlayerBase[target] or getPlayerTurretCount(map, target) > 1 then
        map.fieldBreach = nil
        if e.ready then event(map, "Повторный удар отменён: брешь закрыта или срок истёк", tick) end
        return
    end
    if e.ready and abs(source.x - target.x) <= 26 * CHUNK and abs(source.y - target.y) <= 26 * CHUNK then
        return target
    end
end

function field.useBreach(map, squad, target, tick)
    squad.fieldBreach = true
    squad.goal = {x = target.x + 16, y = target.y + 16, kind = "strike", reach = 40,
        fieldChunk = target, untilTick = map.fieldBreach.untilTick}
    map.fieldBreach = nil
    event(map, "Штатный отряд направлен в подтверждённую брешь", tick)
end

function field.strikeStillUseful(map, chunk)
    return live(map, chunk) and map.chunkToPlayerBase[chunk] and getPlayerTurretCount(map, chunk) <= 1
end

-- Bases are persistent identities, not proximity guesses. Where Rampant has
-- no base record (e.g. an unowned nest), keep the exact source chunk as before.
local function sourceIdentity(map, chunk)
    local base = map.chunkToBase and map.chunkToBase[chunk]
    if base and base.id then return map.surface.index .. ":base:" .. base.id, base end
    return keyAt(map, chunk), chunk
end

local function findSource(map, chunk)
    local key, identity = sourceIdentity(map, chunk)
    local entry = lookup(map, "fieldSources", key)
    if entry and (not entry.identity or entry.identity == identity) then return entry, key, identity end
    return nil, key, identity
end

function field.launch(map, chunk, tick)
    if not live(map, chunk) then return end
    local e, key, identity = findSource(map, chunk)
    if not e then
        e = {count = 0, since = tick, identity = identity}
        store(map, "fieldSources", key, e, 32, 256)
    end
    if tick - e.since > 18000 then e.count, e.since = 0, tick end
    e.count = e.count + 1
end

function field.loseNest(map, chunk, tick)
    if not live(map, chunk) then return end
    local e = findSource(map, chunk)
    if e and e.count >= 3 and tick - e.since <= 18000 then
        e.count, e.since, e.untilTick = 0, tick, tick + RESPITE_TTL
        event(map, "Потеря гнезда на активной базе: локальная передышка", tick)
    end
end

function field.held(map, chunk, tick)
    if not map.fieldSources or not live(map, chunk) then return false end
    local e = findSource(map, chunk)
    return e and e.untilTick and tick < e.untilTick
end

function field.report(map, lines)
    local report = map.fieldReport
    if not report then return end
    for i = 0, 7 do
        local e = report.items[(report.next + i - 1) % 8 + 1]
        if e then lines[#lines + 1] = {"", "[Rampant · " .. e.tick .. "] ", e.text} end
    end
end

return field
