local table = require("__flib__.table")

-- Each production graph bracket, from highest to lowest
-- Used in find_precision_bracket()
local FLOW_PRECISION_BRACKETS = {
    defines.flow_precision_index.one_thousand_hours,
    defines.flow_precision_index.two_hundred_fifty_hours,
    defines.flow_precision_index.fifty_hours,
    defines.flow_precision_index.ten_hours,
    defines.flow_precision_index.one_hour,
    defines.flow_precision_index.ten_minutes,
    defines.flow_precision_index.one_minute,
    defines.flow_precision_index.five_seconds
}

-- The length of each precision bracket, in ticks
local FLOW_PRECISION_BRACKETS_LENGTHS = {
    [defines.flow_precision_index.one_thousand_hours] =      1000*60*60*60,
    [defines.flow_precision_index.two_hundred_fifty_hours] = 250*60*60*60,
    [defines.flow_precision_index.fifty_hours] =             50*60*60*60,
    [defines.flow_precision_index.ten_hours] =               10*60*60*60,
    [defines.flow_precision_index.one_hour] =                1*60*60*60,
    [defines.flow_precision_index.ten_minutes] =             10*60*60,
    [defines.flow_precision_index.one_minute] =              1*60*60,
    [defines.flow_precision_index.five_seconds] =            5*60,
}

QUALITY_NAMES_SET = {}
for quality_name, _quality_prototype in pairs(prototypes.quality) do
    QUALITY_NAMES_SET[quality_name] = true
end

local function find_possible_existing_completion_time(storage_force, new_milestone)
    for _, complete_milestone in pairs(storage_force.complete_milestones) do
        if complete_milestone.type == new_milestone.type and
           complete_milestone.name == new_milestone.name and
           complete_milestone.quality == new_milestone.quality and
           complete_milestone.quantity == new_milestone.quantity then
            return complete_milestone.completion_tick, complete_milestone.lower_bound_tick
        end
    end
    return nil, nil
end

function merge_new_milestones(force_name, new_loaded_milestones)
    local storage_force = storage.forces[force_name]
    local new_complete = {}
    local new_incomplete = {}
    local new_milestones_by_group = {}

    local current_group = "Other"
    for i, new_loaded_milestone in pairs(new_loaded_milestones) do
        if new_loaded_milestone.type == "group" then
            current_group = new_loaded_milestone.name
        elseif new_loaded_milestone.type ~= "alias" then
            local new_milestone = table.deep_copy(new_loaded_milestone)
            new_milestone.sort_index = i
            new_milestone.group = current_group
            new_milestones_by_group[current_group] = new_milestones_by_group[current_group] or {}

            local next_milestone = new_milestone
            while next_milestone ~= nil do
                local completion_tick, lower_bound_tick = find_possible_existing_completion_time(storage_force, next_milestone)
                if completion_tick == nil then
                    table.insert(new_incomplete, next_milestone)
                    -- Intentionally insert the same reference in both new_milestones_by_group and new_incomplete/new_incomplete
                    table.insert(new_milestones_by_group[current_group], next_milestone)
                    next_milestone = nil
                else
                    next_milestone.completion_tick = completion_tick
                    next_milestone.lower_bound_tick = lower_bound_tick
                    table.insert(new_complete, next_milestone)
                    table.insert(new_milestones_by_group[current_group], next_milestone)
                    if next_milestone.next then
                        next_milestone = create_next_milestone(force_name, next_milestone)
                    else
                        next_milestone = nil
                    end
                end
            end
        end
    end

    storage_force.complete_milestones = new_complete
    storage_force.incomplete_milestones = new_incomplete
    storage_force.milestones_by_group = new_milestones_by_group
end

function initialize_alias_table()
    -- First make a dict of milestone names to attach a type to aliases later
    local milestone_type_by_name = {}
    for _, loaded_milestone in pairs(storage.loaded_milestones) do
        milestone_type_by_name[loaded_milestone.name] = loaded_milestone.type
    end
    storage.production_aliases = {}
    for _, loaded_milestone in pairs(storage.loaded_milestones) do
        if loaded_milestone.type == "alias" and (
            prototypes.item[loaded_milestone.name] ~= nil or
            prototypes.fluid[loaded_milestone.name] ~= nil or
            prototypes.entity[loaded_milestone.name] ~= nil
        ) then
            local alias_type = milestone_type_by_name[loaded_milestone.equals]
            if alias_type then
                local alias_milestone = {type=alias_type, name=loaded_milestone.name, quantity=loaded_milestone.quantity, quality=loaded_milestone.quality}
                storage.production_aliases[loaded_milestone.equals] = {} or storage.production_aliases[loaded_milestone.equals]
                table.insert(storage.production_aliases[loaded_milestone.equals], alias_milestone)
            end
        end
    end
