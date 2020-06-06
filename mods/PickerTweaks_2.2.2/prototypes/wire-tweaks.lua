local Recipe = require('__stdlib__/stdlib/data/recipe')
local Item = require('__stdlib__/stdlib/data/item')

--(( Free Wires )) --
--[[
    "name": "freenetworkwiring",
    "title": "Free Network Wiring",
    "author": "Vas",
    "homepage": "https://mods.factorio.com/mod/freenetworkwiring",
    "description":
        With the circuit network already being annoying as is,
        no one wants to have to pay for thousands of wires! Not to mention,
        blueprints give you the wires for free, so this mod makes the red and green wires free,
        and is compatible with nearly any mod that alters those wires.
        I'll add compatibility to other modded wires too if someone ever makes any other color wires.
--]]
if settings.startup['picker-free-circuit-wires'].value then
    Recipe('red-wire'):clear_ingredients()
    Recipe('green-wire'):clear_ingredients()
end --))

--(( Almost Invisible Wires)) --
--[["name": "AlmostInvisibleElectricWires",
    "version": "0.0.5",
    "title": "Almost Invisible Electric Wires",
    "author": "DellAquila",
    "description":
        "You can make the wires 80%, 50% or completely invisible.
        The Red and Green wire can be Blue and Yellow, or invisible too.
        Now you can customize it in settings.", --]]
if not (settings.startup['picker-wire-color-copper'].value == 'default') then
    local wire = data.raw['utility-sprites']['default'].copper_wire
    local shadow = data.raw['utility-sprites']['default'].wire_shadow
    shadow.filename = '__PickerTweaks__/graphics/wires/transparent-wire-shadow.png'
    shadow.hr_version = nil

    if settings.startup['picker-wire-color-copper'].value == 'invisible' then
        wire.filename = '__PickerTweaks__/graphics/wires/copper/copper-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/copper/hr-copper-wire.png'
    elseif settings.startup['picker-wire-color-copper'].value == '80' then
        wire.filename = '__PickerTweaks__/graphics/wires/copper/80-copper-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/copper/80-hr-copper-wire.png'
    elseif settings.startup['picker-wire-color-copper'].value == '50' then
        wire.filename = '__PickerTweaks__/graphics/wires/copper/50-copper-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/copper/50-hr-copper-wire.png'
    elseif settings.startup['picker-wire-color-copper'].value == '30' then
        wire.filename = '__PickerTweaks__/graphics/wires/copper/30-copper-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/copper/30-hr-copper-wire.png'
    end
end

if not (settings.startup['picker-wire-color-green'].value == 'default') then
    local wire = data.raw['utility-sprites']['default'].green_wire
    local shadow = data.raw['utility-sprites']['default'].wire_shadow
    shadow.filename = '__PickerTweaks__/graphics/wires/transparent-wire-shadow.png'
    shadow.hr_version = nil

    if settings.startup['picker-wire-color-green'].value == 'blue' then
        Item('green-wire', 'item').icon = '__PickerTweaks__/graphics/wires/green/icon-blue-wire.png'
        wire.filename = '__PickerTweaks__/graphics/wires/green/green-wire-b.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/green/hr-green-wire-b.png'
    elseif settings.startup['picker-wire-color-green'].value == 'invisible' then
        wire.filename = '__PickerTweaks__/graphics/wires/green/green-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/green/hr-green-wire.png'
    elseif settings.startup['picker-wire-color-green'].value == '50' then
        wire.filename = '__PickerTweaks__/graphics/wires/green/50-green-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/green/50-hr-green-wire.png'
    end
end

if not (settings.startup['picker-wire-color-red'].value == 'default') then
    local wire = data.raw['utility-sprites']['default'].green_wire
    local shadow = data.raw['utility-sprites']['default'].wire_shadow
    shadow.filename = '__PickerTweaks__/graphics/wires/transparent-wire-shadow.png'
    shadow.hr_version = nil

    if settings.startup['picker-wire-color-red'].value == 'yellow' then
        Item('green-wire', 'item').icon = '__PickerTweaks__/graphics/wires/red/icon-yellow-wire.png'
        wire.filename = '__PickerTweaks__/graphics/wires/red/red-wire-y.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/red/hr-red-wire-y.png'
    elseif settings.startup['picker-wire-color-red'].value == 'invisible' then
        wire.filename = '__PickerTweaks__/graphics/wires/red/red-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/red/hr-red-wire.png'
    elseif settings.startup['picker-wire-color-red'].value == '50' then
        wire.filename = '__PickerTweaks__/graphics/wires/red/50-red-wire.png'
        wire.hr_version.filename = '__PickerTweaks__/graphics/wires/red/50-hr-red-wire.png'
    end
end --))
