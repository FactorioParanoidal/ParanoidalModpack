local events = require("scripts.events")
local milestone_events = require("milestones.remote_interface")
local COMPLETIONS_PER_PASS = 256
local core_util = require("__core__/lualib/util.lua")
local flib_format = require("__flib__.format")
require("milestones.gui")
require("milestones.milestones_util")

local function print_to_players(players, message)
    for _, player in pairs(players) do
        if not settings.get_player_settings(player)["milestones_disable_chat_notifications"].value then
            player.print(message)
        end
    end
end

local function force_print(force, message)
    print_to_players(force.players, message)
    -- Paranoidal: players inside this force's Blueprint Sandboxes force are notified too.
    local sandbox_force = get_sandbox_force(force)
    if sandbox_force then
        print_to_players(sandbox_force.players, message)
    end
end

local function raise_milestone_reached_event(force, milestone, message)
    milestone_events.raise(force, milestone, message)
end

-- Writes to a file named "milestones-<MAP SEED>.txt"
-- Each milestone reached appends a new line.
-- Each line is JSON and looks like this:
-- {"force":"player","name":"iron-ore","quantity":10,"type"="item","completion_tick":5279,"completion_time":"1:27"}
local function write_milestone_to_file(force, milestone, human_timestamp)
    local file_name = string.format("milestones-%s.txt", game.default_map_gen_settings.seed)
    local table = {
        force = force.name,
        name = milestone.name,
        quantity = milestone.quantity,
        type = milestone.type,
        quality = milestone.quality,
        completion_tick = milestone.completion_tick,
        completion_time = human_timestamp,
    }
    local json = helpers.table_to_json(table) .. "\n"
    for _, player in pairs(force.players) do
        if settings.get_player_settings(player)["milestones_write_file"].value then
            helpers.write_file(file_name, json, true, player.index)
        end
    end
end


local function print_milestone_reached(force, milestone)
    local human_timestamp = flib_format.time(milestone.completion_tick)
    local sprite_name = sprite_prefix(milestone) .. "." .. milestone.name
    local milestone_localised_name
    local message
    if milestone.type == "technology" then
        local technology = prototypes.technology[milestone.name]
        milestone_localised_name = technology.localised_name
        local level_string = (milestone.quantity == 1 and "" or " Level "..milestone.quantity)
        local image_tag = string.format("[img=%s]", sprite_name)
        milestone_localised_name = {"", image_tag, milestone_localised_name}
        -- Paranoidal: hidden technologies researched by script mark events of other mods (e.g. Factorissimo).
        local key = technology.hidden and "milestones.message_milestone_reached_event" or "milestones.message_milestone_reached_technology"
        message = {key, milestone_localised_name, level_string, human_timestamp}
    else
        if milestone.type == "item" or milestone.type == "item_consumption" then
            if milestone.name == "se-rocket-launch-pad-silo-dummy-result-item" then
                milestone_localised_name = "Cargo rocket"
            else
                milestone_localised_name = prototypes.item[milestone.name].localised_name
            end
        elseif milestone.type == "fluid" or milestone.type == "fluid_consumption" then
            milestone_localised_name = prototypes.fluid[milestone.name].localised_name
        elseif milestone.type == "kill" then
            milestone_localised_name = prototypes.entity[milestone.name].localised_name
        else
            error("Недопустимый тип этапа: " .. milestone.type)
        end

        local message_type
        if milestone.type == "kill" then
            message_type = "kill"
        elseif milestone.type == "item_consumption" or milestone.type == "fluid_consumption" then
            message_type = "consumption"
        else
            message_type = "item"
        end

        if milestone.quality then
            local image_tags = string.format("[img=quality.%s][img=%s]", milestone.quality, sprite_name)
            milestone_localised_name = {"", image_tags, prototypes.quality[milestone.quality].localised_name, " ", milestone_localised_name}
        else
            local image_tag = string.format("[img=%s]", sprite_name)
            milestone_localised_name = {"", image_tag, milestone_localised_name}
        end

        local postscript
        if milestone.name == "character" then
            postscript = " (haha! 😁)"
        end

        if milestone.quantity == 1 then
            message = {"", {"milestones.message_milestone_reached_" ..message_type.. "_first", milestone_localised_name, human_timestamp}, postscript}
        else
            local print_quantity = milestone.quantity
            if milestone.quantity >= 10000 then
                print_quantity = core_util.format_number(milestone.quantity, true)
            end
            message = {"", {"milestones.message_milestone_reached_" ..message_type.. "_more", print_quantity, milestone_localised_name, human_timestamp}, postscript}
        end
    end

    force_print(force, message)
    raise_milestone_reached_event(force, milestone, message)
    write_milestone_to_file(force, milestone, human_timestamp)
    force.play_sound{path="utility/achievement_unlocked"}
    local sandbox_force = get_sandbox_force(force)
    if sandbox_force then
        sandbox_force.play_sound{path="utility/achievement_unlocked"}
    end
