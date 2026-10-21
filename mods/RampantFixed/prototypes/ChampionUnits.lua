-- Reforged Paranoidal: unit prototypes of the champions and hour bosses (libs/Champions.lua).
--
-- A champion is a copy of an ordinary unit named <unit> .. constants.CHAMPION_SUFFIX. on_entity_damaged can only be
-- filtered by prototype, not by unit: with the ordinary prototype every hit on every unit of that kind went to the
-- script while a champion lived. The copies are made for every unit libs/Champions.lua can pick:
--  * Rampant biters, spitters and flyers of tier 2 and above (a champion is one tier above the nest's units);
--  * units of the other nests (vanilla, Bob), except Big Monsters and mferrari nests;
-- and never for units whose attack damages themselves (suicide and nuclear biters).
-- Copies are not spawned by nests, have no loot (the champion drops one artifact) and are hidden in Factoriopedia.
-- Runs at the end of data-final-fixes, after the resistance updates of this mod. If a copy is missing, the runtime
-- spawns the ordinary unit as before.

local constants = require("__RampantFixed__/libs/Constants")

local SUFFIX = constants.CHAMPION_SUFFIX
local RAMPANT_UNIT = "^(.+)%-(%a+)%-v(%d+)%-t(%d+)%-rampant$"
local RAMPANT_TYPES = {biter = true, spitter = true, flyer = true}

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

-- Big Monsters / mferrari spawners (libs/ForeignEnemies.lua, no requires: usable at the data stage)
local excludedSpawner = require("__RampantFixed__/libs/ForeignEnemies").isForeign

local units = data.raw["unit"]
local selected = {}

for name in pairs(units) do
    local _, unitType, _, tier = string.match(name, RAMPANT_UNIT)
    if unitType and RAMPANT_TYPES[unitType] and (tonumber(tier) >= 2) then
        selected[name] = true
    end
end

for spawnerName, spawner in pairs(data.raw["unit-spawner"]) do
    if not excludedSpawner(spawnerName) then
        for _, definition in pairs(spawner.result_units or {}) do
            local name = definition.unit or definition[1]
            if name and units[name] and not string.find(name, "rampant", 1, true) then
                selected[name] = true
            end
        end
    end
end

local names = {}
for name in pairs(selected) do
    names[#names + 1] = name
end
table.sort(names)

local copies = {}
for _, name in ipairs(names) do
    local unit = units[name]
    local copyName = name .. SUFFIX
    if (not units[copyName]) and (not hurtsItself(unit)) then
        local copy = table.deepcopy(unit)
        copy.name = copyName
        copy.localised_name = unit.localised_name or {"entity-name." .. name}
        copy.loot = nil
        copy.hidden_in_factoriopedia = true
        copies[#copies + 1] = copy
    end
end

if #copies > 0 then
    data:extend(copies)
end
log("RampantFixed: champion unit prototypes: " .. #copies)