end

function mark_milestone_reached(storage_force, milestone, tick, milestone_index, lower_bound_tick) -- lower_bound_tick is optional
    milestone.completion_tick = tick
    if lower_bound_tick then milestone.lower_bound_tick = lower_bound_tick end
    table.insert(storage_force.complete_milestones, milestone)
    table.remove(storage_force.incomplete_milestones, milestone_index)
    sort_milestones(storage_force.milestones_by_group[milestone.group])
end

function mark_milestone_unreached(storage_force, milestone, milestone_index)
    milestone.completion_tick = nil
    milestone.lower_bound_tick = nil
    table.insert(storage_force.incomplete_milestones, milestone)
    table.remove(storage_force.complete_milestones, milestone_index)
    sort_milestones(storage_force.milestones_by_group[milestone.group])
end

function parse_next_formula(next_formula)
    if next_formula == nil or string.len(next_formula) < 2 then return nil, nil end
    local operator = string.sub(next_formula, 1, 1)
    local next_value = tonumber(string.sub(next_formula, 2))

    if next_value == nil then return nil, nil end
    if operator == '*' then operator = 'x' end

    if operator == 'x' then
        if next_value <= 1 then return nil, nil end
    elseif operator == '+' then
        if next_value <= 0 then return nil, nil end
    else
        return nil, nil
    end

    return operator, next_value
end

function create_next_milestone(force_name, milestone)
    local operator, next_value = parse_next_formula(milestone.next)
    if operator == nil then
        game.forces[force_name].print({"", {"milestones.message_invalid_next"}, milestone.next})
        return
    end

    local new_milestone = table.deep_copy(milestone)
    if operator == '+' then
        new_milestone.quantity = milestone.quantity + next_value
    elseif operator == 'x' then
        new_milestone.quantity = milestone.quantity * next_value
    end

    new_milestone.lower_bound_tick = nil
    new_milestone.completion_tick = nil
    new_milestone.sort_index = milestone.sort_index + 0.0001 -- Should work until there's 10000 iterations of an infinite milestone, lol
    new_milestone.hidden = nil

    return new_milestone
end

function floor_to_nearest_minute(tick)
    return (tick - (tick % (60*60)))
end

function ceil_to_nearest_minute(tick)
    local modulo = tick % (60*60)
    if modulo == 0 then return tick end
    return tick - modulo + 60*60
end

local function is_consumption_type(milestone_type)
    if milestone_type == "item_consumption" or milestone_type == "fluid_consumption" then
        return true
    else
        return false
    end
end

local function get_category_type(milestone)
    if is_consumption_type(milestone.type) then
        return "output"
    else
        return "input"
    end
end

-- These sum_* methods need to be performant, so we sacrifice DRY a bit to avoid checking the same conditions many times

-- item_id could be a String or a ItemIDAndQualityIDPair
local function sum_counts(flow_statistics_table, item_id, flow_stats_method_name)
    local total_count = 0
    for _, flow_statistics in pairs(flow_statistics_table) do
        total_count = total_count + flow_statistics[flow_stats_method_name](item_id)
    end
    return total_count
end

local function sum_counts_merged_qualities(flow_statistics_table, item_name, flow_stats_method_name)
    local total_count = 0
    for _, flow_statistics in pairs(flow_statistics_table) do
        for quality_name, _  in pairs(QUALITY_NAMES_SET) do
            total_count = total_count + flow_statistics[flow_stats_method_name]({name=item_name, quality=quality_name})
        end
    end
    return total_count
end

-- item_id could be a String or a ItemIDAndQualityIDPair
local function sum_get_flow_counts(flow_statistics_table, item_id, category_type, precision_index, sample_index)
    local total_count = 0
    for _, flow_statistics in pairs(flow_statistics_table) do
        total_count = total_count + flow_statistics.get_flow_count({
            name=item_id,
            category=category_type,
            precision_index=precision_index,
            sample_index=sample_index,
            count=true,
        })    
    end
    return total_count
end

local function sum_get_flow_counts_merged_qualities(flow_statistics_table, item_name, category_type, precision_index, sample_index)
    local total_count = 0
    for _, flow_statistics in pairs(flow_statistics_table) do
        for quality_name, _  in pairs(QUALITY_NAMES_SET) do
            total_count = total_count + flow_statistics.get_flow_count({
                name={name=item_name, quality=quality_name},
                category=category_type,
                precision_index=precision_index,
                sample_index=sample_index,
                count=true,
            })
        end
    end
    return total_count
