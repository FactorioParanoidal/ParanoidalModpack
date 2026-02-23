local Data = require('__kry_stdlib__/stdlib/data/data')

--custom input for copy and paste chest
Data {
    type = 'custom-input',
    name = 'picker-copy-chest',
    key_sequence = 'SHIFT + C',
    order = 'chest-copy'
}
Data {
    type = 'custom-input',
    name = 'picker-paste-chest',
    key_sequence = 'SHIFT + V',
    order = 'chest-paste'
}