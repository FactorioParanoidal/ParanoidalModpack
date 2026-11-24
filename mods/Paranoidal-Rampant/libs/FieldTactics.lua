-- Optional, bounded doctrine state. Only callers in the new AI mode use it.
local field = {}
local colony = require("ColonyMind")
local funnel = require("ColonyFunnel")
local route = require("ColonyRoute")
field.colony = colony
local live = require("ChunkQueue").isLive
local getPlayerTurretCount = require("ChunkPropertyUtils").getPlayerTurretCount
local floor, abs = math.floor, math.abs
local constants = require("Constants")
local gates = require("AIPredicates")
local truceInfo = gates.truceInfo
local frontRegion = require("FrontTargets").region
local CHUNK = constants.CHUNK_SIZE
local EDGE_TTL, BREACH_TTL, RESPITE_TTL = 7200, 10800, 5400

local function event(map, text, tick)
    local report = map.fieldReport or {next = 1, items = {}}
    map.fieldReport = report
    local slot, row = report.next, {tick = tick, text = text}
    report.items[slot] = row
    report.next = slot % 8 + 1
    return row, slot
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
    -- An incidental colony-only sighting can use spare space, never evict
    -- an ordinary observation or advance either ordinary replacement cursor.
    local function slot(r, limit)
        if not entry.scanOnly then return r.next end
        if #r.slots < limit then return #r.slots + 1 end
        local p = r.slots[r.next]
        local v = index.values[p.key]
        if not v or v.slot ~= p or v.scanOnly then return r.next end
    end
    local a,b = slot(ring,localLimit),slot(index,globalLimit)
    if not a or not b then return false end
    local function add(r, limit, pos)
        local previous = r.slots[pos]
        if previous and index.values[previous.key] and index.values[previous.key].slot == previous then
            index.values[previous.key] = nil
        end
        r.slots[pos] = entry.slot
        if not entry.scanOnly then r.next = pos % limit + 1 end
    end
    entry.map = map
    entry.slot = {key = key}
    add(ring, localLimit, a)
    add(index, globalLimit, b)
    index.values[key] = entry
    return true
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

local reserveKinds = {"assembling-machine", "mining-drill", "radar", "roboport"}
field.reserveKinds = reserveKinds
local reserveTypes = {}
for _,kind in ipairs(reserveKinds) do reserveTypes[kind]=true end

function field.observe(map, entity, buildNotice, scanOnly)
    local weight = infrastructure[entity.type]
    if not (weight and entity.valid and entity.unit_number and entity.destructible and hostile(map, entity)) then return end
    local key = entity.unit_number
    local e = lookup(map, "fieldTargets", key)
    if not e or (e.scanOnly and not scanOnly) then
        -- Promote at the exact slots an ordinary first observation would use.
        e = e or {entity = entity, weight = weight}
        e.scanOnly = scanOnly
        if not store(map, "fieldTargets", key, e, 16, 128) then return end
    end
    -- A construction event alone need not have been observed. Only the
    -- existing chunk scan's actual sample dates it for the colony.
    if map.universe.colonyMind and not buildNotice then
        local p = entity.position
        e.seen, e.epoch, e.force, e.x, e.y = game.tick, map.universe.frontRevision, entity.force.name, p.x, p.y
    end
end

function field.validObjective(map, target)
    return target and target.valid and target.surface == map.surface and target.destructible and hostile(map, target)
end

-- Read-only projection of the existing 16-entry observation ring. Legacy
-- entries without a dated observation are not advance intelligence.
local function usable(map,e,force,tick)
    if not e or not e.seen or tick-e.seen > 7200 or e.epoch ~= map.universe.frontRevision or e.force ~= force then return end
    local entity = e.entity
    if not field.validObjective(map,entity) or entity.force.name ~= force or not reserveTypes[entity.type]
        or (map.universe.safeBuildings and (not field.isProtected or field.isProtected(entity))) then return end
    local p = entity.position
    if e.x~=p.x or e.y~=p.y then return end -- a moved building has not been seen here
    local col = map[floor(p.x/CHUNK)*CHUNK]; local c = col and col[floor(p.y/CHUNK)*CHUNK]
    if c and map.chunkToPlayerBase[c] then return c end
end

