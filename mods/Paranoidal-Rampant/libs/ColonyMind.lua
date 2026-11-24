-- Two-front observations. The optional executor borrows one paid ordinary
-- assault; neither planner consumes ordinary AI target selection or RNG.
local orders = require("ColonyOrders")
local rail = require("ColonyRail")
local shift = require("ColonyRelocation")
local funnel = require("ColonyFunnel")
local outcome = require("ColonyOutcome")
local gates = require("AIPredicates")
local mind = {SETTING="rampantFixed--colonyMind", COMMAND="rampantFixed--colonyOrders", orders=orders}
local FRONT_LIFE, WINDOW, MEMORY = 21600, 3600, 36000
local NEAR2, SEPARATE2, REACH2 = 96^2, 224^2, (26 * 32)^2
local mobile = {character = true, car = true, ["spider-vehicle"] = true}
local fixed = {["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true, turret = true}
local function distance2(x, y, p)
    return (p.x - x)^2 + (p.y - y)^2
end

function mind.configure(u, requested, allowOrders)
    u.colonyRequested = requested or nil
    local enabled = requested and not u.classicAI and u.heavyAI ~= false or nil
    local command = enabled and allowOrders or nil
    if enabled ~= u.colonyMind or command ~= u.colonyOrders then
        local map = u.colonySurface and u.maps[u.colonySurface]
        if map then mind.stop(map, game.tick) end
        u.colonyEpoch = (u.colonyEpoch or 0) + 1
        u.colonySurface, u.colonyFollowSurface = nil, nil
    end
    u.colonyMind, u.colonyOrders = enabled, command
end

local function current(map)
    local u, s = map.universe, map.colonyShadow
    if s and s.epoch == u.colonyEpoch and s.diplomacy == u.frontRevision and s.order == map.orderEpoch then return s end
end

local function open(map, tick)
    return not map.suspended and map.surface.valid and gates.attackAllowed(map, tick)
end

local function eligible(map, squad)
    -- A flight crossing a lake cannot vouch for ground access to the far bank.
    return map.universe.colonyMind and squad.learn and not squad.flight and not squad.external
        and not squad.undergoundAttack and not squad.settlers
        and (squad.doctrineEpoch or 0) == (map.universe.doctrineEpoch or 0)
        and (squad.orderEpoch or 0) == (map.orderEpoch or 0) and squad.groupNumber ~= nil
end

local function match(s, p, force, tick)
    for i, f in ipairs(s.fronts) do
        if tick - f.seen <= FRONT_LIFE and (not force or f.force == force) and distance2(f.x, f.y, p) <= NEAR2 then return i end
    end
end

local function remember(s, p, force, tick, knownFront)
    local i = knownFront or match(s, p, force, tick)
    if i then s.fronts[i].seen = tick; return i end
    if s.op or s.ticket then return end -- pin both fronts through execution
    local free
    for j, f in ipairs(s.fronts) do
        if tick - f.seen > FRONT_LIFE then free = free or j
        elseif distance2(f.x, f.y, p) < SEPARATE2 then return end
    end
    free = free or (#s.fronts < 2 and #s.fronts + 1)
    if free then s.fronts[free] = {x = p.x, y = p.y, since = tick, seen = tick, force = force}; return free end
end

local function reserve(map)
    local u = map.universe
    return map.finalSquadCost and map.points >= map.finalSquadCost and u.squadCount < u.AI_MAX_SQUAD_COUNT * 0.7
end

function mind.issued(map, squad, goal, tick)
    if squad.support or squad.colonyMission or not eligible(map, squad) then return end
    local f = funnel.raid(map, tick)
    local s = current(map)
    if map.universe.colonySurface or (s and s.op) then return funnel.stop(f,"funnel-before","funnel-busy") end
    if not s or #s.fronts < 2 or s.fronts[1].force ~= s.fronts[2].force
        or tick - s.fronts[1].seen > FRONT_LIFE or tick - s.fronts[2].seen > FRONT_LIFE then
        return funnel.stop(f,"funnel-before","funnel-fronts")
    end
    if not open(map, tick) then return funnel.stop(f,"funnel-before","window-closed") end
    if not reserve(map) then return funnel.stop(f,"funnel-before","no-reserve") end
    if goal.entity and not goal.entity.valid then return funnel.stop(f,"funnel-before","funnel-unmatched") end
    local i = match(s, goal, goal.entity and goal.entity.force.name, tick)
    if not i then return funnel.stop(f,"funnel-before","funnel-unmatched") end
    local a, b = s.fronts[i], s.fronts[3-i]
    if a.lastProbe == squad.groupNumber or not squad.originPosition or distance2(b.x, b.y, squad.originPosition) > REACH2 then
        return funnel.stop(f,"funnel-before","funnel-probe")
    end
    map.universe.colonyFollowSurface = nil -- no overlapping ordinary follow-up from an earlier operation
    map.universe.colonySurface = map.surface.index
    a.lastProbe = squad.groupNumber
    -- Fronts are pinned during an operation. Replacing the peer slot creates
    -- a new `since`; a legacy unpaired reply is not evidence about this pair.
    local habit = b.since and a.replyPeerSince == b.since and a.replyTick and tick - a.replyTick <= MEMORY and a.replies or 0
    s.serial = (map.colonySerial or s.serial) + 1
    map.colonySerial = s.serial
    funnel.add(f,"observed")
    s.op = {funnel = f, id = s.serial, probe = squad.groupNumber, probeSize = squad.startSize, probeLosses = 0, preRaidLosses = squad.losses or 0,
        probeCost = squad.formationCost, a = i, b = 3-i, started = tick, deadline = tick + WINDOW,
        peerSince = b.since, prior = habit, needed = habit >= 2 and 1 or 2, hits = 0, crew = {}}
    outcome.join(s.op, squad) -- evidence of a reaction and usefulness of a continuation are separate
end

local function groundReporter(map, squad, force, unit)
    local forces = map.universe.activePlayerForceSet
    return forces and forces[force] and eligible(map,squad) and gates.groundMember(map.surface,squad,unit)
end

-- Only reports with a known source compete for the shared 16 places.
local function admit(map, tick)
    if not open(map, tick) then return end
    local u = map.universe
    if u.colonyIngressTick ~= tick then u.colonyIngressTick, u.colonyIngress = tick, 0 end
    if u.colonyIngress >= 16 then
        if u.colonySurface and u.maps[u.colonySurface] == map then
            local op = map.colonyShadow and map.colonyShadow.op
            if op and tick < op.deadline then op.partial = true end
            orders.doubt(map,nil,nil,"incomplete",tick)
        end
        return
    end
    u.colonyIngress = u.colonyIngress + 1
    return true
end

local function witness(map, squad, p, force, kind, tick, knownFront, member, cause)
    local u = map.universe
    local s = current(map)
    if not s then
        if map.colonyShadow then mind.stop(map,tick) end
        s = {epoch = u.colonyEpoch, diplomacy = u.frontRevision, order = map.orderEpoch, fronts = {}, serial = 0}
        map.colonyShadow = s
    end
    if s.ticket then orders.doubt(map,p,force,kind,tick,squad) end
    local i = remember(s, p, force, tick, knownFront)
    local op = s.op
    if not i or not op or tick >= op.deadline then return end
    if kind ~= 'hit' then shift.contact(map,op,i,s.fronts[i],squad,member,cause,p,tick) end
    local moved = op.motion and op.motion.at
    if i == op.a and squad.groupNumber == op.probe then
        if kind == "fixed" then op.fixed, op.raidHit = true, nil
        elseif kind == "mobile" then op.mobile, op.lastMobile, op.raidHit = op.mobile or tick, tick, nil
        elseif kind == "hit" then
            if moved and tick > moved and member.unit_number==op.motion.raidPartner and shift.localHit(map,squad,member,p,cause,force) then
                op.motion.raidEye = member.unit_number
            end
            if op.coverTick and tick > op.coverTick then op.probeHit = tick end
            if not op.fixed and not op.raidDoubt and op.lastMobile and tick > op.lastMobile then op.raidHit = tick end
        end
    elseif i == op.a and kind ~= "hit" and not op.raidDoubt then
        -- One independent casualty is enough to dispute this option for this
        -- observation. Count its reporting group; do not acquire more witnesses.
        op.raidHit, op.raidDoubt, op.raidCoverGroup = nil, tick, squad.groupNumber
        outcome.join(op,squad)
    elseif i == op.b and squad.groupNumber ~= op.probe then
        if kind == "mobile" or kind == "fixed" then
            if not op.coverTick then
                op.coverTick,op.coverGroup=tick,squad.groupNumber
                outcome.join(op, squad)
            end
            op.cover = (op.cover == "mobile" and "mobile") or kind
            op.hits, op.firstHit, op.secondHit, op.firstTick, op.secondTick = 0, nil, nil, nil, nil
        elseif op.mobile and tick > op.mobile and op.hits < 2 and op.firstHit ~= squad.groupNumber
            and (not op.cover or (moved and shift.localHit(map,squad,member,p,cause,force) and cause.unit_number ~= op.motion.firstBuilding
                and (squad.groupNumber~=op.coverGroup or member.unit_number==op.motion.partner))) then
            if moved then
                op.motion[op.firstHit and 'secondEye' or 'firstEye'] = member.unit_number
                op.motion[op.firstHit and 'secondBuilding' or 'firstBuilding'] = cause.unit_number
            end
            if op.firstHit then op.secondHit,op.secondTick = squad.groupNumber,tick else op.firstHit,op.firstTick = squad.groupNumber,tick end
            op.hits = op.hits + 1
            outcome.join(op, squad)
        end
    end
end

-- Read only an already credited building-death event. A local projected
-- step names a chunk, not a building. In a tie use only the two pinned IDs.
local function keptHit(map,s,squad,p,force,tick,member,entity)
    local r=s and s.last
    if not r or not r.keepUntil or tick>=r.keepUntil or r.id~=s.serial then
        map.universe.colonyFollowSurface=nil;return
    end
    if r.keepUnit or r.group~=squad.groupNumber or map.universe.groupNumberToSquad[r.group]~=squad or squad.group.unique_id~=r.group
        or r.force~=force or r.issued or tick<r.ended
        or squad.retreated or squad.support or squad.excluded or squad.goal or squad.pendingGoal
        or not entity or not entity.valid or not entity.unit_number or entity.surface~=map.surface
        or entity.force.name~=force or entity.position.x~=p.x or entity.position.y~=p.y
        or member.force.name~='enemy' or distance2(p.x,p.y,member.position)>64^2 then return end
    if r.status=='local-task' then
        if math.floor(p.x/32)*32~=r.localX or math.floor(p.y/32)*32~=r.localY then return end
    elseif r.status=='no-edge' then
        local seen=false
        for _,q in ipairs(r.options) do
            if q.unit==entity.unit_number and q.x==p.x and q.y==p.y then seen=true;break end
        end
        if not seen then return end
    else return end
    r.keepUnit,r.keepTick,r.keepX,r.keepY=entity.unit_number,tick,p.x,p.y
    map.universe.colonyFollowSurface=nil
end

function mind.hit(map, squad, p, force, tick, member, entity)
    if squad.colonyMission or not groundReporter(map,squad,force,member) then return end
    local s = current(map)
    local pinned = s and (s.op or s.ticket)
    local i = pinned and match(s,p,force,tick)
    local watching = map.universe.colonySurface == map.surface.index
    -- A third site cannot refresh either pinned front. Keep the one other
    -- useful effect: replacing the physical eye of an already named role.
    if pinned and not i and not (watching and rail.newEye(pinned,squad.groupNumber,member,tick)) then return end
    if not admit(map,tick) then return end
    if not pinned and map.universe.colonyFollowSurface==map.surface.index then keptHit(map,s,squad,p,force,tick,member,entity) end
    if not pinned or i then witness(map,squad,p,force,"hit",tick,i,member,entity) end
    -- A real front hit may just have established the role. Never grant it
    -- before admission, and never write an eye for a dropped report.
    if watching then rail.noteHit(map,squad,member,tick) end
end

-- While the slots are pinned, an independent death outside both fronts
-- cannot create a third one. Do keep cover at an off-centre pinned site:
-- it can contradict the task even if the casualty misses the front circle.
local function lossInScope(map,p,force,tick)
    local s = current(map)
    if not s or not (s.op or s.ticket) or match(s,p,force,tick) then return true end
    local r = s.ticket
    if not r or r.issued or r.force ~= force then return false end
    if r.status == "approach" or not r.options then return distance2(r.x,r.y,p) <= NEAR2 end
    for _,q in ipairs(r.options) do
        if q.state == "candidate" and distance2(q.x,q.y,p) <= NEAR2 then return true end
    end
    return false
end

-- Accounting only: the credited opponent and victim must both be at the
-- site to call this local, or both well outside to discount a witness's
-- separate fight. A candidate can lie one radius from its pinned front
-- and have another radius of cover (also enclosing the rail eye's reach).
local function lossArea(s, r, id, p, source, force)
    local far = true
    for i=1,2 do
        local f = s.fronts[i]
        if not f or f.force ~= force then return end
        local a,b = distance2(f.x,f.y,p),distance2(f.x,f.y,source)
        if a <= NEAR2 and b <= NEAR2 then return "siteLosses" end
        if a <= 4*NEAR2 or b <= 4*NEAR2 then far = false end
        local q = r.options and r.options[i]
        if q and q.x and distance2(q.x,q.y,p) <= NEAR2 and distance2(q.x,q.y,source) <= NEAR2 then return "siteLosses" end
    end
    if far and id ~= r.probe and id ~= r.group then return "awayLosses" end
end

function mind.loss(map, squad, p, force, cause, tick, unit)
    local s=map.colonyShadow
    local op=s and s.op
    if op and op.probe==squad.groupNumber and tick<op.deadline and op.probeLosses then op.probeLosses=op.probeLosses+1 end
    local record = s and (op or s.ticket)
    local adverse,source,reported
    local crew = record and record.crew
    if cause and cause.valid and cause.force.name == force and cause.surface == map.surface then
        local kind = mobile[cause.type] and "mobile" or fixed[cause.type] and "fixed"
        if kind or (crew and crew[squad.groupNumber]) then
            local at = cause.position
            if distance2(p.x,p.y,at) <= 64^2 and groundReporter(map,squad,force,unit) then
                if crew and map.universe.colonySurface == map.surface.index and current(map) == s then source = at end
                if kind then
                    if squad.colonyMission then
                        if record and record.status == "approach" and record.group == squad.groupNumber then adverse = kind end
                    elseif lossInScope(map,p,force,tick) and admit(map,tick) then
                        witness(map,squad,p,force,kind,tick,nil,unit,cause); reported = true
                    end
                end
            end
        end
    end
    -- A paid ground casualty at B without a local, identified cause cannot
    -- certify a single defender. Disqualify only the relocation exception.
    if not reported and record and (op and op.motion ~= false or record.motion and (record.status=='await-slot' or record.status=='gathering'))
        and tick < (record.deadline or record.untilTick) and map.universe.colonySurface == map.surface.index
        and current(map) == s and squad.formationCost and squad.formationCost > 0 and groundReporter(map,squad,force,unit)
        and match(s,p,force,tick) == (op and op.b or record.target) then
        -- Discarding the exception needs no new witness slot. A fresh report
        -- which closes a ticket still goes through ordinary ingress/accounting.
        if op then op.motion = false elseif admit(map,tick) then orders.doubt(map,p,force,'unidentified',tick,squad) end
    end
    -- Include the casualty that first identified the cover witness. The
    -- caller supplies actual hostile losses, even for a non-witness executor.
    local member = crew and crew[squad.groupNumber]
    if member and tick < (record.deadline or record.untilTick) then
        member.lost = member.lost + 1
        local key = source and open(map,tick) and lossArea(s,record,squad.groupNumber,p,source,force)
        if key then member[key] = (member[key] or 0) + 1 end
    end
    return adverse
end

-- The death handler has now charged the casualty to both squad and route.
-- An executor may contradict its own unissued task, never corroborate it.
function mind.approachLoss(map,squad,p,force,kind,tick,field)
    local g = squad.goal
    local r = g and g.colonyRecord
    if r and r.status == "approach" and not g.issued and r.force == force and distance2(r.x,r.y,p) <= NEAR2
        and orders.owner(map,squad,g,tick) and field.colonyTargetLive(map,g) and admit(map,tick) then
        orders.doubt(map,p,force,kind,tick,squad)
    end
end

local function finish(map,s,action,reason,target,tick,brain)
    local op = s.op
    local a = s.fronts[op.a]
    if action == "strike" then
        if reason ~= 'mobile-crossed' then a.replies, a.replyTick, a.replyPeerSince = math.min(2, op.prior + 1), op.mobile, op.peerSince end
    elseif not op.partial and op.cover and (op.mobile or op.probeHit) then a.replies, a.replyTick, a.replyPeerSince = 0, nil, nil end
    s.last = {id = op.id, action = action, reason = reason, target = target, tick = tick, prior = op.prior, peerSince = op.peerSince}
    if reason == 'mobile-crossed' then s.last.motion = op.motion end
    orders.decided(map,op,s.last,tick,brain)
    s.op = nil
    local u = map.universe
    if not s.ticket and u.colonySurface and u.maps[u.colonySurface] == map then u.colonySurface = nil end
end

function mind.invalidate(u,tick)
    u.colonyFollowSurface=nil
    local map=u.colonySurface and u.maps[u.colonySurface]
    if map then mind.stop(map,tick) end
    u.colonySurface=nil
end

function mind.stop(map,tick)
    if map.universe.colonyFollowSurface==map.surface.index then map.universe.colonyFollowSurface=nil end
    local s = map.colonyShadow
    if s and s.op then finish(map,s,"cancel","window-closed",0,tick) end
    orders.stop(map,tick)
    map.colonyShadow = nil
end

-- One operation for the whole universe. Only the existing small target ring
-- is consulted, once on decision; waiting rechecks only the one or two pinned sightings.
function mind.step(u,tick,brain)
    if not u.colonyMind or not u.colonySurface then return end
    local map = u.maps[u.colonySurface]
    local s = map and current(map)
    if not s or not open(map,tick) then
        if map then mind.stop(map,tick) end
        u.colonySurface=nil; return
    end
    local watching=s.op or s.ticket
    if watching and watching.railWatch then rail.step(map,watching,tick) end
    if s.ticket then orders.maintain(map,tick,brain); return end
    local op=s.op
    if not op then u.colonySurface=nil; return end
    if not op.peerSince then op.partial = true end -- unverified reports from before actor/pair tracking
    if op.partial then finish(map,s,"cancel","incomplete",0,tick)
    elseif not reserve(map) then finish(map,s,"cancel","no-reserve",0,tick)
    elseif op.motion and op.motion.partner and op.motion.at and op.cover then
        if tick >= op.deadline then finish(map,s,'cancel','timeout',0,tick)
        elseif op.hits==2 and op.firstHit~=op.coverGroup and op.secondHit~=op.coverGroup then finish(map,s,'cancel','both-guarded',0,tick)
        elseif op.motion.raidEye and op.hits==2 then finish(map,s,'strike','mobile-crossed',op.b,tick,brain) end
    elseif op.cover and (op.mobile or op.fixed or op.raidDoubt) then finish(map,s,"cancel","both-guarded",0,tick)
    elseif op.cover and op.probeHit then finish(map,s,"redirect","probe-contact",op.a,tick,brain)
    elseif op.mobile and op.hits >= op.needed then finish(map,s,"strike","second-contact",op.b,tick,brain)
    elseif tick >= op.deadline then finish(map,s,"cancel","timeout",0,tick) end
end

function mind.report(map, lines, tick)
    local u = map.universe
    if not u.colonyRequested and not map.colonyFunnel then return end
    local mode = not u.colonyMind and "mode-off" or u.colonyOrders and "funnel-command" or "funnel-shadow"
    lines[#lines+1] = {"rampant-colony.current-mode",{"rampant-colony."..mode}}
    if not u.colonyMind or not open(map,tick) then
        lines[#lines+1] = {"rampant-colony.inactive"}; funnel.report(map,lines); orders.report(map,lines); return
    end
    local s = current(map)
    local op = s and s.op
    if op and tick < op.deadline then
        lines[#lines+1] = {"rampant-colony.pending", op.id, op.a, op.b, op.prior, op.hits, op.needed, op.deadline}
    elseif not (s and s.ticket) then
        local n = 0
        for _, f in ipairs(s and s.fronts or {}) do if tick - f.seen <= FRONT_LIFE then n = n + 1 end end
        lines[#lines+1] = {"rampant-colony.waiting", n}
    end
    funnel.report(map,lines)
    orders.report(map,lines)
    local last = s and s.last
    if last then
        local action = {"rampant-colony." .. (last.adviceAction or last.action)}
        local advised = last.adviceTarget or last.target
        if advised ~= 0 then action[2] = advised end
        lines[#lines+1] = {u.colonyOrders and "rampant-colony.command-result" or "rampant-colony.result", last.id, last.tick,
            action, {"rampant-colony." .. last.reason}, last.prior}
    end
end

return mind
