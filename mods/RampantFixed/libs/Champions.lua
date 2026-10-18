-- Reforged Paranoidal: champions ("вожаки") and hour bosses.
--
-- Every 7-11 minutes a champion, every 50-70 minutes a bigger hour boss leaves a random nest within reach of the
-- player base and attacks its most defended spot (the player chunk with most turrets in the 3x3 around).
--  * unit: same faction as the nest, one tier above the units the nest spawns now; ground biters below 10%
--    evolution, biters/spitters 50/50 from 10%, biters/spitters/flyers by a third from 30% (fallback to what the
--    faction has). Non-Rampant nests (vanilla, Bob) give their next stronger unit of the same kind;
--  * health: x10 (champion) / x50 (hour boss) of the ordinary unit of that kind, kept as a script pool on top of
--    the engine health; the health bar shows the pool share. A champion moves at half the speed of those units;
--  * looks: a random colour (one of the six Bob artifact colours) as a glow (+ light at night), a silver / bigger
--    gold star above it. The body colour cannot be changed at runtime;
--  * below 15% of the pool it walks back to a nest, regenerates there, gets one of 200 names (shown under the star)
--    and attacks again;
--  * death: the loot is one big artifact of its colour; the corpse stays 1 minute and keeps the glow;
--  * only the hour boss is announced ("You hear a strange sound in the distance...");
--  * Rampant never packs champions (SquadCompression), they live in their own script-driven group.
-- Map setting rampantFixed--champions switches new spawns. Data: universe.champions, created on first use.

if championsG then
    return championsG
end
local champions = {}

local constants = require("Constants")
local aiBrain = require("AIBrain")
local engineGroupHelpers = require("EngineGroupHelpers")

local CHUNK_SIZE = constants.CHUNK_SIZE
local AI_STATE_PEACEFUL = constants.AI_STATE_PEACEFUL

local turretsAround = aiBrain.turretsAround
local inPlayerBase = engineGroupHelpers.inPlayerBase

local mRandom = math.random
local mMin = math.min
local mMax = math.max
local sFind = string.find
local sMatch = string.match
local sFormat = string.format

champions.SETTING = "rampantFixed--champions"

local UPDATE_TICKS = 60             -- champions.update runs every 60 ticks (control.lua)
local RETRY_TICKS = 3600            -- nothing could be spawned: try again in a minute
local RETREAT_SHARE = 0.15          -- of the health pool
local REGEN_TICKS = 90 * 60         -- full pool regenerated at a nest in 90 seconds
local RETREAT_TIMEOUT = 5 * 3600    -- regenerates where it is if it cannot reach a nest
local HOME_RADIUS = 12
local ATTACK_RADIUS = 24
local NEST_RANGE = 12 * CHUNK_SIZE  -- nests within this distance from the target
local FALLBACK_NESTS = 6            -- otherwise the nearest ones
local SPAWN_TRIES = 12
local CORPSE_TICKS = 60 * 60
local NAME_COUNT = 200
local NAME_LIFT = 0.35              -- name centre above the selection box top

local GLOW_SPRITE = "rampantFixed-champion-glow"

local KINDS = {
    champion = {healthK = 10, speedK = 0.5, intervalMin = 7 * 3600, intervalMax = 11 * 3600, maxAlive = 3,
                star = "rampantFixed-champion-star-silver", starScale = 0.35, starLift = 1.0,
                glowScale = 0.9, lightScale = 1.5, warning = false},
    hourBoss = {healthK = 50, intervalMin = 50 * 3600, intervalMax = 70 * 3600, maxAlive = 1,
                star = "rampantFixed-champion-star-gold", starScale = 0.5, starLift = 1.2,
                glowScale = 1.3, lightScale = 2.5, warning = true},
}
local KIND_ORDER = {"champion", "hourBoss"}
champions.KINDS = KINDS

