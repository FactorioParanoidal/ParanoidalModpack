-- Reforged Paranoidal: flights - flyer units acting on their own.
--
-- Flyers (startup setting rampantFixed--flyers) cross walls, water and cliffs. In the old behaviour they simply
-- walked with the ground squads. Here they form flights of their own:
--  * a ground attack squad that gathered flyers hands them over to a new flight;
--  * every few seconds a map may launch a flight from free flyers around an active nest, independently of the
--    ground waves (more often while a ground strike is under way, to hit somewhere else at the same time);
--  * a flight picks a weak spot of the player base (valuable, few turrets): shore targets are approached over the
--    water/void side, outposts and deep targets directly; target kinds are learned from outcomes;
--  * hit and run: after a short strike or heavy losses it moves to the next weak spot nearby or flies home.
-- Never before 10% evolution (flyers do not spawn earlier either, see SwarmUtils). Off in classic mode.

if flyerAIG then
    return flyerAIG
end
local flyerAI = {}

local constants = require("Constants")
local aiBrain = require("AIBrain")
local field = aiBrain.field
local chatNames = require("ChatNames")
local aiPredicates = require("AIPredicates")
local unitGroupUtils = require("UnitGroupUtils")
local mapUtils = require("MapUtils")
local squadCompression = require("SquadCompression")
local unitUtils = require("UnitUtils")

local CHUNK_SIZE = constants.CHUNK_SIZE
local SQUAD_RAIDING = constants.SQUAD_RAIDING

local createSquad = unitGroupUtils.createSquad
local canAttack = aiPredicates.canAttack
local getChunkByXY = mapUtils.getChunkByXY
local countPackedUnits = squadCompression.countPackedUnits
local championUnits = unitUtils.championUnits

local mRandom = math.random
local mFloor = math.floor
local mMax = math.max
local mMin = math.min

local DEFINES_DISTRACTION_NONE = defines.distraction.none
local DEFINES_DISTRACTION_BY_DAMAGE = defines.distraction.by_damage
local DEFINES_DISTRACTION_BY_ANYTHING = defines.distraction.by_anything

flyerAI.MIN_EVOLUTION = aiPredicates.FLYER_MIN_EVOLUTION
local MIN_FLIGHT_SIZE = 4
local MIN_SPLIT_SIZE = 3
local GATHER_RADIUS = 40
local GATHER_LIMIT = 30
local FLIGHT_COST = 20
local FLIGHT_RANGE = 40 * CHUNK_SIZE
local HOP_RANGE = 8 * CHUNK_SIZE
local MAX_HOPS = 2
local STRIKE_TICKS = 45 * 60        -- time on a target before moving on
local FLEE_LOSSES = 0.45
local FLYER_SPEED = 0.2             -- tiles per tick, for the travel time estimate

aiBrain.flyers = flyerAI

----------------------------------------------------------------------------------------------------------------------
-- flyer prototypes (same on every peer; not stored)

