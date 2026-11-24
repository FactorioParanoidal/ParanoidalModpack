-- Local approach evidence, not a second pathfinder. One loss site in each
-- dated building sighting; one perpendicular lane indicated by a real ground
-- reporter. All route probes are charged to the two sites' shared allowance.
local route = {}
local C = require('Constants')
local gates = require('AIPredicates')
local rail = require('ColonyRail')
local live = require('ChunkQueue').isLive
local turretCount = require('ChunkPropertyUtils').getPlayerTurretCount
local N, LIFE = C.CHUNK_SIZE, 5400
local function at(map,x,y) return map[x] and map[x][y] end
local function coord(x) return math.floor(x/N)*N end
local function pass(c,axis) return c and (c.terrainPass==C.CHUNK_ALL_DIRECTIONS or c.terrainPass==axis) end

-- A direction flag alone doesn't say where a strip meets its neighbour.
-- Full rows and columns cross inside turns; successive parallel strips must
-- meet at the same offset. No search for a second strip. For legacy chunks
-- test just the central strip once on demand with the original terrain mask.
local function lane(map,c,axis)
    if not pass(c,axis) then return end
    local vertical=axis==C.CHUNK_NORTH_SOUTH
    local key=vertical and 'colonyCol' or 'colonyRow'
    local v=c[key]
    if v==nil then
        local x,y=c.x,c.y
        local area=vertical and {{x+16,y},{x+17,y+N}} or {{x,y+16},{x+N,y+17}}
        v=map.surface.count_tiles_filtered{area=area,collision_mask='player',limit=1}==0
            and map.surface.count_entities_filtered{area=area,type='cliff',limit=1}==0 and 16 or false
        c[key]=v
    end
    return v
end
function route.connected(map,a,b,axis)
    if not pass(a,axis) or not pass(b,axis) then return false end
    local v=lane(map,a,axis)
    return v and v==lane(map,b,axis) or false
end

-- A saved logical goal is not ownership of a replacement engine command.
function route.ownsMove(cmd,g)
    if not cmd or not g.moveX or cmd.type~=defines.command.compound or cmd.structure_type~=defines.compound_command.return_last then return false end
    local s=cmd.commands
    -- Factorio removes the completed one-tick wander, not the compound wrapper.
    local n=#s
    if n~=1 and (n~=2 or s[1].type~=defines.command.wander or s[1].ticks_to_wait~=1) then return false end
    local m=s[n]
    if m.type~=defines.command.go_to_location or m.destination_entity or (m.radius and m.radius~=3) then return false end
    local p=m.destination
    if not p or p.x~=g.moveX or p.y~=g.moveY or not g.moveDistraction or m.distraction~=g.moveDistraction then return false end
    -- Same waypoint with a different path policy is a different move. The
    -- producer requests caching and leaves the other PathfinderFlags at default.
    local f=m.pathfind_flags
    return not f or (f.cache~=false and not f.low_priority and not f.no_break and not f.prefer_straight_paths
        and not f.allow_destroy_friendly_entities and not f.allow_paths_through_own_entities)
end

local function same(h,map,e,c,b,cover)
    local u=map.universe
    return h and h.target==c and h.bad==b and live(map,b) and h.badRevision==b.passRevision
        and h.targetRevision==c.passRevision and h.defRev==c.frontDefenceRevision and h.cover==cover
        and h.badCover==turretCount(map,b) and h.epoch==u.colonyEpoch and h.dip==u.frontRevision and h.order==map.orderEpoch
        and h.force==e.force and h.x==e.x and h.y==e.y
end

-- The existing death event supplies the actual member and hostile force.
-- Area raids cannot identify a concrete building. A second casualty from
-- the same assignment is not a second independent approach.
function route.loss(map,sq,g,tick,p,victim,force,brain)
    local u=map.universe
    if g.routeNoted or g.issued or g.walker~=sq.groupNumber or g.walkEpoch~=u.colonyEpoch or sq.retreated
        or g.kind~='objective' or map.objectiveRaid~=g or sq.goal~=g or g.epoch~=u.frontRevision
        or not sq.learn or sq.flight or sq.external or sq.support or sq.undergoundAttack or sq.settlers or sq.excluded
        or not sq.formationCost or sq.formationCost<=0 or tick>=g.untilTick or (sq.orderEpoch or 0)~=(map.orderEpoch or 0)
        or map.suspended or not gates.attackAllowed(map,tick) or not gates.groundMember(map.surface,sq,victim)
        or u.groupNumberToSquad[sq.groupNumber]~=sq or not route.ownsMove(sq.group.command,g) then return end
    local c,b=g.targetChunk,at(map,coord(p.x),coord(p.y))
    if not b or math.abs(b.x-c.x)+math.abs(b.y-c.y)~=N or not b.terrainPass or b.terrainPass==C.CHUNK_IMPASSABLE then return end
    if g.colonyRecord and not brain.field.colony.orders.owner(map,sq,g,tick) then return end
    local e,target=brain.field.resolveReserve(map,{unit=g.unit,x=g.x,y=g.y,force=force},tick)
    if not e or target~=c or e.entity~=g.entity then return end
    local cover=brain.turretsAround(map,c);local h=e.approachLoss
    if not same(h,map,e,c,b,cover) or tick>=h.last.tick+LIFE then
        h={target=c,bad=b,badRevision=b.passRevision,targetRevision=c.passRevision,defRev=c.frontDefenceRevision,cover=cover,
            badCover=turretCount(map,b),epoch=u.colonyEpoch,dip=u.frontRevision,order=map.orderEpoch,force=force,x=e.x,y=e.y}
        e.approachLoss=h
    elseif h.last.id~=sq.groupNumber then h.previous=h.last end
    h.last={id=sq.groupNumber,tick=tick};g.routeNoted=true
