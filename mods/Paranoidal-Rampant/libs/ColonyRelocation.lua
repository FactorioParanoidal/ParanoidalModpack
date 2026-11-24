-- Reinspect two local encounters, not a vehicle's journey. Enemy unit numbers
-- label the journal; do not identify a vehicle across an unseen stretch of map.
local shift = {}
local rail = require('ColonyRail')
local gates = require('AIPredicates')
local CHUNK = require('Constants').CHUNK_SIZE
local function near(a,b,r) return (a.x-b.x)^2+(a.y-b.y)^2 <= r*r end
local function sight(e) return math.min(32,e.prototype.vision_distance) end
local function paid(map,sq,unit)
    return sq.formationCost and sq.formationCost>0 and not (sq.retreated or sq.excluded)
        and unit and unit.valid and unit.unit_number and unit.force.name=='enemy'
        and sq.group and sq.group.valid and sq.group.unique_id==sq.groupNumber
        and map.universe.groupNumberToSquad[sq.groupNumber]==sq
end

-- At most once per front in this operation. A surviving member of the
-- casualty's paid squad sees the defender within its own prototype's vision.
local function partner(map,sq,victim,vehicle)
    local at=vehicle.position
    local nearby=map.surface.find_entities_filtered{position=at,radius=32,type='unit',force=victim.force,limit=8}
    local eye
    for _,e in ipairs(nearby) do
        if e~=victim and e.unit_number and (not eye or e.unit_number<eye.unit_number) and gates.groundMember(map.surface,sq,e)
            and e.health>0 and near(e.position,at,sight(e)) and near(e.position,victim.position,sight(e)) then eye=e end
    end
    if not eye then return end
    local peers=map.surface.find_entities_filtered{position=eye.position,radius=sight(eye),type=vehicle.type,force=vehicle.force,limit=2}
    if #peers==1 and peers[1]==vehicle then return eye.unit_number end
end

function shift.contact(map,op,side,front,sq,unit,car,p,tick)
    local m=op.motion
    if m==false or (side==op.a and not m) then return end
    local localCar=car and (car.type=='car' or car.type=='spider-vehicle') and car.unit_number and paid(map,sq,unit)
        and near(car.position,p,32) and near(car.position,front,64)
    if side==op.b and m==nil and not op.coverTick and not op.mobile and not op.fixed and not op.raidDoubt
        and sq.groupNumber~=op.probe and localCar then
        local eye=partner(map,sq,unit,car);local at=car.position
        op.motion=eye and {vehicle=car.unit_number,kind=car.type,model=car.name,from=tick,x=at.x,y=at.y,partner=eye} or false
    elseif side==op.a and m and not m.at and op.cover=='mobile' and not op.mobile and not op.fixed and not op.raidDoubt
        and sq.groupNumber==op.probe and localCar and car.name==m.model and tick>m.from then
        local eye=partner(map,sq,unit,car)
        if eye then
            m.at,m.raidVehicle,m.raidAt,m.raidPartner=tick,car.unit_number,car.position,eye
            op.needed=2 -- familiar replies never substitute for a fresh second report
        else op.motion=false end
    else op.motion=false end
end

local buildings={['assembling-machine']=true,['mining-drill']=true,radar=true,roboport=true}
function shift.localHit(map,sq,unit,p,building,force)
    return building and building.valid and buildings[building.type] and building.unit_number
        and building.force.name==force and building.surface==map.surface and paid(map,sq,unit) and near(unit.position,p,sight(unit))
end

local guards={'character','car','spider-vehicle','turret','ammo-turret','electric-turret','fluid-turret','artillery-turret'}
local function observer(map,r,id,number,site)
    if not number then return end
    local e=rail.eye(map,r,id)
    local sq=e and map.universe.groupNumberToSquad[id]
    if sq and sq.groupNumber==id and sq.group.unique_id==id and e.unit_number==number and e.force.name=='enemy'
        and e.health>0 and near(e.position,site,sight(e)) then return e end
end

-- Gathering only, after the actual candidate and ordinary job qualify. B's
-- initial eye must also be one of the credited post-response hit witnesses,
-- and see both the original guard position and the actual candidate now.
function shift.confirm(map,r,q,tick,position)
    local m=r.motion
    if not m or not m.raidAt or not m.partner or not m.model or not m.raidPartner or m.raidPartner~=m.raidEye
        or q.target==r.raidFront or q.cover~=0 or not r.peerSince or tick>=r.untilTick or not near(q,m,32) then return false end
    local hostile=map.universe.activePlayerForces
    if not hostile or not hostile[1] then return false end
    local a=observer(map,r,r.probe,m.raidEye,m.raidAt)
    local n=r.coverGroup==r.firstHit and m.firstEye or r.coverGroup==r.secondHit and m.secondEye
    if not a or n~=m.partner then return false end
    local b=observer(map,r,r.coverGroup,n,q)
    if not b or not near(b.position,m,sight(b)) then return false end
    local cars=map.surface.find_entities_filtered{position=a.position,radius=sight(a),force=q.force,type=m.kind,limit=2}
    if #cars~=1 or cars[1].name~=m.model or not near(cars[1].position,m.raidAt,32) or not near(a.position,cars[1].position,sight(a)) then return false end
    m.seenA,m.seenB,m.nowVehicle=a.unit_number,b.unit_number,cars[1].unit_number
    -- The initial post is INSIDE this local inspection. A clear footprint
    -- says nothing about stock, distant defenders or the next arrival.
    local seen=map.surface.find_entities_filtered{position=b.position,radius=sight(b),force=hostile,type=guards,limit=1}
    if seen[1] then m.blocker=seen[1].unit_number;return false end
    -- An open second site alone says nothing about the ordinary alternative.
    -- Compare its *current* scent projection to the raid witness's own view.
    local at=cars[1].position
    m.postX,m.postY=math.floor(at.x/CHUNK)*CHUNK,math.floor(at.y/CHUNK)*CHUNK
    if r.stepX~=m.postX or r.stepY~=m.postY or not near(a.position,
        {x=r.stepX+position.x%CHUNK,y=r.stepY+position.y%CHUNK},sight(a)) then return false,'shift-off-route' end
    return true
end

function shift.report(r,lines)
    local m=r.motion
    if not m then return end
    if m.partner then
        lines[#lines+1]={'rampant-colony.mobile-sites',r.id,m.vehicle,m.from,m.raidVehicle,m.at,m.partner,m.nowVehicle or '—',m.seenA or '—',m.seenB or '—'}
    else lines[#lines+1]={'rampant-colony.mobile-trace',r.id,m.vehicle,m.from,m.at,m.seenA or '—',m.seenB or '—'} end
    if m.postX then lines[#lines+1]={'rampant-colony.mobile-path',r.id,r.stepX or '—',r.stepY or '—',m.postX,m.postY} end
    if m.blocker then lines[#lines+1]={'rampant-colony.mobile-guard',r.id,m.seenB,m.blocker,r.unit} end
end
return shift
