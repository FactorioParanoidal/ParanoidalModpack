local NANO = {}

NANO.DEBUG = false

--Combat robot names, indexed by capsule name
NANO.COMBAT_ROBOTS = {
    {capsule = 'bob-laser-robot-capsule', unit = 'bob-laser-robot', qty = 5, rank = 75},
    {capsule = 'destroyer-capsule', unit = 'destroyer', qty = 5, rank = 50},
    {capsule = 'defender-capsule', unit = 'defender', qty = 1, rank = 25},
    {capsule = 'distractor-capsule', unit = 'distractor', qty = 1, rank = 1}
}

NANO.FOOD = {
    ['alien-goop-cracking-cotton-candy'] = 100,
    ['cooked-biter-meat'] = 50,
    ['cooked-fish'] = 40,
    ['raw-fish'] = 20,
    ['raw-biter-meat'] = 20
}

NANO.TRANSPORT_TYPES = {
    ['transport-belt'] = 2,
    ['underground-belt'] = 2,
    ['splitter'] = 8,
    ['loader'] = 2
}

NANO.ALLOWED_NOT_ON_MAP = {
    ['entity-ghost'] = true,
    ['tile-ghost'] = true,
    ['item-on-ground'] = true
}

---@type ItemStackDefinition[]
NANO.USABLE_EXPLOSIVES = {
    { name = 'cliff-explosives', count = 1 }, 
    { name = 'explosives', count = 10 }, 
    { name = 'explosive-rocket', count = 4 },
    { name = 'explosive-cannon-shell', count = 4 }, 
    { name = 'cluster-grenade', count = 2 }, 
    { name = 'grenade', count = 14 },
    { name = 'land-mine', count = 5 }, 
    { name = 'artillery-shell', count = 1 }
}

--Tables linked to technologies, values are the tile radius
NANO.BOT_RADIUS = {[0] = 7, [1] = 9, [2] = 11, [3] = 13, [4] = 15}
NANO.AUTO_SPEEDS = {[0] = 25, [1] = 21, [2] = 18, [3] = 15, [4] = 13}
--Manual speeds work out to 15, 12, 10, ~8.6, 7.5
--Which... maybe the later ones should give bigger boosts?
--No, the numbers don't look that different, but they FEEL a lot faster, and that's what matters.

NANO.MANUAL_RADIUS = 10

NANO.MAX_EMPTYING_STACK = 10
NANO.MAX_FILLING_STACK = 10

NANO.POLL_RATE = 60
NANO.MAX_QUEUE_SIZE = 100

NANO.control = {}
NANO.control.loglevel = 2

return NANO
