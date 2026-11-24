-- A recommendation may use one *already paid* ordinary ground assault. This
-- module never recruits, calls set_command, changes points, or samples RNG.
local orders = {}
local funnel = require("ColonyFunnel")
local gates = require("AIPredicates")
local feedback = require("ColonyOutcome")
local choice = require("ColonyChoice")
local rail = require("ColonyRail")
local route = require("ColonyRoute")
local SLOT_LIFE, MIN_GROUND = 3600, 6

local function ticket(map)
    local s = map.colonyShadow
    return s and s.ticket
end

local function current(map, r)
    local u = map.universe
    -- Never start executing a saved forecast whose witnesses predate ground
    -- actor checks. A previously issued attack still owns its actual outcome.
    return u.colonyMind and r and (r.peerSince or r.issued) and r.epoch == u.colonyEpoch and r.diplomacy == u.frontRevision
        and r.order == map.orderEpoch and map.surface.valid and u.colonySurface == map.surface.index
        and not map.suspended and u.activePlayerForceSet and u.activePlayerForceSet[r.force]
end

local function endTicket(map, r, status, tick)
    if not r or ticket(map) ~= r then return end
    local u, s = map.universe, map.colonyShadow
    local sq = r.group and u.groupNumberToSquad and u.groupNumberToSquad[r.group]
    r.losses = sq and math.max(0,(sq.losses or 0)-(r.lossBase or 0)) or r.losses
    if r.funnel then
        funnel.stop(r.funnel,"funnel-after","status-" .. status)
        r.funnel = nil
    end
    r.railIncomplete = r.railIncomplete or (r.railWatch and r.railWatch.incomplete)
    r.railWatch,r.railGate=nil,nil
    r.status, r.ended = status, tick
    if status == "repelled" then s.fronts[r.target].repelledAt = tick
    elseif status == "achieved" then s.fronts[r.target].repelledAt = nil end
    local g = map.objectiveRaid
    if g and g.colonyRecord == r then
        g.done, map.objectiveRaid = true, nil
        if orders.recall and sq and sq.goal==g and (status=="closed" or status=="expired" or status=="target-lost"
            or status=="new-cover" or status=="missing-reports" or status=="stop-lost" or status=="route-changed") then orders.recall(sq,g,tick) end
    end
    s.ticket = nil
    if map.surface.valid and u.colonySurface == map.surface.index then u.colonySurface = nil end
end

function orders.routeLost(map,goal,tick)
    if goal.colonyPath and not goal.issued then endTicket(map,goal.colonyRecord,"route-changed",tick) end
end

function orders.stop(map, tick)
    endTicket(map, ticket(map), "closed", tick)
end