end

-- Sums get_input/output_count for an array of LuaFlowStatistics, merging qualities if needed
local function get_total_count(flow_statistics_table, milestone)
    local flow_stats_method_name = is_consumption_type(milestone.type) and "get_output_count" or "get_input_count"
    if milestone.type == "item" or milestone.type == "item_consumption" or milestone.type == "kill" then -- These are the Item or Kill LuaFlowStatistics, they always take a quality.
        if milestone.quality then -- Specific quality
            return sum_counts(flow_statistics_table, {name=milestone.name, quality=milestone.quality}, flow_stats_method_name)
        else
            return sum_counts_merged_qualities(flow_statistics_table, milestone.name, flow_stats_method_name)
        end
    else -- Fluid LuaFlowStatistics, no qualities here.
        return sum_counts(flow_statistics_table, milestone.name, flow_stats_method_name)
    end
end

-- Sums get_flow_counts for an array of LuaFlowStatistics, merging qualities if needed
local function get_total_flow_count(flow_statistics_table, milestone, precision_index, sample_index)
    local category_type = get_category_type(milestone)
    local item_name
    if milestone.type == "item" or milestone.type == "item_consumption" then -- These are the Item LuaFlowStatistics, they always take a quality.
        if milestone.quality then -- Specific quality
            return sum_get_flow_counts(flow_statistics_table, {name=milestone.name, quality=milestone.quality}, category_type, precision_index, sample_index)
        else
            return sum_get_flow_counts_merged_qualities(flow_statistics_table, milestone.name, category_type, precision_index, sample_index)
        end
    else -- Fluid or Kills LuaFlowStatistics, no qualities here.
        return sum_get_flow_counts(flow_statistics_table, milestone.name, category_type, precision_index, sample_index)
    end
end

local function find_precision_bracket(milestone, flow_statistics_table, is_consumption)
    local total_count = get_total_count(flow_statistics_table, milestone)
    local previous_bracket = "ALL"
    for _, bracket in pairs(FLOW_PRECISION_BRACKETS) do

        -- The first bracket that does NOT match the total count indicates the upper bound first production time.
        -- e.g: if total_count = 4, and 4 were created in the last 1000 hours, 4 were created in the last 250 hours, and 2 were created in the last 50 hours,
        -- then the first creation was between 50 and 250 hours ago, and we should search the 250 hours precision bracket.

        if FLOW_PRECISION_BRACKETS_LENGTHS[bracket] <= game.tick then -- Skip bracket if the game is not long enough
            local bracket_count = get_total_flow_count(flow_statistics_table, milestone, bracket, nil)
            if bracket_count <= total_count - milestone.quantity then
                return previous_bracket
            end
        end
        previous_bracket = bracket
    end
    -- If we haven't found any count drop after going through all brackets
    -- then the item was produced during most recent bracket, which is within the last 5 seconds (improbable but could happen).
    return previous_bracket
end

local function find_sample_in_precision_bracket(milestone, bracket, flow_statistics_table)
    local total_count = get_total_count(flow_statistics_table, milestone)
     -- TODO: we already did this get_total_flow_count earlier in this same tick in find_precision_bracket, cache?
    local bracket_count = get_total_flow_count(flow_statistics_table, milestone, bracket, nil)
    local count_before_bracket = total_count - bracket_count
    local count_this_bracket = 0
    for i = 300,1,-1 do -- Start from oldest
        local sample_count = get_total_flow_count(flow_statistics_table, milestone, bracket, i)
        count_this_bracket = count_this_bracket + sample_count
        if count_this_bracket + count_before_bracket >= milestone.quantity then
            return i
        end
    end
    -- We should almost never reach this point because we already determined this is the bracket where the milestone was reached.
    -- It can happen when a mod creates items on tick 0 (i.e. before the game starts).
    log("Couldn't find sample! milestone: " ..serpent.line(milestone).. ", bracket: " ..bracket..
    ", count_before_bracket: " ..count_before_bracket.. ", count_this_bracket: " ..count_this_bracket)
    return 0
end

local function get_tick_bounds_from_sample(bracket, sample_index)
    local sample_precision_in_ticks = FLOW_PRECISION_BRACKETS_LENGTHS[bracket] / 300
    local upper_bound_ticks_ago = sample_precision_in_ticks * sample_index
    local lower_bound_ticks_ago = sample_precision_in_ticks * (sample_index - 1)
    return upper_bound_ticks_ago, lower_bound_ticks_ago
end

