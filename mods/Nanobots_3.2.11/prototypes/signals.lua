local group = {
    type = 'item-subgroup',
    name = 'nanobot-signals',
    group = 'signals',
    order = 'zzzzzz'
}

local signal1 = {
    type = 'virtual-signal',
    name = 'nano-signal-chop-trees',
    icon = '__Nanobots__/graphics/icons/signals/chop-trees.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-a'
}
local signal2 = {
    type = 'virtual-signal',
    name = 'nano-signal-item-on-ground',
    icon = '__Nanobots__/graphics/icons/signals/item-on-ground.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-b'
}
--luacheck: ignore signal3
local signal3 = {
    type = 'virtual-signal',
    name = 'nano-signal-remove-tiles',
    icon = '__Nanobots__/graphics/icons/signals/remove-tiles.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-c'
}
--luacheck: ignore signal4
local signal4 = {
    type = 'virtual-signal',
    name = 'nano-signal-landfill-the-world',
    icon = '__Nanobots__/graphics/icons/signals/item-on-ground.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-d'
}
local signal5 = {
    type = 'virtual-signal',
    name = 'nano-signal-deconstruct-finished-miners',
    icon = '__Nanobots__/graphics/icons/signals/deconstruct-miners.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-e'
}
local signal6 = {
    type = 'virtual-signal',
    name = 'nano-signal-catch-fish',
    icon = '__Nanobots__/graphics/icons/signals/remove-fish.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-f'
}
local signal99 = {
    type = 'virtual-signal',
    name = 'nano-signal-closest-roboport',
    icon = '__Nanobots__/graphics/icons/signals/closest-roboport.png',
    icon_size = 32,
    subgroup = 'nanobot-signals',
    order = '[nano-signal]-z'
}

data:extend {group, signal1, signal2, signal5, signal6, signal99}
