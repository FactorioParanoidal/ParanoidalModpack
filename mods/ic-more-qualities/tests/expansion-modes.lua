-- Production modes as twin machines (scripts/expansion/modes.lua, prototypes/mode-twins.lua): names, eligibility,
-- the swap (state copied, open windows follow, failure undone), the quality beacon (effect equal to n independent
-- rolls, follows modules, recipe quality and position, off for recycling and the other excluded recipes),
-- operation counters, a weaker mode deciding the running operation again, the layout migration of older saves,
-- reverting every twin. The engine fast replace and beacon are mocks, not Factorio (engine checks:
-- test-runs/ic-twin1-20261102, ic-beacon1-20261102).
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")
local near = mock.near

defines = mock.defines()
storage = {}
script = {register_on_object_destroyed = function() end}
game = {tick = 0, connected_players = {}, surfaces = {}}
local renders = {}
rendering = {
    draw_sprite = function(spec)
        local id = #renders + 1
        local object = {id = id, valid = true, sprite = spec.sprite}
        object.destroy = function() object.valid = false end
        renders[id] = object
        return object
    end,
    get_object_by_id = function(id) return renders[id] end,
}

-- Qualities and machine prototypes ------------------------------------------------------------------------------
local Q = {}
Q.rare = {name = "rare", level = 3, next_probability = 0.15}
Q.uncommon = {name = "uncommon", level = 2, next = Q.rare, next_probability = 0.18}
Q.normal = {name = "normal", level = 0, next = Q.uncommon, next_probability = 0.204}
Q["ic-defect-2"] = {name = "ic-defect-2", level = 0, next = Q.normal, next_probability = 0.1}
local box = {left_top = {x = -1.5, y = -1.5}, right_bottom = {x = 1.5, y = 1.5}}
local function machine_prototype(name, extra)
    local p = {name = name, items_to_place_this = {{name = name}}, allowed_effects = {quality = true, speed = true},
        selection_box = box}
    for k, v in pairs(extra or {}) do p[k] = v end
    return p
end
local entity_prototypes = {}
for _, base in ipairs({"assembler", "furnace", "lamp", "workshop-like", "loner"}) do
    entity_prototypes[base] = machine_prototype(base)
end
for _, base in ipairs({"assembler", "furnace", "lamp"}) do
    entity_prototypes[base .. "-ic-mode-careful"] = machine_prototype(base .. "-ic-mode-careful")
    entity_prototypes[base .. "-ic-mode-precise"] = machine_prototype(base .. "-ic-mode-precise")
end
entity_prototypes["loner-ic-mode-careful"] = machine_prototype("loner-ic-mode-careful") -- no precise twin
entity_prototypes["ic-mode-beacon"] = {name = "ic-mode-beacon"}
prototypes = {
    entity = entity_prototypes,
    quality = Q,
    recipe = {chest = {name = "chest", category = "crafting"}, plate = {name = "plate", category = "smelting"}},
    mod_data = {["ic-quality-expansion"] = {data = {no_mode = {lamp = true}}}},
    get_entity_filtered = function()
        local result = {}
        for name, p in pairs(entity_prototypes) do if name ~= "ic-mode-beacon" then result[name] = p end end
        return result
    end,
}

-- Engine mock: machines and beacons on one surface ----------------------------------------------------------------
local surface = {index = 1, machines = {}, beacons = {}, no_group = {}}
game.surfaces = {surface}
local next_unit = 100
local function key(position) return position.x .. ":" .. position.y end
local function beacon_effect(position)
    local b = surface.beacons[key(position)]
    return b and b.valid and b.effects.quality or 0
