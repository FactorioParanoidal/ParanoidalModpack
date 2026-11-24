-- Local feedback for a paid Factorio assignment. The observation journal owns
-- the record; each of the two front slots remembers at most one such record.
local outcome = {}
local LIFE = 5400 -- same horizon as ordinary ground-raid evidence

-- Only named participants: probe, up to two hit witnesses, first contrary
-- witness per front/phase, executor. Repeat roles never repay a formation.
function outcome.join(record, squad)
    local crew, id = record.crew, squad.groupNumber
    if crew and not crew[id] then
        crew[id] = {cost = squad.formationCost, size = squad.startSize, retreatAt = squad.retreatAt,
            before = squad.losses or 0, lost = 0}
    end
end

-- Regroup consumes the donor once. Keep its known formation price (never a
-- new charge), without retaining a growing list of disbanded groups. A donor
-- already in the role ledger was counted on entry; future losses belong to
-- the receiving group, not to both. Do not infer earlier transfers or prices.
function outcome.reinforce(r, donor, units)
    local a = r.reinforcement
    if not a then
        a = {sources=0, units=0, other=0, points=0, unknown=0, before=0}
        r.reinforcement = a
    end
    a.sources, a.units, a.last = a.sources + 1, a.units + units, donor.groupNumber
    if not r.crew[donor.groupNumber] then
        a.other = a.other + 1
        a.before = a.before + (donor.losses or 0)
        if donor.formationCost ~= nil then a.points = a.points + donor.formationCost else a.unknown = a.unknown + 1 end
    end
end

local function totals(r)
    local a = r.reinforcement
    local groups, points, unknown, lost, before, light = 0, 0, 0, 0, 0, true
    local atSite, elsewhere = 0, 0
    if a then groups, points, unknown, before = a.other, a.points, a.unknown, a.before end
    for _, p in pairs(r.crew) do
        groups = groups + 1
        if p.cost ~= nil then points = points + p.cost else unknown = unknown + 1 end
        before = before + p.before -- reported separately, not charged to this assignment
        lost = lost + p.lost
        -- Don't promote an expensive success as evidence of an easy repeat.
        -- Use the group's own ordinary withdrawal share, not a new price for a biter.
        local away = p.awayLosses or 0
        atSite, elsewhere = atSite + (p.siteLosses or 0), elsewhere + away
        -- Only a witnessed off-site fight by a supporting group is excluded
        -- from the repeat estimate. Unclassified/legacy losses still count.
        if not p.size or not p.retreatAt or p.lost - away >= p.size * p.retreatAt then light = false end
    end
    return groups, points, unknown, lost, before, light and unknown == 0, atSite, elsewhere
end

local function previous(s, r, chunk, defence, tick, members, cost)
    local front, peer = s.fronts[r.target], s.fronts[3-r.target]
    local m = front.continuation
    if not m then return end
    local p = m.record
    if not p.regroupTracked or p.reinforcement or tick >= p.ended + LIFE or (m.chunk == chunk and (m.revision ~= chunk.passRevision
        or m.coverRevision ~= chunk.frontDefenceRevision or m.defence ~= defence)) then
        front.continuation = nil -- don't revive a superseded observation if the count returns to its old value
        return
    end
    if m.chunk ~= chunk or m.peerSince ~= peer.since or m.peerX ~= peer.x or m.peerY ~= peer.y
        or p.action ~= r.action or p.reason ~= r.reason or p.force ~= r.force or p.prototype ~= r.prototype or p.x ~= r.x or p.y ~= r.y
        or not members or not p.members or not cost or cost ~= p.cost then return end
    -- Do not generalise a small failed group to a larger one, or a large
    -- group's success to fewer members. Never ask for a bigger wave.
    if (p.balance < 0 and members > p.members) or (p.balance > 0 and members < p.members) then return end
    return p
end

function outcome.precedent(s, option, r, chunk, defence, tick)
    if not r.crew or not r.regroupTracked or r.reinforcement then return end -- not one comparable formation
    local p = previous(s, option, chunk, defence, tick, r.members, r.cost)
    if p then return p.id, p.balance end
end

function outcome.learn(map, r, goal, status, tick, field)
    if not r.crew or not r.regroupTracked or r.reinforcement then return end -- journal the battle, not a repeat for the original squad
    if not r.issued or not goal.checked or map.objectiveRaid ~= goal then return end
    if status == 'achieved' then
        if not goal.confirmed then return end
    elseif status == 'repelled' then
        if not r.targetLosses or r.targetLosses == 0 or not field.colonyTargetLive(map, goal) then return end
    else return end
    local c, s = goal.targetChunk, map.colonyShadow
    if map.universe.frontRevision ~= goal.epoch or not c or map[c.x] == nil or map[c.x][c.y] ~= c
        or goal.defence == nil or c.frontDefence ~= goal.defence or c.passRevision ~= goal.revision
        or c.frontDefenceRevision ~= goal.defenceRevision then return end
    local p = previous(s, r, c, goal.defence, tick, r.members, r.cost)
    local _, _, _, _, _, light = totals(r)
    local delta = status == 'repelled' and -1 or light and 1 or 0
    r.balance = delta == 0 and 0 or math.max(-1, math.min(1, (p and p.balance or 0) + delta))
    local peer = s.fronts[3-r.target]
    s.fronts[r.target].continuation = {record = r, chunk = c, revision = c.passRevision, defence = goal.defence,
        coverRevision = c.frontDefenceRevision, peerSince = peer.since, peerX = peer.x, peerY = peer.y}
end

function outcome.report(r, lines)
    if not r.crew then return end
    local n, points, unknown, lost, before, _, atSite, elsewhere = totals(r)
    lines[#lines+1] = {'rampant-colony.operation-cost', r.id, n, points, unknown, lost,
        r.routeLosses or '—', r.targetLosses or '—', before}
    if lost > 0 then
        lines[#lines+1] = {'rampant-colony.loss-scope', r.id, atSite, elsewhere, lost - atSite - elsewhere}
    end
    local a = r.reinforcement
    if a then lines[#lines+1] = {'rampant-colony.operation-regroup', r.id, r.members or '—', a.units, a.sources, a.last} end
    if r.basis or r.balance ~= nil then
        lines[#lines+1] = {'rampant-colony.operation-memory', r.id, r.basis or '—', r.priorBalance or '—', r.balance or '—'}
    end
end

return outcome
