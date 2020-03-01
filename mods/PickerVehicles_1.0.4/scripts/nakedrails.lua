local Event = require('__stdlib__/stdlib/event/event')

local function on_selected_area(event)
    local alt = event.name == defines.events.on_player_alt_selected_area
    local replace_straight, replace_curved

    if event.item == 'picker-naked-rails-nakedify' then
        replace_straight = not alt and 'picker-naked-straight-rail' or 'straight-rail'
        replace_curved = not alt and 'picker-naked-curved-rail' or 'curved-rail'
    elseif event.item == 'picker-naked-rails-stoneify' then
        replace_straight = 'straight-rail'
        replace_curved = 'curved-rail'
    elseif event.item == 'picker-naked-rails-sleepify' then
        replace_straight = not alt and 'picker-sleepy-straight-rail' or 'straight-rail'
        replace_curved = not alt and 'picker-sleepy-curved-rail' or 'curved-rail'
    elseif event.item == 'picker-naked-rails-remnantify' then
        replace_straight = 'straight-rail-remnants'
        replace_curved = 'curved-rail-remnants'
    else
        return
    end

    if alt and event.item == 'picker-naked-rails-remnantify' then
        for k, entity in pairs(event.entities) do
            if entity.type == 'rail-remnants' then
                entity.destroy()
            end
        end

        return
    end

    local surface = event.entities and event.entities[1] and event.entities[1].surface

    for k, entity in pairs(event.entities) do
        if entity.type == 'straight-rail' and entity.name ~= replace_straight or entity.type == 'curved-rail' and entity.name ~= replace_curved or entity.name == 'straight-rail-remnants' or entity.name == 'curved-rail-remnants' then
            if entity.valid then
                local n = entity.name
                local d = entity.direction
                local f = entity.force
                local p = entity.position
                local straight = entity.type == 'straight-rail' or entity.name:find('straight-rail')

                if event.item == 'picker-naked-rails-remnantify' then
                    replace_straight = n .. '-remnants'
                    replace_curved = n .. '-remnants'
                end

                entity.destroy()
                surface.create_entity {
                    name = straight and replace_straight or replace_curved,
                    position = p,
                    force = f,
                    direction = d
                }
            end
        end
    end
end

if settings.startup['picker-naked-rails'].value then
    Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, on_selected_area)
end
