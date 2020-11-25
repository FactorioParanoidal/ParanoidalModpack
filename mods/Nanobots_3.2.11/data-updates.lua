local Recipe = require('__stdlib__/stdlib/data/recipe')

require('prototypes/technology/shortcuts')

-- bobmods recipe changes
if mods['boblibrary'] then

    if settings.get_startup('bobmods-logistics-disableroboports') then
        Recipe('roboport-interface'):replace_ingredient('roboport', 'bob-logistic-zone-expander')
    end
    Recipe('gun-nano-emitter'):replace_ingredient('electronic-circuit', 'basic-circuit-board')
    Recipe('ammo-nano-constructors'):replace_ingredient('electronic-circuit', 'basic-circuit-board')
    Recipe('ammo-nano-termites'):replace_ingredient('electronic-circuit', 'basic-circuit-board')

    Recipe('equipment-bot-chip-items'):add_ingredient('robot-brain-construction')
    Recipe('equipment-bot-chip-trees'):add_ingredient('robot-brain-construction')
    Recipe('equipment-bot-chip-nanointerface'):add_ingredient('robot-brain-construction')
    Recipe('equipment-bot-chip-nanointerface'):add_ingredient('gun-nano-emitter')
    Recipe('equipment-bot-chip-launcher'):add_ingredient('robot-brain-combat')
    Recipe('equipment-bot-chip-feeder'):add_ingredient('robot-brain-combat')
end
