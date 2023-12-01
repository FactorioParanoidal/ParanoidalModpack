-- These preset addons will add new milestones at the end of the detected milestones preset from presets.lua
-- All addons that meet their "required mods" will be used.
-- Add milestones for a mod here if the mod is highly modular and could be used with any other major mod.

-- If you would rather do things yourself, you can add your preset addon in your own mod:
-- Have your mod implement a "milestones_preset_addons" interface, which the Milestones mod will call (in presets_loader.lua).
-- Example: 
-- remote.add_interface("ice-armor", {
--     milestones_preset_addons = function()
--         return {
--             ["Ice Armor"] = {
--                 required_mods = {"ice-armor"},
--                 milestones = {
--                     {type="group", name="Progress"},
--                     {type="item",  name="ice-armor", quantity=1},
--                 }
--             }
--         }
--     end
-- })




remote.add_interface("NE Enemies", {
    milestones_preset_addons = function()
        return {
            ["NE Enemies"] = {
                required_mods = {"Natural_Evolution_Enemies"},
                milestones = {
                    {type="group", name="Kills"},
                    NE_Enemies.Settings.NE_Alien_Artifact_Eggs and
                        {type="kill", name="ne-larva-worm-1",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Alien_Artifact_Eggs and
                        {type="kill", name="ne-larva-worm-1",     quantity=100, next="x10"} or nil,
                    NE_Enemies.Settings.NE_Alien_Artifact_Eggs and
                        {type="kill", name="ne-larva-worm-2",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Alien_Artifact_Eggs and
                        {type="kill", name="ne-larva-worm-2",     quantity=100, next="x10"} or nil,        
                    NE_Enemies.Settings.NE_Spawners_Blue and        
                        {type="kill", name="ne-spawner-blue",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Spawners_Blue and 
                        {type="kill", name="ne-spawner-blue",     quantity=100, next="x10"} or nil,
                    NE_Enemies.Settings.NE_Spawners_Red and 
                        {type="kill", name="ne-spawner-red",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Spawners_Red and 
                        {type="kill", name="ne-spawner-red",     quantity=100, next="x10"} or nil,
                    NE_Enemies.Settings.NE_Spawners_Green and 
                        {type="kill", name="ne-spawner-green",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Spawners_Green and 
                        {type="kill", name="ne-spawner-green",     quantity=100, next="x10"} or nil,
                    NE_Enemies.Settings.NE_Spawners_Yellow and 
                        {type="kill", name="ne-spawner-yellow",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Spawners_Yellow and 
                        {type="kill", name="ne-spawner-yellow",     quantity=100, next="x10"} or nil,
                    NE_Enemies.Settings.NE_Spawners_Pink and 
                        {type="kill", name="ne-spawner-pink",     quantity=1} or nil,
                    NE_Enemies.Settings.NE_Spawners_Pink and 
                        {type="kill", name="ne-spawner-pink",     quantity=100, next="x10"} or nil,
               }
            }
        }
    end
})

