local Color = require('__stdlib__/stdlib/utils/color')

local allowed_colors = {'vanilla'}
for color_name in pairs(Color.color) do
    allowed_colors[#allowed_colors + 1] = color_name
end

-- Robots
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-unminable-construction-robots',
        setting_type = 'startup',
        default_value = true,
        order = 'robots-a'
        --default factorio false
    },
    {
        type = 'bool-setting',
        name = 'picker-unminable-logistic-robots',
        setting_type = 'startup',
        default_value = true,
        order = 'robots-b'
        --default factorio false
    },
    {
        type = 'bool-setting',
        name = 'picker-fireproof-construction-robots',
        setting_type = 'startup',
        default_value = true,
        order = 'robots-c'
        --default factorio false
    },
    {
        type = 'bool-setting',
        name = 'picker-noalt-construction-robots',
        setting_type = 'startup',
        default_value = true,
        order = 'robots-d'
        --default factorio false
    },
    {
        type = 'bool-setting',
        name = 'picker-noalt-logistic-robots',
        setting_type = 'startup',
        default_value = true,
        order = 'robots-e'
        --default factorio false
    },
    {
        type = 'int-setting',
        name = 'picker-adjustable-bot-scale',
        setting_type = 'startup',
        default_value = 50,
        minimum_value = 25,
        maximum_value = 200,
        order = 'robots-f'
        --default factorio 100
    },
    {
        type = 'bool-setting',
        name = 'picker-show-bots-on-map',
        setting_type = 'startup',
        default_value = false,
        order = 'robots-g'
    },
}

-- Reacher
data:extend {
    {
        type = 'double-setting',
        name = 'picker-reacher-reach-distance',
        setting_type = 'startup',
        default_value = 10,
        maximum_value = 10000,
        minimum_value = 1,
        order = 'reacher-a'
        --default factorio 10
    },
    {
        type = 'double-setting',
        name = 'picker-reacher-build-distance',
        setting_type = 'startup',
        default_value = 10,
        maximum_value = 10000,
        minimum_value = 1,
        order = 'reacher-b'
        --default factorio 10
    },
    {
        type = 'double-setting',
        name = 'picker-reacher-reach-resource-distance',
        setting_type = 'startup',
        default_value = 2.7,
        maximum_value = 10000,
        minimum_value = 1,
        order = 'reacher-c'
        --default factorio 2.7
    },
    {
        type = 'double-setting',
        name = 'picker-reacher-drop-item-distance',
        setting_type = 'startup',
        default_value = 10,
        maximum_value = 10000,
        minimum_value = 1,
        order = 'reacher-d'
        --default factorio 10
    },
    {
        type = 'double-setting',
        name = 'picker-reacher-item-pickup-distance',
        setting_type = 'startup',
        default_value = 1,
        maximum_value = 100,
        minimum_value = 1,
        order = 'reacher-e'
        --default factorio 1
    },
    {
        type = 'double-setting',
        name = 'picker-reacher-loot-pickup-distance',
        setting_type = 'startup',
        default_value = 2,
        maximum_value = 100,
        minimum_value = 1,
        order = 'reacher-f'
        --default factorio 2
    }
}

-- Brighter Lights
data:extend {
    {
        type = 'string-setting',
        name = 'picker-enhanced-lights',
        setting_type = 'startup',
        default_value = 'grfwoot',
        allowed_values = {'default', 'grfwoot', 'darkfrei'},
        order = 'brighter-lights-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-brighter-lights-player',
        setting_type = 'startup',
        default_value = false,
        order = 'brighter-lights-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-brighter-lights-vehicles',
        setting_type = 'startup',
        default_value = false,
        order = 'brighter-lights-c'
    }
}

-- Squeak Through
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-smaller-tree-box',
        setting_type = 'startup',
        default_value = true,
        order = 'squeak-through-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-squeak-through',
        setting_type = 'startup',
        default_value = false,
        order = 'squeak-through-b'
    }
}

-- Corpse
data:extend {
    {
        type = 'int-setting',
        name = 'picker-corpse-time',
        setting_type = 'startup',
        default_value = 60 * 60,
        minimum_value = 1,
        maximum_value = 60 * 60 * 60 * 60,
        order = 'corpse-a'
        --default factorio 54000, 15 minutes
    },
    {
        type = 'int-setting',
        name = 'picker-player-corpse-time',
        setting_type = 'startup',
        default_value = 60 * 60 * 15,
        minimum_value = 1,
        maximum_value = 60 * 60 * 60 * 60,
        order = 'corpse-b'
        --default factorio 54000, 15 minutes
    }
}

-- Gui
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-smaller-gui-borders',
        setting_type = 'startup',
        default_value = false,
        order = 'gui-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-small-unplugged-icon',
        setting_type = 'startup',
        default_value = true,
        order = 'gui-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-brighter-cell-background',
        setting_type = 'startup',
        default_value = false,
        order = 'gui-b'
    }
}