function orders.decided(map, op, r, tick, brain)
    local s, u = map.colonyShadow, map.universe
    local history = map.colonyHistory or {}
    map.colonyHistory = history
    if #history == 4 then table.remove(history,1) end
    history[#history+1] = r
    r.started, r.probe, r.response, r.hits = op.started, op.probe, op.mobile, op.hits
    r.crew, r.raidCoverGroup, r.raidDoubt = op.crew, op.raidCoverGroup, op.raidDoubt
    r.firstHit, r.secondHit, r.coverTick = op.firstHit, op.secondHit, op.coverTick
    r.firstTick, r.secondTick, r.probeHit, r.coverGroup = op.firstTick, op.secondTick, op.probeHit, op.coverGroup
    r.probeLosses,r.preRaidLosses,r.probeSize,r.probeCost=op.probeLosses,op.preRaidLosses,op.probeSize,op.probeCost
    local f = op.funnel
    if r.target == 0 then
        local reason = r.reason
        if reason == "timeout" then
            reason = op.cover and "funnel-redirect" or not op.mobile and "funnel-response" or "funnel-witnesses"
        end
        funnel.stop(f,"funnel-during",reason)
        r.status, r.ended = "cancelled", tick; return
    end
    funnel.add(f,"advised")
    local front = s.fronts[r.target]
    r.force, r.slots = front.force, 0
    local lastSeenUntil = choice.prepare(map,op,r,tick,brain)
    if not lastSeenUntil then
        funnel.stop(f,"funnel-after","status-no-target")
        r.status, r.ended = "no-target", tick; return
    end
    funnel.add(f,"live")
    r.epoch, r.diplomacy, r.order = u.colonyEpoch, u.frontRevision, map.orderEpoch
    r.status, r.untilTick = "await-slot", math.min(tick + SLOT_LIFE, op.deadline, lastSeenUntil)
    if tick >= r.untilTick then
        funnel.stop(f,"funnel-after","status-expired")
        r.status,r.ended="expired",tick; return
    end
    r.funnel, r.railWatch, s.ticket = f, op.railWatch, r
end

-- New cover or incomplete evidence before the attack command: do not renew
-- a recommendation on the strength of the old reports.
function orders.doubt(map, p, force, kind, tick, squad)
    local r = ticket(map)
    if not r or r.status == "issued" then return end
    if kind == "incomplete" then return endTicket(map,r,"missing-reports",tick) end
    if kind == "hit" or force ~= r.force then return end
    if r.motion and (r.status=='await-slot' or r.status=='gathering') then
        local f = map.colonyShadow.fronts[r.target]
        if (p.x-f.x)^2+(p.y-f.y)^2 <= 96^2 then
            if squad and r.crew then feedback.join(r,squad) end
            return endTicket(map,r,'new-cover',tick)
        end
    end
    if r.options and (r.status=="await-slot" or r.status=="gathering") then
        local affected,closed=choice.cover(r,p,squad,tick)
        if affected and squad and tick<r.untilTick then feedback.join(r,squad) end
        if closed then endTicket(map,r,"new-cover",tick) end
    elseif (p.x-r.x)^2+(p.y-r.y)^2<=96^2 then
        if squad and tick<r.untilTick and r.options then
            local q=r.options[r.target];q.coverGroup,q.coverTick=squad.groupNumber,tick;feedback.join(r,squad)
        end
        endTicket(map,r,"new-cover",tick)
    end
end

function orders.maintain(map, tick, brain)
    local r = ticket(map)
    if not r then return end
    if not current(map,r) or not gates.attackAllowed(map,tick) then endTicket(map,r,"closed",tick)
    elseif tick >= r.untilTick then
        endTicket(map,r,r.status == "await-slot" and "no-slot" or r.status == "gathering" and "no-group" or "expired",tick)
    elseif r.status == "await-slot" or r.status == "gathering" then
        if not choice.survives(map,r,tick,brain.field) then endTicket(map,r,"target-lost",tick) end
    elseif not rail.current(map,r) then endTicket(map,r,"stop-lost",tick)
    elseif not map.objectiveRaid or map.objectiveRaid.colonyRecord~=r or not brain.field.colonyTargetLive(map,map.objectiveRaid) then
        endTicket(map,r,"target-lost",tick)
    elseif map.objectiveRaid.colonyPath and not route.current(map,map.objectiveRaid,tick,brain) then
        orders.routeLost(map,map.objectiveRaid,tick)
    end
end

-- Called only after ordinary recruitment/charge, never from a timer. Do not
-- require the same points/free slot a second time after they have been spent.
function orders.nominate(map, squad, tick, uncommitted)
    local r = ticket(map)
    if not r or r.status ~= "await-slot" or not current(map,r) or tick >= r.untilTick then return end
    r.slots = r.slots + 1
    if not uncommitted then return end
    r.plain = (r.plain or 0)+1
    local p = squad.originPosition
    if squad.startSize < MIN_GROUND or not choice.inRange(r,p) then return end
    r.status, r.slotTick, r.group, r.cost = "gathering", tick, squad.groupNumber,squad.formationCost
    r.lossBase = squad.losses or 0
    r.regroupTracked = true -- observe from nomination, including before gathering
    feedback.join(r, squad)
    squad.colonySlot = r.id
end

-- Accounting only: the ordinary retreating squad has already selected its partner.
function orders.regroupRecord(map, partner, tick)
    local r = ticket(map)
    if not (r and r.crew and r.group == partner.groupNumber and tick < r.untilTick and current(map,r)) then return end
    if r.status == 'gathering' and partner.colonySlot == r.id then return r end
    local g = partner.goal
    if (r.status == 'approach' or r.status == 'issued') and g and g == map.objectiveRaid and g.colonyRecord == r then return r end
end

-- At finished-gathering, *after* flyers have been split and before packing.
-- No work for any other group. Count actual mobile ground members, not an
-- estimated wave or the requested unit count; stop once the minimum is met.
function orders.gathered(map, squad, tick, brain)
    local id = squad.colonySlot
    squad.colonySlot = nil
    local r = ticket(map)
    if not id or not r or r.id ~= id or r.group ~= squad.groupNumber or r.status ~= "gathering" then return end
    if not current(map,r) or not gates.attackAllowed(map,tick) then return endTicket(map,r,"closed",tick) end
    if tick >= r.untilTick then return endTicket(map,r,"no-group",tick) end
    if squad.flight or squad.settlers or squad.external or squad.goal or squad.pendingGoal or not squad.learn
        or squad.undergoundAttack or squad.support or squad.retreated or squad.vengence or squad.excluded or squad.fieldBreach
        or squad.tactic ~= "assault" or not squad.group.valid then
        return endTicket(map,r,"no-group",tick)
    end
    local n, members = 0, squad.group.members
    for i=1,math.min(#members,32) do
        local unit = members[i]
        if unit.valid and unit.type == "unit" and not gates.isRampantFlyer(unit.name) then
            n=n+1; if n == MIN_GROUND then break end
        end
    end
    r.members = #members
    if r.crew then r.crew[r.group].size = r.members end -- after the flight split; the original price is unchanged
    if n < MIN_GROUND then return endTicket(map,r,"no-group",tick) end
    funnel.add(r.funnel,"gathered")
    local entry,c,reason,path = choice.pick(map,r,squad,tick,brain)
    r.railIncomplete=r.railWatch and r.railWatch.incomplete
    r.railWatch=nil
    if not entry then
        -- One short look at the actual ordinary group's work. Not a ticket,
        -- lock, promise of victory or reason to postpone any other squad.
        if reason=='local-task' or reason=='no-edge' then
            r.keepUntil=math.min(r.untilTick,tick+1800)
            map.universe.colonyFollowSurface=map.surface.index
        end
        return endTicket(map,r,reason,tick)
    end
    funnel.add(r.funnel,"ready")
    r.funnel = nil -- from here on, the outcome belongs to the execution journal
    if not map.universe.colonyOrders then return endTicket(map,r,"would-send",tick) end
    -- Same surface-wide objective lock and ground executor as an ordinary raid.
    local goal = brain.field.claimObjective(map,entry.entity,c,tick)
    goal.epoch, goal.colonyRecord, goal.colonyPath = map.universe.frontRevision, r, path
    -- Walking is not the attack order. Evidence can expire on the way.
    r.status = "approach"
    if r.crew then r.routeLosses, r.targetLosses = 0, 0 end
    squad.goal, squad.colonyMission = goal, true
end

function orders.owner(map,squad,goal,tick)
    local r = goal.colonyRecord
    return r and current(map,r) and map.universe.colonyOrders and ticket(map)==r and map.objectiveRaid==goal
        and not goal.done and tick<r.untilTick and r.group==squad.groupNumber and r.unit==goal.unit
        and not squad.flight and not squad.external and not squad.settlers and gates.attackAllowed(map,tick)
        and goal.entity.valid and goal.entity.force.name==r.force and rail.current(map,r)
end

function orders.issued(map,squad,goal,tick)
    if orders.owner(map,squad,goal,tick) then
        local r = goal.colonyRecord
        r.railGate,goal.colonyPath=nil,nil -- from here on, attribute only the existing building order
        r.status, r.issued, r.untilTick = "issued", r.issued or tick, goal.untilTick
    end
end

function orders.closed(map,goal,success,tick,outcome,field)
    local r = goal.colonyRecord
    if not r or ticket(map)~=r then return end
    local sq = map.universe.groupNumberToSquad[r.group]
    local status = (not current(map,r) or not gates.attackAllowed(map,tick)) and "closed"
        or tick>=r.untilTick and "expired" or success and r.issued and goal.confirmed and "achieved" or r.issued and outcome=="repelled" and "repelled"
        or not rail.current(map,r) and "stop-lost" or (not goal.entity.valid and "target-lost")
        or (not r.issued and sq and (sq.losses or 0) > r.lossBase and "approach-losses") or "unconfirmed"
    if status == "achieved" or status == "repelled" then feedback.learn(map,r,goal,status,tick,field) end
    endTicket(map,r,status,tick)
end

function orders.report(map,lines)
    for _,r in ipairs(map.colonyHistory or {}) do
        local sources={"rampant-colony.sources",r.probe,r.started,r.response or "—",r.firstHit or "—",r.firstTick or "—",
            r.secondHit or "—",r.secondTick or "—",r.coverGroup or "—",r.coverTick or "—",r.probeHit or "—"}
        local costs={"rampant-colony.costs",r.preRaidLosses or "—",r.probeLosses or "—",r.probeSize or "—",r.probeCost or "—",r.cost or "—"}
        lines[#lines+1] = {"rampant-colony.history",r.id,r.tick,{"rampant-colony."..r.reason},sources,r.unit or "—",r.seen or "—",
            r.plain or 0,r.slots or 0,r.group or "—",r.issued or "—",{"rampant-colony.status-"..r.status},r.ended or "—",r.losses or "—",costs}
        choice.report(r, lines)
        feedback.report(r, lines)
        if r.keepUnit then
            lines[#lines+1]={'rampant-colony.kept-hit',r.id,r.group,r.keepUnit,r.keepX,r.keepY,r.keepTick}
        elseif r.keepUntil then
            lines[#lines+1]={'rampant-colony.kept-unconfirmed',r.id,r.group,r.keepUntil}
        end
    end
end

return orders
