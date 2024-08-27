function register_events()
    if settings.global["hardcore-mode-for-playing-disable-hand-resource-mining"].value then
        script.on_event(
            {
                defines.events.on_player_mined_entity,
                defines.events.on_robot_mined_entity
            },
            on_player_mined_entity
        )
        log("on_player_mined_entity " .. tostring(on_player_mined_entity))
        script.on_event({ defines.events.on_player_mined_item }, on_player_mined_item)
        log("on_player_mined_item " .. tostring(on_player_mined_item))
    else
        script.on_event(
            {
                defines.events.on_player_mined_entity,
                defines.events.on_robot_mined_entity
            },
            nil
        )
        script.on_event({ defines.events.on_player_mined_item }, nil)
    end
    if
        settings.global["hardcore-mode-for-playing-disable-hand-crafting"].value or
        settings.global["hardcore-mode-for-playing-enable-technology-research-reevaluting"].value or
        settings.global["hardcore-mode-for-playing-disable-production-entities-beyond-factorissimo-building"].value
    then
        script.on_event(
            {
                defines.events.on_built_entity,
                defines.events.script_raised_built
            },
            on_built_disabling_event
        )
    else
        script.on_event(
            {
                defines.events.on_built_entity,
                defines.events.script_raised_built
            },
            nil
        )
    end
    if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
        script.on_event(defines.events.on_sector_scanned, on_sector_scanned)
    end
    script.on_event(defines.events.on_research_finished, technology_research_finished)
    script.on_event(defines.events.on_tick, on_tick_event)
    script.on_event(defines.events.on_train_changed_state, on_train_changed_state)
    script.on_event(defines.events.on_train_created, on_train_created)
end

script.on_load(
    function()
        register_events()
    end
)
script.on_init(
    function()
        register_events()
    end
)
script.on_configuration_changed(
    function()
        register_events()
    end
)
script.on_event(
    defines.events.on_runtime_mod_setting_changed,
    function()
        register_events()
    end
)
script.on_configuration_changed(function(configuration_changed_data)
    register_events()
    global.configuration_changed = configuration_changed_data.new_version ~= configuration_changed_data.old_version or
        configuration_changed_data.migration_applied or configuration_changed_data.mod_startup_settings_changed
        or _table.size(configuration_changed_data.mod_changes) > 0
end)