local flyerNameList
local flyerNameSet
local function loadFlyerNames()
    flyerNameList = {}
    flyerNameSet = {}
    for name in pairs(prototypes.get_entity_filtered({{filter = "type", type = "unit"}})) do
        if aiPredicates.isRampantFlyer(name) then
            flyerNameList[#flyerNameList + 1] = name
            flyerNameSet[name] = true
        end
    end
end

function flyerAI.isFlyer(name)
    if not flyerNameSet then
        loadFlyerNames()
    end
    return flyerNameSet[name] == true
end

local function flyersExist()
    if not flyerNameList then
        loadFlyerNames()
    end
    return #flyerNameList > 0
end

local function evolutionAllows(map)
    return aiPredicates.flyerEvolutionAllows(map.surface)
end

local function countFlights(universe)
    local count = 0
    for _, squad in pairs(universe.groupNumberToSquad) do
        if squad.flight then
            count = count + 1
        end
    end
    return count
end

local function flightCap(universe)
    return mMax(2, mFloor((universe.AI_MAX_SQUAD_COUNT or 20) * 0.25))
end

----------------------------------------------------------------------------------------------------------------------
-- targets

-- kinds: shore (approached from water/void), outpost (no turrets around), deep (most valuable weak spot)
local FLIGHT_KINDS = {"shore", "outpost", "deep"}
local kindNames = {}
local kindScores = {}

local function pickTarget(map, ai, x, y, range, excluded, tick)
    -- learned choice of the kind, then the best target of that kind
    local count = 0
    for i = 1, #FLIGHT_KINDS do
        local kind = FLIGHT_KINDS[i]
        local value, samples = aiBrain.valueOf(ai.flight, kind, tick)
        count = count + 1
        kindNames[count] = kind
        kindScores[count] = value + ((samples < 2) and 0.15 or 0)
    end
    local kind = aiBrain.softmaxPick(kindNames, kindScores, count, 0.15, 0.1)
    local escortX = ai.escortUntil > tick and ai.escortX or nil
    local preferred, preferredScore, backup, backupScore
    for _, pick in ipairs(aiBrain.weakCandidates(map, x, y, range, excluded, true, tick)) do
        local entry, c = pick.entry, pick.chunk
        local score = pick.value / (1 + pick.distance / 640) * (0.7 + mRandom() * 0.6)
        if escortX then
            local away = aiBrain.distance(c.x + 16, c.y + 16, escortX, ai.escortY)
            score = score * mMin(2, 0.5 + away / 320)
        end
        if not backupScore or score > backupScore then backup, backupScore = entry, score end
        if (kind == "deep" or (kind == "shore" and entry.shore) or (kind == "outpost" and entry.turrets == 0))
                and (not preferredScore or score > preferredScore) then
            preferred, preferredScore = entry, score
        end
    end
    if preferred then return preferred, kind end
    return backup, "deep"
end

-- the side of the target chunk where water or unscanned land is: flyers come from there
local function shoreApproach(map, chunk)
    for s = 1, 8 do
        local vector = aiBrain.SECTOR_VECTORS[s]
        local x = chunk.x + mFloor(vector[1] + 0.5) * CHUNK_SIZE
        local y = chunk.y + mFloor(vector[2] + 0.5) * CHUNK_SIZE
        if getChunkByXY(map, x, y) == -1 then
            return chunk.x + 16 + vector[1] * 72, chunk.y + 16 + vector[2] * 72
        end
    end
    return nil
end

----------------------------------------------------------------------------------------------------------------------
-- commands

local function strike(map, squad, entry, kind, tick)
    local group = squad.group
    local chunk = entry.chunk
    field.note(map, "air-selected", tick)
    local goal = aiBrain.raidGoal(map, entry, tick, true)
    goal.origin = group.position
    local objective = goal.kind == "objective" and goal or nil
    if not aiBrain.recheckRaid(map, goal) then
        if objective then field.closeObjective(map, objective, false, tick) end
        field.note(map, "unconfirmed", tick)
        return false
    end
    squad.flightObjective = objective
    local tx, ty = goal.x, goal.y
    local commands = {}
    if kind == "shore" then
        local wx, wy = shoreApproach(map, chunk)
        if wx then
            commands[#commands + 1] = {type = defines.command.go_to_location, destination = {x = wx, y = wy}, radius = 12,
                                       distraction = DEFINES_DISTRACTION_NONE}
        end
    end
    commands[#commands + 1] = {type = defines.command.go_to_location, destination = {x = tx, y = ty}, radius = 10,
                               distraction = DEFINES_DISTRACTION_BY_DAMAGE}
    if objective then
        commands[#commands + 1] = {type = defines.command.attack, target = objective.entity,
                                   distraction = DEFINES_DISTRACTION_NONE}
    else
        commands[#commands + 1] = {type = defines.command.attack_area, destination = {x = tx, y = ty}, radius = 24,
                                   distraction = DEFINES_DISTRACTION_BY_ANYTHING}
    end
    group.set_command({type = defines.command.compound, structure_type = defines.compound_command.return_last,
                       commands = commands})
    if not group.valid then
        squad.disbandTick = tick    -- the engine dropped the emptied group on the new command
        if objective then field.closeObjective(map, objective, false, tick) end
        return false
    end
    field.beginRaid(map, squad, goal, tick)
    group.start_moving()
    local position = group.position
    local travel = aiBrain.distance(position.x, position.y, tx, ty) / FLYER_SPEED
    squad.flightPhase = "strike"
    squad.flightKind = squad.flightKind or kind
    squad.strikeUntil = tick + mFloor(travel) + STRIKE_TICKS
    if objective then squad.strikeUntil = mMin(squad.strikeUntil, objective.untilTick) end
    squad.hitChunks[chunk] = true
    squad.onTheWay = true
    squad.nextCommandTick = tick + 60
    squad.checkTick = squad.strikeUntil + 18000
    aiBrain.debugPrint(map, "Авианалёт (бойцов: " .. tostring(squad.startSize) .. "), " .. chatNames.name(kind) .. ": удар [gps=" .. tx .. "," .. ty
        .. "," .. map.surface.name .. "]")
    return true
end

local function releaseObjective(map, squad, tick)
    local goal = squad.flightObjective
    if goal then
        field.closeObjective(map, goal, goal.confirmed, tick)
        squad.flightObjective = nil
        return true
    end
end

local function goHome(map, squad, tick)
    field.finishRaid(map, squad, "unconfirmed", tick)
    releaseObjective(map, squad, tick)
    local group = squad.group
    squad.flightPhase = "return"
    squad.strikeUntil = nil
    group.set_command({type = defines.command.go_to_location, destination = {x = squad.originPosition.x, y = squad.originPosition.y},
                       radius = 16, distraction = DEFINES_DISTRACTION_NONE})
    if not group.valid then
        squad.disbandTick = tick    -- the engine dropped the emptied group on the new command
        return
    end
    group.start_moving()
    squad.onTheWay = true
    squad.nextCommandTick = tick + 60
    squad.checkTick = tick + 18000
end

local function relocateOrReturn(map, squad, tick)
    -- A lock ends the mission, including when a different group destroys it.
    if squad.flightObjective or squad.returnAfterStrike or not field.modeCurrent(map, squad)
            or (squad.orderEpoch or 0) ~= (map.orderEpoch or 0)
            or not aiPredicates.attackAllowed(map, tick) or not evolutionAllows(map) then
        goHome(map, squad, tick)
        return
    end
    field.finishRaid(map, squad, "unconfirmed", tick)
    local ai = aiBrain.getMapAI(map)
    local losses = squad.losses or 0
    if ((squad.hops or 0) < MAX_HOPS) and (losses < squad.startSize * FLEE_LOSSES) then
        local position = squad.group.position
        local entry, kind = pickTarget(map, ai, position.x, position.y, HOP_RANGE, squad.hitChunks, tick)
        if entry then
            squad.hops = (squad.hops or 0) + 1
            if strike(map, squad, entry, kind, tick) then return end
        end
    end
    goHome(map, squad, tick)
end

----------------------------------------------------------------------------------------------------------------------
-- flights

local function registerFlight(map, group, size, tick)
    local universe = map.universe
    local squad = createSquad(group.position, map, group, false)
    squad.flight = true
    squad.doctrineEpoch, squad.orderEpoch = universe.doctrineEpoch, map.orderEpoch
    squad.excluded = true       -- not counted as an attack squad
    squad.status = SQUAD_RAIDING
    squad.startSize = size
    squad.losses = 0
    squad.kills = 0
    squad.hitChunks = {}
    squad.hops = 0
    squad.disbandTick = tick + 20 * 3600
    universe.groupNumberToSquad[squad.groupNumber] = squad
    return squad
end

-- first order of a new flight; false if there is nothing to strike (the flight is disbanded)
local function launch(map, squad, tick)
    local ai = aiBrain.getMapAI(map)
    local position = squad.group.position
    local entry, kind = pickTarget(map, ai, position.x, position.y, FLIGHT_RANGE, nil, tick)
    if not entry then
        squad.disbandTick = tick
        return false
    end
    if strike(map, squad, entry, kind, tick) then return true end
    squad.disbandTick = tick
    return false
end

-- a ground attack squad hands its flyers over to a flight
function flyerAI.splitFlight(map, squad)
    local universe = map.universe
    if not flyersExist() or not evolutionAllows(map) then
        return
    end
    if countFlights(universe) >= flightCap(universe) then
        return
    end
    local group = squad.group
    local members = group.members
    local champions = championUnits(universe)
    local flyers
    local count = 0
    for i = 1, #members do
        local member = members[i]
        if member.valid and flyerNameSet[member.name] and not (champions and champions[member.unit_number]) then
            count = count + 1
            flyers = flyers or {}
            flyers[count] = member
        end
    end
    if count == 0 or (count < MIN_SPLIT_SIZE and count < #members) then return end
    local tick = game.tick
    local ai = aiBrain.getMapAI(map)
    local origin = flyers[1].position
    local entry, kind = pickTarget(map, ai, origin.x, origin.y, FLIGHT_RANGE, nil, tick)
    if not entry or not aiPredicates.attackAllowed(map, tick) then return end
    local units = count + countPackedUnits(universe, flyers)
    if count == #members then
        if not squad.excluded then universe.squadCount = universe.squadCount - 1 end
        if squad.goal and squad.goal.kind == "objective" then
            aiBrain.field.closeObjective(map, squad.goal, false, tick)
        end
        squad.goal, squad.pendingGoal = nil, nil
        squad.flight, squad.excluded = true, true
        squad.startSize = units
        squad.hitChunks, squad.hops = {}, 0
        squad.originPosition = origin
        squad.disbandTick = tick + 20 * 3600
        strike(map, squad, entry, kind, tick)
        return
    end
    local flightGroup = map.surface.create_unit_group({position = origin, force = group.force})
    for i = 1, count do
        flightGroup.add_member(flyers[i])
    end
    -- packed flyers count with their whole pack: sizes and losses are in units
    local flight = registerFlight(map, flightGroup, units, tick)
    if squad.startSize then
        squad.startSize = mMax(1, squad.startSize - units)
    end
    strike(map, flight, entry, kind, tick)
end

local flyerQuery = {position = {0, 0}, radius = GATHER_RADIUS, force = "enemy", type = "unit", name = nil, limit = GATHER_LIMIT}

-- an active nest chunk to launch from: rotates over the active nests, then over the raid nests
local function rotate(chunks, key)
    if key and (chunks[key] == nil) then
        key = nil       -- the stored chunk left the table: start over
    end
    local chunk = next(chunks, key)
    if (not chunk) and key then
        chunk = next(chunks, nil)
    end
    return chunk
end

local function nextLaunchChunk(map, ai)
    local chunk = rotate(map.chunkToActiveNest, ai.flightNestKey)
    if chunk then
        ai.flightNestKey = chunk
        return chunk
    end
    chunk = rotate(map.chunkToActiveRaidNest, ai.flightRaidNestKey)
    ai.flightRaidNestKey = chunk
    return chunk
end

local function tryLaunch(map, tick)
    local universe = map.universe
    local ai = aiBrain.getMapAI(map)
    if ai.nextFlightTick > tick then
        return
    end
    ai.nextFlightTick = tick + 600
    if (not map.frontTargets) or (map.points < FLIGHT_COST) or (not evolutionAllows(map)) or (not canAttack(map, tick)) then
        return
    end
    local chunk = nextLaunchChunk(map, ai)
    if not chunk or not aiBrain.chunkIsLive(map, chunk) or field.held(map, chunk, tick) then
        return
    end
    flyerQuery.position[1] = chunk.x + 16
    flyerQuery.position[2] = chunk.y + 16
    flyerQuery.name = flyerNameList
    local found = map.surface.find_entities_filtered(flyerQuery)
    local champions = championUnits(universe)
    local free = {}
    for i = 1, #found do
        local unit = found[i]
        local commandable = unit.commandable
        -- a flying champion walking home to regenerate has no group either
        if commandable and (not commandable.parent_group) and not (champions and champions[unit.unit_number]) then
            free[#free + 1] = unit
        end
    end
    if #free < MIN_FLIGHT_SIZE then
        return
    end
    local units = #free + countPackedUnits(universe, free)
    local cost = FLIGHT_COST + units
    if map.points < cost then return end
    local group = map.surface.create_unit_group({position = free[1].position, force = free[1].force})
    for i = 1, #free do
        group.add_member(free[i])
    end
    local flight = registerFlight(map, group, units, tick)
    if launch(map, flight, tick) then
        field.launch(map, chunk, tick)
        ai.lastFlightTick = tick
        map.points = map.points - cost
        if universe.aiPointsPrintSpendingToChat then
            game.print(map.surface.name .. ": Очки: -" .. cost .. ". [Полёт] Всего: " .. string.format("%.2f", map.points))
        end
    end
    -- the next flight: sooner when the AI is aggressive (temperament) or a ground strike is under way
    local delay = 2400 + mFloor(mRandom() * 3000 * (1.2 - (map.temperament or 0.5) * 0.6))
    if ai.escortUntil > tick then
        delay = mFloor(delay * 0.5)
    end
    ai.nextFlightTick = tick + delay
    return true -- a slot remains reserved even if the empty target list disbanded this flight
end

-- on_tick every 300 ticks
function flyerAI.plan(universe, tick)
    if not aiBrain.active(universe) or not flyersExist() then
        return
    end
    local slots = flightCap(universe) - countFlights(universe)
    if slots <= 0 then return end
    for _, map in pairs(universe.maps) do
        if map and not map.suspended and map.surface and map.surface.valid and map.ai and tryLaunch(map, tick) then
            slots = slots - 1
            if slots <= 0 then return end
        end
    end
end

-- group finished its command (target cleared, or arrived home)
function flyerAI.dispatch(map, squad)
    local tick = game.tick
    if #squad.group.members == 0 then
        squad.disbandTick = tick     -- the whole flight was shot down: no new command for an empty group
        return
    end
    local phase = squad.flightPhase
    if phase == "return" then
        squad.disbandTick = tick     -- home: the flyers idle at the nests again
    elseif phase == "strike" then
        relocateOrReturn(map, squad, tick)
    elseif field.modeCurrent(map, squad) and aiPredicates.attackAllowed(map, tick) and evolutionAllows(map) then
        launch(map, squad, tick)
    else
        squad.disbandTick = tick
    end
end

function flyerAI.onStrikeTimeout(map, squad)
    if squad.flightPhase == "strike" then
        local tick = game.tick
        if not field.modeCurrent(map, squad) or not aiPredicates.attackAllowed(map, tick) or not evolutionAllows(map) then
            -- This timer can fire before the engine finishes its compound.
            -- Defer the return to dispatch; do not replace the running order.
            squad.strikeUntil, squad.returnAfterStrike = nil, true
        else
            relocateOrReturn(map, squad, tick)
        end
    else
        squad.strikeUntil = nil
    end
end

-- a flyer of the flight was killed by the player
function flyerAI.onLoss(map, squad, entity, tick, hostileLoss)
    squad.losses = (squad.losses or 0) + 1
    if not squad.engageX then
        local position = entity.position
        squad.engageX = position.x
        squad.engageY = position.y
    end
    if hostileLoss then field.recordRaidLoss(map, squad, squad.startSize * FLEE_LOSSES, tick) end
    if (squad.flightPhase == "strike") and (squad.losses >= squad.startSize * FLEE_LOSSES)
        and squad.group and squad.group.valid then
        aiBrain.debugPrint(map, "Авианалёт прекращает атаку; потери: " .. squad.losses .. "/" .. squad.startSize)
        goHome(map, squad, tick)
    end
end

function flyerAI.onFlightEnd(map, squad, tick)
    if aiBrain.active(map.universe) then releaseObjective(map, squad, tick) end
    if squad.learned or not squad.flightKind then
        return
    end
    squad.learned = true
    local kills = squad.kills or 0
    local losses = squad.losses or 0
    if (kills == 0) and (losses == 0) then
        return
    end
    local reward = aiBrain.squadReward(kills, losses, mMax(1, squad.startSize or 1))
    local ai = aiBrain.getMapAI(map)
    aiBrain.updateValue(ai.flight, squad.flightKind, reward, tick)
    aiBrain.debugPrint(map, string.format("Авианалёт «%s» завершён: уничтожено %d, потеряно %d, результат %.2f", chatNames.name(squad.flightKind), kills, losses, reward))
end

flyerAIG = flyerAI
return flyerAI
