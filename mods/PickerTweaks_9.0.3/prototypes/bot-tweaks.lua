--Make construction and logistic robots unminable (no plucking them from the air)
--Based on Small-Fixes by Choumiko

local Data = require('__stdlib__/stdlib/data/data')

local types = {'construction-robot', 'logistic-robot'}

--Make them un-minable and fire proof and show on map
for index, bot in pairs(types) do
    for _, entity in Data:pairs(data.raw[bot]) do
        local flags = entity:Flags()
        if bot == 'construction-robot' then
            if settings.startup['picker-unminable-construction-robots'].value then
                entity.minable = nil
            end
            if settings.startup['picker-fireproof-construction-robots'].value then
                entity.resistances = entity.resistances or {}
                table.insert(entity.resistances, {type = 'fire', percent = 100})
            end
            if settings.startup['picker-noalt-construction-robots'].value then
                flags:add('hide-alt-info')
            end
        end
        if bot == 'logistic-robot'then
            if settings.startup['picker-unminable-logistic-robots'].value then
                entity.minable = nil
            end
            if settings.startup['picker-noalt-logistic-robots'].value then
                flags:add('hide-alt-info')
            end
        end
        if settings.startup['picker-show-bots-on-map'].value then
            -- "name": "ShowBotsOnMap",
            -- "description": "Now you can see your robots on the map",
            -- "title": "Show Bots On Map",
            -- "author": "darkfrei",
            --entity = Data(entity)
            flags:remove('not-on-map')
            entity.map_color = {r = index - 1, g = index - 1, b = index - 1}
        end
    end
end