-- Converts from "X ticks ago" to "X ticks since start of the game"
local function get_realtime_tick_bounds(lower_bound_ticks_ago, upper_bound_ticks_ago, bracket)
    local lower_bound_ticks, upper_bound_ticks = game.tick - lower_bound_ticks_ago, game.tick - upper_bound_ticks_ago
    log("lower_bound_ticks: " ..lower_bound_ticks.. " - upper_bound_ticks: " ..upper_bound_ticks)

    -- Samples are bound to absolute game time. e.g. sample #3 for defines.flow_precision_index.one_minute corresponds to ticks 25 to 36.
    -- Floor to the real bounds of the sample.
    if bracket ~= "ALL" then
        local sample_precision_in_ticks = FLOW_PRECISION_BRACKETS_LENGTHS[bracket] / 300
        local sample_offset = lower_bound_ticks % sample_precision_in_ticks
        lower_bound_ticks = lower_bound_ticks - sample_offset + 1
        upper_bound_ticks = upper_bound_ticks - sample_offset
        log("sample_offset: " ..sample_offset)
        log("lower_bound_ticks: " ..lower_bound_ticks.. " - upper_bound_ticks: " ..upper_bound_ticks)
    end

    return lower_bound_ticks, upper_bound_ticks
end

local function find_production_tick_bounds(milestone, flow_statistics_table)
    local precision_bracket = find_precision_bracket(milestone, flow_statistics_table)
    log("bracket to search: " ..precision_bracket)

    local lower_bound_ticks_ago, upper_bound_ticks_ago
    if precision_bracket == "ALL" then
        -- Completion time is over 1000 hours ago, there are no samples to go through
        -- All we know is it's between tick 0 and 1000 hours ago
        lower_bound_ticks_ago, upper_bound_ticks_ago = game.tick, FLOW_PRECISION_BRACKETS_LENGTHS[defines.flow_precision_index.one_thousand_hours]
    else
        local sample_index = find_sample_in_precision_bracket(milestone, precision_bracket, flow_statistics_table)
        if sample_index == 0 then
            return game.tick, game.tick -- Created this exact tick, usually on tick 0 before the start of the game
        end
        lower_bound_ticks_ago, upper_bound_ticks_ago = get_tick_bounds_from_sample(precision_bracket, sample_index)
    end

    lower_bound_real_time, upper_bound_real_time = get_realtime_tick_bounds(lower_bound_ticks_ago, upper_bound_ticks_ago, precision_bracket)

    return lower_bound_real_time, upper_bound_real_time
end

-- TODO FIXME: This does not account for aliases at all!
function find_completion_tick_bounds(milestone, item_stats, fluid_stats, kill_stats)
    if milestone.type == "technology" then
        return 0, game.tick -- No way to know past research time
    elseif milestone.type == "item" or milestone.type == "item_consumption" then
        return find_production_tick_bounds(milestone, item_stats)
    elseif milestone.type == "fluid" or milestone.type == "fluid_consumption" then
        return find_production_tick_bounds(milestone, fluid_stats)
    elseif milestone.type == "kill" then
        return find_production_tick_bounds(milestone, kill_stats)
    end
end

function sort_milestones(milestones)
    table.sort(milestones, function(a,b)
        if a.completion_tick and not b.completion_tick then return true end -- a comes first
        if not a.completion_tick and b.completion_tick then return false end -- b comes first
        if a.completion_tick == b.completion_tick then return a.sort_index < b.sort_index end
        return a.completion_tick < b.completion_tick
    end)
end

function filter_hidden_milestones(milestones, show_incomplete)
    local visible_milestones = {}
    for _, milestone in pairs(milestones) do
        if milestone.completion_tick ~= nil or (show_incomplete and not milestone.hidden) then
            table.insert(visible_milestones, milestone)
        end
    end
    return visible_milestones
end

function backfill_completion_times(force)
    log("Backfilling completion times for " .. force.name)
    local backfilled_anything = false
    local technologies = force.technologies
    local storage_force = storage.forces[force.name]

    local i = 1
    while i <= #storage_force.incomplete_milestones do
        local milestone = storage_force.incomplete_milestones[i]
        if is_valid_milestone(milestone) and is_milestone_reached(milestone, storage_force, technologies) then
            local lower_bound, upper_bound = find_completion_tick_bounds(milestone, storage_force.item_stats, storage_force.fluid_stats, storage_force.kill_stats)
            log("Tick bounds for " ..milestone.name.. " : " ..lower_bound.. " - " ..upper_bound)
            if milestone.next then
                local next_milestone = create_next_milestone(force.name, milestone)
                table.insert(storage_force.incomplete_milestones, next_milestone)
                table.insert(storage_force.milestones_by_group[next_milestone.group], next_milestone)
            end
            mark_milestone_reached(storage_force, milestone, upper_bound, i, lower_bound)
            backfilled_anything = true
        else
            i = i + 1
        end
    end
    sort_milestones(storage_force.complete_milestones)
    for _group_name, group_milestones in pairs(storage_force.milestones_by_group) do
        sort_milestones(group_milestones)
    end
    return backfilled_anything
