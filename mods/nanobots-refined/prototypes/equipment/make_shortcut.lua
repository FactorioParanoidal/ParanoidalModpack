local Data = require('__stdlib2__/stdlib/data/data')

local function make_shortcut(chip)
    if mods['PickerInventoryTools'] then
        chip:copy('picker-disabled-' .. chip.name):set_fields {
            localised_name = {'nano-disabled-equipment.disabled', chip.localised_name or {'equipment-name.' .. chip.name}}
        }

        Data {
            type = 'shortcut',
            name = 'toggle-' .. chip.name,
            order = 'c[toggles]-z[' .. chip.name .. ']',
            action = 'lua',
            toggleable = true,
            localised_name = {'shortcut.toggle-' .. chip.name},
            associated_control_input = nil,
            technology_to_unlock = 'personal-roboport-equipment',
            icon = {
                filename = chip.sprite.filename,
                priority = 'extra-high-no-scale',
                size = 32,
                scale = 1,
                mipmap_count = 0,
                flags = {'gui-icon'}
            }
        }
    end
end

return make_shortcut
