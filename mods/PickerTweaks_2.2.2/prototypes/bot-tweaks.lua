--Make construction and logistic robots unminable (no plucking them from the air)
--Based on Small-Fixes by Choumiko

local Data = require('__stdlib__/stdlib/data/data')

local types = {'construction-robot', 'logistic-robot'}

local scale = settings.startup['picker-adjustable-bot-scale'].value

local bot_animations = {
    'idle',
    'idle_with_cargo',
    'in_motion',
    'in_motion_with_cargo',
    'shadow_idle',
    'shadow_in_motion',
    'shadow_in_motion_with_cargo',
    'working'
}
local function resize_bot(entity)
    for _, animation in pairs(bot_animations) do
        local nr = entity[animation]
        if nr then
            nr.scale = (nr.scale or 1) * scale
            local hr = nr.hr_version
            if hr then
                hr.scale = (hr.scale or 1) * scale
            end
        end
    end
end

--Make them un-minable and fire proof and show on map
--? Can the alt info be scaled?
for index, bot in pairs(types) do
    for _, entity in Data:pairs(data.raw[bot]) do
        local flags = entity:Flags()
        if bot == 'construction-robot' then
            if settings.startup['picker-unminable-construction-robots'].value then
                entity.minable = nil
            end
            if settings.startup['picker-fireproof-construction-robots'].value then
                entity.resistances = entity.resistances or {}
                local changed = false
                for _, resistance in pairs(entity.resistances) do
                    if resistance.type == 'fire' then
                        resistance.percent = 100
                        changed = true
                        break
                    end
                end
                if not changed then
                    table.insert(entity.resistances, {type = 'fire', percent = 100})
                end
            end
            if settings.startup['picker-noalt-construction-robots'].value then
                flags:add('hide-alt-info')
            end
        end
        if bot == 'logistic-robot' then
            if settings.startup['picker-unminable-logistic-robots'].value then
                entity.minable = nil
            end
            if settings.startup['picker-noalt-logistic-robots'].value then
                flags:add('hide-alt-info')
            end
        end
        if settings.startup['picker-adjustable-bot-scale'].value ~= 1 then
            --[[
                "name": "SmallRobots",
                "title": "Small Robots - Just make the two robots a little smaller.",
	            "author": "DellAquila, Kryzeth",
                "description": "Logistic Robot and Construction Robot are 50% smaller. Better with mod
                    More accurate player size compared to vehicles. Work with all modded robots.
                    You can set the size you want for your robots Smaller or Bigger."
            --]]
            resize_bot(entity)
        end
        if settings.startup['picker-show-bots-on-map'].value then
            --[[
                "name": "ShowBotsOnMap",
                "description": "Now you can see your robots on the map",
                "title": "Show Bots On Map",
                "author": "darkfrei",
            --]]
            flags:remove('not-on-map')
            entity.map_color = {r = index - 1, g = index - 1, b = index - 1}
        end
    end
end
