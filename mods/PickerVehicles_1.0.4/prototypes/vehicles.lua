local Data = require('__stdlib__/stdlib/data/data')

Data {type = 'custom-input', name = 'picker-dude-wheres-my-car', key_sequence = 'CONTROL + SHIFT + J'}
Data {type = 'custom-input', name = 'picker-toggle-train-control', key_sequence = 'J'}
Data {type = 'custom-input', name = 'picker-goto-station', key_sequence = 'J'}
Data {type = 'custom-input', name = 'picker-goto-next-station', key_sequence = 'SHIFT + J'}
Data {type = 'custom-input', name = 'picker-honk', key_sequence = 'H'}

if settings.startup['picker-manual-train-keys'].value then
    Data {type = 'custom-input', name = 'picker-up-event', linked_game_control = 'move-up', key_sequence = ''}
    Data {type = 'custom-input', name = 'picker-down-event', linked_game_control = 'move-down', key_sequence = ''}
    Data {type = 'custom-input', name = 'picker-left-event', linked_game_control = 'move-left', key_sequence = ''}
    Data {type = 'custom-input', name = 'picker-right-event', linked_game_control = 'move-right', key_sequence = ''}
end

Data {type = 'sound', name = 'deltic-start', filename = '__PickerVehicles__/sounds/deltic_honk_1.ogg'}
Data {type = 'sound', name = 'deltic-stop', filename = '__PickerVehicles__/sounds/deltic_honk_2.ogg'}
Data {type = 'sound', name = 'train-stop', filename = '__PickerVehicles__/sounds/honk_long.ogg'}
Data {type = 'sound', name = 'train-start', filename = '__PickerVehicles__/sounds/honk_2x.ogg'}
Data {type = 'sound', name = 'car-horn', filename = '__PickerVehicles__/sounds/horn_honk.ogg'}
Data {type = 'sound', name = 'horn-long', filename = '__PickerVehicles__/sounds/horn_xlong.ogg'}
