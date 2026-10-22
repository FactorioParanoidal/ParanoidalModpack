local Recipe = require('__stdlib2__/stdlib/data/recipe')
local Technology = require('__stdlib2__/stdlib/data/technology')

require('prototypes/technology/shortcuts')

-- bobmods recipe changes
if mods['bobelectronics'] then

    local key = 'bobmods-logistics-disableroboports'
    if settings["startup"][key] and settings["startup"][key].value then
        Recipe('roboport-interface'):replace_ingredient('roboport', 'bob-logistic-zone-expander')
    end
    Recipe('gun-nano-emitter'):replace_ingredient('electronic-circuit', 'bob-basic-circuit-board')
    Recipe('ammo-nano-constructors'):replace_ingredient('electronic-circuit', 'bob-basic-circuit-board')
    Recipe('ammo-nano-levelers'):replace_ingredient('electronic-circuit', 'bob-basic-circuit-board')

    Recipe('equipment-bot-chip-items'):add_ingredient('bob-robot-brain')
    Recipe('equipment-bot-chip-trees'):add_ingredient('bob-robot-brain')
    Recipe('equipment-bot-chip-nanointerface'):add_ingredient('bob-robot-brain')
    Recipe('equipment-bot-chip-launcher'):add_ingredient('bob-robot-brain')
    Recipe('equipment-bot-chip-feeder'):add_ingredient('bob-robot-brain')
end

if mods['aai-industry'] then
    Technology('nanobots'):remove_prereq('logistics')
    Technology('nanobots'):add_prereq('electronics')
    --removing logistics is debatable, but most people would have it by that point anyway, 
    --and it's a pretty arbitrary prereq in the first place
end

if not settings.startup["nanobots-auto"].value then
    --(... and settings.startup["nanobots-network-limits"].value)
    -- ^if I decide to put that setting back in
    data.raw.recipe["equipment-bot-chip-nanointerface"].hidden = true
end