end

-- Paranoidal: periodic tracking without per-milestone polling.
--
-- Upstream checked 1/frequency of the incomplete milestones every tick; each item/kill check made
-- one API call per surface per quality prototype (47 qualities with ic-more-qualities), every cycle,
-- for every force including Blueprint Sandboxes forces. Now each cycle of `frequency` ticks:
--   * the cycle start snapshots which names are needed (incomplete milestones + aliases) per force;
--   * the reads are spread over the last READ_WINDOW ticks of the cycle: one task = one
--     LuaFlowStatistics (one surface) of one force/key, read once (counts dictionary, already summed
--     over qualities) or by name;
--   * the last tick of the cycle evaluates every incomplete milestone from these totals.
-- Milestones with an explicit quality are read directly at evaluation. Technology milestones still
-- use on_research_finished only. Reading at the end of the cycle keeps detection within one cycle
-- plus at most READ_WINDOW ticks, close to upstream. The state lives in storage.tracker, so
-- saving/loading mid-cycle is deterministic.
--
-- paranoidal-achievements: this cycle is the only reader of the production statistics in the mod.
-- Other consumers (scripted achievements) add the names they need at the cycle start and get the
-- totals of their force at the cycle end, after the milestones:
--   add_statistics_consumer{needs = fn(force_name, tick) -> {[key] = {[name] = true}} or nil,
--                           receive = fn(force_name, totals)}
-- Keys: item_in, item_out, fluid_in, fluid_out, kill_in (all qualities summed). Consumers are added
-- while control.lua loads, always in the same order: storage.tracker keeps their indices.

local READ_WINDOW = 60

local statistics_consumers = {}

