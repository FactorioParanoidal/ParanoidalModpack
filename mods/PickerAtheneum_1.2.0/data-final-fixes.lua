if require('__PickerAtheneum__/config').DEBUG then
    require('__stdlib__/stdlib/data/developer/developer').make_test_entities()
    data:extend{
        {
            type = 'custom-input',
            name = 'picker-reload-mods',
            key_sequence = 'SHIFT + PAGEDOWN',
            localised_name = 'Reload Mods'
        },
        {
            type = 'custom-input',
            name = 'picker-dump-data',
            key_sequence = 'SHIFT + PAGEUP',
            localised_name = 'Dump Data'
        }
    }
end
