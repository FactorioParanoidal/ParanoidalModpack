-- Shadow comparison only. Keep one receipt per surface, not a fleet index.
-- An area order is not an assignment to a building, proof of ground access,
-- or evidence that no other flight is operating elsewhere.
local air = {}
local gates = require('AIPredicates')
local live = require('ChunkQueue').isLive

function air.issued(map,sq,goal,tick)
    local u,raid=map.universe,sq.localRaid
    if not u.colonyMind or not sq.flight or sq.external or sq.flightObjective or goal.kind~='strike'
        or not raid or raid.goal~=goal or not raid.flight or not goal.issued then return end
    local old=map.colonyAirArea;local ambiguous
    if old and old.epoch==u.colonyEpoch and old.dip==u.frontRevision and old.order==map.orderEpoch then
        ambiguous=old.ambiguous
        if old.id~=sq.groupNumber and old.ends>tick then ambiguous=math.max(ambiguous or 0,old.ends) end
    end
    raid.airStamp=tick
    map.colonyAirArea={id=sq.groupNumber,stamp=tick,ends=sq.strikeUntil,epoch=u.colonyEpoch,dip=u.frontRevision,
        order=map.orderEpoch,ambiguous=ambiguous and ambiguous>tick and ambiguous or nil}
end

-- Called only after BOTH independent ground checks, the ordinary task and
-- the lock/rail comparison. Nothing returned here can be used as authority.
function air.forecast(map,r,a,b,tick)
    local u,v=map.universe,map.colonyAirArea
    if not v or not u.colonyMind or v.epoch~=u.colonyEpoch or v.dip~=u.frontRevision or v.order~=map.orderEpoch
        or tick>=v.ends or (v.ambiguous and tick<v.ambiguous) or a.weight~=b.weight or a.steps~=b.steps
        or a.cover~=b.cover or (a.priorBalance or 0)~=(b.priorBalance or 0) then return end
    local sq=u.groupNumberToSquad[v.id];local raid=sq and sq.localRaid;local g=sq and sq.group
    if not raid or raid.airStamp~=v.stamp or not raid.flight or not sq.flight or sq.external or sq.map~=map
        or sq.flightPhase~='strike' or sq.flightObjective or sq.returnAfterStrike or sq.strikeUntil~=v.ends
        or (sq.doctrineEpoch or 0)~=(u.doctrineEpoch or 0) or (sq.orderEpoch or 0)~=(map.orderEpoch or 0)
        or not g or not g.valid or g.surface~=map.surface or g.unique_id~=v.id or not gates.flyerEvolutionAllows(map.surface) then return end
    local goal=raid.goal;local cmd=g.command
    if not goal or not goal.issued or goal.done or goal.kind~='strike' or not live(map,goal.targetChunk)
        or not cmd or cmd.type~=defines.command.compound then return end
    local legs=cmd.commands;local area=legs and legs[#legs];local p=area and area.destination
    if not area or area.type~=defines.command.attack_area or not p or p.x~=goal.x or p.y~=goal.y or area.radius~=24 then return end
    local function overlaps(q) return (p.x-q.x)^2+(p.y-q.y)^2<=area.radius^2 end
    local one,two=overlaps(a),overlaps(b);if one==two then return end
    r.airGroup,r.airTick,r.airSite,r.airOther=v.id,v.stamp,one and a.unit or b.unit,one and b.unit or a.unit
end

function air.report(r,lines)
    if r.airGroup then lines[#lines+1]={'rampant-colony.air-forecast',r.id,r.airGroup,r.airTick,r.airSite,r.airOther} end
end
return air