-- Never treat a build notification as a sighting. This is at most one
-- type-filtered sample in the chunk being scored, after the regular counts.
-- More than four matches: keep just the ordinary sample, not an arbitrary prefix.
function field.sampleChunk(map,chunk,first,possible)
    if possible==0 or (possible==1 and reserveTypes[first.type]) then return end
    local query=map.universe.hasPlayerStructuresQuery
    local list=map.surface.find_entities_filtered{area=query.area,force=query.force,type=reserveKinds,limit=5}
    if #list>4 then return end
    table.sort(list,function(a,b) return (a.unit_number or 0)<(b.unit_number or 0) end)
    for _,e in ipairs(list) do
        if e~=first and e.valid and e.unit_number and e.surface==map.surface then
            local p=e.position
            if floor(p.x/CHUNK)*CHUNK==chunk.x and floor(p.y/CHUNK)*CHUNK==chunk.y
                and (not map.universe.safeBuildings or (field.isProtected and not field.isProtected(e))) then
                field.observe(map,e,false,true)
            end
        end
    end
end

-- Local ranking hint only; the future executor hasn't been recruited here.
-- At most three cached, collinear edges from the reported contact. No tile
-- query, path search or claim that a not-yet-confirmed site is unreachable.
local function localAccess(map,front,c)
    if c.terrainPass==constants.CHUNK_IMPASSABLE then return 0 end
    if not c.terrainPass then return 1 end
    local x,y=floor(front.x/CHUNK)*CHUNK,floor(front.y/CHUNK)*CHUNK
    if x~=c.x and y~=c.y then return 1 end
    local dx=c.x==x and 0 or c.x>x and CHUNK or -CHUNK
    local dy=c.y==y and 0 or c.y>y and CHUNK or -CHUNK
    local key=dx==0 and 'colonyCol' or 'colonyRow'
    while x~=c.x or y~=c.y do
        local a=map[x] and map[x][y];x,y=x+dx,y+dy
        local b=map[x] and map[x][y]
        if not a or not a[key] or not b or a[key]~=b[key] then return 1 end
    end
    return 2
end

-- Disjoint front circles, one pass over the same 16 slots even with two choices.
function field.peekReserve(map,front,tick,brain,other)
    local best, alternative, bestChunk, altChunk, bestRank, altRank
    for _,slot in ipairs(map.fieldTargets.slots) do
        local e = lookup(map,"fieldTargets",slot.key)
        local c = e and e.slot == slot and usable(map,e,front.force,tick)
        if c then
            local primary = (e.x-front.x)^2+(e.y-front.y)^2 <= 96^2
            if primary or (other and (e.x-other.x)^2+(e.y-other.y)^2 <= 96^2) then
                if brain.turretsAround(map,c)<=2 then
                    local f,old,previous,rank=front,best,bestChunk,bestRank
                    if not primary then f,old,previous,rank=other,alternative,altChunk,altRank end
                    local value
                    if old then
                        rank=rank or localAccess(map,f,previous)
                        value=c==previous and rank or localAccess(map,f,c)
                    end
                    if not old or value>rank or (value==rank and (e.weight>old.weight or (e.weight==old.weight and slot.key<old.slot.key))) then
                        old,previous,rank=e,c,value
                    end
                    if primary then best,bestChunk,bestRank=old,previous,rank else alternative,altChunk,altRank=old,previous,rank end
                end
            end
        end
    end
    return best, alternative
end

function field.resolveReserve(map,r,tick)
    local e = lookup(map,"fieldTargets",r.unit)
    local c = usable(map,e,r.force,tick)
    if c then
        local p=e.entity.position
        if p.x==r.x and p.y==r.y then return e,c end
    end
end

-- A conservative corridor through known terrain, not a pathfinder. Check
-- at most 40 cardinal edges just once per nominated group. An unscanned
-- gap or a detour we cannot confirm is a reason to keep the ordinary job.
function field.groundApproach(map,p,target,probe)
    local x,y=floor(p.x/CHUNK)*CHUNK,floor(p.y/CHUNK)*CHUNK
    local dx,dy=target.x-x,target.y-y
    if abs(dx)+abs(dy)>40*CHUNK then return false end
    probe=probe or route.connected
    local function step(horizontal)
        local sx,sy,axis
        if horizontal then sx,sy,axis=dx>0 and CHUNK or -CHUNK,0,constants.CHUNK_EAST_WEST
        else sx,sy,axis=0,dy>0 and CHUNK or -CHUNK,constants.CHUNK_NORTH_SOUTH end
        local nx,ny=x+sx,y+sy
        local ok=probe(map,map[x] and map[x][y],map[nx] and map[nx][ny],axis)
        if ok then x,y,dx,dy=nx,ny,dx-sx,dy-sy end
        return ok
    end
    while dx~=0 or dy~=0 do
        local horizontal=abs(dx)>=abs(dy) -- original tie: X first
        local ok=step(horizontal)
        if ok==false and dx~=0 and dy~=0 then ok=step(not horizontal) end
        if not ok then return ok end -- false: blocked; nil: budget exhausted
    end
    return target.terrainPass~=nil and target.terrainPass~=constants.CHUNK_IMPASSABLE
