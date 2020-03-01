data:extend {
    {
        type = 'custom-input',
        name = 'picker-manual-inventory-sort',
        key_sequence = 'SHIFT + E'
    },
    {
        type = 'custom-input',
        name = 'picker-copy-chest',
        key_sequence = 'CONTROL + SHIFT + C',
        order = 'chest-copy'
    },
    {
        type = 'custom-input',
        name = 'picker-paste-chest',
        key_sequence = 'CONTROL + SHIFT + V',
        order = 'chest-paste'
    }
}

require('prototypes/inventory-tools')
require('prototypes/zapper')
require('prototypes/filter-fill')
