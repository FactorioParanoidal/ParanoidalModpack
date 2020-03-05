local Data = require('__stdlib__/stdlib/data/data')

local function get_new_path(oldTexturePath)
    return (string.gsub(oldTexturePath, '^%_%_base%_%_', '__PickerTweaks__'))
end

if settings.startup['picker-realistic-reactor-glow'].value then
    -- "name": "RealisticReactorGlow",
    -- "title": "Realistic Reactor Glow",
    -- "author": "<NO_NAME>",
    -- "description": "The glow of working nuclear reactor has the proper color now!"
    local nuclearReactorItem = Data("nuclear-reactor", "item")
    nuclearReactorItem.icon = get_new_path(nuclearReactorItem.icon)
    nuclearReactorItem.icon_size = 32

    local nuclearReactorReactor = Data('nuclear-reactor', 'reactor')
    nuclearReactorReactor.light.color = {b = 0.94, g = 1, r = 0}
    nuclearReactorReactor.working_light_picture.filename = get_new_path(nuclearReactorReactor.working_light_picture.filename)
    nuclearReactorReactor.working_light_picture.hr_version.filename = get_new_path(nuclearReactorReactor.working_light_picture.hr_version.filename)

    local nuclearReactorTechnology = Data('nuclear-power', 'technology')
    nuclearReactorTechnology.icon = get_new_path(nuclearReactorTechnology.icon)
end