-- the six Bob artifact colours: the loot is the big artifact of the same colour
local COLORS = {
    {name = "red", color = {r = 1, g = 0.2, b = 0.15}, item = "bob-alien-artifact-red"},
    {name = "orange", color = {r = 1, g = 0.55, b = 0.1}, item = "bob-alien-artifact-orange"},
    {name = "yellow", color = {r = 1, g = 0.92, b = 0.2}, item = "bob-alien-artifact-yellow"},
    {name = "green", color = {r = 0.3, g = 1, b = 0.25}, item = "bob-alien-artifact-green"},
    {name = "blue", color = {r = 0.25, g = 0.55, b = 1}, item = "bob-alien-artifact-blue"},
    {name = "purple", color = {r = 0.75, g = 0.3, b = 1}, item = "bob-alien-artifact-purple"},
}
local FALLBACK_ITEM = "bob-alien-artifact"

local TYPES = {biter = true, spitter = true, flyer = true}
local RAMPANT_UNIT = "^(.+)%-(%a+)%-v(%d+)%-t(%d+)%-rampant$"
local MAX_TIER = 10

-- set by control.lua: re-registers the dynamic events (on_entity_damaged, on_post_entity_died)
champions.onTrackedChanged = nil

----------------------------------------------------------------------------------------------------------------------
-- data

local function getData(universe)
    local data = universe.champions
    if not data then
        data = {units = {}, corpses = {}, nextTick = {}, usedNames = {}, usedCount = 0}
        universe.champions = data
    end
    return data
end

local function notifyChanged()
    if champions.onTrackedChanged then
        champions.onTrackedChanged()
    end
end

-- read-only (also used in on_load): the record of a tracked champion entity
function champions.recordOf(universe, entity)
    local data = universe and universe.champions
    local unitNumber = data and entity.unit_number
    return unitNumber and data.units[unitNumber]
end

