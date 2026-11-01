-- Production modes II and III (careful, precise) as hidden twins of every machine with modes, plus the
-- hidden beacon of the quality-module boost. data-final-fixes, after every other change of the machines.
-- A machine switched to a mode is replaced by its twin (scripts/expansion/modes.lua), so the engine itself
-- crafts 5 or 20 times slower and draws 5 or 20 times the power, at any machine speed. Twins exist whenever
-- quality is on (also with defects off): a save with machines in a mode must never lose them at load.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local shared = require("prototypes.expansion-shared")

local M = {}

local function joules(energy) return require("util").parse_energy(energy) end
local function watts(power) return joules(power) * 60 end
local function power_string(value) return string.format("%.17gW", value) end
local function energy_string(value) return string.format("%.17gJ", value) end

-- Items that place each entity (place_result), by entity name.
local function placing_items(raw)
    local result = {}
    for kind in pairs(defines.prototypes.item) do
        for name, item in pairs(raw[kind] or {}) do
            local target = item.place_result
            if type(target) == "string" and target ~= "" then
                result[target] = result[target] or {}
                table.insert(result[target], name)
            end
        end
    end
    for _, list in pairs(result) do table.sort(list) end
    return result
end

-- Machines that get production modes; the same rule as modes.eligible at runtime: a player-placeable
-- assembling machine or furnace except the workshop, Creative Mod and the machines without modes.
function M.machines(raw, no_mode, items)
    local list = {}
    for _, kind in ipairs(M.types) do
        for name, machine in pairs(raw[kind] or {}) do
            if name ~= names.workshop and not name:find("^creative%-mod") and not no_mode[name]
                and (items[name] or machine.placeable_by) and machine.energy_usage then
                list[#list + 1] = machine
            end
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end
M.types = {"assembling-machine", "furnace"}

local function scale_source(source, factor)
    if source.type == "electric" then
        if source.buffer_capacity then source.buffer_capacity = energy_string(joules(source.buffer_capacity) * factor) end
        if source.input_flow_limit then source.input_flow_limit = power_string(watts(source.input_flow_limit) * factor) end
    elseif source.type == "fluid" then
        if source.fluid_usage_per_tick then source.fluid_usage_per_tick = source.fluid_usage_per_tick * factor end
    end
end

-- Twin of `machine` for `mode`: crafting speed / time, energy usage x time (energy per operation x time^2,
-- as rules.modes[mode].energy), the same drain and pollution per minute (so pollution per operation x time),
-- mined and placed as the original, merged with it in the deconstruction planner and Factoriopedia.
function M.twin(machine, mode, items)
    local definition = rules.modes[mode]
    local factor = definition.time
    local twin = table.deepcopy(machine)
    twin.name = machine.name .. names.mode_twin_suffix[mode]
    twin.crafting_speed = machine.crafting_speed / factor
    local usage = watts(machine.energy_usage)
    twin.energy_usage = power_string(usage * factor)
    local source = twin.energy_source
    if source then
        if source.type == "electric" then
            -- The engine default drain is 1/30 of energy_usage: keep the drain of the original.
            source.drain = machine.energy_source.drain or power_string(usage / 30)
        end
        scale_source(source, factor)
    end
    twin.hidden = true
    twin.hidden_in_factoriopedia = true
    twin.factoriopedia_alternative = machine.name
    twin.deconstruction_alternative = machine.deconstruction_alternative or machine.name
    twin.next_upgrade = nil
    if not twin.placeable_by then
        local placing = {}
        for _, item in ipairs(items[machine.name] or {}) do placing[#placing + 1] = {item = item, count = 1} end
        twin.placeable_by = placing
    end
    local flags = twin.flags or {}
    local seen = {}
    for _, flag in ipairs(flags) do seen[flag] = true end
    if not seen["not-in-made-in"] then flags[#flags + 1] = "not-in-made-in" end
    twin.flags = flags
    local base_name = machine.localised_name or {"?", {"entity-name." .. machine.name},
        items[machine.name] and {"item-name." .. items[machine.name][1]} or machine.name}
    twin.localised_name = {"ic-quality.mode-twin-" .. mode, base_name}
    twin.localised_description = machine.localised_description or {"?", {"entity-description." .. machine.name}, ""}
    return twin
end

-- Hidden beacon: only quality, a tiny box at the machine centre with supply distance 0 (only the machine it
-- stands on; engine check test-runs/ic-twin1-20261102), its own beacon counter.
function M.beacon()
    local flags = table.deepcopy(shared.hidden_flags)
    flags[#flags + 1] = "not-in-made-in"
    return {
        type = "beacon",
        name = names.mode_beacon,
        localised_name = {"entity-name.ic-mode-beacon"},
        icon = names.graphics .. "icons/mode-precise.png",
        icon_size = 64,
        hidden = true,
        hidden_in_factoriopedia = true,
        flags = flags,
        selectable_in_game = false,
        is_military_target = false,
        max_health = 1000,
        collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
        collision_mask = {layers = {}},
        energy_source = {type = "void"},
        energy_usage = "1W",
        supply_area_distance = 0,
        distribution_effectivity = 1,
        distribution_effectivity_bonus_per_quality_level = 0,
        profile = {1},
        beacon_counter = "same_type",
        module_slots = names.mode_module_count,
        allowed_effects = {"quality"},
        allowed_module_categories = {"quality"},
    }
end

-- Hidden modules of the beacon: module i has quality effect 2^(i-1) hundredths, so any effect from 0.01 to
-- (2^count - 1) / 100 is one set of modules (the engine keeps effects to two decimals). Category "quality":
-- the engine drops beacon modules of a category that the recipe (4035 recipes of the Beta 8 module port) or
-- the machine does not allow (test-runs/ic-beacon1-20261102), and "quality" is allowed wherever quality is.
function M.modules()
    local list = {}
    for index = 1, names.mode_module_count do
        list[#list + 1] = {
            type = "module",
            name = names.mode_module_prefix .. index,
            localised_name = {"item-name.ic-mode-quality"},
            icon = names.graphics .. "icons/mode-precise.png",
            icon_size = 64,
            hidden = true,
            hidden_in_factoriopedia = true,
            category = "quality",
            tier = 1,
            effect = {quality = 2 ^ (index - 1) / 100},
            stack_size = 1,
            subgroup = "module",
            order = "z[ic-mode]-" .. string.format("%02d", index),
        }
    end
    return list
end

function M.apply(raw)
    local no_mode = require("prototypes.expansion-final").no_mode_machines(raw)
    local items = placing_items(raw)
    local prototypes, count, grouped = {}, 0, 0
    for _, machine in ipairs(M.machines(raw, no_mode, items)) do
        -- The swap is an engine fast replace (scripts/expansion/modes.lua): it needs a fast-replaceable group.
        -- None of these machines is linked by next_upgrade (dump 2026-11-01), so the group is its own name.
        if (machine.fast_replaceable_group or "") == "" then
            machine.fast_replaceable_group = machine.name
            grouped = grouped + 1
        end
        for _, mode in ipairs(rules.mode_order) do
            if mode ~= "normal" then
                prototypes[#prototypes + 1] = M.twin(machine, mode, items)
                count = count + 1
            end
        end
    end
    prototypes[#prototypes + 1] = M.beacon()
    for _, prototype in ipairs(M.modules()) do prototypes[#prototypes + 1] = prototype end
    return prototypes, {"IC modes: machine twins " .. count .. " (careful and precise), machines given a fast-replaceable group "
        .. grouped .. ", beacon modules " .. names.mode_module_count}
end

return M
