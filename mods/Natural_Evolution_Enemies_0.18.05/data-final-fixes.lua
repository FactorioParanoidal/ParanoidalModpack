if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end
NE_Enemies.Settings.NE_Adjust_Vanilla_Worms = settings.startup["NE_Adjust_Vanilla_Worms"].value


--- Update Vanilla Worm Stuff -- Medium worm will become fire worm and big worm will be come unit launcher worm
require ("prototypes.NE_Units.Worm_Changes")
require("prototypes.NE_Units.Update_Immunities")

