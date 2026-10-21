-- Reforged Paranoidal: unit prototypes of the champions and hour bosses (libs/Champions.lua).
--
-- A champion is a copy of a unit named constants.championUnitName(kind, unit, nest unit): one copy per kind and per
-- unit the nest spawns now, as libs/Champions.lua (resolveBoss) picks them. The copy has the real health of the
-- champion: max(own health, healthK x health of the nest unit), so the health bar and the tooltip show it as it is, and
-- no natural regeneration (it regenerates at a nest by script). on_entity_damaged can only be filtered by prototype,
-- not by unit: with own prototypes the filter reaches the champions only. Copies are made for:
--  * Rampant biters, spitters and flyers: the unit tierUp tiers above every unit of the line (capped at tier 10);
--  * units of the other nests (vanilla, Bob), except Big Monsters and mferrari nests: the next stronger unit of the
--    same kind among the nest's units (hour boss: the one after it);
-- and never for units whose attack damages themselves (suicide and nuclear biters).
-- Copies are not spawned by nests, have no loot (the champion drops one artifact) and are hidden in Factoriopedia.
-- Runs at the end of data-final-fixes, after the resistance updates of this mod. If a copy is missing, the runtime
-- spawns the ordinary unit with a script health pool as before.

local constants = require("__RampantFixed__/libs/Constants")

local KINDS = constants.CHAMPION_KINDS
local championUnitName = constants.championUnitName
local RAMPANT_UNIT = "^(.+)%-(%a+)%-v(%d+)%-t(%d+)%-rampant$"
local RAMPANT_TYPES = {biter = true, spitter = true, flyer = true}
local MAX_TIER = 10

-- a single prototype entry or an array of them
local function asList(value)
    if value == nil then
        return {}
    end
    if value.type ~= nil then
        return {value}
    end
    return value
end

-- same test as selfDestructs in libs/Champions.lua: a damage effect on the source of the attack
local function hurtsItself(unit)
    local attack = unit.attack_parameters
    local ammoType = attack and attack.ammo_type
    for _, trigger in pairs(asList(ammoType and ammoType.action)) do
        for _, delivery in pairs(asList(trigger.action_delivery)) do
            for _, effect in pairs(asList(delivery.source_effects)) do
                if effect.type == "damage" then
                    return true
                end
            end
        end
    end
    return false
end

-- same as unitKind in libs/Champions.lua
local function unitKind(name)
    if string.find(name, "flyer", 1, true) then
        return "flyer"
    elseif string.find(name, "spitter", 1, true) then
        return "spitter"
    end
    return "biter"
end

-- Big Monsters / mferrari spawners (libs/ForeignEnemies.lua, no requires: usable at the data stage)
local excludedSpawner = require("__RampantFixed__/libs/ForeignEnemies").isForeign

local units = data.raw["unit"]

local function healthOf(unit)
    return unit.max_health or 10
end

-- copy name -> {kind, boss, nest unit}
local pairsByName = {}

local function addPair(kind, bossName, localName)
    pairsByName[championUnitName(kind, bossName, localName)] = {kind = kind, boss = bossName, nest = localName}
end

for name in pairs(units) do
    local faction, unitType, variation, tier = string.match(name, RAMPANT_UNIT)
    if unitType and RAMPANT_TYPES[unitType] then
        tier = tonumber(tier)
        for kind, spec in pairs(KINDS) do
            local bossName = faction .. "-" .. unitType .. "-v" .. variation .. "-t" ..
                math.min(tier + spec.tierUp, MAX_TIER) .. "-rampant"
            if units[bossName] then
                addPair(kind, bossName, name)
            end
        end
    end
end

-- vanilla / Bob nests: the next stronger unit of the same kind among the nest's units (tierUp steps)
for spawnerName, spawner in pairs(data.raw["unit-spawner"]) do
    if not excludedSpawner(spawnerName) then
        local nestUnits = {}
        for _, definition in pairs(spawner.result_units or {}) do
            local name = definition.unit or definition[1]
            if name and units[name] then
                nestUnits[#nestUnits + 1] = name
            end
        end
        for _, localName in ipairs(nestUnits) do
            if not string.find(localName, "rampant", 1, true) then
                local desiredType = unitKind(localName)
                for kind, spec in pairs(KINDS) do
                    local bossName = localName
                    local bossHealth = healthOf(units[localName])
                    for _ = 1, spec.tierUp do
                        local stronger, strongerHealth
                        for _, name in ipairs(nestUnits) do
                            if unitKind(name) == desiredType then
                                local health = healthOf(units[name])
                                if (health > bossHealth) and ((not strongerHealth) or (health < strongerHealth)) then
                                    stronger = name
                                    strongerHealth = health
                                end
                            end
                        end
                        if not stronger then
                            break
                        end
                        bossName = stronger
                        bossHealth = strongerHealth
                    end
                    addPair(kind, bossName, localName)
                end
            end
        end
    end
end

local names = {}
for name in pairs(pairsByName) do
    names[#names + 1] = name
end
table.sort(names)

local copies = {}
for _, copyName in ipairs(names) do
    local pair = pairsByName[copyName]
    local unit = units[pair.boss]
    if (not units[copyName]) and (not hurtsItself(unit)) then
        local copy = table.deepcopy(unit)
        copy.name = copyName
        copy.localised_name = unit.localised_name or {"entity-name." .. pair.boss}
        copy.max_health = math.max(healthOf(unit), healthOf(units[pair.nest]) * KINDS[pair.kind].healthK)
        copy.healing_per_tick = 0
        copy.loot = nil
        copy.hidden_in_factoriopedia = true
        copies[#copies + 1] = copy
    end
end

if #copies > 0 then
    data:extend(copies)
end
log("RampantFixed: champion unit prototypes: " .. #copies)
