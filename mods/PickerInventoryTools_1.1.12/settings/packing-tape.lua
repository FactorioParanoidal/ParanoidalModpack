--[[
    "name": "packing-tape",
    "title": "Packing Tape",
    "author": "calcwizard",
    "description": "Mining a chest or wagon allows players to pick it up with all the items inside and carry
                    it in their inventory. Now supports cars!"
--]] --
data:extend{
    {
        name = 'picker-moveable-chests',
        setting_type = 'startup',
        type = 'bool-setting',
        default_value = false,
        order = 'picker-moveable-chests'
    }
}
