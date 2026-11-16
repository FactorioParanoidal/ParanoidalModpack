local get_factory_by_building = remote_api.get_factory_by_building

function factorissimo.toggle_port_markers(factory)
    if not factory.built then return end
    if #(factory.outside_port_markers) == 0 then
        for id, cpos in pairs(factory.layout.connections) do
            local sprite_data = {
                sprite = "utility/indication_arrow",
                orientation = cpos.direction_out / 16,
                target = {
                    entity = factory.building,
                    offset = {cpos.outside_x - 0.5 * cpos.indicator_dx, cpos.outside_y - 0.5 * cpos.indicator_dy}
                },
                surface = factory.building.surface,
                only_in_alt_mode = true,
                render_layer = "entity-info-icon",
            }
            table.insert(factory.outside_port_markers, rendering.draw_sprite(sprite_data).id)
        end
    else
        for _, sprite in pairs(factory.outside_port_markers) do
            local object = rendering.get_object_by_id(sprite)
            if object then object.destroy() end
        end
        factory.outside_port_markers = {}
    end
end

factorissimo.on_event("factory-rotate", function(event)
    local player = game.get_player(event.player_index)
    local entity = player.selected
    if not entity or not has_layout(entity.name) then return end
    local factory = get_factory_by_building(entity)
    if not factory then return end
    factorissimo.toggle_port_markers(factory)
end)
