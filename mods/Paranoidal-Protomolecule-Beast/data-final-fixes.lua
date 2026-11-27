-- The creatures are made last, so that every other mod's buildings are there to be made into them, as they end up.
require("prototypes.beasts")

if mods["zzzparanoidal"] then
    require("__zzzparanoidal__/tweaks/entity/bottleneck-indicators")
end
