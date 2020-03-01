local Event = require('__stdlib__/stdlib/event/event')
--local Position = require('__stdlib__/stdlib/area/position')
local tables = {}

tables.tick_options = {
    skip_valid = true,
    protected_mode = false
}

tables.protected = {
    protected_mode = Event.options.protected_mode,
    skip_valid = true
}
tables.empty = {}


tables.bitwise_marker_entry = {
    [0x00] = 1,
    [0x01] = 2,
    [0x04] = 3,
    [0x05] = 4,
    [0x10] = 5,
    [0x11] = 6,
    [0x14] = 7,
    [0x15] = 8,
    [0x40] = 9,
    [0x41] = 10,
    [0x44] = 11,
    [0x45] = 12,
    [0x50] = 13,
    [0x51] = 14,
    [0x54] = 15,
    [0x55] = 16
}

tables.allowed_types = {
    ['pipe'] = true,
    ['pipe-to-ground'] = true,
    ['pump'] = true
}

return tables