-- Iondicators
data:extend {
    {
        type = 'string-setting',
        name = 'picker-iondicators-line',
        setting_type = 'startup',
        default_value = 'vanilla',
        allowed_values = allowed_colors,
        order = 'iondicators-a'
    },
    {
        type = 'string-setting',
        name = 'picker-iondicators-arrow',
        setting_type = 'startup',
        default_value = 'vanilla',
        allowed_values = allowed_colors,
        order = 'iondicators-b'
    }
}

-- Ghost
data:extend{
    {
        type = 'string-setting',
        name = 'picker-ghost-tint',
        setting_type = 'startup',
        default_value = 'vanilla',
        allowed_values = allowed_colors,
        order = 'ghost-a'
    }
}

-- Roundup
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-disable-smoke',
        setting_type = 'startup',
        default_value = false,
        order = 'roundup-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-disable-decorations',
        setting_type = 'startup',
        default_value = false,
        order = 'roundup-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-roundup',
        setting_type = 'startup',
        default_value = true,
        order = 'roundup-c'
    },
    {
        type = 'bool-setting',
        name = 'picker-roundup-resources',
        setting_type = 'startup',
        default_value = false,
        order = 'roundup-d'
    }
}

-- Entities
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-clean-tree-burning',
        setting_type = 'startup',
        default_value = false,
        order = 'entities-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-fireproof-rail-signals',
        setting_type = 'startup',
        default_value = false,
        order = 'entities-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-fireproof-rolling-stock',
        setting_type = 'startup',
        default_value = false,
        order = 'entities-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-generic-vehicle-grids',
        setting_type = 'startup',
        default_value = false,
        order = 'entities-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-realistic-reactor-glow',
        setting_type = 'startup',
        default_value = true,
        order = 'entities-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-no-artillery-reveal',
        setting_type = 'startup',
        default_value = false,
        order = 'recipes-a'
    }
}

-- Inventory
data:extend {
    {
        type = 'int-setting',
        name = 'picker-inventory-size',
        setting_type = 'startup',
        default_value = 80,
        minimum_value = 1,
        maximum_value = 600,
        order = 'inventory-a'
        --default factorio 80
    },
    {
        type = 'bool-setting',
        name = 'picker-replace-wood',
        setting_type = 'startup',
        default_value = false,
        order = 'inventory-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-free-circuit-wires',
        setting_type = 'startup',
        default_value = false,
        order = 'inventory-c'
    },
    {
        type = 'int-setting',
        name = 'picker-tile-stack',
        setting_type = 'startup',
        default_value = 0,
        minimum_value = 0,
        maximum_value = 100000,
        order = 'inventory-d'
    }
}

-- Wire color
data:extend {
    {
        type = 'string-setting',
        name = 'picker-wire-color-copper',
        setting_type = 'startup',
        default_value = 'default',
        allowed_values = {'default', 'invisible', '30', '50', '80'},
        order = 'wire-color-a'
    },
    {
        type = 'string-setting',
        name = 'picker-wire-color-green',
        setting_type = 'startup',
        default_value = 'default',
        allowed_values = {'default', 'blue', 'invisible', '50'},
        order = 'wire-color-b'
    },
    {
        type = 'string-setting',
        name = 'picker-wire-color-red',
        setting_type = 'startup',
        default_value = 'default',
        allowed_values = {'default', 'yellow', 'invisible', '50'},
        order = 'wire-color-c'
    }
}

-- Sounds
data:extend {
    {
        type = 'double-setting',
        name = 'picker-belt-sounds',
        setting_type = 'startup',
        default_value = 1.0,
        maximum_value = 2.0,
        minimum_value = 0.0,
        order = 'sounds-a'
    }
}

-- Ingredients
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-return-ingredients',
        setting_type = 'startup',
        default_value = true,
        order = 'ingredients-a'
    }
}

-- Tiles
data:extend{
    {
        type = 'bool-setting',
        name = 'picker-multi-concrete',
        setting_type = 'startup',
        default_value = false,
        order = 'tiles-a'
    }
}

-- Belts
data:extend{
    {
        type = 'bool-setting',
        name = 'picker-underground-lengths',
        setting_type = 'startup',
        default_value = false,
        order = 'belts-underneathies-a'
    },
    {
        type = 'int-setting',
        name = 'picker-underground-bus-gap',
        setting_type = 'startup',
        default_value = 4,
        minimum_value = 1,
        maximum_value = 32,
        order = 'belts-underneathies-b'
    },
    {
        type = 'bool-setting',
        name = 'picker-legacy-belt-fast-replace',
        setting_type = 'startup',
        default_value = false,
        order = 'belts-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-silent-belts',
        setting_type = 'startup',
        default_value = false,
        order = 'belts-b'
    },
}
