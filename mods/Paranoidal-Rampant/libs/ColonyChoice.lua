-- One comparison for a nominated Factorio assault, using the two pinned
-- fronts, the existing observation ring and cached chunks. Never issues a job.
local choice = {}
local outcome = require("ColonyOutcome")
local rail = require("ColonyRail")
local shift = require("ColonyRelocation")
local route = require("ColonyRoute")
local air = require("ColonyAir")
local CHUNK = require("Constants").CHUNK_SIZE
local RANGE2, STEPS = (26*32)^2, 40

local function focus(r, q)
    r.action, r.target = q.action, q.target
    r.unit, r.x, r.y, r.seen, r.prototype = q.unit, q.x, q.y, q.seen, q.prototype
    r.basis, r.priorBalance = q.basis, q.priorBalance
end

-- Freeze up to one actual sighting per supported front. Late construction
-- or disappearance cannot substitute a third observation for a pinned one.
function choice.prepare(map, op, r, tick, brain)
    local fronts = map.colonyShadow.fronts
    local i, j = r.target, 3-r.target
    local both = r.action == "strike" and r.reason ~= 'mobile-crossed' and op.raidHit and not op.fixed and not op.raidDoubt
    local a,b
    if map.fieldTargets then a,b=brain.field.peekReserve(map,fronts[i],tick,brain,both and fronts[j]) end
    local function option(index, supported, e)
        local q={target=index, action=index==op.a and "redirect" or "strike", reason=r.reason, force=fronts[index].force,
            state=supported and "no-target" or "unsupported"}
        if e and supported then
            q.unit,q.x,q.y,q.seen,q.prototype=e.slot.key,e.x,e.y,e.seen,e.entity.name
            q.state="candidate"
        end
        return q
    end
    r.adviceTarget, r.adviceAction, r.raidFront, r.raidHit = i, r.action, op.a, op.raidHit
    r.options = {[i]=option(i,true,a), [j]=option(j,both,b)}
    local q = a and r.options[i] or (both and b and r.options[j])
    if not q then return end
    focus(r,q)
    return math.max(q.seen, (both and b and b.seen) or q.seen) + 7200
end

local function anyone(r)
    return r.options[1].state=="candidate" or r.options[2].state=="candidate"
end

-- Only for a still-unassigned ticket. Once selected, the executor owns one
-- objective and uses the usual exact-target checks, never a fallback target.
function choice.survives(map,r,tick,field)
    if not r.options then return field.resolveReserve(map,r,tick) end
    for _,q in ipairs(r.options) do
        if q.state=="candidate" and (tick>=q.seen+7200 or not field.resolveReserve(map,q,tick)) then q.state="target-lost" end
    end
    return anyone(r)
end

function choice.cover(r,p,squad,tick)
    local affected=false
    for _,q in ipairs(r.options) do
        if q.state=="candidate" and (p.x-q.x)^2+(p.y-q.y)^2<=96^2 then
            q.state,q.coverGroup,q.coverTick="new-cover",squad and squad.groupNumber,tick
            affected=true
        end
    end
    return affected, not anyone(r)
end

function choice.inRange(r,p)
    if not r.options then return (r.x-p.x)^2+(r.y-p.y)^2<=RANGE2 end
    for _,q in ipairs(r.options) do
        if q.state=="candidate" and (q.x-p.x)^2+(q.y-p.y)^2<=RANGE2 then return true end
    end
    return false
end

-- No score conversion between pheromones, points and buildings. A switch
-- between two corroborated sites needs an advantage with no worse observed
-- building weight, turret count, local result or known corridor length.
local function dominates(a,b)
    local pa,pb=a.priorBalance or 0,b.priorBalance or 0
    return a.weight>=b.weight and a.cover<=b.cover and a.steps<=b.steps and pa>=pb
        and (a.weight>b.weight or a.cover<b.cover or a.steps<b.steps or pa>pb)
end