end

function field.colonyTargetLive(map,g)
    local e=g.entity
    return field.validObjective(map,e) and e.force.name==g.colonyRecord.force and e.position.x==g.x and e.position.y==g.y
        and (not map.universe.safeBuildings or (field.isProtected and not field.isProtected(e))) and live(map,g.targetChunk)
end

function field.lockAvailable(map,tick)
    local old=map.objectiveRaid
    return not old or old.done or old.untilTick<tick or not field.validObjective(map,old.entity)
end

function field.claimObjective(map,entity,chunk,tick)
    if not field.lockAvailable(map,tick) then return end
    if map.objectiveRaid then field.closeObjective(map,map.objectiveRaid,false,tick) end
    local p=entity.position
    local goal={x=p.x,y=p.y,entity=entity,unit=entity.unit_number,kind="objective",targetChunk=chunk,reach=40,untilTick=tick+7200}
    map.objectiveRaid=goal
    return goal
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
        if e and not e.scanOnly and e.slot == ring.slots[i] and field.validObjective(map, e.entity) then
            local p = e.entity.position
            if floor(p.x / CHUNK) * CHUNK == targetChunk.x and floor(p.y / CHUNK) * CHUNK == targetChunk.y
                    and (not best or e.weight > best.weight) then
                best = e
            end
        end
    end
    if best then
        return field.claimObjective(map,best.entity,targetChunk,tick)
    end
end

-- Annotate the existing eight-event journal, not a second history. The marker
-- contains no group/entity references. A reused slot must never inherit updates.
function field.identifyRaid(map, squad, goal, row, slot)
    if not (map.universe.colonyMind and squad.tactic == 'raider' and not squad.external and not squad.flight
        and squad.groupNumber and (squad.formationCost or 0) > 0 and map.fieldReport.items[slot] == row) then return end
    local c = goal.targetChunk
    local mark = {group = squad.groupNumber, tick = row.tick, unit = goal.unit, x = c.x, y = c.y,
        epoch = map.universe.colonyEpoch, slot = slot}
    row.raid, goal.journalRaid = mark, mark
end

local function raidMark(map, squad, goal)
    local mark = goal and goal.journalRaid
    if mark and map.universe.colonyMind and mark.epoch == map.universe.colonyEpoch
        and (not squad or (squad.groupNumber == mark.group and not squad.external and not squad.flight)) then return mark end
end

function field.raidPhase(map, squad, goal, tick, phase)
    local mark = raidMark(map, squad, goal)
    local row = mark and map.fieldReport and map.fieldReport.items[mark.slot]
    if not row or row.raid ~= mark then return end
    if phase == 'gather' or phase == 'move' then
        if not row.result and not row[phase] then row[phase] = tick end
    elseif not row.result or (row.result == 'closed' and row.at == tick and phase == 'retreat') then
        row.result, row.at = phase, tick
    end
end

function field.closeObjective(map, goal, success, tick, outcome)
    if goal.done then return end
    if goal.journalRaid and not goal.issued then field.raidPhase(map,nil,goal,tick,'closed') end
    if goal.colonyRecord then colony.orders.closed(map,goal,success,tick,outcome,field) end
    goal.done = true
    if map.objectiveRaid == goal then map.objectiveRaid = nil end
end

function field.modeCurrent(map, squad)
    local u = map.universe
    return not u.classicAI and (squad.doctrineEpoch or 0) == (u.doctrineEpoch or 0)
end

function field.note(map, key, tick)
    local row, slot = event(map, {"rampant-fronts." .. key}, tick)
    if map.universe.colonyMind then
        if key == "ground-selected" then funnel.groundSelected(map)
        elseif key == "ground-issued" then funnel.groundIssued(map) end
        return row, slot
    end
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
    if goal.kind == "objective" then squad.objectiveIssued = true end
    squad.localRaid = {goal = goal, group = squad.groupNumber, flight = squad.flight == true}
    local row = field.note(map, squad.flight and "air-issued" or "ground-issued", tick)
    if row and goal.journalRaid then
        row.related = raidMark(map,squad,goal)
        field.raidPhase(map,squad,goal,tick,'issued')
    end
    if goal.colonyRecord then colony.orders.issued(map,squad,goal,tick)
    elseif map.universe.colonyMind then colony.issued(map, squad, goal, tick) end
end

