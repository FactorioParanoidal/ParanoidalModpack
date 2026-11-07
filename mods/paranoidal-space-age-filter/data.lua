-- Hides Space Age from the other mods and, with it on, keeps of its changes to the base game only what the space
-- platforms need (space-age-platforms.lua).
if require("space-age-filter")("data") then require("space-age-platforms").install() end
