if not thxbob then
    thxbob = {}
end
if not thxbob.lib then
    thxbob.lib = {}
end

if not NE_Functions then
    NE_Functions = {}
end

if not NE_Enemies then
    NE_Enemies = {}
end
if not NE_Enemies.Settings then
    NE_Enemies.Settings = {}
end




require("libs.NE_Functions")

if not mods["combat-mechanics-overhaul"] then

    if not mods["alien-biomes"] then

        require("libs.collision-mask-util-extended")
        collision_mask_util_extended = require("__Natural_Evolution_Enemies__/libs/collision-mask-util-extended")
    end

end



NE_Common = require('common-data')
---------------------------------------------------------------

----- Achievements

require("prototypes.Achievements.Achievements")

-------- New Units
require("prototypes.NE_Units.Settings")
require("prototypes.NE_Units.Damage-types")
require("prototypes.NE_Units.Functions")
require("prototypes.NE_Units.Fire_Stuff")
require ("prototypes.NE_Units.Projectiles")
require("prototypes.NE_Units.New_Biter_Units")
require("prototypes.NE_Units.New_Spitter_Units")
require("prototypes.NE_Units.Megladon_Biter_Unit")
require("prototypes.NE_Units.New_Worms")
require("prototypes.NE_Units.New_Spawners")

---- New Ammo Type
require("prototypes.Categories.ammo-category")