function choice.pick(map, r, squad, tick, brain)
    r.choiceTick, r.pick = tick, "ordinary"
    -- Journal the authority at this gathering, not the settings when the report is opened.
    r.choiceMode = map.universe.colonyOrders and "command" or "shadow"
    if not r.options then return nil,nil,"unknown-task" end -- no two-front snapshot for this legacy ticket
    local field, p, origin = brain.field, squad.group.position, squad.originPosition
    local cx,cy = math.floor(p.x/CHUNK)*CHUNK, math.floor(p.y/CHUNK)*CHUNK
    local entries,chunks,paths={},{},{}
    local total=0
    for i,q in ipairs(r.options) do
        if q.state=="candidate" then
            local e,c=field.resolveReserve(map,q,tick)
            if not e or tick>=q.seen+7200 then q.state="target-lost"
            elseif (q.x-p.x)^2+(q.y-p.y)^2>RANGE2 then q.state="out-of-range"
            else
                if r.railWatch then rail.describe(map,r,q,e.entity) end
                q.weight, q.cover = e.weight, brain.turretsAround(map,c)
                q.steps = (math.abs(c.x-cx)+math.abs(c.y-cy))/CHUNK
                if q.steps>STEPS then q.state="no-route"
                elseif q.cover>2 then q.state="new-cover"
                elseif field.frontPenalty(map,origin.x,origin.y,c,false,q.cover,tick)<0.5 then q.state="repeat-repulse"
                else
                    q.basis,q.priorBalance = outcome.precedent(map.colonyShadow,q,r,c,q.cover,tick)
                    if q.priorBalance and q.priorBalance<0 then q.state="keep-task"
                    else
                        local path=route.propose(map,r,q,e,c,cx,cy,tick)
                        if path==false then q.state="no-route"
                        else entries[i],chunks[i],paths[i],total=e,c,path,total+(path and path.steps or q.steps) end
                    end
                end
            end
        end
    end
    -- One shared allowance, not 40 steps per option. Never prefer the first
    -- enumerated site merely because the second did not fit the budget.
    if total>STEPS then return nil,nil,"choice-budget" end
    -- Length is a lower bound on a successful walk. Charge each actual edge
    -- test, including a blocked preferred axis, to this gathering only.
    local left=STEPS
    local function probe(m,from,to,axis)
        if left==0 then return nil end -- unknown, not an impassable edge
        left=left-1
        return route.connected(m,from,to,axis)
    end
    local a,b
    for i,q in ipairs(r.options) do
        if entries[i] then
            local path,ok=paths[i]
            if path then ok=route.check(map,path,squad,q,tick,field,probe)
            else ok=field.groundApproach(map,p,chunks[i],probe) end
            if ok==nil then return nil,nil,"choice-budget" end
            if ok then
                q.state="feasible"
                if not a then a=q else b=q end
            else q.state="no-route" end
        end
    end
    if not a then
        local q=r.options[r.target]
        if q.state=="keep-task" then r.basis,r.priorBalance=q.basis,q.priorBalance end
        return nil,nil,q.state
    end
    if not field.lockAvailable(map,tick) then return nil,nil,"occupied" end
    local checkPost = r.reason=='mobile-crossed'
    r.ordinary,r.localX,r.localY,r.stepX,r.stepY=brain.ordinaryOpportunity(map,squad,tick,checkPost)
    if r.ordinary=="local" then return nil,nil,"local-task" end
    if r.ordinary~="idle" and r.ordinary~="move" then return nil,nil,"unknown-task" end
    if checkPost then
        if b then return nil,nil,'shift-unconfirmed' end
        local clear,why=shift.confirm(map,r,a,tick,p)
        if not clear then return nil,nil,why or 'shift-unconfirmed' end
    end
    if b then
        if dominates(b,a) then a=b
        elseif not dominates(a,b) then
            local tie=rail.breakTie(r,a,b)
            if not tie then air.forecast(map,r,a,b,tick);return nil,nil,"no-edge" end
            a=tie
        end
    end
    focus(r,a)
    r.pick = a.target==r.raidFront and "first" or "second"
    r.untilTick = math.min(r.untilTick, a.seen+7200)
    return entries[a.target],chunks[a.target],nil,paths[a.target]
end

local labels={candidate="choice-pending",unsupported="choice-unsupported",feasible="choice-feasible"}
local function detail(q)
    return {"rampant-colony.choice-option", q.unit or "—", {"rampant-colony."..(labels[q.state] or "status-"..q.state)},
        q.weight or "—", q.cover or "—", q.steps or "—", q.priorBalance or "—", q.basis or "—"}
end

function choice.report(r,lines)
    shift.report(r,lines)
    local opts=r.options
    local a=opts and opts[r.raidFront]; local b=opts and opts[3-r.raidFront]
    if r.raidCoverGroup or (a and a.coverGroup) or (b and b.coverGroup) then
        lines[#lines+1]={"rampant-colony.choice-cover",r.id,r.raidCoverGroup or "—",r.raidDoubt or "—",
            a and a.coverGroup or "—",a and a.coverTick or "—",b and b.coverGroup or "—",b and b.coverTick or "—"}
    end
    if not opts or not r.choiceTick then return end
    route.report(r,lines)
    air.report(r,lines)
    rail.report(r,lines)
    lines[#lines+1]={"rampant-colony.choice", r.id,r.choiceTick,{"rampant-colony.job-"..(r.ordinary or "unchecked")},r.localX or "—",r.localY or "—",
        detail(r.options[r.raidFront]),detail(r.options[3-r.raidFront]),{"rampant-colony.pick-"..r.pick},r.raidHit or "—"}
    local mode = r.choiceMode == "command" and "funnel-command" or r.choiceMode == "shadow" and "funnel-shadow" or "mode-unknown"
    lines[#lines+1] = {"rampant-colony.choice-authority",r.id,r.choiceTick,{"rampant-colony."..mode}}
end

return choice
