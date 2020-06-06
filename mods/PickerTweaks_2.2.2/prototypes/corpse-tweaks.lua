local Data = require('__stdlib__/stdlib/data/data')

--[[
    "name": "Noxys_QuickerStumpFade",
    "title": "Noxys Fading",
    "author": "Noxy",
    "homepage": "https://mods.factorio.com/user/_noxy_",
    "description": "Configurable fade away times for various corpse entities (like biters, tree stumps, destroyed buildings)."
--]]
local corpse_time = settings.startup['picker-corpse-time'].value
for _, corpse in pairs(data.raw['corpse']) do
    if corpse.time_before_removed == 54000 then
        corpse.time_before_removed = corpse_time
    end
end

Data('character-corpse', 'character-corpse').time_to_live = settings.startup['picker-player-corpse-time'].value
