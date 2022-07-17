--[[
    "name": "CursorUpgradeCarousel",
    "title": "Cursor Upgrade Carousel",
    "author": "raiguard",
    "description": "Shift+scroll to quickly access an item's upgrades or downgrades. If you do not have the item, the ghost cursor will be used instead (100% not cheaty!). Should be compatible with all mods out of the box, assuming they correctly defined their entities' upgrades. Users can also define their own custom upgrade paths in the mod settings."
--]]
if not (mods['CursorUpgradeCarousel'] or mods['CursorEnhancements']) then
    data:extend {
        {
            type = 'custom-input',
            name = 'picker-carousel-forwards',
            key_sequence = 'CONTROL + mouse-wheel-up',
            --linked_game_control = 'cycle-blueprint-forwards'
        },
        {
            type = 'custom-input',
            name = 'picker-carousel-backwards',
            key_sequence = 'CONTROL + mouse-wheel-down',
            --linked_game_control = 'cycle-blueprint-backwards'
        }
    }
end