-- read-only (also used in on_load): sorted prototype names of tracked champions, nil if none
function champions.trackedNames(universe)
    local data = universe and universe.champions
    if not data then
        return nil
    end
    local names
    local seen = {}
    for _, record in pairs(data.units) do
        local name = record.prototypeName
        if not seen[name] then
            seen[name] = true
            names = names or {}
            names[#names + 1] = name
        end
    end
    if names then
        table.sort(names)
    end
    return names
end

local function premultiplied(color, alpha)
    return {r = color.r * alpha, g = color.g * alpha, b = color.b * alpha, a = alpha}
end

----------------------------------------------------------------------------------------------------------------------
-- unit choice

-- weight of a spawn definition at the evolution (linear between points, edge values outside)
local function weightAt(points, evo)
    local n = #points
    if n == 0 then
        return 0
    end
    if evo <= points[1].evolution_factor then
        return points[1].weight
    end
    for i = 2, n do
        local p = points[i]
        if evo <= p.evolution_factor then
            local q = points[i - 1]
            local span = p.evolution_factor - q.evolution_factor
            if span <= 0 then
                return p.weight
            end
            return q.weight + (p.weight - q.weight) * (evo - q.evolution_factor) / span
        end
    end
    return points[n].weight
end

local function unitKind(name)
    if sFind(name, "flyer", 1, true) then
        return "flyer"
    elseif sFind(name, "spitter", 1, true) then
        return "spitter"
    end
    return "biter"
end

local function excludedSpawner(name)
    return sFind(name, "^maf") or sFind(name, "^bm%-")    -- Big Monsters spawners
end

-- boss unit and the ordinary unit it is compared with, or nil if the nest has no unit of that kind
local function resolveBoss(spawnerPrototype, desiredType, evo)
    local units = spawnerPrototype.result_units
    if (not units) or (#units == 0) then
        return nil
    end
    local best, bestWeight
    for _, definition in pairs(units) do
        local weight = weightAt(definition.spawn_points, evo)
        if (not bestWeight) or (weight > bestWeight) then
            best = definition.unit
            bestWeight = weight
        end
    end
    if not best then
        return nil
    end
    local entityPrototypes = prototypes.entity
    local faction, unitType, variation, tier = sMatch(best, RAMPANT_UNIT)
    if faction then
        if not TYPES[unitType] then
            return nil
        end
        tier = tonumber(tier)
        local prefix = faction .. "-" .. desiredType .. "-v" .. variation .. "-t"
        local bossName = prefix .. mMin(tier + 1, MAX_TIER) .. "-rampant"
        local localName = prefix .. tier .. "-rampant"
        if entityPrototypes[bossName] and entityPrototypes[localName] then
            return bossName, localName
        end
        return nil
    end
    if sFind(best, "rampant", 1, true) or (unitKind(best) ~= desiredType) or (not entityPrototypes[best]) then
        return nil
    end
    -- vanilla / Bob nests: the next stronger unit of the same kind among the nest's units
    local bestHealth = entityPrototypes[best].get_max_health()
    local stronger, strongerHealth
    for _, definition in pairs(units) do
        local name = definition.unit
        local prototype = entityPrototypes[name]
        if prototype and (name ~= best) and (unitKind(name) == desiredType) then
            local health = prototype.get_max_health()
            if (health > bestHealth) and ((not strongerHealth) or (health < strongerHealth)) then
                stronger = name
                strongerHealth = health
            end
        end
    end
    return stronger or best, best
end

local function typesToTry(evo, forced)
    if forced then
        return {forced}
    end
    if evo < 0.1 then
        return {"biter"}
    end
    if evo < 0.3 then
        if mRandom(2) == 1 then
            return {"biter", "spitter"}
        end
        return {"spitter", "biter"}
    end
    local roll = mRandom(3)
    if roll == 1 then
        return {"biter", "spitter", "flyer"}
    elseif roll == 2 then
        return {"spitter", "biter", "flyer"}
    end
    return {"flyer", "biter", "spitter"}
end

----------------------------------------------------------------------------------------------------------------------
-- target and nests

-- the most defended player chunk (most turrets in the 3x3 around), else the most valuable one
local function pickTarget(map)
    local best, bestScore
    local ties = 0
    for chunk in pairs(map.chunkToPlayerTurrets) do
        local score = turretsAround(map, chunk)
        if (not bestScore) or (score > bestScore) then
            best = chunk
            bestScore = score
            ties = 1
        elseif score == bestScore then
            ties = ties + 1
            if mRandom(ties) == 1 then
                best = chunk
            end
        end
    end
    if not best then
        for chunk, value in pairs(map.chunkToPlayerBase) do
            if (not bestScore) or (value > bestScore) then
                best = chunk
                bestScore = value
            end
        end
    end
    if best then
        return {x = best.x + CHUNK_SIZE * 0.5, y = best.y + CHUNK_SIZE * 0.5}
    end
end

local function nestCandidates(map, target)
    local inRange = {}
    local all = {}
    local range2 = NEST_RANGE * NEST_RANGE
    local center = {x = 0, y = 0}
    for chunk, count in pairs(map.chunkToNests) do
        if count > 0 then
            center.x = chunk.x + CHUNK_SIZE * 0.5
            center.y = chunk.y + CHUNK_SIZE * 0.5
            if not inPlayerBase(map, center) then
                local dx = center.x - target.x
                local dy = center.y - target.y
                local d2 = dx * dx + dy * dy
                if d2 <= range2 then
                    inRange[#inRange + 1] = chunk
                else
                    all[#all + 1] = {chunk = chunk, d2 = d2}
                end
            end
        end
    end
    if #inRange > 0 then
        return inRange
    end
    table.sort(all, function(a, b) return a.d2 < b.d2 end)
    for i = 1, mMin(FALLBACK_NESTS, #all) do
        inRange[i] = all[i].chunk
    end
    return inRange
end

-- a nest to come back to: the original one if a spawner is still there, else the nearest nest chunk
local function findHome(map, record, position)
    local surface = map.surface
    local home = record.home
    if surface.count_entities_filtered({position = home, radius = 32, force = "enemy", type = "unit-spawner",
                                        limit = 1}) > 0 then
        return home
    end
    local best, bestD2
    local center = {x = 0, y = 0}
    for chunk, count in pairs(map.chunkToNests) do
        if count > 0 then
            center.x = chunk.x + CHUNK_SIZE * 0.5
            center.y = chunk.y + CHUNK_SIZE * 0.5
            local dx = center.x - position.x
            local dy = center.y - position.y
            local d2 = dx * dx + dy * dy
            if ((not bestD2) or (d2 < bestD2)) and (not inPlayerBase(map, center)) then
                best = {x = center.x, y = center.y}
                bestD2 = d2
            end
        end
    end
    return best or home
end

----------------------------------------------------------------------------------------------------------------------
-- looks

local function selectionTop(entity)
    local box = entity.prototype.selection_box
    return box.left_top.y, mMax(1, box.right_bottom.x - box.left_top.x)
end

local function drawName(record)
    local entity = record.entity
    local top = selectionTop(entity)
    local color = COLORS[record.colorIndex].color
    rendering.draw_text({
        text = {"rampant-champion-name." .. sFormat("name-%03d", record.nameIndex)},
        surface = entity.surface,
        target = {entity = entity, offset = {0, top - NAME_LIFT}},
        color = {r = 0.5 + color.r * 0.5, g = 0.5 + color.g * 0.5, b = 0.5 + color.b * 0.5, a = 1},
        scale = 1.1,
        alignment = "center",
        vertical_alignment = "middle",
    })
end

-- glow (visible by day) and light (by night); attached to a unit or a corpse
local function drawAura(spec, color, target, size)
    local surface = target.surface
    rendering.draw_sprite({
        sprite = GLOW_SPRITE,
        surface = surface,
        target = target,
        tint = premultiplied(color, 0.55),
        x_scale = size * spec.glowScale,
        y_scale = size * spec.glowScale * 0.75,
        render_layer = "lower-object",
    })
    rendering.draw_light({
        sprite = "utility/light_medium",
        surface = surface,
        target = target,
        color = color,
        scale = size * spec.lightScale,
        intensity = 0.75,
    })
end

local function drawMarks(record)
    local entity = record.entity
    local spec = KINDS[record.kind]
    local color = COLORS[record.colorIndex].color
    local top, size = selectionTop(entity)
    drawAura(spec, color, entity, size)
    rendering.draw_sprite({
        sprite = spec.star,
        surface = entity.surface,
        target = {entity = entity, offset = {0, top - spec.starLift}},
        x_scale = spec.starScale,
        y_scale = spec.starScale,
        render_layer = "air-entity-info-icon",
    })
    if record.nameIndex then
        drawName(record)
    end
end

local function giveName(data, record)
    if data.usedCount >= NAME_COUNT then
        data.usedNames = {}
        data.usedCount = 0
    end
    local used = data.usedNames
    local k = mRandom(NAME_COUNT - data.usedCount)
    for i = 1, NAME_COUNT do
        if not used[i] then
            k = k - 1
            if k == 0 then
                used[i] = true
                data.usedCount = data.usedCount + 1
                record.nameIndex = i
                break
            end
        end
    end
    if record.nameIndex then
        drawName(record)
    end
end

----------------------------------------------------------------------------------------------------------------------
-- health pool

local function syncHealth(record)
    local entity = record.entity
    local health = entity.max_health * record.pool / record.poolMax
    if health < 0.1 then
        health = 0.1
    end
    entity.health = health
end

----------------------------------------------------------------------------------------------------------------------
-- commands

-- the champion's own script-driven group; recreated if lost, the champion is taken back if someone recruited it
local function ensureGroup(record)
    local entity = record.entity
    local group = record.group
    local commandable = entity.commandable
    local parent = commandable and commandable.parent_group
    if group and group.valid and parent and (parent.unique_id == group.unique_id) then
        return group, false
    end
    if not (group and group.valid) then
        group = entity.surface.create_unit_group({position = entity.position, force = entity.force})
        record.group = group
    end
    group.add_member(entity)
    return group, true
end

local function orderAttack(record)
    local group = ensureGroup(record)
    group.set_command({
        type = defines.command.attack_area,
        destination = record.target,
        radius = ATTACK_RADIUS,
        distraction = defines.distraction.by_enemy,
    })
    group.start_moving()
end

local function orderRetreat(record)
    local group = ensureGroup(record)
    group.set_command({
        type = defines.command.go_to_location,
        destination = record.home,
        radius = 6,
        distraction = defines.distraction.none,
    })
    group.start_moving()
end

local function orderRest(record)
    local group = ensureGroup(record)
    group.set_command({
        type = defines.command.wander,
        radius = 5,
        ticks_to_wait = REGEN_TICKS,
        distraction = defines.distraction.by_damage,
    })
    group.start_moving()
end

local function attackAgain(map, record, tick)
    record.state = "attack"
    record.stateTick = tick
    record.target = pickTarget(map) or record.target
    orderAttack(record)
end

local function startRetreat(universe, record, tick)
    local map = universe.maps[record.surfaceIndex]
    if not map then
        return
    end
    record.state = "retreat"
    record.stateTick = tick
    record.home = findHome(map, record, record.entity.position)
    orderRetreat(record)
end

----------------------------------------------------------------------------------------------------------------------
-- spawning

local function create(universe, map, kind, bossName, localName, position, home, target, tick)
    local spec = KINDS[kind]
    local surface = map.surface
    local entity = surface.create_entity({name = bossName, position = position, force = "enemy"})
    if not (entity and entity.valid and entity.unit_number) then
        return nil
    end
    local localPrototype = prototypes.entity[localName]
    if spec.speedK and localPrototype.speed then
        entity.speed = localPrototype.speed * spec.speedK
    end
    local poolMax = mMax(entity.max_health, localPrototype.get_max_health() * spec.healthK)
    local _, size = selectionTop(entity)
    local record = {
        size = size,
        entity = entity,
        unitNumber = entity.unit_number,
        prototypeName = bossName,
        kind = kind,
        colorIndex = mRandom(#COLORS),
        surfaceIndex = surface.index,
        pool = poolMax,
        poolMax = poolMax,
        state = "attack",
        stateTick = tick,
        createdTick = tick,
        home = {x = home.x, y = home.y},
        target = target,
    }
    local data = getData(universe)
    data.units[record.unitNumber] = record
    drawMarks(record)
    orderAttack(record)
    if spec.warning then
        for _, player in pairs(game.connected_players) do
            if player.surface.index == surface.index then
                player.print({"description.rampantFixed--championHourWarning"}, {color = {r = 0.85, g = 0.6, b = 0.35}})
            end
        end
    end
    notifyChanged()
    return entity
end

local function spawn(universe, map, kind, tick, forcedType)
    local surface = map.surface
    local target = pickTarget(map)
    if not target then
        return nil
    end
    local candidates = nestCandidates(map, target)
    local count = #candidates
    if count == 0 then
        return nil
    end
    local evo = game.forces.enemy.get_evolution_factor(surface)
    local area = {{0, 0}, {0, 0}}
    local query = {area = area, force = "enemy", type = "unit-spawner"}
    for _, desiredType in ipairs(typesToTry(evo, forcedType)) do
        for _ = 1, mMin(SPAWN_TRIES, count * 2) do
            local chunk = candidates[mRandom(count)]
            area[1][1] = chunk.x
            area[1][2] = chunk.y
            area[2][1] = chunk.x + CHUNK_SIZE
            area[2][2] = chunk.y + CHUNK_SIZE
            local spawners = surface.find_entities_filtered(query)
            if #spawners > 0 then
                local spawner = spawners[mRandom(#spawners)]
                if not excludedSpawner(spawner.name) then
                    local bossName, localName = resolveBoss(spawner.prototype, desiredType, evo)
                    if bossName then
                        local position = surface.find_non_colliding_position(bossName, spawner.position, 24, 0.5)
                        if position and not inPlayerBase(map, position) then
                            local entity = create(universe, map, kind, bossName, localName, position,
                                spawner.position, target, tick)
                            if entity then
                                return entity
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- a surface with a connected player, Rampant AI out of the truce and something to attack
local function pickMap(universe)
    local candidates = {}
    local seen = {}
    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local index = surface.index
        if not seen[index] then
            seen[index] = true
            local map = universe.maps[index]
            if map and (not map.suspended) and map.surface.valid and (not surface.peaceful_mode)
                and (map.state ~= AI_STATE_PEACEFUL) and next(map.chunkToNests)
                and (next(map.chunkToPlayerTurrets) or next(map.chunkToPlayerBase)) then
                candidates[#candidates + 1] = map
            end
        end
    end
    if #candidates > 0 then
        return candidates[mRandom(#candidates)]
    end
end

local function interval(spec)
    return mRandom(spec.intervalMin, spec.intervalMax)
end

local function aliveCount(data, kind)
    local count = 0
    for _, record in pairs(data.units) do
        if (record.kind == kind) and (not record.died) then
            count = count + 1
        end
    end
    return count
end

local function schedule(universe, tick)
    local data = getData(universe)
    local nextTick = data.nextTick
    local enabled = settings.global[champions.SETTING].value
    for _, kind in ipairs(KIND_ORDER) do
        local spec = KINDS[kind]
        local due = nextTick[kind]
        if not due then
            nextTick[kind] = tick + interval(spec)
        elseif tick >= due then
            if (not enabled) or (aliveCount(data, kind) >= spec.maxAlive) then
                nextTick[kind] = tick + interval(spec)
            else
                local map = pickMap(universe)
                if map and spawn(universe, map, kind, tick) then
                    nextTick[kind] = tick + interval(spec)
                else
                    nextTick[kind] = tick + RETRY_TICKS
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------------
-- life cycle

local function stepRecord(universe, data, record, tick)
    local map = universe.maps[record.surfaceIndex]
    if not map then
        return
    end
    local entity = record.entity
    local state = record.state
    if state == "attack" then
        local group, regrouped = ensureGroup(record)
        if regrouped or not group.has_command then
            attackAgain(map, record, tick)
        end
    elseif state == "retreat" then
        local position = entity.position
        local dx = position.x - record.home.x
        local dy = position.y - record.home.y
        if ((dx * dx + dy * dy) <= HOME_RADIUS * HOME_RADIUS) or ((tick - record.stateTick) > RETREAT_TIMEOUT) then
            record.state = "regen"
            record.stateTick = tick
            orderRest(record)
        else
            local group, regrouped = ensureGroup(record)
            if regrouped or not group.has_command then
                orderRetreat(record)
            end
        end
    elseif state == "regen" then
        record.pool = mMin(record.poolMax, record.pool + record.poolMax * UPDATE_TICKS / REGEN_TICKS)
        syncHealth(record)
        if record.pool >= record.poolMax then
            if not record.nameIndex then
                giveName(data, record)     -- survived its first attack and came back
            end
            attackAgain(map, record, tick)
        else
            local group, regrouped = ensureGroup(record)
            if regrouped or not group.has_command then
                orderRest(record)
            end
        end
    end
end

-- every 60 ticks (control.lua)
function champions.update(universe, tick)
    local data = universe.champions
    if data then
        local changed = false
        for unitNumber, record in pairs(data.units) do
            if not record.entity.valid then
                data.units[unitNumber] = nil    -- removed without on_post_entity_died (destroyed by a script)
                changed = true
            elseif not record.died then
                stepRecord(universe, data, record, tick)
            end
        end
        local corpses = data.corpses
        if corpses[1] then
            local kept = 0
            local count = #corpses
            for i = 1, count do
                local corpse = corpses[i]
                if corpse.entity.valid and (tick < corpse.expire) then
                    kept = kept + 1
                    corpses[kept] = corpse
                elseif corpse.entity.valid then
                    corpse.entity.destroy()
                end
            end
            for i = kept + 1, count do
                corpses[i] = nil
            end
        end
        if changed then
            notifyChanged()
        end
    end
    schedule(universe, tick)
end

-- on_entity_damaged for a tracked champion (control.lua dispatches)
function champions.onDamaged(universe, event, record)
    local entity = event.entity
    record.pool = record.pool - event.final_damage_amount
    if record.pool <= 0 then
        record.pool = 0
        if entity.health > 0 then
            local cause = event.cause
            entity.die(event.force, (cause and cause.valid) and cause or nil)
        end
        return
    end
    syncHealth(record)      -- also keeps it alive when the hit took the engine health to 0
    if (record.state == "attack") and (record.pool < record.poolMax * RETREAT_SHARE) then
        startRetreat(universe, record, event.tick)
    end
end

-- on_entity_died / script_raised_destroy (control.lua onDeath): one big artifact of its colour instead of the loot
function champions.onDied(universe, event)
    local data = universe.champions
    if not data then
        return
    end
    local unitNumber = event.entity.unit_number
    local record = unitNumber and data.units[unitNumber]
    if not record then
        return
    end
    record.died = true
    local loot = event.loot
    if loot then
        loot.clear()
        local item = COLORS[record.colorIndex].item
        if not prototypes.item[item] then
            item = prototypes.item[FALLBACK_ITEM] and FALLBACK_ITEM
        end
        if item then
            loot.insert({name = item, count = 1})
        end
    end
end

-- on_post_entity_died (registered only while champions are tracked): the corpse stays 1 minute with the glow
function champions.onPostDied(universe, event)
    local data = universe.champions
    local unitNumber = event.unit_number
    local record = data and unitNumber and data.units[unitNumber]
    if not record then
        return
    end
    data.units[unitNumber] = nil
    local spec = KINDS[record.kind]
    local color = COLORS[record.colorIndex].color
    local marked = false
    for _, corpse in pairs(event.corpses or {}) do
        if corpse.valid and (corpse.type == "corpse") then
            corpse.corpse_expires = false
            if not marked then
                marked = true
                drawAura(spec, color, corpse, record.size or 1)
            end
            data.corpses[#data.corpses + 1] = {entity = corpse, expire = event.tick + CORPSE_TICKS}
        end
    end
    notifyChanged()
end

----------------------------------------------------------------------------------------------------------------------
-- remote

-- spawns now (no timer, no cap); kind "champion" or "hourBoss", unitType optional
function champions.spawnNow(universe, surfaceIndex, kind, unitType)
    local map = universe.maps[surfaceIndex]
    if (not map) or (not KINDS[kind]) or (unitType and not TYPES[unitType]) then
        return nil
    end
    return spawn(universe, map, kind, game.tick, unitType)
end

-- read-only snapshot
function champions.report(universe)
    local data = universe.champions
    local result = {units = {}, corpses = 0, nextTick = {}}
    if not data then
        return result
    end
    for unitNumber, record in pairs(data.units) do
        local entity = record.entity
        result.units[#result.units + 1] = {
            unitNumber = unitNumber, kind = record.kind, name = record.prototypeName, state = record.state,
            pool = record.pool, poolMax = record.poolMax, nameIndex = record.nameIndex,
            color = COLORS[record.colorIndex].name, died = record.died,
            health = entity.valid and entity.health or nil, maxHealth = entity.valid and entity.max_health or nil,
            speed = entity.valid and entity.speed or nil,
            position = entity.valid and entity.position or nil, home = record.home, target = record.target,
        }
    end
    result.corpses = #data.corpses
    for kind, tick in pairs(data.nextTick) do
        result.nextTick[kind] = tick
    end
    return result
end

championsG = champions
return champions
