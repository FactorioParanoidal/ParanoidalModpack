--[[
    "name": "CursorUpgradeCarousel",
    "title": "Cursor Upgrade Carousel",
    "author": "raiguard",
    "description": "Shift+scroll to quickly access an item's upgrades or downgrades. If you do not have the item, the ghost cursor will be used instead (100% not cheaty!). Should be compatible with all mods out of the box, assuming they correctly defined their entities' upgrades. Users can also define their own custom upgrade paths in the mod settings."
--]]
if not mods['CursorUpgradeCarousel'] then
    data:extend {
        {
            type = 'bool-setting',
            name = 'picker-use-carousel',
            setting_type = 'runtime-per-user',
            default_value = true,
            order = 'picker-carousel-a'
        },
        {
            type = 'bool-setting',
            name = 'picker-carousel-always-give-in-map-editor',
            setting_type = 'runtime-per-user',
            default_value = true,
            order = 'picker-carousel-b'
        },
        {
            type = 'string-setting',
            name = 'picker-carousel-registry',
            setting_type = 'runtime-global',
            default_value = "{['medium-electric-pole'] = 'big-electric-pole', ['big-electric-pole'] = 'substation'}",
            order = 'picker-carousel-c'
        }
    }
end
