-------------------------------------------------------------------------------
--[[Extra Settings Info]] --
-------------------------------------------------------------------------------
--[[
    "name": "Noxys_Extra_Settings_Info",
    "version": "0.0.3",
    "title": "Noxys Extra Settings Info",
    "author": "Noxy",
--]]
if data.raw['bool-setting'] then
    for _, v in pairs(data.raw['bool-setting']) do
        if v.default_value ~= nil then
            v.localised_description = {'picker-extra-settings-info.merge', {'mod-setting-description.' .. v.name}, '\n\n' .. 'Default: ' .. tostring(v.default_value)}
        end
    end
end
for _, s in pairs {'int-setting', 'double-setting'} do
    if data.raw[s] then
        for _, v in pairs(data.raw[s]) do
            local t = {}
            if v.minimum_value ~= nil then
                table.insert(t, 'Minimum: ' .. v.minimum_value)
            end
            if v.default_value ~= nil then
                table.insert(t, 'Default: ' .. v.default_value)
            end
            if v.maximum_value ~= nil then
                table.insert(t, 'Maximum: ' .. v.maximum_value)
            end
            if #t then
                v.localised_description = {'picker-extra-settings-info.merge', {'mod-setting-description.' .. v.name}, '\n\n' .. table.concat(t, ', ')}
            end
        end
    end
end
if data.raw['string-setting'] then
    for _, v in pairs(data.raw['string-setting']) do
        local t = {}
        if v.default_value ~= nil then
            table.insert(t, 'Default: "' .. v.default_value .. '"')
        end
        if v.allow_blank == true then
            table.insert(t, 'Allows blank')
        elseif v.allow_blank == false then
            table.insert(t, 'Disallows blank')
        end
        if #t then
            v.localised_description = {'picker-extra-settings-info.merge', {'mod-setting-description.' .. v.name}, '\n\n' .. table.concat(t, ', ')}
        end
    end
end
