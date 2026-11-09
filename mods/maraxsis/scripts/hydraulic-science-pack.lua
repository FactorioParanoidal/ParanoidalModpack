maraxsis.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
    if not maraxsis_constants.DEGRADATION_ENABLED then
        return
    end

    if not event.launched_by_rocket then return end
    local pod = event.cargo_pod
    local inventory = pod.get_inventory(defines.inventory.cargo_unit)

    for i = 1, #inventory do
        local stack = inventory[i]
        if stack.valid_for_read and stack.name == "hydraulic-science-pack" then
            local quality = stack.quality
            if quality.level <= 0 then
                assert(stack.set_stack{
                    name = "maraxsis-fish-oil",
                    count = stack.count
                })
            else
                local new_quality = quality.previous
                if new_quality then
                    assert(stack.set_stack{
                        name = "hydraulic-science-pack",
                        count = stack.count,
                        quality = new_quality,
                        spoil_percent = stack.spoil_percent
                    })
                end
            end
        end
    end
end)