end
local function new_machine(name, position, state)
    next_unit = next_unit + 1
    local kind = name:find("^furnace") and "furnace" or "assembling-machine"
    local e = {valid = true, name = name, type = kind, unit_number = next_unit, position = position, direction = 0,
        quality = {name = "normal"}, force = {index = 1}, surface = surface, health = 350, max_health = 350,
        products_finished = 0, destructible = true, minable_flag = true, operable = true, rotatable = true,
        disabled_by_script = false, mirroring = false, prototype = entity_prototypes[name], native = 0,
        crafting = false, crafting_progress = 0, recipe = nil, recipe_quality = Q.normal, result_quality = nil,
        deconstruct = false}
    for k, v in pairs(state or {}) do e[k] = v end
    e.get_recipe = function()
        if not e.recipe then return nil end
        return {name = e.recipe, category = prototypes.recipe[e.recipe] and prototypes.recipe[e.recipe].category}, e.recipe_quality
    end
    e.is_crafting = function() return e.crafting end
    e.to_be_deconstructed = function() return e.deconstruct end
    e.to_be_upgraded = function() return false end
    e.destroy = function()
        e.valid = false
        if surface.machines[key(e.position)] == e then surface.machines[key(e.position)] = nil end
    end
    setmetatable(e, {__index = function(t, k)
        if k == "effects" then return {quality = rawget(t, "native") + beacon_effect(rawget(t, "position"))} end
    end})
    return e
end
local function place(name, x, state)
    local e = new_machine(name, {x = x, y = 0}, state)
    surface.machines[key(e.position)] = e
    return e
