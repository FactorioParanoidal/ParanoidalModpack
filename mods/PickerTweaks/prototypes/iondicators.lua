local Color = require('__stdlib__/stdlib/utils/color')
local utility_sprites = data.raw['utility-sprites'].default

-------------------------------------------------------------------------------
-- [Smaller no power]--
-------------------------------------------------------------------------------
-- Code and Gfx from "Ion's Tweaks: Less Unplugged", by "author": "KingIonTrueLove"
-- "name": "SmallerLogisticDeliveryIcon",
-- "title": "Smaller Logistic Delivery Icon",
-- "author": "Mungu",
-- "description": "Smaller icon for Logistic Delivery (Robots)",
if settings.startup['picker-small-unplugged-icon'].value then
    data.raw['item-request-proxy']['item-request-proxy'].picture.filename =
        '__PickerTweaks__/graphics/material-construction.png'
    utility_sprites.electricity_icon_unplugged.filename = '__PickerTweaks__/graphics/electricity-icon-unplugged.png'
    utility_sprites.too_far_from_roboport_icon.filename = '__PickerTweaks__/graphics/too-far-from-roboport-icon.png'
end
-- No power, Low power, roboport etc etc

-------------------------------------------------------------------------------
-- [Iondicators]--
-------------------------------------------------------------------------------
-- GFX From "Iondicators" by "KingIonTrueLove" https://mods.factorio.com/mods/ion_cannon_1
local ion_line = settings.startup['picker-iondicators-line'].value
local ion_arrow = settings.startup['picker-iondicators-arrow'].value
if ion_line ~= 'vanilla' then
    utility_sprites.indication_line.filename = '__PickerTweaks__/graphics/iondicators/indication-line.png'
    utility_sprites.indication_line.tint = Color(Color.color[ion_line], 0.5)
end
if ion_arrow ~= 'vanilla' then
    utility_sprites.indication_arrow.filename = '__PickerTweaks__/graphics/iondicators/indication-arrow.png'
    utility_sprites.indication_arrow.tint = Color(Color.color[ion_arrow], 0.5)
end