function field.finishRaid(map, squad, outcome, tick)
    local raid = squad.localRaid
    if not raid then return end
    squad.localRaid = nil
    local goal = raid.goal
    if goal.kind == "objective" then field.closeObjective(map, goal, outcome == "success", tick, outcome) end
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

-- A loss inside the chunk is journalled even when it cannot prove defeat
-- of this assignment. Check the force credited by on_entity_died and the
-- actual attack command; a surviving ticket alone does not own a battle.
local function fightingObjective(map, squad, raid, tick, unit, force)
    local g, u = raid.goal, map.universe
    if not g.issued or not g.checked or g ~= squad.goal or g ~= map.objectiveRaid or raid.group ~= squad.groupNumber
        or squad.external or squad.merged or squad.excluded or map.suspended or tick >= g.untilTick
        or g.epoch ~= u.frontRevision or (squad.orderEpoch or 0) ~= (map.orderEpoch or 0)
        or not gates.groundMember(map.surface,squad,unit) or not field.validObjective(map,g.entity)
        or g.entity.force.name ~= force or g.entity.unit_number ~= g.unit then return false end
    if g.colonyRecord then
        if not g.colonyRecord.issued or not colony.orders.owner(map,squad,g,tick) or not field.colonyTargetLive(map,g) then return false end
    elseif not gates.attackAllowed(map,tick) or not live(map,g.targetChunk) or g.x ~= g.entity.position.x or g.y ~= g.entity.position.y
        or (u.safeBuildings and (not field.isProtected or field.isProtected(g.entity))) then return false end
    local cmd = squad.group.command
    return cmd and cmd.type == defines.command.attack and cmd.target == g.entity
end

