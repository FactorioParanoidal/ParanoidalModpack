-- Local train-stop sightings for Colony Mind. No fleet or entity searches:
-- the existing train event supplies a stopped train; a named, paid ground
-- participant must actually be present. Neither rails nor stock become goals.
local rail = {}
local gates = require('AIPredicates')
local CHUNK = require('Constants').CHUNK_SIZE
local function near(a,b,range)
    return (a.x-b.x)^2+(a.y-b.y)^2 <= range^2
end

-- A group's position can be its gathering point even if no unit is there.
-- Pin the actual ground unit credited by the existing hit event (at most
-- one per named role); never enumerate a squad or acquire another scout.
local function newMember(r,id,unit,tick)
    if not r or not r.crew or r.partial or (r.status and r.status~='await-slot' and r.status~='gathering')
        or tick >= (r.deadline or r.untilTick) or (id~=r.probe and id~=r.firstHit and id~=r.secondHit) then return false end
    local paid,w=r.crew[id],r.railWatch
    return paid and paid.cost and paid.cost>0 and not (w and w.eyes and w.eyes[id]==unit)
end

-- Off-front hits compete for ingress only when rail can use a new eye.
-- A front hit already admitted on its own merits can locate a ground witness
-- even when the train-arrival history is incomplete.
function rail.newEye(r,id,unit,tick)
    return r and not (r.railWatch and r.railWatch.incomplete) and newMember(r,id,unit,tick)
end

function rail.noteHit(map,sq,unit,tick)
    local s=map.colonyShadow
    local r=s and (s.op or s.ticket)
    local id=sq.groupNumber
    if not newMember(r,id,unit,tick) or not gates.groundMember(map.surface,sq,unit) then return end
    local w=r.railWatch
    if not w then w={};r.railWatch=w end
    w.eyes=w.eyes or {};w.eyes[id]=unit
end

-- The same credited ground member can locate an ingress at gathering.
-- Read only the pinned member, never the group's rally point or a member list.
function rail.eye(map,r,id)
    local u,w=map.universe,r.railWatch
    local paid=id and r.crew and r.crew[id]; local sq=paid and paid.cost and paid.cost>0 and u.groupNumberToSquad[id]
    if not (w and sq and sq.learn and not (sq.external or sq.flight or sq.undergoundAttack or sq.settlers or sq.retreated or sq.excluded)
        and (sq.doctrineEpoch or 0)==(u.doctrineEpoch or 0) and (sq.orderEpoch or 0)==(map.orderEpoch or 0)) then return end
    local g=sq.group;local eye=w.eyes and w.eyes[id]
    if g and g.valid and g.surface==map.surface and gates.groundMember(map.surface,sq,eye) then return eye end
end

local function witness(map,r,side,station,vehicle)
    local function sees(id)
        local eye=rail.eye(map,r,id)
        if eye and near(eye.position,station,64) and near(eye.position,vehicle,64) then return id end
    end
    if side==(r.a or r.raidFront) then return sees(r.probe) end
    return sees(r.firstHit) or sees(r.secondHit)
end

local function intact(map,v)
    local e=v.station
    return e.valid and e.surface==map.surface and e.force.name==v.force and e.position.x==v.x and e.position.y==v.y
end

