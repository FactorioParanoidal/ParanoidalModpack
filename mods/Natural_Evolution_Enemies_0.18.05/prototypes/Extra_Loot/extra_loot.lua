if settings.startup["NE_Alien_Artifacts"].value == true then

	if not NE_Enemies then NE_Enemies = {} end
	if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

	NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value


	local function add_loot(spawner,item)
	  if not spawner.loot then spawner.loot = {} end
	  local has = false
	  for _,v in pairs(spawner.loot) do
		if v.item == item.item then has = true break end
		end
	  if not has then
		table.insert(spawner.loot,item)
		end
	  end


	  
	 for k, spawners in pairs(data.raw["unit-spawner"]) do
	 
		add_loot(
		  spawners,
		  {item = "alien-artifact",count_min = 5,count_max = 10,probability = 1/NE_Enemies.Settings.NE_Difficulty}
		  ) 
	  
	 end
	 
	 
	 for k, units in pairs(data.raw["unit"]) do
	 
		 add_loot(
		  units,
		  {item = "small-alien-artifact",count_min = 1,count_max = 3,probability = 1/NE_Enemies.Settings.NE_Difficulty}
		  )
	  
	 end
 
 end

