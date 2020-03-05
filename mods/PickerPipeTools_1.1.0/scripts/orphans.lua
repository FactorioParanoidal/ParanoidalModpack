-------------------------------------------------------------------------------
--[[Pipe Orphans]] --
-------------------------------------------------------------------------------
-- Code modified from GotLag's Orphan Finder: https://mods.factorio.com/mods/GotLag/Orphan%20Finder

local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
local Position = require('__stdlib__/stdlib/area/position')

local types = {
    ['underground-belt'] = 'underground-belt',
    ['transport-belt'] = 'underground-belt',
    ['pipe-to-ground'] = 'pipe-to-ground',
    ['pipe'] = 'pipe-to-ground'
}

local ugs = {
    ['underground-belt'] = 'underground-belt',
    ['pipe-to-ground'] = 'pipe-to-ground'
}

local function _find_mark(entity)
    return entity.surface.find_entity('picker-highlight-box', entity.position)
end

local function _destroy_mark(entity)
    local mark = _find_mark(entity)
    if mark then
        mark.destroy()
    end
end

local function find_orphans(event)
    local player, pdata = Player.get(event.player_index)
    local cursor_type = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.prototype.place_result and types[player.cursor_stack.prototype.place_result.type]
    if (player.selected and types[player.selected.type]) or cursor_type then
        local etype = player.selected and types[player.selected.type] or cursor_type
        if (event.tick > (pdata['next_check_' .. etype] or 0)) and player.mod_settings['picker-find-orphans'].value then
            local ent = player.selected or player
            local filter = {area = Position(ent.position):expand_to_area(64), type = etype, force = player.force}
            for _, entity in pairs(ent.surface.find_entities_filtered(filter)) do
                local not_con = not entity.neighbours or (entity.neighbours and not entity.neighbours.type and #entity.neighbours[1] < 2)

                if not_con and not _find_mark(entity) then
                    entity.surface.create_entity {
                        name = 'picker-highlight-box',
                        target = entity,
                        render_player_index = 1,
                        position = entity.position,
                        box_type = 'not-allowed',
                        force = player.force,
                        time_to_live = 60 * 10,
                        blink_interval = 30
                    }
                end
            end
            pdata['next_check_' .. etype] = event.tick + (defines.time.second * 10)
        end
    end
end
Event.register({defines.events.on_selected_entity_changed, defines.events.on_player_cursor_stack_changed}, find_orphans)

local function orphan_builder(event)
    if ugs[event.created_entity.type] and event.created_entity.neighbours then
        local _, pdata = Player.get(event.player_index)
        local ents = event.created_entity.neighbours

        if not ents.type then
            for _, inner in pairs(ents) do
                for _, ent in pairs(inner) do
                    _destroy_mark(ent)
                end
            end
        else
            _destroy_mark(ents)
        end
        pdata._next_check = event.tick + (defines.time.second * 2)
    end
end
Event.register(defines.events.on_built_entity, orphan_builder)