-- At most 16 actual arrival events examined per tick for the one current
-- operation. If arrivals were missed, discard the rail discriminator only.
function rail.arrived(map,train,firstStock,tick)
    local s,u=map.colonyShadow,map.universe
    if not (s and u.colonyMind and u.colonySurface==map.surface.index and s.epoch==u.colonyEpoch
        and s.diplomacy==u.frontRevision and s.order==map.orderEpoch and not map.suspended) then return end
    local r=s.op or s.ticket
    if not r or not r.crew or r.partial or (r.status and (not r.options or (r.status~='await-slot' and r.status~='gathering')))
        or tick >= (r.deadline or r.untilTick) then return end
    local w=r.railWatch
    if w and w.incomplete then return end
    if not w then w={};r.railWatch=w end
    if w.tick~=tick then w.tick,w.count=tick,0 end
    if w.count==16 then w.incomplete=true;return end
    w.count=w.count+1
    local stop=train.station
    if not (stop and stop.valid and stop.surface==map.surface and gates.attackAllowed(map,tick)) then return end
    local force=stop.force.name
    if not (u.activePlayerForceSet and u.activePlayerForceSet[force] and firstStock.force.name==force) then return end
    local p=stop.position
    for i,f in ipairs(s.fronts) do
        if f.force==force and near(f,p,96) then
            local v=w[i]
            if r.options and r.options[i].state~='candidate' then return end
            if v and (v.station~=stop or not v.left or v.again or not intact(map,v) or tick<=v.left) then return end
            local stock=firstStock
            if not near(stock.position,p,16) then stock=train.back_stock end -- reversing a multi-car train
            if not (stock and stock.valid and stock.surface==map.surface and stock.force.name==force and near(stock.position,p,16)) then return end
            local at=stock.position;local id=witness(map,r,i,p,at)
            if id then
                if v then v.again,v.againBy=tick,id
                else w[i]={station=stop,stopId=stop.unit_number,x=p.x,y=p.y,force=force,first=tick,firstBy=id,
                    stock=stock,parked=at} end
            end
            return
        end
    end
end

-- Inside the existing 60-tick observation. The witness must see the original
-- carriage move off while the stop has no stopped train; no train-ID counting.
function rail.step(map,r,tick)
    local w=r.railWatch
    if not w or not w.tick or w.incomplete or tick >= (r.deadline or r.untilTick) then return end
    for i=1,2 do
        local v=w[i]
        if v and not v.left and tick>v.first and intact(map,v) then
            local stock=v.stock
            if stock.valid and stock.surface==map.surface and stock.force.name==v.force then
                local pos=stock.position
                if not near(pos,v.parked,16) then
                    local id=witness(map,r,i,v,pos)
                    if id and not v.station.get_stopped_train() then
                        v.left,v.leftBy,v.stock,v.parked=tick,id,nil,nil
                    end
                end
            end
        end
    end
end

-- Record facts, not 'inactive' on the other front, and never infer unloading.
-- Missing old-save evidence has no weight. Use only a previously admitted
-- assembler or drill near the same physical stop, not all buildings on a line.
function rail.describe(map,r,q,e)
    local w=r.railWatch
    local v=w and not w.incomplete and w[q.target]
    if not v or (e.type~='assembling-machine' and e.type~='mining-drill') or not intact(map,v)
        or v.force~=q.force or not near(q,v,CHUNK) then return end
    q.stopId,q.arrival,q.arrivedBy=v.stopId,v.first,v.firstBy
    q.vacancy,q.leftBy,q.returned,q.returnedBy=v.left,v.leftBy,v.again,v.againBy
end

function rail.breakTie(r,a,b)
    if a.weight~=b.weight or a.cover~=b.cover or a.steps~=b.steps or (a.priorBalance or 0)~=(b.priorBalance or 0)
        or (not not a.returned)==(not not b.returned) then return end
    local q=a.returned and a or b
    r.railTie,r.railGate=q.stopId,r.railWatch[q.target]
    return q
end

function rail.current(map,r)
    return not r.railGate or intact(map,r.railGate)
end

function rail.report(r,lines)
    if not r.options then return end
    for _,q in ipairs(r.options) do
        if q.stopId then
            lines[#lines+1]={'rampant-colony.rail-visits',r.id,q.unit,q.stopId,q.arrivedBy,q.arrival,
                q.leftBy or '—',q.vacancy or '—',q.returnedBy or '—',q.returned or '—'}
        end
    end
    if r.railTie then lines[#lines+1]={'rampant-colony.rail-tie',r.id,r.railTie} end
    if r.railIncomplete then lines[#lines+1]={'rampant-colony.rail-incomplete',r.id} end
end

return rail
