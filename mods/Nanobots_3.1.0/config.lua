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

--Tables linked to technologies, values are the tile radius
NANO.BOT_RADIUS = {[0] = 7, [1] = 9, [2] = 11, [3] = 13, [4] = 15}
NANO.QUEUE_SPEED_BONUS = {[0] = 0, [1] = 2, [2] = 4, [3] = 6, [4] = 8}

NANO.control = {}
NANO.control.loglevel = 0

return NANO
