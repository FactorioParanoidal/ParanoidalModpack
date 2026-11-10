local schema = require("milestones.schema")

local function reply(command, message)
    local player = command.player_index and game.get_player(command.player_index)
    if player then player.print(message) else log(message) end
end

local function permitted(command)
    local player = command.player_index and game.get_player(command.player_index)
    if player and not player.admin then
        reply(command, {"milestones.message_settings_permission_denied"})
        return false
    end
    return true
end

local function player_force(command)
    if not permitted(command) then return nil end
    local player = command.player_index and game.get_player(command.player_index)
    if not player then
        reply(command, {"milestones.message_command_requires_player"})
        return nil
    end
    return get_display_storage_force(player.force)
end

commands.add_command("milestones-debug-print-forces",
    "- Print the internal force state (admin only).", function(command)
        if not permitted(command) then return end
        local text = serpent.block(storage.forces)
        reply(command, text)
        if command.player_index then log(text) end
    end)

commands.add_command("milestones-debug-print-loaded-milestones",
    "- Print the loaded milestones (admin only).", function(command)
        if not permitted(command) then return end
        local text = serpent.block(storage.loaded_milestones)
        reply(command, text)
        if command.player_index then log(text) end
    end)

commands.add_command("milestones-set-milestone-time",
    "- Set an incomplete milestone time: name,lower_tick,upper_tick (admin only).", function(command)
        if not command.parameter then return end
        local own, force = player_force(command)
        if not own then return end
        local name, lower, upper = command.parameter:match("^%s*([^,]+),%s*([^,]+),%s*([^,]+)%s*$")
        lower, upper = tonumber(lower), tonumber(upper)
        if not name or not schema.finite(lower) or not schema.finite(upper)
            or lower < 0 or lower > upper or upper > game.tick or lower % 1 ~= 0 or upper % 1 ~= 0 then
            reply(command, {"milestones.message_invalid_time"})
            return
        end
        name = name:match("^%s*(.-)%s*$")
        for i, milestone in ipairs(own.incomplete_milestones) do
            if milestone.name == name then
                mark_milestone_reached(own, milestone, upper, i, lower)
                sort_milestones(own.complete_milestones)
                reset_milestones_tracker()
                refresh_gui_for_force(force)
                reply(command, "Milestone set.")
                return
            end
        end
        reply(command, "Milestone not found.")
    end)

commands.add_command("milestones-reset-milestone",
    "- Reset one completed milestone: name (admin only).", function(command)
        if not command.parameter then return end
        local own, force = player_force(command)
        if not own then return end
        for i, milestone in ipairs(own.complete_milestones) do
            if milestone.name == command.parameter then
                mark_milestone_unreached(own, milestone, i)
                refresh_gui_for_force(force)
                reply(command, "Milestone reset.")
                return
            end
        end
        reply(command, "Milestone not found.")
    end)

commands.add_command("milestones-reinitialize-gui",
    "- Rebuild your milestone window.", function(command)
        if command.player_index then reinitialize_player(command.player_index) end
    end)

commands.add_command("milestones-reinitialize-surfaces",
    "- Rebuild statistics references and backfill incomplete milestones (admin only).", function(command)
        if not permitted(command) then return end
        remove_ignored_surface_statistics()
        reset_milestones_tracker()
        for name in pairs(storage.forces) do
            local force = game.forces[name]
            if force then
                backfill_completion_times(force)
                refresh_gui_for_force(force)
            end
        end
        reply(command, {"milestones.message_settings_backfilled"})
    end)

commands.add_command("milestones-reinitialize-storage",
    "- Initialise missing state and rebuild windows without deleting progress (admin only).", function(command)
        if not permitted(command) then return end
        for _, force in pairs(game.forces) do initialize_force_if_needed(force) end
        for _, player in pairs(game.players) do reinitialize_player(player.index) end
    end)