end

function is_production_milestone_reached(milestone, storage_force)
    local flow_statistics_table
    if milestone.type == "item" or milestone.type == "item_consumption" then
        flow_statistics_table = storage_force.item_stats
    elseif milestone.type == "fluid" or milestone.type == "fluid_consumption" then
        flow_statistics_table = storage_force.fluid_stats
    elseif milestone.type == "kill" then
        flow_statistics_table = storage_force.kill_stats
    else
        error("Invalid milestone type! " .. milestone.type)
    end

    local milestone_count = get_total_count(flow_statistics_table, milestone)

    -- Aliases
    if storage.production_aliases[milestone.name] then
        for _, alias in pairs(storage.production_aliases[milestone.name]) do
            local alias_count = get_total_count(flow_statistics_table, alias)
            if alias_count then
                milestone_count = milestone_count or 0 -- Could be nil
                milestone_count = milestone_count + alias_count * alias.quantity
            end
        end
    end

    return milestone_count and milestone_count >= milestone.quantity
end

function is_tech_milestone_reached(milestone, technology)
    if milestone.type == "technology" and
       technology.name == milestone.name and
       -- strict > because the level we get is the current researchable level, not the researched level
       -- if technology.level == technology.prototype.level then this is just a non-repeating tech with a number at the end e.g. 'Electronics 3'
       (technology.researched or (technology.level > milestone.quantity and technology.level > technology.prototype.level)) then
        return true
    end
    return false
end

function is_milestone_reached(milestone, storage_force, technologies)
    if milestone.type == "technology" then
        local technology = technologies[milestone.name]
        return is_tech_milestone_reached(milestone, technology)
    else
        return is_production_milestone_reached(milestone, storage_force)
    end
end

function remove_invalid_milestones_all_forces()
    for _force_name, storage_force in pairs(storage.forces) do
        remove_invalid_milestones_for_force(storage_force)
    end
end

function remove_invalid_milestones_for_force(storage_force)
    remove_invalid_milestones(storage_force.complete_milestones)
    remove_invalid_milestones(storage_force.incomplete_milestones)
    for _group_name, milestones_by_group in pairs(storage_force.milestones_by_group) do
        remove_invalid_milestones(milestones_by_group, true)
    end
end

function remove_invalid_milestones(milestones, silent)
    local i = 1
    while i <= #milestones do
        local milestone = milestones[i]
        if is_valid_milestone(milestone) then
            i = i + 1
        else
            table.remove(milestones, i)
            if not silent then
                table.insert(storage.delayed_chat_messages, {"milestones.message_invalid_item", milestone.name})
            end
        end
    end
end

function get_milestone_prototype(milestone)
    if milestone.type == "item" or milestone.type == "item_consumption" then
        return prototypes.item[milestone.name]
    elseif milestone.type == "fluid" or milestone.type == "fluid_consumption" then
        return prototypes.fluid[milestone.name]
    elseif milestone.type == "technology" then
        return prototypes.technology[milestone.name]
    elseif milestone.type == "kill" then
        return prototypes.entity[milestone.name]
    end
end

function remove_invalid_aliases()
    for milestone_name, alias_list in pairs(storage.production_aliases) do
        -- Reverse iterating to delete in-place
        for i=#alias_list,1,-1 do
            if not is_valid_milestone(alias_list[i]) then
                table.remove(alias_list, i)
            end
        end
        if next(alias_list) == nil then
            storage.production_aliases[milestone_name] = nil
        end
    end
end

function is_valid_milestone(milestone)
    local prototype = get_milestone_prototype(milestone)
    if prototype == nil then
        return false
    end
    if milestone.quality and prototypes.quality[milestone.quality] == nil then
        return false
    end
    return true
end

function sprite_prefix(milestone)
    if milestone.type == "item" or milestone.type == "item_consumption" then
        return "item"
    elseif milestone.type == "fluid" or milestone.type == "fluid_consumption" then
        return "fluid"
    elseif milestone.type == "kill" then
        return "entity"
    elseif milestone.type == "technology" then
        return "technology"
    else
        error("Unknown milestone type: " .. milestone.type)
    end
end
