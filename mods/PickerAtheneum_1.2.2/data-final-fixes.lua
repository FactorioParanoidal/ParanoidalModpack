require('__stdlib__/stdlib/utils/globals')

if prequire('__PickerAtheneum__/.debug/debug') then
    require('__stdlib__/stdlib/data/developer/developer').make_test_entities()
    data:extend {
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

if mods['debugadapter'] then
    data:extend {
        {
            type = 'custom-input',
            name = 'picker-trigger-breakpoint',
            key_sequence = 'CONTROL + SHIFT + END',
            localised_name = 'Trigger Breakpoint'
        }
    }
end
