-- Whether paving and building clear decorations by themselves. Д-ОК (Paranoidal-Droid-M-O) cleans the floors around
-- his station; while he is in the game and the startup setting is on, this mod leaves that work to him: tiles keep
-- their own share of removal (base game: 15-25 % on stone path and concrete), buildings only what the engine removes
-- under them. Both stages read the same startup setting and mod list, so data and control always agree.
local droid = "Paranoidal-Droid-M-O"
local setting = settings.startup["paranoidal-decoration-cleanup-droid-m-o"]
local yield = setting and setting.value

local active
if script then
	active = script.active_mods[droid] ~= nil
else
	active = mods[droid] ~= nil
end

return {automatic = not (yield and active)}
