-------------------------------------------------------------------------------
--[[Smokeless]] --
-------------------------------------------------------------------------------
-- "name": "Smokeless",
-- "author": "can00336",
-- "description": "Removes UPS-hogging smoke from the game."
if settings.startup['picker-disable-smoke'].value then
    local count = 0
    local type_ignores = {
        ['construction-robot'] = true,
        ['explosion'] = true,
        ['particle-source'] = true,
        ['flame-thrower-explosion'] = true
    }

    for _, raw_type in pairs(data.raw) do
        for _, entity in pairs(raw_type) do
            if entity.smoke then
                if not type_ignores[entity.type] then
                    entity.smoke = nil
                    count = count + 1
                end
            end
            if entity.burner then
                if entity.burner.smoke then
                    entity.burner.smoke = nil
                    count = count + 1
                end
            end
            if entity.energy_source then
                if entity.energy_source.smoke then
                    entity.energy_source.smoke = nil
                    count = count + 1
                end
            end
            if entity.type == 'locomotive' and entity.stop_trigger then
                if entity.stop_trigger[3] then
                    count = count + 1
                    entity.stop_trigger = entity.stop_trigger[3]
                end
            end
        end
    end
    if __DebugAdapter then
        __DebugAdapter.print(count .. ' Smoking entities changed.')
    end
end
