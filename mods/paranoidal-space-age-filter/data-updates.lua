-- Every data.lua has run: if no mod after Space Age noticed the end of its data.lua, the base game is put back now,
-- before the data-updates of the other mods.
local platforms = data.paranoidal_space_age_filter
if platforms then platforms.finish("data-updates") end
