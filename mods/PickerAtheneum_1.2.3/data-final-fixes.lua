require('__stdlib__/stdlib/utils/globals')
require('scenarios/testing/data')

if settings.startup['picker-debug'].value then
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
