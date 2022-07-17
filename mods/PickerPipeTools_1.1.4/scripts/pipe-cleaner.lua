-------------------------------------------------------------------------------
--[[Pipe Cleaner]] --
-------------------------------------------------------------------------------
--Loosley based on pipe manager by KeyboardHack
local Event = require('__stdlib__/stdlib/event/event')
local table = require('__stdlib__/stdlib/utils/table')

--Start at a drain and clear fluidboxes out that match. find drain connections not cleaned and repeat
local function flush(event)
    local player = game.players[event.player_index]
    local entity = player.selected
    local fluidbox = entity and entity.fluidbox

    if not (entity and fluidbox) then
        return
    end

    if not (player.admin or not settings.global['picker-tool-admin-only'].value) then
        return player.print({'picker.must-be-admin'})
    end

    if fluidbox then
        for i = 1, #fluidbox do
            fluidbox.flush(i)
        end
        fluidbox.owner.last_user = player
    end
end
Event.register('picker-pipe-cleaner', flush)

--API request flush_filters
local function remove_graffiti(event)
    local player = game.players[event.player_index]
    local entity = player.selected
    local fluidbox = entity and entity.fluidbox

    if not (entity and fluidbox) then
        return
    end

    if not (player.admin or not settings.global['picker-tool-admin-only'].value) then
        return player.print({'picker.must-be-admin'})
    end

    local frame = player.gui.center.picker_pipe_filter
    local _ = frame and frame.destroy()

    local entities = {}
    local rootered = {}

    local function rooter_it(v)
        if not rootered[v.owner.unit_number] then
            entities[v.owner.unit_number] = v
        end
    end

    entities[entity.unit_number] = fluidbox

    repeat
        local index, drain = next(entities)
        if index then
            ---@cast drain -?
            rootered[index] = drain
            for i = 1, #drain do
                drain.set_filter(i, nil)
                table.each(drain.get_connections(i), rooter_it)
            end

            entities[index] = nil
            drain.owner.last_user = player
        end
    until not index
    player.print({'pipe-cleaner.remove-all-filters'})
end
Event.register('picker-filter-cleaner', remove_graffiti)
