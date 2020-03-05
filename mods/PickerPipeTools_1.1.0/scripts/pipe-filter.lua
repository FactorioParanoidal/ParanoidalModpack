local Event = require('__stdlib__/stdlib/event/event')
local Gui = require('__stdlib__/stdlib/event/gui')

local FRAME = 'picker_pipe_filter'
local pipe_types = {
    ['pipe'] = true,
    ['pipe-to-ground'] = true,
    ['storage-tank'] = true
}

local function get_pipe(stream)
    local _, x, y, surface_index = stream:match('^(%d+)_([%-%.0-9]+)_([%-%.0-9]+)_(%d+)')
    local pos = {x = x, y = y}
    for i, ent in pairs(game.surfaces[tonumber(surface_index)].find_entities_filtered {position = pos}) do
        if pipe_types[ent.type] then
            return ent
        end
    end
end

local function pipe_filter(event)
    local player = game.players[event.player_index]
    local frame = player.gui.center[FRAME]

    if frame then
        return frame.destroy()
    end

    local pipe = player.selected
    if pipe and pipe_types[pipe.type] then
        frame =
            player.gui.center.add {
            type = 'frame',
            name = FRAME,
            caption = {'', pipe.localised_name, ' ', pipe.unit_number}
        }
        local t =
            frame.add {
            type = 'table',
            name = 'boxes',
            column_count = #pipe.fluidbox
        }
        local caption = pipe.unit_number .. '_' .. pipe.position.x .. '_' .. pipe.position.y .. '_' .. pipe.surface.index
        for i = 1, #pipe.fluidbox do
            local filter = pipe.fluidbox.get_filter(i)
            filter = filter and filter.name or nil
            local box_table =
                t.add {
                type = 'table',
                name = 'picker_pipe_box_index' .. i,
                column_count = 1,
                caption = i
            }
            box_table.add {
                type = 'choose-elem-button',
                elem_type = 'fluid',
                fluid = filter,
                name = 'picker_pipe_element_filter',
                caption = caption
            }
        end
        player.opened = frame
    end
end
Event.register('picker-pipe-filter', pipe_filter)

local function close_gui(event)
    local player = game.players[event.player_index]
    local gui = player.gui.center[FRAME]
    if gui then
        return gui.destroy()
    end
end
Event.register(defines.events.on_gui_closed, close_gui)

local function change_filter(event)
    local pipe = get_pipe(event.element.caption)
    if pipe then
        local filter
        if event.element.elem_value then
            filter = {
                name = event.element.elem_value,
                force = true
            }
        end
        pipe.fluidbox.set_filter(tonumber(event.element.parent.caption), filter)
    end
end

Gui.on_elem_changed('picker_pipe_element_filter', change_filter)
