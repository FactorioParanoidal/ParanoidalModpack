local function cleanup_entities_for_factoriomaps()
    print("Starting factoriomaps-factorissimo integration script")

    for surface_index, factory_list in pairs(storage.surface_factories) do
        local surface = game.get_surface(surface_index)
        if not surface then goto continue end

        remote.call("factoriomaps", "surface_set_hidden", surface.name, true)

        for _, factory in pairs(factory_list) do
            if factory.built then
                for _, id in pairs(factory.outside_overlay_displays) do
                    local object = rendering.get_object_by_id(id)
                    if object then object.destroy() end
                end

                remote.call("factoriomaps", "link_renderbox_area", {
                    from = {
                        {factory.outside_x - factory.layout.outside_size / 2, factory.outside_y - factory.layout.outside_size / 2},
                        {factory.outside_x + factory.layout.outside_size / 2, factory.outside_y + factory.layout.outside_size / 2},
                        surface = factory.outside_surface.name
                    },
                    to = {
                        {factory.inside_x - factory.layout.inside_size / 2 - 1, factory.inside_y - factory.layout.inside_size / 2 - 1},
                        {factory.inside_x + factory.layout.inside_size / 2 + 1, factory.inside_y + factory.layout.inside_size / 2 + 1},
                        surface = factory.inside_surface.name
                    }
                })
            end
        end
        ::continue::
    end
end

script.on_load(function()
    if not remote.interfaces.factoriomaps then return end
    local event_id = remote.call("factoriomaps", "get_start_capture_event_id")
    factorissimo.on_event(event_id, cleanup_entities_for_factoriomaps)
end)
