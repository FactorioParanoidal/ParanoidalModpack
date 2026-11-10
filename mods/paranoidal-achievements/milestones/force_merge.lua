local table = require("__flib__.table")
local identity = require("milestones.identity")
local sandbox = require("scripts.sandbox")
local M = {}

local function key(milestone)
    return string.format("%s\0%s\0%s\0%.17g\0%s\0%.17g", milestone.type, milestone.name,
        milestone.quality or "", milestone.quantity, milestone.group or "Other", milestone.sort_index or 0)
end

local function merge_time(destination, source)
    if source.completion_tick == nil then return end
    local upper = source.completion_tick
    local lower = source.lower_bound_tick or upper
    if destination.completion_tick ~= nil then
        lower = math.min(lower, destination.lower_bound_tick or destination.completion_tick)
        upper = math.min(upper, destination.completion_tick)
    end
    destination.completion_tick = upper
    destination.lower_bound_tick = lower < upper and lower or nil
end

function M.merge(source_name, destination)
    local source = storage.forces[source_name]
    local ignored = sandbox.is_force_name(source_name) or sandbox.is_force(destination)
    if source and not ignored then
        local own = storage.forces[destination.name]
        if not own then
            own = {complete_milestones={}, incomplete_milestones={}, milestones_by_group={},
                item_stats={}, fluid_stats={}, kill_stats={}}
            storage.forces[destination.name] = own
        end
        do
            local records, by_key = {}, {}
            for _, list in ipairs({own.complete_milestones, own.incomplete_milestones}) do
                for _, milestone in ipairs(list) do
                    records[#records + 1] = milestone
                    local signature = key(milestone)
                    by_key[signature] = by_key[signature] or {}
                    table.insert(by_key[signature], milestone)
                end
            end
            for _, list in ipairs({source.complete_milestones, source.incomplete_milestones}) do
                for _, milestone in ipairs(list) do
                    local signature = key(milestone)
                    local matches = by_key[signature]
                    if matches then
                        for _, existing in ipairs(matches) do merge_time(existing, milestone) end
                    else
                        local copy = table.deep_copy(milestone)
                        copy.id = nil
                        records[#records + 1] = copy
                        by_key[signature] = {copy}
                    end
                end
            end
            own.complete_milestones, own.incomplete_milestones, own.milestones_by_group = {}, {}, {}
            for _, milestone in ipairs(records) do
                local list = milestone.completion_tick ~= nil and own.complete_milestones or own.incomplete_milestones
                list[#list + 1] = milestone
                local group = milestone.group or "Other"
                milestone.group = group
                own.milestones_by_group[group] = own.milestones_by_group[group] or {}
                table.insert(own.milestones_by_group[group], milestone)
            end
        end
        own.item_stats, own.fluid_stats, own.kill_stats = {}, {}, {}
        add_flow_statistics_to_storage_force(destination)
        remove_invalid_milestones_for_force(own)
        identity.ensure(own)
        backfill_completion_times(destination)
        sort_milestones(own.complete_milestones)
        for _, list in pairs(own.milestones_by_group) do sort_milestones(list) end
    end
    clear_force(source_name)
    if not ignored then
        initialize_force_if_needed(destination)
        refresh_gui_for_force(destination)
    end
end

return M
