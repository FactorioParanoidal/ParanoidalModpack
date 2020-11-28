if not thxbob then thxbob = {} end
if not thxbob.lib then thxbob.lib = {} end

if not NE_Functions then NE_Functions = {} end

if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end


require ("libs.NE_Functions")

---------------------------------------------------------------

----- Achievements

require ("prototypes.Achievements.Achievements")
	

-------- New Units
require ("prototypes.NE_Units.Settings")
require ("prototypes.NE_Units.damage-types")
require ("prototypes.NE_Units.Functions")
require ("prototypes.NE_Units.Fire_Stuff")
require ("prototypes.NE_Units.New_Biter_Units")
require ("prototypes.NE_Units.New_Spitter_Units")
require ("prototypes.NE_Units.Megladon_Biter_Unit")
require ("prototypes.NE_Units.New_Spawners")




		