end

-- nil: no applicable history. false: this corridor repeats two dated losses
-- but no single alternate ingress is corroborated. Never pick a compass side
-- by iteration order. A distant group centre cannot stand in for a witness.
function route.propose(map,r,q,e,c,x,y,tick)
    local h=e.approachLoss
    if not h or not h.previous or tick>=h.previous.tick+LIFE or not same(h,map,e,c,h.bad,q.cover) then return end
    local dx,dy=c.x-h.bad.x,c.y-h.bad.y
    if dx~=0 and (y~=c.y or (c.x-x)*dx<=0) or dy~=0 and (x~=c.x or (c.y-y)*dy<=0) then return end
    q.badX,q.badY,q.loss1,q.lossTick1,q.loss2,q.lossTick2=h.bad.x,h.bad.y,h.previous.id,h.previous.tick,h.last.id,h.last.tick
    if q.steps<2 then return false end -- already in the casualty chunk
    local ox,oy,by
    local function witness(id)
        local eye=rail.eye(map,r,id)
        if not eye then return true end
        local pos=eye.position;local sx,sy=coord(pos.x)-c.x,coord(pos.y)-c.y
        if math.abs(sx)+math.abs(sy)~=N or sx*dx+sy*dy~=0 then return true end
        if by and (ox~=sx or oy~=sy) then return false end
        ox,oy,by=sx,sy,by or id;return true
    end
    if q.target==r.raidFront then witness(r.probe)
    elseif not witness(r.firstHit) or not witness(r.secondHit) then return false end
    if not by then return false end
    return {x=x,y=y,dx=dx,dy=dy,ox=ox,oy=oy,steps=q.steps+2,by=by,h=h,expires=h.previous.tick+LIFE}
end

-- Start -> parallel lane -> witnessed side of the building -> building.
-- Store only the chosen corridor on the live goal, never all paths on a map.
function route.check(map,path,sq,q,tick,field,probe)
    local x,y=path.x,path.y;local nodes={};local revisions={}
    local c=at(map,x,y);if not c then return false end
    nodes[1],revisions[1]=c,c.passRevision
    for i=1,path.steps do
        local dx,dy=path.dx,path.dy
        if i==1 then dx,dy=path.ox,path.oy elseif i==path.steps then dx,dy=-path.ox,-path.oy end
        x,y=x+dx,y+dy;local b=at(map,x,y);local axis=dx==0 and C.CHUNK_NORTH_SOUTH or C.CHUNK_EAST_WEST
        local ok=probe(map,c,b,axis)
        if not ok then return ok end
        if (i<path.steps and turretCount(map,b)>0) or field.edgeScore(map,sq,c,b,0,tick)<0 then return false end
        nodes[i+1],revisions[i+1]=b,b.passRevision;c=b
    end
    path.nodes,path.revisions,path.next=nodes,revisions,2
    q.steps,q.sideX,q.sideY,q.sideBy=path.steps,c.x+path.ox,c.y+path.oy,path.by
    return true
end

-- Before another movement or attack, a rescan, lost sighting, new defence
-- or aged evidence cancels this owned walk. No world scan or route search.
function route.current(map,g,tick,brain)
    local path=g.colonyPath
    if not path or g.issued then return true end
    local c,h=g.targetChunk,path.h
    local e,target=brain.field.resolveReserve(map,g.colonyRecord,tick)
    if tick>=path.expires or target~=c or not e or e.approachLoss~=h or not same(h,map,e,c,h.bad,brain.turretsAround(map,c)) then return false end
    for i,b in ipairs(path.nodes) do
        if not live(map,b) or b.passRevision~=path.revisions[i] or (i>1 and i<#path.nodes and turretCount(map,b)>0) then return false end
    end
    return true
end

-- false: a distraction took the group off the admitted lane. nil: it can
-- now use the normal final attack/reach, not a new attack-area command.
local function point(nodes,i)
    local b,a,d=nodes[i],nodes[i-1],nodes[i+1]
    local x=(a.x==b.x or d.x==b.x) and b.colonyCol or 16
    local y=(a.y==b.y or d.y==b.y) and b.colonyRow or 16
    return {x=b.x+x+.5,y=b.y+y+.5}
end
function route.waypoint(path,p)
    local i=path.next;local b=path.nodes[i];local x,y=coord(p.x),coord(p.y)
    if x==b.x and y==b.y then
        if i==#path.nodes then return end
        local aim=point(path.nodes,i)
        if (p.x-aim.x)^2+(p.y-aim.y)^2>12^2 then return aim end
        i=i+1;path.next=i;b=path.nodes[i]
    else
        local prev=path.nodes[i-1];if x~=prev.x or y~=prev.y then return false end
    end
    if i<#path.nodes then return point(path.nodes,i) end
end

function route.report(r,lines)
    for _,q in ipairs(r.options) do
        if q.badX then
            lines[#lines+1]={'rampant-colony.route-evidence',r.id,q.unit,q.badX,q.badY,q.loss1,q.lossTick1,q.loss2,q.lossTick2}
            if q.sideBy then lines[#lines+1]={'rampant-colony.route-side',q.sideBy,q.sideX,q.sideY,q.steps} end
        end
    end
end
return route