function add_statistics_consumer(consumer)
    statistics_consumers[#statistics_consumers + 1] = consumer
end

local function add_consumer_needs(needed, force_name, tick, requested)
    for index, consumer in ipairs(statistics_consumers) do
        local extra = consumer.needs(force_name, tick)
        if extra then
            for key, names in pairs(extra) do
                if next(names) then
                    needed = needed or {}
                    local own = needed[key]
                    if not own then
                        own = {}
                        needed[key] = own
                    end
                    for name in pairs(names) do own[name] = true end
                end
            end
            requested[#requested + 1] = index
        end
    end
    return needed
end

local function start_tracker_cycle(tick, frequency)
    local tasks = {}
    local needed_by_force = {}
    local totals_by_force = {}
    local consumers_by_force = {}
    for force_name, storage_force in pairs(storage.forces) do
        totals_by_force[force_name] = {}
        local requested = {}
        local needed = add_consumer_needs(collect_needed_names(storage_force), force_name, tick, requested)
        if #requested > 0 then consumers_by_force[force_name] = requested end
        if needed then
            needed_by_force[force_name] = needed
            for key, _ in pairs(needed) do
                totals_by_force[force_name][key] = {}
            end
            add_flow_statistics_tasks(tasks, force_name, storage_force, needed)
        end
    end
    storage.tracker = {
        frequency = frequency,
        start_tick = tick,
        tasks = tasks,
        next_task = 1,
        needed = needed_by_force,
        totals = totals_by_force,
        consumers = consumers_by_force,
    }
    return storage.tracker
end

local function run_tracker_tasks(tracker, last_task)
    local tasks = tracker.tasks
    for task_index = tracker.next_task, math.min(last_task, #tasks) do
        local task = tasks[task_index]
        local needed = tracker.needed[task.force_name]
        local totals = tracker.totals[task.force_name]
        if needed and totals then
            accumulate_flow_totals(totals[task.key], task.flow_statistics, task.key, needed[task.key])
        end
    end
    tracker.next_task = math.max(tracker.next_task, last_task + 1)
end

local function evaluate_tracker_cycle(tracker)
    for force_name, totals in pairs(tracker.totals) do
        local storage_force = storage.forces[force_name]
        local force = game.forces[force_name]
        if storage_force and force then
            local backfill_only = storage_force.backfill_pending
            local reached_anything = backfill_only and backfill_completion_times(force) or false
            local incomplete_milestones = storage_force.incomplete_milestones
            local i, completed = 1, 0
            while not backfill_only and i <= #incomplete_milestones and completed < COMPLETIONS_PER_PASS do
                local milestone = incomplete_milestones[i]
                if milestone.type ~= "technology"
                and is_production_milestone_reached(milestone, storage_force, totals) then
                    if milestone.next then
                        local next_milestone = create_next_milestone(force_name, milestone, true)
                        if next_milestone then
                            -- Same name and type: it is evaluated from the same totals later in this loop.
                            table.insert(incomplete_milestones, next_milestone)
                            table.insert(storage_force.milestones_by_group[next_milestone.group], next_milestone)
                        end
                    end
                    mark_milestone_reached(storage_force, milestone, game.tick, i)
                    print_milestone_reached(force, milestone)
                    reached_anything = true
                    completed = completed + 1
                else
                    -- When a milestone is reached, incomplete_milestones loses an element
                    -- so we only increment when a milestone is not reached
                    i = i + 1
                end
            end
            if reached_anything then
                refresh_gui_for_force(force) -- Once per force and cycle instead of once per milestone
            end
        end
    end
    for force_name, requested in pairs(tracker.consumers or {}) do
        local totals = tracker.totals[force_name]
        if totals and game.forces[force_name] then
            for _, index in ipairs(requested) do
                local consumer = statistics_consumers[index]
                if consumer then consumer.receive(force_name, totals) end
            end
        end
    end
end

function track_item_creation(event)
    local frequency = storage.milestones_check_frequency_setting
    local tracker = storage.tracker
    if tracker == nil or tracker.frequency ~= frequency then
        if event.tick % frequency ~= 0 then return end -- Start cycles on the same boundaries as upstream
        tracker = start_tracker_cycle(event.tick, frequency)
    end

    local step = event.tick - tracker.start_tick
    local window = math.min(frequency, READ_WINDOW)
    local window_step = step - (frequency - window)
    if window_step >= 0 then
        run_tracker_tasks(tracker, math.floor(#tracker.tasks * (window_step + 1) / window))
    end

    if step >= frequency - 1 then
        run_tracker_tasks(tracker, #tracker.tasks) -- Nothing left normally; guards against skipped steps
        storage.tracker = nil
        evaluate_tracker_cycle(tracker)
    end
end
-- Called every tick by control.lua (one on_tick handler for the whole mod).

function check_technology_milestone_reached(event)
    local technology_researched = event.research
    local force = event.research.force
    local storage_force = storage.forces[force.name]
    if storage_force == nil then return end

    local i, completed = 1, 0
    while i <= #storage_force.incomplete_milestones do
        if completed >= COMPLETIONS_PER_PASS then
            storage_force.backfill_pending = true
            break
        end
        local milestone = storage_force.incomplete_milestones[i]
        if is_tech_milestone_reached(milestone, technology_researched) then
            if milestone.next then
                local next_milestone = create_next_milestone(force.name, milestone, true)
                if next_milestone then
                    table.insert(storage_force.incomplete_milestones, next_milestone)
                    table.insert(storage_force.milestones_by_group[next_milestone.group], next_milestone)
                end
            end
            mark_milestone_reached(storage_force, milestone, game.tick, i)
            print_milestone_reached(force, milestone)
            completed = completed + 1
        else
            i = i + 1
        end
    end
    if completed > 0 then refresh_gui_for_force(force) end
end
events.on(defines.events.on_research_finished, check_technology_milestone_reached)

