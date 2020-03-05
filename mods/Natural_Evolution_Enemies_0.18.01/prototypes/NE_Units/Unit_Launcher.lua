if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value





--------- Used for Unit Launcher - Thanks Supercheese for this code :)
-- The result in the right column is the enemy that appears when the enemy in the left column dies. So if a behemoth spitter dies, medium spitters will appear.
-- For spawners, the current evolution factor rounded down to the nearest 10% (though 99% is rounded up to 100%) is used to look up which enemy appears.


--- Find the NAME of the unit
if not subEnemyNameTable then subEnemyNameTable = {} end

--- Unit Unit-Launcher
subEnemyNameTable["ne_green_splash_1"] = {}
subEnemyNameTable["ne_green_splash_1"][0] = 			"ne-biter-fastL-1"
subEnemyNameTable["ne_green_splash_1"][1] = 			"ne-biter-fastL-2"
subEnemyNameTable["ne_green_splash_1"][2] = 			"ne-biter-fastL-2"
subEnemyNameTable["ne_green_splash_1"][3] = 			"ne-biter-fastL-"..math.floor( 3 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][4] = 			"ne-biter-fastL-"..math.floor( 3 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][5] = 			"ne-biter-fastL-"..math.floor( 4 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][6] = 			"ne-biter-fastL-"..math.floor( 5 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][7] = 			"ne-biter-fastL-"..math.floor( 5 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][8] = 			"ne-biter-fastL-"..math.floor( 5 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][9] = 			"ne-biter-fastL-"..math.floor( 6 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["ne_green_splash_1"][10] =			"ne-biter-fastL-"..math.floor( 6 + (NE_Enemies.Settings.NE_Difficulty / 2))


--- Worm Unit-Launcher
-- Uses a random name in control.lua


--- Unit Spawner
subEnemyNameTable["Spawner-Breeder"] = {}
subEnemyNameTable["Spawner-Breeder"][0] = 			"ne-biter-breeder-"..math.floor( 3 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][1] = 			"ne-biter-breeder-"..math.floor( 3 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][2] = 			"ne-biter-breeder-"..math.floor( 4 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][3] = 			"ne-biter-breeder-"..math.floor( 4 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][4] = 			"ne-biter-breeder-"..math.floor( 5 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][5] = 			"ne-biter-breeder-"..math.floor( 5 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][6] = 			"ne-biter-breeder-"..math.floor( 6 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][7] = 			"ne-biter-breeder-"..math.floor( 6 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][8] = 			"ne-biter-breeder-"..math.floor( 7 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][9] = 			"ne-biter-breeder-"..math.floor( 7 + (NE_Enemies.Settings.NE_Difficulty / 2))
subEnemyNameTable["Spawner-Breeder"][10] =			"ne-biter-breeder-"..math.floor( 8 + (NE_Enemies.Settings.NE_Difficulty / 2))



-- NUMBERS
-- The result in the right column is the number of enemies that appear when the enemy in the left column dies.
-- The current evolution factor rounded down to the nearest 10% is also used to look up which enemy appears.

if not subEnemyNumberTable then subEnemyNumberTable = {} end

--- Unit Unit-Launcher
subEnemyNumberTable["ne_green_splash_1"] = {}
subEnemyNumberTable["ne_green_splash_1"][0] = 			math.floor(1)    
subEnemyNumberTable["ne_green_splash_1"][1] = 			math.floor(1 + NE_Enemies.Settings.NE_Difficulty / 2)   
subEnemyNumberTable["ne_green_splash_1"][2] = 			math.floor(1 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["ne_green_splash_1"][3] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2) 
subEnemyNumberTable["ne_green_splash_1"][4] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2)  
subEnemyNumberTable["ne_green_splash_1"][5] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2)  
subEnemyNumberTable["ne_green_splash_1"][6] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)
subEnemyNumberTable["ne_green_splash_1"][7] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)
subEnemyNumberTable["ne_green_splash_1"][8] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["ne_green_splash_1"][9] = 			math.floor(4 + NE_Enemies.Settings.NE_Difficulty / 2)   
subEnemyNumberTable["ne_green_splash_1"][10] =			math.floor(5 + NE_Enemies.Settings.NE_Difficulty / 2)    


--- Worm Unit-Launcher
subEnemyNumberTable["ne_green_splash_2"] = {}
subEnemyNumberTable["ne_green_splash_2"][0] = 			math.floor(1)    
subEnemyNumberTable["ne_green_splash_2"][1] = 			math.floor(1 + NE_Enemies.Settings.NE_Difficulty / 2)   
subEnemyNumberTable["ne_green_splash_2"][2] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["ne_green_splash_2"][3] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2) 
subEnemyNumberTable["ne_green_splash_2"][4] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2)  
subEnemyNumberTable["ne_green_splash_2"][5] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)  
subEnemyNumberTable["ne_green_splash_2"][6] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)
subEnemyNumberTable["ne_green_splash_2"][7] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)
subEnemyNumberTable["ne_green_splash_2"][8] = 			math.floor(4 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["ne_green_splash_2"][9] = 			math.floor(4 + NE_Enemies.Settings.NE_Difficulty / 2)   
subEnemyNumberTable["ne_green_splash_2"][10] =			math.floor(5 + NE_Enemies.Settings.NE_Difficulty / 2)    

--- Unit Spawner
subEnemyNumberTable["Spawner-Breeder"] = {}
subEnemyNumberTable["Spawner-Breeder"][0] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["Spawner-Breeder"][1] = 			math.floor(2 + NE_Enemies.Settings.NE_Difficulty / 2)   
subEnemyNumberTable["Spawner-Breeder"][2] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["Spawner-Breeder"][3] = 			math.floor(3 + NE_Enemies.Settings.NE_Difficulty / 2) 
subEnemyNumberTable["Spawner-Breeder"][4] = 			math.floor(4 + NE_Enemies.Settings.NE_Difficulty / 2)  
subEnemyNumberTable["Spawner-Breeder"][5] = 			math.floor(4 + NE_Enemies.Settings.NE_Difficulty / 2)  
subEnemyNumberTable["Spawner-Breeder"][6] = 			math.floor(4 + NE_Enemies.Settings.NE_Difficulty / 2)
subEnemyNumberTable["Spawner-Breeder"][7] = 			math.floor(5 + NE_Enemies.Settings.NE_Difficulty / 2)
subEnemyNumberTable["Spawner-Breeder"][8] = 			math.floor(5 + NE_Enemies.Settings.NE_Difficulty / 2)    
subEnemyNumberTable["Spawner-Breeder"][9] = 			math.floor(6 + NE_Enemies.Settings.NE_Difficulty / 2)   
subEnemyNumberTable["Spawner-Breeder"][10] =			math.floor(6 + NE_Enemies.Settings.NE_Difficulty / 2)    