function field.recordRaidLoss(map, squad, threshold, tick, position, unit, force, brain)
    local raid = squad.localRaid
    local goal = raid and raid.goal or squad.goal
    local c = goal and goal.targetChunk
    if not c or not position or goal.done or not field.modeCurrent(map, squad) then return end
    -- Ground squads approach before the attack order; flights receive their
    -- compound at launch. Only a death inside the assigned chunk can testify
    -- to its defence. The squad-wide retreat counter still counts every loss.
    local r = goal.colonyRecord
    if r and r.group ~= squad.groupNumber then return end
    if r and not r.crew then r = nil end -- legacy ticket: no partial casualty breakdown
    local exactGround = raid and not raid.flight and goal.kind == "objective"
    if exactGround and unit and unit.valid then
        local pack = map.universe.compressedUnits[unit.unit_number]
        if pack and pack.count > 1 then raid.packLoss = true end -- survivors can reappear after the carrier dies
    end
    if floor(position.x / CHUNK) * CHUNK ~= c.x or floor(position.y / CHUNK) * CHUNK ~= c.y then
        if brain and unit and map.universe.colonyMind then route.loss(map,squad,goal,tick,position,unit,force,brain) end
        if r then r.routeLosses = r.routeLosses + 1 end
        if not goal.routeLossReported then
            goal.routeLossReported = true
            local row = event(map, {"rampant-colony.route-loss"}, tick)
            if goal.journalRaid then row.related = raidMark(map,squad,goal) end
        end
        return
    end
    if not raid then return end
    raid.targetLosses = (raid.targetLosses or 0) + 1
    if r and r.issued then r.targetLosses = raid.targetLosses end
    if not exactGround then
        if threshold and raid.targetLosses >= threshold then field.finishRaid(map, squad, "repelled", tick) end
        return
    end
    if not fightingObjective(map,squad,raid,tick,unit,force) then return end
    local n = (raid.defenderLosses or 0) + 1 -- never backfill from the old raw count
    raid.defenderLosses = n
    local size = squad.startSize
    if size and size > 0 and not raid.packLoss and n >= size and n >= (raid.nextWipeCheck or 0) then
        -- Only a possible wipe reads the member list. Inside the death
        -- callback the final unit must still be the group's sole member.
        local members = squad.group.members
        if #members == 1 and members[1] == unit then
            field.finishRaid(map, squad, "repelled", tick)
            return
        end
        raid.nextWipeCheck = n + math.max(1, #members - 1)
    end
    if threshold and n >= threshold then return raid end -- for a retreat that actually takes place

end

function field.confirmObjective(map, squad, entity, tick, credit, position)
    local raid = squad.localRaid
    local goal = raid and raid.goal
    if not goal or not field.modeCurrent(map, squad) then return end
    if goal.colonyRecord and (not colony.orders.owner(map,squad,goal,tick) or not field.colonyTargetLive(map,goal)) then return end
    local p, c = position or entity.position, goal.targetChunk
    local localHit = p and floor(p.x / CHUNK) * CHUNK == c.x and floor(p.y / CHUNK) * CHUNK == c.y
    local legs = raid.flight and squad.flightResults
    local leg = legs and legs[#legs]
    if localHit and leg then
        leg.kills = leg.kills + 1
        leg.credit = leg.credit + (credit or 1)
    end
    if goal.kind == "objective" then
        if not goal.done and goal.untilTick >= tick and goal.unit == entity.unit_number and goal.entity == entity then
            goal.confirmed = true
            squad.objectiveAchieved = true -- survives withdrawal/lock release for the learning result
            if leg then leg.objective = true end
            field.finishRaid(map, squad, "success", tick)
            return true
        end
    elseif localHit then
        raid.hit = true
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
        if map.colonyShadow then colony.stop(map,tick) end
        map.orderEpoch = (map.orderEpoch or 0) + 1
        if map.objectiveRaid and not map.objectiveRaid.issued then
            field.closeObjective(map, map.objectiveRaid, false, tick)
        end
        if map.ai then map.ai.followUps, map.ai.waves = {}, {} end
    end
    field.cancelBreach(map, tick)
end

-- Legacy evidence has no credited ground attacker or hostile force. Never
-- use it to issue a new order, or join two different diplomatic episodes.
local function currentBreach(map, b)
    local u = map.universe
    return b and b.force and u.activePlayerForceSet and u.activePlayerForceSet[b.force]
        and b.revision == u.frontRevision and b.order == map.orderEpoch
end

-- Two distinct ordinary squads must each prove a local ground success.
function field.recordBreach(map, squad, chunk, tick, member, force)
    if squad.flight or squad.external or squad.support or squad.colonyMission or squad.fieldBreach or squad.fieldOutcome
            or not squad.learn or not live(map, chunk) then return end
    if field.breachTruce(map, tick) then
        field.cancelBreach(map, tick)
        return
    end
    local u = map.universe
    if not (u.activePlayerForceSet and u.activePlayerForceSet[force] and gates.groundMember(map.surface,squad,member)
        and member.force.name == "enemy") then return end
    if squad.breachKillChunk ~= chunk or squad.breachForce ~= force or squad.breachRevision ~= u.frontRevision
        or squad.breachOrder ~= map.orderEpoch then
        squad.breachKillChunk, squad.breachLocalKills = chunk, 0
        squad.breachForce, squad.breachRevision, squad.breachOrder = force, u.frontRevision, map.orderEpoch
    end
    squad.breachLocalKills = (squad.breachLocalKills or 0) + 1
    if squad.breachLocalKills < 2 or not map.chunkToPlayerBase[chunk] or getPlayerTurretCount(map, chunk) > 1
            or (squad.losses or 0) > (squad.startSize or 0) * 0.3 then return end
    local old = map.fieldBreach
    if old and (not currentBreach(map,old) or old.untilTick < tick or not live(map, old.chunk)) then old = nil end
    if not old then
        squad.fieldOutcome = true
        map.fieldBreach = {chunk = chunk, source = squad.groupNumber, force = force, revision = u.frontRevision,
            order = map.orderEpoch, untilTick = tick + BREACH_TTL}
    elseif not old.ready and old.force == force and old.source ~= squad.groupNumber and abs(old.chunk.x - chunk.x) <= CHUNK
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
    if not currentBreach(map,e) or e.untilTick < tick or not live(map, target) or not map.chunkToPlayerBase[target] or getPlayerTurretCount(map, target) > 1 then
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
        fieldChunk = target, breach = map.fieldBreach, untilTick = map.fieldBreach.untilTick}
    map.fieldBreach = nil
    event(map, "Штатный отряд направлен в подтверждённую брешь", tick)
end

function field.strikeStillUseful(map, chunk, breach)
    return currentBreach(map,breach) and live(map, chunk) and map.chunkToPlayerBase[chunk] and getPlayerTurretCount(map, chunk) <= 1
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
        if e then
            local text, mark = e.text, e.raid or e.related
            if mark then
                local site = mark.unit and {"rampant-colony.raid-building",mark.unit} or {"rampant-colony.raid-area",mark.x,mark.y}
                text = {"",{"rampant-colony.raid-ref",mark.group,mark.tick,site}," ",e.text}
                if e.raid then
                    local result = e.result and {"rampant-colony.raid-at",{"rampant-colony.raid-"..e.result},e.at} or {"rampant-colony.raid-unknown"}
                    text = {"",text," ",{"rampant-colony.raid-steps",e.gather or "—",e.move or "—",result}}
                end
            end
            lines[#lines + 1] = {"", "[Rampant · " .. e.tick .. "] ", text}
        end
    end
end

return field