end
local function group(name) return (name:gsub("%-ic%-mode%-%a+$", "")) end
local MODULE = {}
for i = 1, 12 do MODULE["ic-mode-quality-" .. i] = 2 ^ (i - 1) / 100 end
surface.create_entity = function(spec)
    if spec.name == "ic-mode-beacon" then
        local b = {valid = true, name = spec.name, position = spec.position, force = spec.force, surface = surface,
            unit_number = 0, effects = {quality = 0}, modules = {}}
        next_unit = next_unit + 1
        b.unit_number = next_unit
        local inventory = {}
        inventory.clear = function()
            b.modules = {}
            b.effects.quality = 0
        end
        inventory.insert = function(stack)
            b.modules[#b.modules + 1] = stack.name
            b.effects.quality = b.effects.quality + MODULE[stack.name]
            return 1
        end
        b.get_module_inventory = function() return inventory end
        b.destroy = function()
            b.valid = false
            if surface.beacons[key(b.position)] == b then surface.beacons[key(b.position)] = nil end
        end
        b.teleport = function(position)
            surface.beacons[key(b.position)] = nil
            b.position = position
            surface.beacons[key(position)] = b
            return true
        end
        surface.beacons[key(spec.position)] = b
        return b
    end
    local old = surface.machines[key(spec.position)]
    local replaced = spec.fast_replace and old and old.valid and group(old.name) == group(spec.name)
        and not surface.no_group[group(spec.name)]
    -- The engine keeps recipe, running craft, result quality and modules; health comes back full and the
    -- finished counter starts at 0 (test-runs/ic-twin1-20261102).
    local state = {}
    if replaced then
        for _, k in ipairs({"recipe", "recipe_quality", "crafting", "crafting_progress", "result_quality", "native"}) do
            state[k] = old[k]
        end
        old.valid = false
    end
    local e = new_machine(spec.name, spec.position, state)
    if replaced or not old then surface.machines[key(spec.position)] = e end
    return e
end
surface.find_entities_filtered = function(filter)
    local wanted = {}
    for _, name in ipairs(type(filter.name) == "table" and filter.name or {filter.name}) do wanted[name] = true end
    local list = {}
    for _, e in pairs(surface.machines) do if e.valid and wanted[e.name] then list[#list + 1] = e end end
    for _, b in pairs(surface.beacons) do if b.valid and wanted[b.name] then list[#list + 1] = b end end
    table.sort(list, function(a, b) return a.unit_number < b.unit_number end)
    return list
end

local rules = require("scripts.expansion.rules")
local modes = require("scripts.expansion.modes")
local infos = {
    chest = {all_finished = true, recycling = false},
    plate = {all_finished = false, recycling = false},
    ["chest-recycling"] = {all_finished = false, recycling = true},
    sign = {all_finished = true, recycling = false},
}
local everywhere = true
modes.context = {
    recipe = function(name) return infos[name] end,
    no_quality = function() return {sign = true} end,
}
setmetatable(modes.context, {__index = function(_, k) if k == "quality_everywhere" then return everywhere end end})

-- Names and eligibility --------------------------------------------------------------------------------------------
assert(modes.split("assembler-ic-mode-precise").base == "assembler" and modes.split("assembler-ic-mode-precise").mode == "precise")
assert(modes.split("assembler") == nil and modes.split("ghost-ic-mode-precise") == nil, "a twin needs both prototypes")
assert(modes.base_name("furnace-ic-mode-careful") == "furnace" and modes.mode_of_name("furnace-ic-mode-careful") == "careful")
assert(modes.definition_of_name("assembler-ic-mode-precise") == rules.modes.precise and modes.definition_of_name("assembler") == nil)
assert(modes.twin_name("assembler", "careful") == "assembler-ic-mode-careful" and modes.twin_name("assembler", "normal") == "assembler")
assert(#modes.twin_names() == 7)
assert(modes.eligible(place("assembler", 0)) and modes.eligible(place("assembler-ic-mode-careful", 10)))
assert(not modes.eligible(place("lamp", 20)), "a machine without modes (mod-data no_mode)")
assert(not modes.eligible(place("loner", 30)), "a machine without both twins")
surface.machines = {}

-- The beacon effect equals n independent rolls ------------------------------------------------------------------------
local function wanted_bits(native, probability, boost)
    local p = math.min(1, native * probability)
    return math.floor(((1 - (1 - p) ^ boost) / probability - native) * 100 + 0.5)
end
local tracked = {}
local function on_tracked(entity, old_id, keep) tracked[#tracked + 1] = {entity = entity, old = old_id, keep = keep} end
local player = {valid = true, connected = true}
game.connected_players = {player}
local base = place("assembler", 0, {recipe = "chest", crafting = true, crafting_progress = 0.4, result_quality = Q.normal,
    native = 1.32, health = 120, products_finished = 7, last_user = player, disabled_by_script = true})
player.opened = base
local twin = modes.set(base, "precise", on_tracked)
assert(twin and twin.name == "assembler-ic-mode-precise" and not base.valid)
assert(twin.health == 120 and twin.products_finished == 7 and twin.last_user == player and twin.disabled_by_script == true,
    "health, finished counter, last user and script flags copied")
assert(twin.crafting_progress == 0.4 and twin.result_quality == Q.normal, "running craft kept by the engine")
assert(player.opened == twin, "an open window follows the machine")
assert(tracked[1].entity == twin and tracked[1].old == base.unit_number and tracked[1].keep == true)
local record = storage.ic_modes.records[twin.unit_number]
local bits = wanted_bits(1.32, 0.204, 10)
assert(record and record.mode == "precise" and record.bits == bits, "bits " .. tostring(record and record.bits) .. " vs " .. bits)
near(twin.effects.quality, 1.32 + bits / 100, 1e-9)
near(modes.native_quality_effect(twin), 1.32)
near((1.32 + bits / 100) * 0.204, 1 - (1 - 1.32 * 0.204) ^ 10, 0.002)
assert(renders[record.render].sprite == "ic-mode-precise")
assert(modes.set(twin, "precise") == twin, "the same mode changes nothing")

-- The beacon follows modules, recipe quality and position; off where no boost applies.
twin.native = 0
modes.refresh(record)
assert(record.bits == 0 and record.beacon == nil, "no quality modules: no beacon")
twin.native = 0.2
modes.refresh(record)
assert(record.bits == wanted_bits(0.2, 0.204, 10) and record.beacon.valid)
twin.recipe_quality = Q.uncommon
modes.refresh(record)
assert(record.bits == wanted_bits(0.2, 0.18, 10), "chance of the recipe quality")
twin.recipe_quality = Q["ic-defect-2"]
modes.refresh(record)
assert(record.bits == 0, "defective ingredients: no boost")
twin.recipe_quality = Q.normal
for _, case in ipairs({{"chest-recycling", 0}, {"sign", 0}, {"plate", nil}}) do
    twin.recipe = case[1]
    modes.refresh(record)
    if case[2] then assert(record.bits == case[2], case[1]) end
end
assert(record.bits == wanted_bits(0.2, 0.204, 10), "a material with quality everywhere")
everywhere = false
modes.refresh(record)
assert(record.bits == 0, "a material without quality everywhere stays standard")
everywhere = true
twin.recipe = "chest"
twin.native = 6
modes.refresh(record)
assert(record.bits == 0, "a native chance of 100% needs nothing")
twin.native = 1.32
modes.refresh(record)
local beacon = record.beacon
twin.position = {x = 3, y = 0}
surface.machines["0:0"], surface.machines["3:0"] = nil, twin
modes.refresh(record)
assert(beacon.valid and beacon.position.x == 3 and record.beacon == beacon, "moved with the machine")
twin.position = {x = 0, y = 0}
surface.machines["3:0"], surface.machines["0:0"] = nil, twin
modes.refresh(record)
-- Operation counters: the finished counter since the last look.
storage.ic_stats = nil
twin.products_finished = twin.products_finished + 5
modes.refresh(record)
assert(storage.ic_stats[1]["mode.precise"] == 5)

-- A weaker mode during an upgraded operation decides it again: kept with the share of the weaker chance.
local keep = (1 - (1 - 1.32 * 0.204) ^ 3) / (1 - (1 - 1.32 * 0.204) ^ 10)
twin.result_quality = Q.uncommon
local random = math.random
math.random = function() return keep - 1e-6 end
local careful = modes.set(twin, "careful", on_tracked)
assert(careful.name == "assembler-ic-mode-careful" and careful.result_quality == Q.uncommon and tracked[2].keep == false)
local careful_record = storage.ic_modes.records[careful.unit_number]
assert(careful_record.bits == wanted_bits(1.32, 0.204, 3) and storage.ic_modes.records[twin.unit_number] == nil)
assert(storage.ic_stats[1]["mode.precise"] == 5, "counted before the swap, not twice")
math.random = function() return 0.999 end
local normal = modes.set(careful, "normal", on_tracked)
assert(normal.name == "assembler" and normal.result_quality == "normal", "not kept: the recipe quality (written by name)")
assert(storage.ic_modes.records[careful.unit_number] == nil and not careful_record.beacon, "beacon gone with the mode")
-- A stronger mode keeps the decision of the running operation.
normal.result_quality = Q.uncommon
local strong = modes.set(normal, "precise", on_tracked)
assert(strong.result_quality == Q.uncommon and tracked[4].keep == true)
math.random = random

-- Refused and failed switches ---------------------------------------------------------------------------------------
strong.deconstruct = true
local result, reason = modes.set(strong, "normal", on_tracked)
assert(result == nil and reason == "marked" and strong.valid)
strong.deconstruct = false
surface.no_group.furnace = true
local lone = place("furnace", 50, {})
result, reason = modes.set(lone, "careful")
assert(result == nil and reason == "failed" and lone.valid and surface.machines["50:0"] == lone, "no fast replace: undone")
surface.no_group.furnace = nil
local lamp = place("lamp", 60, {})
assert(modes.set(lamp, "precise") == nil, "no modes")

-- on_tick: due records are looked at again -------------------------------------------------------------------------
local strong_record = storage.ic_modes.records[strong.unit_number]
strong.products_finished = strong.products_finished + 2
game.tick = strong_record.due
modes.on_tick(game.tick)
assert(strong_record.due == game.tick + modes.REFRESH and storage.ic_stats[1]["mode.precise"] == 7)
strong.valid = false
game.tick = strong_record.due
modes.on_tick(game.tick)
assert(storage.ic_modes.records[strong.unit_number] == nil and not strong_record.beacon, "invalid machine forgotten")
surface.machines["0:0"] = nil

-- Configuration change: layout 1 (machine slowed by script, power interface) becomes twins; a twin whose machine
-- lost its modes goes back; stray beacons go; every twin gets a record.
local interface = {valid = true}
interface.destroy = function() interface.valid = false end
local old_moded = place("assembler", 100, {recipe = "chest", crafting = true, crafting_progress = 0.7, result_quality = Q.normal})
local old_normal = place("assembler", 110, {})
local lamp_twin = place("lamp-ic-mode-precise", 120, {})
local orphan = place("furnace-ic-mode-careful", 130, {})
local stray = surface.create_entity({name = "ic-mode-beacon", position = {x = 140, y = 0}})
storage.ic_modes = {records = {
    [old_moded.unit_number] = {id = old_moded.unit_number, entity = old_moded, mode = "precise", interface = interface,
        render = rendering.draw_sprite({sprite = "ic-mode-precise"}).id},
    [old_normal.unit_number] = {id = old_normal.unit_number, entity = old_normal, mode = "normal"},
}}
game.tick = 5000
modes.rescan()
local s = storage.ic_modes
assert(s.version == modes.VERSION and not interface.valid)
local migrated = surface.machines["100:0"]
assert(migrated.name == "assembler-ic-mode-precise" and migrated.crafting_progress == 0.7 and s.records[migrated.unit_number])
assert(surface.machines["110:0"] == old_normal and old_normal.valid and not s.records[old_normal.unit_number])
assert(surface.machines["120:0"].name == "lamp" and not lamp_twin.valid, "a twin without modes goes back")
assert(s.records[orphan.unit_number] and s.records[orphan.unit_number].mode == "careful", "a twin found on the map")
assert(not stray.valid, "stray beacon removed")
for _, r in pairs(s.records) do assert(r.due > 5000 and r.due <= 5000 + 1 + modes.REFRESH) end

-- Defects switched off: every twin goes back to its machine, beacons and records go.
migrated.native = 1
modes.refresh(s.records[migrated.unit_number])
assert(s.records[migrated.unit_number].beacon.valid)
local its_beacon = s.records[migrated.unit_number].beacon
modes.revert_all()
assert(surface.machines["100:0"].name == "assembler" and surface.machines["130:0"].name == "furnace")
assert(storage.ic_modes == nil and not its_beacon.valid)

-- An older save loaded without a configuration change (same mod version): migrated at the first tick, the
-- scheduler follows the replaced machine.
local lazy = place("assembler", 200, {recipe = "chest", crafting = true, crafting_progress = 0.3})
storage.ic_modes = {records = {[lazy.unit_number] = {id = lazy.unit_number, entity = lazy, mode = "careful"}}}
local followed
modes.on_tracked = function(entity, old_id, keep) followed = {entity = entity, old = old_id, keep = keep} end
modes.on_tick(6000)
local lazy_twin = surface.machines["200:0"]
assert(lazy_twin.name == "assembler-ic-mode-careful" and storage.ic_modes.version == modes.VERSION)
assert(followed and followed.entity == lazy_twin and followed.old == lazy.unit_number and followed.keep == true)

-- A twin of a machine that lost its modes (recyclers since 2026-11-02) with a record, without a configuration
-- change: back to the original at its next look, the scheduler follows; a revive of its ghost likewise.
local lost = place("lamp-ic-mode-precise", 210, {recipe = "chest", crafting = true, crafting_progress = 0.5})
local lost_record = modes.adopt(lost)
assert(lost_record and storage.ic_modes.records[lost.unit_number])
followed = nil
game.tick = lost_record.due
modes.on_tick(game.tick)
local back = surface.machines["210:0"]
assert(back.name == "lamp" and back.crafting_progress == 0.5 and not lost.valid)
assert(storage.ic_modes.records[lost.unit_number] == nil and storage.ic_modes.records[back.unit_number] == nil)
assert(followed and followed.entity == back and followed.old == lost.unit_number)
modes.on_tracked = nil

print("PASS: twin names and eligibility, swap (health, counter, last user, flags, open window, scheduler hook),")
print("quality beacon = n independent rolls (modules, recipe quality, defects, recycling, no-quality recipes,")
print("materials, 100% native, position), operation counters, weaker mode re-decides the running operation,")
print("stronger keeps it, refused/failed switches, on_tick, layout 1 migration (configuration change and lazy),")
print("stray beacons, revert_all, a twin of a machine without modes reverted at its look (recyclers).")
print("Mocks only, not Factorio.")
