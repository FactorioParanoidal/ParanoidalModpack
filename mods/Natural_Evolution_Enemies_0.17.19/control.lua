--ENEMIES v.0.17.18
local QC_Mod = false

if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value
NE_Enemies.Settings.NE_Starting_Evolution = settings.startup["NE_Starting_Evolution"].value

require ("util")
require ("prototypes.NE_Units.Unit_Launcher")


---************** Used for Testing -----
require ("Test_Spawn")
---*************



--- Scorched Earth
local replaceableTiles_alien =
{
	  -- vanilla
["grass-1"] = "vegetation-green-grass-3",
["grass-3"] = "vegetation-green-grass-2",
["grass-2"] = "vegetation-green-grass-4",
["grass-4"] = "vegetation-green-grass-4",
["dirt-1"] = "mineral-beige-dirt-1",
["dirt-2"] = "mineral-beige-dirt-1",
["dirt-3"] = "mineral-beige-dirt-1",
["dirt-5"] = "mineral-beige-dirt-1",
["dirt-6"] = "mineral-beige-dirt-1",
["dirt-7"] = "mineral-beige-dirt-1",
["dirt-4"] = "mineral-beige-dirt-1",
["dry-dirt"] = "mineral-beige-dirt-1",
["sand-3"] = "mineral-beige-dirt-1",
["sand-2"] = "mineral-beige-dirt-1",
["sand-1"] = "mineral-beige-dirt-1",
["red-desert-0"] = "mineral-beige-dirt-1",
["red-desert-1"] = "mineral-beige-dirt-1",
["red-desert-2"] = "mineral-beige-dirt-1",
["red-desert-3"] = "mineral-beige-dirt-1",

	  -- alien biomes
["frozen-snow-0"] = "frozen-snow-1",
["frozen-snow-1"] = "frozen-snow-2",
["frozen-snow-2"] = "frozen-snow-3",
["frozen-snow-3"] = "frozen-snow-4",
["frozen-snow-4"] = "frozen-snow-5",
["frozen-snow-5"] = "frozen-snow-6",
["frozen-snow-6"] = "frozen-snow-7",
["frozen-snow-7"] = "frozen-snow-8",
["frozen-snow-8"] = "frozen-snow-9",
["frozen-snow-9"] = "volcanic-orange-heat-1",
["mineral-aubergine-dirt-1"] = "mineral-aubergine-dirt-2",
["mineral-aubergine-dirt-2"] = "mineral-aubergine-dirt-3",
["mineral-aubergine-dirt-3"] = "mineral-aubergine-dirt-4",
["mineral-aubergine-dirt-4"] = "mineral-aubergine-dirt-5",
["mineral-aubergine-dirt-5"] = "mineral-aubergine-dirt-6",
["mineral-aubergine-dirt-6"] = "mineral-aubergine-sand-1",
["mineral-aubergine-sand-1"] = "mineral-aubergine-sand-2",
["mineral-aubergine-sand-2"] = "mineral-aubergine-sand-3",
["mineral-aubergine-sand-3"] = "volcanic-orange-heat-1",
["mineral-beige-dirt-1"] = "mineral-beige-dirt-2",
["mineral-beige-dirt-2"] = "mineral-beige-dirt-3",
["mineral-beige-dirt-3"] = "mineral-beige-dirt-4",
["mineral-beige-dirt-4"] = "mineral-beige-dirt-5",
["mineral-beige-dirt-5"] = "mineral-beige-dirt-6",
["mineral-beige-dirt-6"] = "mineral-beige-sand-1",
["mineral-beige-sand-1"] = "mineral-beige-sand-2",
["mineral-beige-sand-2"] = "mineral-beige-sand-3",
["mineral-beige-sand-3"] = "volcanic-orange-heat-1",
["mineral-black-dirt-1"] = "mineral-black-dirt-2",
["mineral-black-dirt-2"] = "mineral-black-dirt-3",
["mineral-black-dirt-3"] = "mineral-black-dirt-4",
["mineral-black-dirt-4"] = "mineral-black-dirt-5",
["mineral-black-dirt-5"] = "mineral-black-dirt-6",
["mineral-black-dirt-6"] = "mineral-black-sand-1",
["mineral-black-sand-1"] = "mineral-black-sand-2",
["mineral-black-sand-2"] = "mineral-black-sand-3",
["mineral-black-sand-3"] = "volcanic-orange-heat-1",
["mineral-brown-dirt-1"] = "mineral-brown-dirt-2",
["mineral-brown-dirt-2"] = "mineral-brown-dirt-3",
["mineral-brown-dirt-3"] = "mineral-brown-dirt-4",
["mineral-brown-dirt-4"] = "mineral-brown-dirt-5",
["mineral-brown-dirt-5"] = "mineral-brown-dirt-6",
["mineral-brown-dirt-6"] = "mineral-brown-sand-1",
["mineral-brown-sand-1"] = "mineral-brown-sand-2",
["mineral-brown-sand-2"] = "mineral-brown-sand-3",
["mineral-brown-sand-3"] = "volcanic-orange-heat-1",
["mineral-cream-dirt-1"] = "mineral-cream-dirt-2",
["mineral-cream-dirt-2"] = "mineral-cream-dirt-3",
["mineral-cream-dirt-3"] = "mineral-cream-dirt-4",
["mineral-cream-dirt-4"] = "mineral-cream-dirt-5",
["mineral-cream-dirt-5"] = "mineral-cream-dirt-6",
["mineral-cream-dirt-6"] = "mineral-cream-sand-1",
["mineral-cream-sand-1"] = "mineral-cream-sand-2",
["mineral-cream-sand-2"] = "mineral-cream-sand-3",
["mineral-cream-sand-3"] = "volcanic-orange-heat-1",
["mineral-dustyrose-dirt-1"] = "mineral-dustyrose-dirt-2",
["mineral-dustyrose-dirt-2"] = "mineral-dustyrose-dirt-3",
["mineral-dustyrose-dirt-3"] = "mineral-dustyrose-dirt-4",
["mineral-dustyrose-dirt-4"] = "mineral-dustyrose-dirt-5",
["mineral-dustyrose-dirt-5"] = "mineral-dustyrose-dirt-6",
["mineral-dustyrose-dirt-6"] = "mineral-dustyrose-sand-1",
["mineral-dustyrose-sand-1"] = "mineral-dustyrose-sand-2",
["mineral-dustyrose-sand-2"] = "mineral-dustyrose-sand-3",
["mineral-dustyrose-sand-3"] = "volcanic-orange-heat-1",
["mineral-grey-dirt-1"] = "mineral-grey-dirt-2",
["mineral-grey-dirt-2"] = "mineral-grey-dirt-3",
["mineral-grey-dirt-3"] = "mineral-grey-dirt-4",
["mineral-grey-dirt-4"] = "mineral-grey-dirt-5",
["mineral-grey-dirt-5"] = "mineral-grey-dirt-6",
["mineral-grey-dirt-6"] = "mineral-grey-sand-1",
["mineral-grey-sand-1"] = "mineral-grey-sand-2",
["mineral-grey-sand-2"] = "mineral-grey-sand-3",
["mineral-grey-sand-3"] = "volcanic-orange-heat-1",
["mineral-purple-dirt-1"] = "mineral-purple-dirt-2",
["mineral-purple-dirt-2"] = "mineral-purple-dirt-3",
["mineral-purple-dirt-3"] = "mineral-purple-dirt-4",
["mineral-purple-dirt-4"] = "mineral-purple-dirt-5",
["mineral-purple-dirt-5"] = "mineral-purple-dirt-6",
["mineral-purple-dirt-6"] = "mineral-purple-sand-1",
["mineral-purple-sand-1"] = "mineral-purple-sand-2",
["mineral-purple-sand-2"] = "mineral-purple-sand-3",
["mineral-purple-sand-3"] = "volcanic-orange-heat-1",
["mineral-red-dirt-1"] = "mineral-red-dirt-2",
["mineral-red-dirt-2"] = "mineral-red-dirt-3",
["mineral-red-dirt-3"] = "mineral-red-dirt-4",
["mineral-red-dirt-4"] = "mineral-red-dirt-5",
["mineral-red-dirt-5"] = "mineral-red-dirt-6",
["mineral-red-dirt-6"] = "mineral-red-sand-1",
["mineral-red-sand-1"] = "mineral-red-sand-2",
["mineral-red-sand-2"] = "mineral-red-sand-3",
["mineral-red-sand-3"] = "volcanic-orange-heat-1",
["mineral-tan-dirt-1"] = "mineral-tan-dirt-2",
["mineral-tan-dirt-2"] = "mineral-tan-dirt-3",
["mineral-tan-dirt-3"] = "mineral-tan-dirt-4",
["mineral-tan-dirt-4"] = "mineral-tan-dirt-5",
["mineral-tan-dirt-5"] = "mineral-tan-dirt-6",
["mineral-tan-dirt-6"] = "mineral-tan-sand-1",
["mineral-tan-sand-1"] = "mineral-tan-sand-2",
["mineral-tan-sand-2"] = "mineral-tan-sand-3",
["mineral-tan-sand-3"] = "volcanic-orange-heat-1",
["mineral-violet-dirt-1"] = "mineral-violet-dirt-2",
["mineral-violet-dirt-2"] = "mineral-violet-dirt-3",
["mineral-violet-dirt-3"] = "mineral-violet-dirt-4",
["mineral-violet-dirt-4"] = "mineral-violet-dirt-5",
["mineral-violet-dirt-5"] = "mineral-violet-dirt-6",
["mineral-violet-dirt-6"] = "mineral-violet-sand-1",
["mineral-violet-sand-1"] = "mineral-violet-sand-2",
["mineral-violet-sand-2"] = "mineral-violet-sand-3",
["mineral-violet-sand-3"] = "volcanic-orange-heat-1",
["mineral-white-dirt-1"] = "mineral-white-dirt-2",
["mineral-white-dirt-2"] = "mineral-white-dirt-3",
["mineral-white-dirt-3"] = "mineral-white-dirt-4",
["mineral-white-dirt-4"] = "mineral-white-dirt-5",
["mineral-white-dirt-5"] = "mineral-white-dirt-6",
["mineral-white-dirt-6"] = "mineral-white-sand-1",
["mineral-white-sand-1"] = "mineral-white-sand-2",
["mineral-white-sand-2"] = "mineral-white-sand-3",
["mineral-white-sand-3"] = "volcanic-orange-heat-1",
["vegetation-blue-grass-1"] = "vegetation-blue-grass-2",
["vegetation-blue-grass-2"] = "mineral-beige-dirt-1",
["vegetation-green-grass-1"] = "vegetation-green-grass-2",
["vegetation-green-grass-2"] = "vegetation-green-grass-3",
["vegetation-green-grass-3"] = "vegetation-green-grass-4",
["vegetation-green-grass-4"] = "mineral-beige-dirt-1",
["vegetation-mauve-grass-1"] = "vegetation-mauve-grass-2",
["vegetation-mauve-grass-2"] = "mineral-beige-dirt-1",
["vegetation-olive-grass-1"] = "vegetation-olive-grass-2",
["vegetation-olive-grass-2"] = "mineral-beige-dirt-1",
["vegetation-orange-grass-1"] = "vegetation-orange-grass-2",
["vegetation-orange-grass-2"] = "mineral-beige-dirt-1",
["vegetation-purple-grass-1"] = "vegetation-purple-grass-2",
["vegetation-purple-grass-2"] = "mineral-beige-dirt-1",
["vegetation-red-grass-1"] = "vegetation-red-grass-2",
["vegetation-red-grass-2"] = "mineral-beige-dirt-1",
["vegetation-turquoise-grass-1"] = "vegetation-turquoise-grass-2",
["vegetation-turquoise-grass-2"] = "mineral-beige-dirt-1",
["vegetation-violet-grass-1"] = "vegetation-violet-grass-2",
["vegetation-violet-grass-2"] = "mineral-beige-dirt-1",
["vegetation-yellow-grass-1"] = "vegetation-yellow-grass-2",
["vegetation-yellow-grass-2"] = "mineral-beige-dirt-1",
["volcanic-blue-heat-1"] = "volcanic-blue-heat-2",
["volcanic-blue-heat-2"] = "volcanic-blue-heat-3",
["volcanic-blue-heat-3"] = "volcanic-blue-heat-4",
["volcanic-blue-heat-4"] = "volcanic-orange-heat-1",
["volcanic-green-heat-1"] = "volcanic-green-heat-2",
["volcanic-green-heat-2"] = "volcanic-green-heat-3",
["volcanic-green-heat-3"] = "volcanic-green-heat-4",
["volcanic-green-heat-4"] = "volcanic-orange-heat-1",
["volcanic-orange-heat-1"] = "volcanic-orange-heat-2",
["volcanic-orange-heat-2"] = "volcanic-orange-heat-3",
["volcanic-orange-heat-3"] = "volcanic-orange-heat-4",
["volcanic-purple-heat-1"] = "volcanic-purple-heat-2",
["volcanic-purple-heat-2"] = "volcanic-purple-heat-3",
["volcanic-purple-heat-3"] = "volcanic-purple-heat-4",
["volcanic-purple-heat-4"] = "volcanic-orange-heat-1"

}


local replaceableTiles =
	{
	  -- vanilla
		["grass-1"] = "grass-3",
		["grass-3"] = "grass-2",
		["grass-2"] = "grass-4",
		["grass-4"] = "red-desert-0",
		["red-desert-0"] = "dirt-3",
		["dirt-3"] = "dirt-5",
		["dirt-5"] = "dirt-6",
		["dirt-6"] = "dirt-7",
		["dirt-7"] = "dirt-4",
		["dirt-4"] = "dry-dirt",
		["dry-dirt"] = "dirt-2",
		["dirt-2"] = "dirt-1",
		["dirt-1"] = "red-desert-2",
		["red-desert-2"] = "red-desert-3",
		["red-desert-3"] = "sand-3",
		["sand-3"] = "sand-2",
		["sand-2"] = "sand-1",
		["sand-1"] = "red-desert-1"

	}


local waterTiles =
{
  ["deepwater"] = true,
  ["deepwater-green"] = true,
  ["water"] = true,
  ["water-green"] = true,
  ["water-shallow"] = true,
  ["water-mud"] = true
  
}


-- Auto repair items
local autoRepairType = 
{
    ["straight-rail"] = true,
    ["curved-rail"] = true,
    ["rail-signal"] = true,
    ["rail-chain-signal"] = true
}


---- List of entities that will auto repair
local autoRepairName = 
{
    ["bi-big-wooden-pole"] = true,
	["bi-huge-wooden-pole"] = true,
}


-- List of Entities Types that can catch fire if destoyed
local catchFire = 
{
    ["furnace"] = true,
	["transport-belt"] = false,
	["boiler"] = false,
	["container"] = false,
	["electric-pole"] = false,
    ["generator"] = true,
    ["offshore-pump"] = true,
	["inserter"] = true,
	["radar"] = true,
	["lamp"] = false,
	["pipe-to-ground"] = false,
	["assembling-machine"] = true,
	["wall"] = false,
	["underground-belt"] = false,
	["loader"] = true,
	["splitter"] = false,
	["car"] = true,
	["solar-panel"] = true,
	["locomotive"] = true,
	["cargo-wagon"] = true,
	["fluid-wagon"] = true,
	["artillery-wagon"] = true,
	["gate"] = false,
	["lab"] = true,
	["rocket-silo"] = true,
	["roboport"] = true,
	["storage-tank"] = true,
	["pump"] = true,
	["market"] = true,
	["accumulator"] = true,
	["beacon"] = true,
	["mining-drill"] = true,
	["electric-turret"] = true,
	["ammo-turret"] = true,
	["turret"] = false,
	["straight-rail"] = false,
    ["curved-rail"] = false,
    ["rail-signal"] = false,
    ["rail-chain-signal"] = false,	
	["reactor"] = true	
}


-- Corpse Size = Fire Size
local corpseSize = 
{
    ["furnace"] = "medium-remnants",
	["transport-belt"] = "small-remnants",
	["boiler"] = "small-remnants",
	["container"] = "small-remnants",
	["electric-pole"] = "small-remnants",
    ["generator"] = "big-remnants",
    ["offshore-pump"] = "small-remnants",
	["inserter"] = "small-remnants",
	["radar"] = "big-remnants",
	["lamp"] = "small-remnants",
	["pipe-to-ground"] = "small-remnants",
	["assembling-machine"] = "big-remnants",
	["wall"] = "small-remnants",
	["underground-belt"] = "small-remnants",
	["loader"] = "small-remnants",
	["splitter"] = "medium-remnants",
	["car"] = "medium-remnants",
	["solar-panel"] = "big-remnants",
	["locomotive"] = "big-remnants",
	["cargo-wagon"] = "medium-remnants",
	["fluid-wagon"] = "medium-remnants",
	["artillery-wagon"] = "big-remnants",
	["gate"] = "small-remnants",
	["lab"] = "big-remnants",
	["rocket-silo"] = "big-remnants",
	["roboport"] = "big-remnants",
	["storage-tank"] = "medium-remnants",
	["pump"] = "small-remnants",
	["market"] = "big-remnants",
	["accumulator"] = "medium-remnants",
	["beacon"] = "big-remnants",
	["mining-drill"] = "big-remnants",
	["electric-turret"] = "big-remnants",
	["ammo-turret"] = "big-remnants",
	["turret"] = "big-remnants",
	["straight-rail"] = "small-remnants",
    ["curved-rail"] = "small-remnants",
    ["rail-signal"] = "small-remnants",
    ["rail-chain-signal"] = "small-remnants",
	["reactor"] = "big-remnants"
}


--------- Achievements 
function Achievements_Init()
 
	-- Enemy Counts
	--- Biters
	if not global.Breeder_Biter_Count then
		global.Breeder_Biter_Count = 0
	end

	if not global.Fire_Biter_Count then
		global.Fire_Biter_Count = 0
	end

	if not global.Fast_Biter_Count then
		global.Fast_Biter_Count = 0
	end	

	if not global.Wallbreaker_Biter_Count then
		global.Wallbreaker_Biter_Count = 0
	end		

	if not global.Tank_Biter_Count then
		global.Tank_Biter_Count = 0
	end	

	--- Spitters
	if not global.Breeder_Spitter_Count then
		global.Breeder_Spitter_Count = 0
	end	
	
	if not global.Fire_Spitter_Count then
		global.Fire_Spitter_Count = 0
	end	
	
	if not global.Ulaunch_Spitter_Count then
		global.Ulaunch_Spitter_Count = 0
	end	
	
	if not global.Webshooter_Spitter_Count then
		global.Webshooter_Spitter_Count = 0
	end	
	
	if not global.Mine_Spitter_Count then
		global.Mine_Spitter_Count = 0
	end	
	
	
	--- Spawners
	if not global.Blue_Spawner_Count then
		global.Blue_Spawner_Count = 0
	end	
	
	if not global.Red_Spawner_Count then
		global.Blue_Spawner_Count = 0
	end		
	
	if not global.Green_Spawner_Count then
		global.Blue_Spawner_Count = 0
	end		
		
	if not global.Yellow_Spawner_Count then
		global.Blue_Spawner_Count = 0
	end		
		
	if not global.Pink_Spawner_Count then
		global.Blue_Spawner_Count = 0
	end		
	


end


---- Expansion Initialization ----
function Expansion_Initialization()
	
	local enemy_expansion = game.map_settings.enemy_expansion		
	
	if not global.max_expansion_distance_NE then
		global.max_expansion_distance_NE = enemy_expansion.max_expansion_distance -- Vanilla 7
	end

	if not global.friendly_base_influence_radius_NE then
		global.friendly_base_influence_radius_NE = enemy_expansion.friendly_base_influence_radius -- Vanilla 2
	end
	
	if not global.enemy_building_influence_radius_NE then
		global.enemy_building_influence_radius_NE = enemy_expansion.enemy_building_influence_radius -- Vanilla 2
	end
	
	if not global.settler_Group_min_size_NE then
		global.settler_Group_min_size_NE = enemy_expansion.settler_group_min_size -- Vanilla 5
	end
	
	if not global.settler_Group_max_size_NE then
		global.settler_Group_max_size_NE = enemy_expansion.settler_group_max_size -- Vanilla 20
	end

	if not global.building_coefficient_NE then
		global.building_coefficient_NE = enemy_expansion.building_coefficient -- vanilla 0.1
	end
	
	if not global.other_base_coefficient_NE then
		global.other_base_coefficient_NE = enemy_expansion.other_base_coefficient -- vanilla 2.0
	end
	
	if not global.neighbouring_chunk_coefficient_NE then
		global.neighbouring_chunk_coefficient_NE = enemy_expansion.neighbouring_chunk_coefficient -- vanilla 0.5
	end
	
	if not global.neighbouring_base_chunk_coefficient_NE then
		global.neighbouring_base_chunk_coefficient_NE = enemy_expansion.neighbouring_base_chunk_coefficient -- vanilla 0.4	
	end
	
	local unit_group = game.map_settings.unit_group	
	if not global.min_Group_radius_NE then
		global.min_Group_radius_NE = unit_group.min_group_radius -- Vanilla 5		
	end	
	
	if not global.max_Group_radius_NE then
		global.max_Group_radius_NE = unit_group.max_group_radius -- Vanilla 30
	end

	if not global.max_Speed_up_NE then
		global.max_Speed_up_NE = unit_group.max_member_speedup_when_behind -- Vanilla 1.4
	end
	
	local path_finder = game.map_settings.path_finder	
	if not global.max_Steps_NE then
		global.max_Steps_NE = path_finder.max_steps_worked_per_tick -- Vanilla 100
	end

end	

---------------------------------------------				 
local function On_Init()

	--- Set Initial Evolution Factor
	if NE_Enemies.Settings.NE_Starting_Evolution then
		
		game.forces.enemy.evolution_factor = (NE_Enemies.Settings.NE_Starting_Evolution / 100)
		if game.forces.enemy.evolution_factor > 1 then
			game.forces.enemy.evolution_factor = 1
		end
		
	end

	--- Used for Unit Turrets
	if not global.tick then
		global.tick = game.tick
	end
	
	if not global.evoFactorFloor then
		if game.forces.enemy.evolution_factor > 0.995 then
			global.evoFactorFloor = 10
		else
			global.evoFactorFloor = math.floor(game.forces.enemy.evolution_factor * 10)
		end
		global.tick = global.tick + 1800
	end
	
	---- Used for Cliff Explosion Trigger
	global.cliff_explosive = {} 
	global.cliff_explosive["ground-explosion"] = "ground-explosion"

	--- Used for Mine Laying attackes
	if global.deployed_mine == nil then
		global.deployed_mine = {} 
	end

		--- Total Spawner Counter
	if global.Total_Number_of_Spawners_Killed == nil then
		global.Total_Number_of_Spawners_Killed = 0 
	end

		--- Spawner Counter
	if global.Recent_Number_of_Spawners_Killed == nil then
		global.Recent_Number_of_Spawners_Killed = 0 
	end

		--- Tech Level counter
	if global.tech_level == nil then
		global.tech_level = 0 
	end	

	--- Number of Rocket Silos
	if global.number_or_rocketsilos == nil then
		global.number_or_rocketsilos = 0
	end

	--- Rocket Silos
	if global.rocketsilos == nil then
		global.rocketsilos = {}
	end
	
	
	
	--- Expansion Initialization ----
	Expansion_Initialization()
	
	--------- Achievements -- 
	Achievements_Init()

	
	--------
	if QC_Mod then
		---*************
		--local surface = game.surfaces['nauvis']
		Test_Spawn()
		---*************
	end
	
	
end

---------------------------------------------				 
local function On_Config_Change()

	
	--- Used for Unit Turrets
	if not global.tick then
		global.tick = game.tick
	end
	
	if not global.evoFactorFloor then
		if game.forces.enemy.evolution_factor > 0.995 then
			global.evoFactorFloor = 10
		else
			global.evoFactorFloor = math.floor(game.forces.enemy.evolution_factor * 10)
		end
		global.tick = global.tick + 1800
	end
	

	
	---- Used for Cliff Explosion Trigger
	global.cliff_explosive = {} 
	global.cliff_explosive["ground-explosion"] = "ground-explosion"

	--- Used for Mine Laying attackes
	if global.deployed_mine == nil then
		global.deployed_mine = {} 
	end

		--- Total Spawner Counter
	if global.Total_Number_of_Spawners_Killed == nil then
		global.Total_Number_of_Spawners_Killed = 0 
	end

		--- Spawner Counter
	if global.Recent_Number_of_Spawners_Killed == nil then
		global.Recent_Number_of_Spawners_Killed = 0 
	end

		--- Tech Level counter
	if global.tech_level == nil then
		global.tech_level = 0 
	end	

	--- Number of Rocket Silos
	if global.number_or_rocketsilos == nil then
		global.number_or_rocketsilos = 0
	end

	--- Rocket Silos
	if global.rocketsilos == nil then
		global.rocketsilos = {}
	end

		
	--- Expansion Initialization ----
	Expansion_Initialization()
	
	--------- Achievements -- 
	Achievements_Init()
	

	
	-- enable researched recipes
	for i, force in pairs(game.forces) do
		for _, tech in pairs(force.technologies) do
			if tech.researched then
				for _, effect in pairs(tech.effects) do
					if effect.type == "unlock-recipe" then          
						force.recipes[effect.recipe].enabled = true
					end
				end
			end
		end
	end
	
end

---------------------------------------------				 
local function Look_and_Attack(entity, factor)

		local surface = entity.surface
		local force = entity.force
		local radius = 15 * NE_Enemies.Settings.NE_Difficulty
		local pos = entity.position
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}	
		local attack_chance = math.random(100) + (6 - NE_Enemies.Settings.NE_Difficulty)

		------writeDebug("Attack Chance: "..attack_chance)
		------writeDebug("Evo Factor: "..math.floor(game.forces.enemy.evolution_factor*100))
		
		if attack_chance < math.floor(game.forces.enemy.evolution_factor * 100) then
			-- find nearby players
			local players = surface.find_entities_filtered{area=area, type="player"}
			local s_radius = math.floor((100 * math.floor(game.forces.enemy.evolution_factor * 10) + 600 * NE_Enemies.Settings.NE_Difficulty) * factor)
			local nr_counts = math.floor((2 * NE_Enemies.Settings.NE_Difficulty + math.floor(game.forces.enemy.evolution_factor * 30)) * factor)
			----writeDebug("Search Radius is: ".. s_radius)
			----writeDebug("Number of units is: ".. nr_counts)
				-- send attacks to all nearby players
				for i,player in pairs(players) do
					player.surface.set_multi_command{command = {type=defines.command.attack, target=player, distraction=defines.distraction.by_enemy},unit_count = nr_counts, unit_search_distance = s_radius}
				end
		end
		
end

---------------------------------------------				 
local function Look_and_Burn(entity, radius)


		local surface = entity.surface
		local force = entity.force
		local radius = radius
		local pos = entity.position
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}	
		local items = {}
		local items = surface.find_entities_filtered({area = area, name = "item-on-ground"})
		
		--writeDebug("# of Items on ground found: ".. #items)
		if (#items > 0) and settings.startup["NE_Challenge_Mode"].value then
	
			for i,item in pairs(items) do
				if item and item.valid then
					item.destroy()
				end
			end		
		end		
end

---------------------------------------------				 
local function Remove_Decal(surface, pos, radius, limit)

		--game.print("Decal Script running")
		local radius = radius
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}			
		surface.destroy_decoratives{area = area, type = "optimized-decorative", limit = limit}
			
end

--- Remove Trees
local function Remove_Trees(entity)

		local surface = entity.surface
		local radius = 1.5
		local pos = entity.position
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}	
		-- find nearby trees
		local trees = {}
		local trees = surface.find_entities_filtered{area = area, type = "tree"}
		-- Remove Trees
		if #trees > 0 then
		----writeDebug("Tree Found")
			for i,tree in pairs(trees) do
				if tree and tree.valid then
					tree.die()
				end
			end
		end
end

--------------------------------------------------------------------
local function On_Built(event)

    local entity = event.created_entity
   	local surface = entity.surface
	local force = entity.force
	local position = entity.position
   
   
   --- If you build a rocket silo, the tech levle rises.
    if entity.valid and  entity.type == "rocket-silo" and settings.startup["NE_Challenge_Mode"].value then
    ----writeDebug("Tech Level: "..global.tech_level)
    
		global.tech_level = global.tech_level + 1000
		global.number_or_rocketsilos = global.number_or_rocketsilos + 1
		----writeDebug("Number of Rocket Silos: "..global.number_or_rocketsilos)
		--- Add silo to table
		global.rocketsilos[entity.unit_number] = {silo=entity}

		
		-- Biters will attack the newly built Rocket Silo
		if not settings.startup["NE_Remove_Biter_Search"].value then
			surface.set_multi_command{command = {type=defines.command.attack, target=entity, distraction=defines.distraction.by_enemy},unit_count = math.floor(4000 * game.forces.enemy.evolution_factor), unit_search_distance = 2500 * NE_Enemies.Settings.NE_Difficulty}
		end
		
    end 
	
end

---------------------------------------------
local function On_Remove(event)
		
	local entity = event.entity		
   	local surface = entity.surface
	local force = entity.force
	local position = entity.position
 	

   ------writeDebug("Tech Level: "..global.tech_level)
   --- If you remove a rocket silo, the tech levle lowers again.
    if entity.valid and  entity.type == "rocket-silo" and settings.startup["NE_Challenge_Mode"].value then
        
		global.tech_level = global.tech_level - 1000
		if global.tech_level <= 0 then global.tech_level = 0 end
		global.number_or_rocketsilos = global.number_or_rocketsilos - 1
		if global.number_or_rocketsilos <= 0 then global.number_or_rocketsilos = 0 end
		
		--- Remove silo from table
		if global.rocketsilos[entity.unit_number] then
			global.rocketsilos[entity.unit_number] = nil
		end

    end 
	
	------writeDebug("Tech Level: "..global.tech_level)
	
	--------- Did you really just kill that tree...
	if entity.valid and settings.startup["NE_Challenge_Mode"].value and (entity.type == "tree") then 

		----writeDebug("Tree Mined")
		----writeDebug("Tech_level: "..global.tech_level)
		Look_and_Attack(entity, 1)
		
		---- Sometimes there are small biters in trees...
		local spawn_chance = math.random(420 - (20 * NE_Enemies.Settings.NE_Difficulty))
		
		if spawn_chance < math.floor(game.forces.enemy.evolution_factor * 100) then
			local monkey_lvl = math.floor(game.forces.enemy.evolution_factor * 10)
			--writeDebug("Evo Factor Lvl: "..monkey_lvl)
			if monkey_lvl <= 1 then monkey_lvl = 1 end
			local tree_monkey_name = "ne-biter-breeder-"..monkey_lvl
			--writeDebug("Tree Monkey Name: "..tree_monkey_name)
		    --- Spawn Monkey
			local tree_monkey = surface.create_entity({name=tree_monkey_name, position=entity.position, force = game.forces.enemy})	
		end
	end


end


--- Check if the entity was a spawner
function isSpawner(enemy)
	if enemy.type == "unit-spawner" then
		return 2
	else
		return 0
	end
end


--[[
--- Return Class
function UnitClass(entity)
	_, _, mod, spiecies,  class, number = string.find(entity.name, "(%a+)-(%a+)-(%a+)-(%d+)")
	return class
end
]]

--- Count Killed NE Unit
local function NE_Unit_Count(entity)
	
	--- Biters
	if string.find(entity.name, "ne%-biter%-breeder%-") then
		global.Breeder_Biter_Count = global.Breeder_Biter_Count + 1
	elseif string.find(entity.name, "ne%-biter%-fire%-") then
		global.Fire_Biter_Count = global.Fire_Biter_Count + 1
	elseif string.find(entity.name, "ne%-biter%-fast%-") then	
		global.Fast_Biter_Count = global.Fast_Biter_Count + 1
	elseif string.find(entity.name, "ne%-biter%-fastL%-") then	-- Launched units
		global.Fast_Biter_Count = global.Fast_Biter_Count + 1
	elseif string.find(entity.name, "ne%-biter%-wallbreaker%-") then	
		global.Wallbreaker_Biter_Count = global.Wallbreaker_Biter_Count + 1
	elseif string.find(entity.name, "ne%-biter%-tank%-") then	
		global.Tank_Biter_Count = global.Tank_Biter_Count + 1
	-- Spitters
	elseif string.find(entity.name, "ne%-spitter%-breeder%-") then	
		global.Breeder_Spitter_Count = global.Breeder_Spitter_Count + 1
	elseif string.find(entity.name, "ne%-spitter%-fire%-") then		
		global.Fire_Spitter_Count = global.Fire_Spitter_Count + 1
	elseif string.find(entity.name, "ne%-spitter%-ulaunch%-") then		
		global.Ulaunch_Spitter_Count = global.Ulaunch_Spitter_Count + 1
	elseif string.find(entity.name, "ne%-spitter%-webshooter%-") then		
		global.Webshooter_Spitter_Count = global.Webshooter_Spitter_Count + 1
	elseif string.find(entity.name, "ne%-spitter%-mine%-") then		
		global.Mine_Spitter_Count = global.Mine_Spitter_Count + 1
	end
	
end


--- Check for Fire Biter
function isFireBiter(entity)
	return (string.find(entity.name, "ne%-biter%-fire%-") or string.find(entity.name, "ne%-spitter%-fire%-"))
end


--- Check for Breeder Biter
function isBreeder(entity)
	return (string.find(entity.name, "ne%-biter%-breeder%-") or string.find(entity.name, "ne%-spitter%-breeder%-"))
end


--- Return Unit#
function UnitNumber(entity)
	_, _, mod, spiecies,  class, number = string.find(entity.name, "(%a+)-(%a+)-(%a+)-(%d+)")
	return number
end

--- Return Spiecies
function UnitSpiecies(entity)
	_, _, mod, spiecies,  class, number = string.find(entity.name, "(%a+)-(%a+)-(%a+)-(%d+)")
	return spiecies
end


--- Return NE Land mine 
function NELandmine(entity)	
--"ne-spitter-land-mine-"..i
	_, _, ne, spiecies, land, mine, number = string.find(entity.name, "(%a+)-(%a+)-(%a+)-(%a+)-(%d+)")
	if land and mine then
		return land..mine
	end
end


---- Spawn Babies from Breeders Units
function SpawnBreederBabies(entity)
	
	local NumberOfBabies = math.floor(math.floor(UnitNumber(entity)) + math.floor(math.sqrt(UnitNumber(entity))) + math.floor(NE_Enemies.Settings.NE_Difficulty * 2)) / 3  -- Number of Babies, 3 to 8 at level 20 on Diff 1 and 5 to 11 at level 20 on Diff 5
	local BabyLvl = math.floor(math.sqrt((UnitNumber(entity)) * 2) + (NE_Enemies.Settings.NE_Difficulty / 3)) -- Baby Level, 4 to 9 at level 20 on Diff 1 and 6 to 10 at level 20 on Diff 5
	local BabyName
	
	if BabyLvl <= 0 then BabyLvl = 1 end
	if UnitSpiecies(entity) then
		BabyName = "ne-"..UnitSpiecies(entity).."-breeder-"..BabyLvl
	else
		BabyName = "ne-biter-breeder-"..BabyLvl
	end
	
	------writeDebug(BabyName)
	------writeDebug(BabyLvl)
	
	--- Only start breeding at Lvl 5 & if there are 10 or less units in the area. - Prevents over-crowding...
	local radius = 12
	local pos = entity.position	
	local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}
	local unit_names = {"ne-biter-breeder-1", "ne-biter-breeder-2", "ne-biter-breeder-3", "ne-biter-breeder-4", "ne-biter-breeder-5", "ne-biter-breeder-6", "ne-biter-breeder-7", "ne-biter-breeder-8", "ne-biter-breeder-9", "ne-biter-breeder-10", "ne-biter-breeder-11", "ne-biter-breeder-12", "ne-biter-breeder-13", "ne-biter-breeder-14", "ne-biter-breeder-15", "ne-biter-breeder-16", "ne-biter-breeder-17", "ne-biter-breeder-18", "ne-biter-breeder-19", "ne-biter-breeder-20", "ne-spitter-breeder-1", "ne-spitter-breeder-2", "ne-spitter-breeder-3", "ne-spitter-breeder-4", "ne-spitter-breeder-5", "ne-spitter-breeder-6", "ne-spitter-breeder-7", "ne-spitter-breeder-8", "ne-spitter-breeder-9", "ne-spitter-breeder-10", "ne-spitter-breeder-11", "ne-spitter-breeder-12", "ne-spitter-breeder-13", "ne-spitter-breeder-14", "ne-spitter-breeder-15", "ne-spitter-breeder-16", "ne-spitter-breeder-17", "ne-spitter-breeder-18", "ne-spitter-breeder-19", "ne-spitter-breeder-20"} 
	local blue_units = entity.surface.count_entities_filtered{area=area, name=unit_names}
		
	--writeDebug("Blue Unit count is: "..blue_units)

	
	if math.floor(UnitNumber(entity)) >= 5 and blue_units <= (9 + NE_Enemies.Settings.NE_Difficulty) then 
		for i = 1, NumberOfBabies do
			local PositionValid = entity.surface.find_non_colliding_position(BabyName, entity.position, 4 , 0.5)
			if PositionValid then
				spawn_unit = entity.surface.create_entity({name = BabyName, position = PositionValid, force = entity.force})
				--- Remove trees around mines, to prevent units from getting stuck
				Remove_Trees(spawn_unit)
			end
		end
	end
	
end


---- Spawn Babies from Breeders Spawners
function SpawnBreederBabies_Spawner(entity)
	
	local NumberOfBabies = math.floor(2 * NE_Enemies.Settings.NE_Difficulty + math.floor(game.forces.enemy.evolution_factor * 30))
	local BabyNumber = math.floor(NE_Enemies.Settings.NE_Difficulty + math.floor(game.forces.enemy.evolution_factor * 10))
	
	if BabyNumber <= 0 then BabyNumber = 1 end
	local BabyName = "ne-biter-breeder-"..BabyNumber
	
	-- No spawn for first 5% of Evo & if there are 15 or less units in the area. - Prevents over-crowding...
	local radius = 8
	local pos = entity.position	
	local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}
	local unit_names = {"ne-biter-breeder-1", "ne-biter-breeder-2", "ne-biter-breeder-3", "ne-biter-breeder-4", "ne-biter-breeder-5", "ne-biter-breeder-6", "ne-biter-breeder-7", "ne-biter-breeder-8", "ne-biter-breeder-9", "ne-biter-breeder-10", "ne-biter-breeder-11", "ne-biter-breeder-12", "ne-biter-breeder-13", "ne-biter-breeder-14", "ne-biter-breeder-15", "ne-biter-breeder-16", "ne-biter-breeder-17", "ne-biter-breeder-18", "ne-biter-breeder-19", "ne-biter-breeder-20", "ne-spitter-breeder-1", "ne-spitter-breeder-2", "ne-spitter-breeder-3", "ne-spitter-breeder-4", "ne-spitter-breeder-5", "ne-spitter-breeder-6", "ne-spitter-breeder-7", "ne-spitter-breeder-8", "ne-spitter-breeder-9", "ne-spitter-breeder-10", "ne-spitter-breeder-11", "ne-spitter-breeder-12", "ne-spitter-breeder-13", "ne-spitter-breeder-14", "ne-spitter-breeder-15", "ne-spitter-breeder-16", "ne-spitter-breeder-17", "ne-spitter-breeder-18", "ne-spitter-breeder-19", "ne-spitter-breeder-20"} 
	local blue_units = entity.surface.count_entities_filtered{area=area, name=unit_names}
		
	--writeDebug("Blue Unit count is: "..blue_units)
	
	if math.floor(game.forces.enemy.evolution_factor * 10) >= 5 and blue_units <= (14 + NE_Enemies.Settings.NE_Difficulty) then 
		for i = 1, NumberOfBabies do
			local PositionValid = entity.surface.find_non_colliding_position(BabyName, entity.position, 8 , 0.5)
			if PositionValid then
				spawn_unit = entity.surface.create_entity({name = BabyName, position = PositionValid, force = entity.force})
				Remove_Trees(spawn_unit)
			end
		end
	end
	
end


-----------------------

function Achievement_Check()

	----writeDebug("Achievement Check Pont")
	---- Unit Kill Check
	if (global.Breeder_Biter_Count >=100 and
		global.Fire_Biter_Count  >=100 and
		global.Fast_Biter_Count  >=100 and
		global.Wallbreaker_Biter_Count  >=100 and
		global.Tank_Biter_Count  >=100 and
		global.Breeder_Spitter_Count  >=100 and
		global.Fire_Spitter_Count  >=100 and
		global.Ulaunch_Spitter_Count  >=100 and
		global.Webshooter_Spitter_Count  >=100 and
		global.Mine_Spitter_Count  >=100) then
		----writeDebug("Achievement #1 PASSED")
		for index, player in pairs(game.players) do --give the achievement to every player
			player.unlock_achievement("killed-all-NE-1")
		end
	elseif (global.Breeder_Biter_Count >=10000 and
		global.Fire_Biter_Count  >=10000 and
		global.Fast_Biter_Count  >=10000 and
		global.Wallbreaker_Biter_Count  >=10000 and
		global.Tank_Biter_Count  >=10000 and
		global.Breeder_Spitter_Count  >=10000 and
		global.Fire_Spitter_Count  >=10000 and
		global.Ulaunch_Spitter_Count  >=10000 and
		global.Webshooter_Spitter_Count  >=10000 and
		global.Mine_Spitter_Count  >=10000) then
		----writeDebug("Achievement #2 PASSED")
		for index, player in pairs(game.players) do --give the achievement to every player
			player.unlock_achievement("killed-all-NE-2")
		end
	elseif (global.Breeder_Biter_Count >=100000 and
		global.Fire_Biter_Count  >=100000 and
		global.Fast_Biter_Count  >=100000 and
		global.Wallbreaker_Biter_Count  >=100000 and
		global.Tank_Biter_Count  >=100000 and
		global.Breeder_Spitter_Count  >=100000 and
		global.Fire_Spitter_Count  >=100000 and
		global.Ulaunch_Spitter_Count  >=100000 and
		global.Webshooter_Spitter_Count  >=100000 and
		global.Mine_Spitter_Count  >=100000) then
		----writeDebug("Achievement #3 PASSED")
		for index, player in pairs(game.players) do --give the achievement to every player
			player.unlock_achievement("killed-all-NE-3")
		end
	else
		----writeDebug("Achievement-Unique FAIL")
	end

	---- Total Count Achievement
	if (global.Breeder_Biter_Count +
		global.Fire_Biter_Count +
		global.Fast_Biter_Count +
		global.Wallbreaker_Biter_Count +
		global.Tank_Biter_Count +
		global.Breeder_Spitter_Count +
		global.Fire_Spitter_Count +
		global.Ulaunch_Spitter_Count +
		global.Webshooter_Spitter_Count +
		global.Mine_Spitter_Count) >= 10000 then
		----writeDebug("Achievement #4 PASSED")
		for index, player in pairs(game.players) do --give the achievement to every player
			player.unlock_achievement("killed-total-NE-1")
		end
	elseif (global.Breeder_Biter_Count +
		global.Fire_Biter_Count +
		global.Fast_Biter_Count +
		global.Wallbreaker_Biter_Count +
		global.Tank_Biter_Count +
		global.Breeder_Spitter_Count +
		global.Fire_Spitter_Count +
		global.Ulaunch_Spitter_Count +
		global.Webshooter_Spitter_Count +
		global.Mine_Spitter_Count) >= 100000 then
		----writeDebug("Achievement #5 PASSED")
		for index, player in pairs(game.players) do --give the achievement to every player
			player.unlock_achievement("killed-total-NE-2")
		end
	elseif (global.Breeder_Biter_Count +
		global.Fire_Biter_Count +
		global.Fast_Biter_Count +
		global.Wallbreaker_Biter_Count +
		global.Tank_Biter_Count +
		global.Breeder_Spitter_Count +
		global.Fire_Spitter_Count +
		global.Ulaunch_Spitter_Count +
		global.Webshooter_Spitter_Count +
		global.Mine_Spitter_Count) >= 1000000 then
		----writeDebug("Achievement #6 PASSED")
		for index, player in pairs(game.players) do --give the achievement to every player
			player.unlock_achievement("killed-total-NE-3")
		end
	else
		----writeDebug("Achievement-Total FAIL")
	end	
	
end

--[[
function check_kill_count()

  
	function isBiter_Breeder(entity)
		return string.find(entity, "ne%-biter%-breeder%-")
	end

		
		for entity_name, kill_count in pairs(game.forces.player.kill_count_statistics.input_counts) do
	  
			----writeDebug("Entity Name: "..entity_name)
			----writeDebug("Kill Count: "..kill_count)	
			--for 1 to kill_count do
			for i = 1, kill_count do
				if isBiter_Breeder(entity_name) then
					global.Breeder_Biter_Count = global.Breeder_Biter_Count + 1
					----writeDebug("The Number of Breeders Killed is: "..global.Breeder_Biter_Count)	
				end
			end
			
			
		end 

end
]]


---------------------------------------------
local function On_Death(event)


	local entity = event.entity	
	local surface = entity.surface
	local force = entity.force	
	local pos = entity.position


   ------writeDebug("Tech Level: "..global.tech_level)
   --- If you remove a rocket silo, the tech levle lowers again.
    if entity.valid and  entity.type == "rocket-silo" and settings.startup["NE_Challenge_Mode"].value then
       
    	global.tech_level = global.tech_level - 1000
		if global.tech_level <= 0 then global.tech_level = 0 end
		global.number_or_rocketsilos = global.number_or_rocketsilos + 1
		if global.number_or_rocketsilos <= 0 then global.number_or_rocketsilos = 0 end
		
		--- Remove silo from table
		if global.rocketsilos[entity.unit_number] then
			global.rocketsilos[entity.unit_number] = nil
		end
		
    end 
	
	--- Unit Launcher Mine Detinated 
    if entity.valid and NELandmine(entity)  == "landmine" then
		------writeDebug("Land Mine has been Detinated")
		if global.deployed_mine[entity.unit_number] then	
			global.deployed_mine[entity.unit_number] = nil
		end

    end
	
	--- Spawn Breeder Units
	if isBreeder(entity) and entity.type == "unit" and UnitNumber(entity) ~= nil then
		------writeDebug("Was a Breeder")
		SpawnBreederBabies(entity)
	end

	
	if isFireBiter(entity) and entity.type == "unit" and UnitNumber(entity) ~= nil then
	
	
	------writeDebug("Fire Unit killed")
		if math.floor(UnitNumber(entity)) < 5 then
		
			local spawn_fire = surface.create_entity({name="ne-fire-flame-0", position = pos, force = "enemy"})		
			--writeDebug("Smaller than 5")
			Look_and_Burn(spawn_fire, 0.25)
			
		elseif math.floor(UnitNumber(entity)) < 10 then
			local spawn_fire = surface.create_entity({name="ne-fire-flame-1", position = pos, force = "enemy"})
			--writeDebug("Smaller than 10")			
			Look_and_Burn(spawn_fire, 0.25)
			
		elseif math.floor(UnitNumber(entity)) < 15 then
			local spawn_fire = surface.create_entity({name="ne-fire-flame-2", position = pos, force = "enemy"})
			--writeDebug("Smaller than 15")
			Look_and_Burn(spawn_fire, 0.375)
			
		else
			local spawn_fire = surface.create_entity({name="ne-fire-flame-3", position = pos, force = "enemy"})
			--writeDebug("Bigger than 15")
			Look_and_Burn(spawn_fire, 0.5)
		end
		
	end

	
	--- Buildings catch fire if destroyed.
	if entity.valid and settings.startup["NE_Burning_Buildings"].value and catchFire[entity.type] then

		local e_corpse = corpseSize[entity.type]
		
		----writeDebug("Corpse Size: "..e_corpse)
		if (force == game.forces.enemy) then
		-- do nothing
		elseif e_corpse == "medium-remnants" then
			surface.create_entity({name="ne-fire-flame-2", position = pos, force = "enemy"})
		elseif e_corpse == "big-remnants" then
			surface.create_entity({name="ne-fire-flame-3", position = pos, force = "enemy"})
		else
			surface.create_entity({name="ne-fire-flame-1", position = pos, force = "enemy"})
		end	
		
	end	

	
 	--------- If you kill a spawner, enemies will attach you.
	if entity.valid and (entity.type == "unit-spawner") then
		if entity.force == game.forces.enemy then

			----writeDebug("Enemy Spawner Killed")
		
			global.Total_Number_of_Spawners_Killed = global.Total_Number_of_Spawners_Killed + 1
			global.Recent_Number_of_Spawners_Killed = global.Recent_Number_of_Spawners_Killed + 1

			
			--- First 20 nests are free of danger
			if settings.startup["NE_Challenge_Mode"].value and global.Total_Number_of_Spawners_Killed > (21 - NE_Enemies.Settings.NE_Difficulty) then 
				Spawn_Megalodon(event, entity)
			end
			
			Look_and_Attack(entity, 1.5)

			--- Spawn Breeder Units
			if entity.name == "ne-spawner-blue" then
				----writeDebug("Was a Breeder Spawner")
				SpawnBreederBabies_Spawner(entity)
			end
			
			--- Cause Fire		
			if entity.name == "ne-spawner-red" then		
				----writeDebug("Was a Fire Spawner")
					local size = 3
					for xxx = -size, size do
					for yyy = -size, size do

					local new_position = {x = pos.x + xxx,y = pos.y + yyy}
				
				
						surface.create_entity({name="ne-fire-flame-3", position = new_position, force = "enemy"})
					end
					end

			end
			
			if settings.startup["NE_Scorched_Earth"].value then
				Scorched_Earth(surface, pos, 6)		
			end
			
			
			
		else
			----writeDebug("Friendly Spawner")
			
		end
	
	end

	
	--------- An Enemy Unit Died
	if entity.valid and entity.force == game.forces.enemy and (entity.type == "unit") and event.force ~= nil and event.cause then--and event.cause.name == "character" then
	
	--- add to the NE unit counter
	NE_Unit_Count(entity)
	
		if settings.startup["NE_Scorched_Earth"].value then
			Scorched_Earth(surface, pos, 2)		
		end
		
	end
	
 	--------- Did you really just kill that tree...
	if entity.valid and settings.startup["NE_Challenge_Mode"].value and (entity.type == "tree") and event.force ~= nil and event.cause and event.cause.name == "character" then
		
		----writeDebug("a Tree was Killed")
		Look_and_Attack(entity, 0.5)
		
		---- Sometimes there are small biters in trees...
		local spawn_chance = math.random(620 - (20 * NE_Enemies.Settings.NE_Difficulty))
		
		if spawn_chance < math.floor(game.forces.enemy.evolution_factor * 100) then
			local tree_monkey = surface.create_entity({name="ne-biter-breeder-1", position=entity.position, force = game.forces.enemy})	
		end
		
	end
	
		
    -- auto repair things like rails, and signals. Also by destroying the entity the enemy retargets.
    if entity.valid and (event.force == game.forces.enemy) and (autoRepairType[entity.type] or autoRepairName[entity.name]) then

        local repairPosition = entity.position
        local repairName = entity.name
        local repairForce = entity.force
        local repairDirection = entity.direction
		local wires
		
		if (entity.type == "electric-pole") then
			wires = entity.neighbours
		end
		
        entity.destroy()
        local entityRepaired = surface.create_entity({position=repairPosition,
                                                               name=repairName,
                                                               direction=repairDirection,
                                                               force=repairForce})
															   

		if wires then
			for connectType,neighbourGroup in pairs(wires) do
				if connectType == "copper" then
				for _,v in pairs(neighbourGroup) do
					entityRepaired.connect_neighbour(v);
				end
				elseif connectType == "red" then
				for _,v in pairs(neighbourGroup) do
					entityRepaired.connect_neighbour({wire = defines.wire_type.red, target_entity = v});
				end
				elseif connectType == "green" then
				for _,v in pairs(neighbourGroup) do
					entityRepaired.connect_neighbour({wire = defines.wire_type.green, target_entity = v});
				end
				end
			end
		end
		
		
        local enemies = surface.find_entities_filtered({area = {{x=repairPosition.x-20, y=repairPosition.y-20},
                                                                         {x=repairPosition.x+20, y=repairPosition.y+20}},
                                                                 type = "unit",
																force = game.forces.enemy})    
																
        for i=1, #enemies do
            local enemy = enemies[i]
            enemy.set_command({type=defines.command.wander,
                               distraction=defines.distraction.by_enemy})
        end
    end

	

end


--------------------------------------------
function Natural_Evolution_Expansion_Settings()

		---- Expansion Initialization ----	
		
	local enemy_expansion = game.map_settings.enemy_expansion
	local unit_group = game.map_settings.unit_group
	local path_finder = game.map_settings.path_finder
	
	local NE_multiplier_plus = ((game.forces.enemy.evolution_factor * 100) + 50) / (77 - NE_Enemies.Settings.NE_Difficulty * 2)	
	local NE_multiplier_minus = (((1 - game.forces.enemy.evolution_factor) * 100 ) + 50) / (73 + NE_Enemies.Settings.NE_Difficulty * 2)

	
	-----

	enemy_expansion.max_expansion_distance = global.max_expansion_distance_NE * NE_multiplier_plus
	-- limit Expansion distance to always we 20 or less. https://forums.factorio.com/viewtopic.php?f=23&t=64381
	if enemy_expansion.max_expansion_distance > 20 then
		enemy_expansion.max_expansion_distance = 20
	end
	
	
	enemy_expansion.friendly_base_influence_radius = global.friendly_base_influence_radius_NE * NE_multiplier_minus 
	enemy_expansion.enemy_building_influence_radius = global.enemy_building_influence_radius_NE * NE_multiplier_minus
	enemy_expansion.building_coefficient = global.building_coefficient_NE * NE_multiplier_minus
	enemy_expansion.other_base_coefficient = global.other_base_coefficient_NE * NE_multiplier_minus
	enemy_expansion.neighbouring_chunk_coefficient = global.neighbouring_chunk_coefficient_NE * NE_multiplier_minus
	enemy_expansion.neighbouring_base_chunk_coefficient = global.neighbouring_base_chunk_coefficient_NE * NE_multiplier_minus
	
	
	enemy_expansion.settler_group_min_size = global.settler_Group_min_size_NE * NE_multiplier_plus
	if enemy_expansion.settler_group_min_size < 1 then
		enemy_expansion.settler_group_min_size = 1
	end
	
	enemy_expansion.settler_group_max_size = global.settler_Group_max_size_NE * NE_multiplier_plus
	if enemy_expansion.settler_group_max_size > 50 then
		enemy_expansion.settler_group_max_size = 50
	end
	

	unit_group.max_group_radius = global.max_Group_radius_NE * NE_multiplier_plus
	if unit_group.max_group_radius > 60 then
		unit_group.max_group_radius = 60
	end
	
	unit_group.min_group_radius = global.min_Group_radius_NE * NE_multiplier_plus
	if unit_group.min_group_radius > unit_group.max_group_radius then
		unit_group.min_group_radius =  math.floor(unit_group.max_group_radius - 1)
	elseif unit_group.min_group_radius < 1 then
		unit_group.min_group_radius = 1
	end
	
	unit_group.max_member_speedup_when_behind = global.max_Speed_up_NE * NE_multiplier_plus
		
	path_finder.max_steps_worked_per_tick = 20 + (global.max_Steps_NE * NE_multiplier_plus)
	if path_finder.max_steps_worked_per_tick > 2000 then
		path_finder.max_steps_worked_per_tick = 200
	end
	
	----writeDebug("The PLUS multiplier is: " .. NE_multiplier_plus)		
	----writeDebug("The MINUS multiplier is: " .. NE_multiplier_minus)
	
	----writeDebug("The max Expansion distance is (Vanilla): " .. global.max_expansion_distance_NE)
	----writeDebug("Changed to due to Evo Factor : " .. enemy_expansion.max_expansion_distance)

	------writeDebug("The max other_base_coefficient factore is (Vanilla): " .. global.other_base_oefficient_NE)
	------writeDebug("Changed to due to Evo Factor : " .. enemy_expansion.other_base_coefficient)

	
		
end
	

------------------------
function Spawn_Megalodon(event, entity)

												      --- 100 to 500                                 0 to 2,000                                               0 to 4,410                 0 to 1,000
	local spawn_chance = math.random(math.max(20, 6500 - ((100 * NE_Enemies.Settings.NE_Difficulty) + math.floor(game.forces.enemy.evolution_factor * 2000) + (global.tech_level * 2) + (global.Recent_Number_of_Spawners_Killed * 50))))
	local surface = entity.surface
	local health = (100 * NE_Enemies.Settings.NE_Difficulty) + math.floor(game.forces.enemy.evolution_factor * 1000) + (global.tech_level * 10)
	local force = entity.force	
	local pos = entity.position
	
	------writeDebug("Health: "..health)
	
	if spawn_chance < (math.floor(game.forces.enemy.evolution_factor * 100) + NE_Enemies.Settings.NE_Difficulty) then
	
		local megalodon_position = surface.find_non_colliding_position("ne-biter-megalodon", entity.position, 5, 0.5)

		--writeDebug("megalodon_position is : "..megalodon_position)
		--writeDebug("entity.position is : "..entity.position.x)
		if megalodon_position then
		
			local megalodon = surface.create_entity({name="ne-biter-megalodon", position=megalodon_position, force = entity.force})	
			megalodon.health = health
			global.Recent_Number_of_Spawners_Killed = 0
			
		end
		
	end

	if event.force ~= nil and event.cause then
		if event.cause.type == "artillery-turret" or  event.cause.type == "artillery-wagon" then
		
			local megalodon_position = surface.find_non_colliding_position("ne-biter-megalodon", entity.position, 5, 0.5)
			if megalodon_position then
			
				local megalodon = surface.create_entity({name="ne-biter-megalodon", position=megalodon_position, force = game.forces.enemy})	
				megalodon.health = health * 2
			
			end		
			------writeDebug("megalodon spawned")
			local enemies = surface.find_enemy_units(pos, 50)
			local attack_group = surface.create_unit_group({position = pos, force = "enemy"})
			----writeDebug("Number of Enemies: "..#enemies)
			if #enemies > 0 then
				for i=1, #enemies do
				----writeDebug("Enemy "..i.." added to group")
				attack_group.add_member(enemies[i])
				end
			end
			
			surface.set_multi_command{command = {type=defines.command.attack, target=event.cause, distraction=defines.distraction.by_enemy},unit_count = #enemies, unit_search_distance = 50}
			----writeDebug("Group sent to attack")
		end
	end
	
	
end


---------------------------------------------
-- Spawn Launched Units 
function SpawnLaunchedUnits(enemy, unit_to_spawn)
	local subEnemyName = subEnemyNameTable[enemy.name]
	
	if not subEnemyName then
		return
	end
	
	if subEnemyNameTable[enemy.name][global.evoFactorFloor] then
		if enemy.name == "ne_green_splash_1" then
			subEnemyName = subEnemyNameTable[enemy.name][global.evoFactorFloor]
		else
			subEnemyName = unit_to_spawn.spawn..subEnemyNameTable[enemy.name][global.evoFactorFloor]
		end
	end
					
	local number =  subEnemyNumberTable[enemy.name][global.evoFactorFloor]
	--writeDebug("The Evo Factor is: " .. global.evoFactorFloor)
	--writeDebug("The FLAG Name is: " .. enemy.name)
	--writeDebug("The Enemy Name is: " .. subEnemyName)
	--writeDebug("The NUMBER is: " .. number)
	for i = 1, number do
		local subEnemyPosition = enemy.surface.find_non_colliding_position(subEnemyName, enemy.position, 2, 0.5)
		if subEnemyPosition then
		
			--writeDebug("The ne_green_splash_1 force is: " .. enemy.force.name)
			create_unit = enemy.surface.create_entity({name = subEnemyName, position = subEnemyPosition})
			--writeDebug("The Created Unit's force is: " .. create_unit.force.name)
			--create_unit = enemy.surface.create_entity({name = subEnemyName, position = subEnemyPosition, force = game.forces.enemy})
			create_unit.health = create_unit.health *.95
			Remove_Trees(create_unit)
			
		end
	end
end


function does_tile_exists(tile_name)
	local found = false
	
	for _, tile_prototype in pairs(game.tile_prototypes) do
		if (tile_prototype.name == tile_name) then
			found = true
		end
	end
	--game.print("FOUND")  -- it does not get here now!
	return found
end

----------------------------------------------
function Scorched_Earth(surface, pos, size)
	--- Turn the terrain into desert
	local New_tiles = {}
	local Scorch_test = false
   
	for xxx = -size, size do
		for yyy = -size, size do

			local new_position = {x = pos.x + xxx,y = pos.y + yyy}
			local currentTilename = surface.get_tile(new_position.x, new_position.y).name
			------writeDebug("The current tile is: " .. currentTilename)
			
			
			if game.active_mods["alien-biomes"] then
			
				if currentTilename == "volcanic-orange-heat-4" then
					local spawn_fire = surface.create_entity({name="ne-fire-flame-0", position = pos, force = "enemy"})
					Look_and_Burn(spawn_fire, 0.25)
					Remove_Decal(surface, new_position, 1.5, 5)
					
				elseif replaceableTiles_alien[currentTilename] then
					if does_tile_exists(replaceableTiles_alien[currentTilename]) then
						table.insert(New_tiles, {name=replaceableTiles_alien[currentTilename], position=new_position})  
						Scorch_test	= true
					end
					Remove_Decal(surface, new_position, 0.5, 1)
					
				end
				
			else				

				if currentTilename == "red-desert-1" then
					local spawn_fire = surface.create_entity({name="ne-fire-flame-0", position = pos, force = "enemy"})
					Look_and_Burn(spawn_fire, 0.25)
					Remove_Decal(surface, new_position, 1.5, 5)
					
				elseif replaceableTiles[currentTilename] then
					if does_tile_exists(replaceableTiles[currentTilename]) then
						table.insert(New_tiles, {name=replaceableTiles[currentTilename], position=new_position}) 
						Scorch_test	= true
					end
					Remove_Decal(surface, new_position, 0.5, 1)					
					
				end
				
			end
			
		end

		
	end

	if Scorch_test then
		surface.set_tiles(New_tiles)
	end

end

-------------------------------------------------------------------------------
--[[EVENTS]]--
-------------------------------------------------------------------------------


local function on_tick()


	if game.tick % (60 * 60 * 5) == 0 then -- Check every 5 min for Achievements
		Achievement_Check()
	end


	if game.tick % (60 * 60 * 10) == 0 then -- Check every 10 min for old mines, Expansion settings

		--- Check for Old Mines
		if global.deployed_mine ~= nil then
		
			for k, Old_Mines in pairs(global.deployed_mine) do
				if  Old_Mines.time and Old_Mines.time + (3600 * 30) < game.tick then -- 3600 is 1 min, remove mines older than 30min

					Old_Mines.mine.destroy()
					Old_Mines.time = nil
					Old_Mines.mine = nil
					
				end
				
			end
			
		end
		
		--- Every 10min, increase the evo factor by 5% of remaining evo, if a silo is build. 
		if global.number_or_rocketsilos >= 1 and settings.startup["NE_Challenge_Mode"].value then
		
			game.forces.enemy.evolution_factor = game.forces.enemy.evolution_factor + (1 - game.forces.enemy.evolution_factor)/5
			if game.forces.enemy.evolution_factor > 1 then game.forces.enemy.evolution_factor = 1 end
			----writeDebug("Increase Evo")
		

	
				-- Biters will attack Rocket Silo and Player(s)
			if not settings.startup["NE_Remove_Biter_Search"].value then
				----writeDebug("Search and attack Rocket Silo and Player(s)")
				---- Attack the player, since you have a silo built						
				for _, player in pairs(game.players) do
					if player.connected and player.valid and player.character and player.character.valid then
						player.surface.set_multi_command{command = {type=defines.command.attack, target=player.character, distraction=defines.distraction.by_enemy},unit_count = math.floor(4000 * game.forces.enemy.evolution_factor), unit_search_distance = 2500 * NE_Enemies.Settings.NE_Difficulty}
					end
				end	
		

				---- Attack the player, since you have a silo built						
				if table_size(global.rocketsilos) >= 1 then
					for _, silo in pairs(global.rocketsilos) do

						----writeDebug("Silo Valid, attack")
						silo.silo.surface.set_multi_command{command = {type=defines.command.attack, target=silo.silo, distraction=defines.distraction.by_enemy},unit_count = math.floor(4000 * game.forces.enemy.evolution_factor), unit_search_distance = 2500 * NE_Enemies.Settings.NE_Difficulty}
				
					end	
				end
			
			end
			
		end
		
		if game.active_mods["Natural_Evolution_Expansion"] then
			----writeDebug("NE Expansion Installled - Do Nothing")
		elseif settings.startup["NE_Expansion_Management"].value then
			----writeDebug("Pass - Will execute Expansion settings")
			Natural_Evolution_Expansion_Settings()	
		end
	
	end
	
end

------------------------ TRIGGERS  -----------------------------------------
script.on_event(defines.events.on_trigger_created_entity, function(event)
	
	local entity = event.entity	

    if entity.valid and NELandmine(entity)  == "landmine" then

		global.deployed_mine[entity.unit_number] = {mine=entity, time=event.tick}
		--- Remove trees around mines, to prevent units from getting stuck
		Remove_Trees(entity)
		------writeDebug(table_size(global.deployed_mine) )
		
    end

	
	--- Unit Launcher Projectile Trigger
	if entity.valid and entity.name == "ne_green_splash_1" then

	if global.tick < event.tick then
		if game.forces.enemy.evolution_factor > 0.995 then
			global.evoFactorFloor = 10
		else
			global.evoFactorFloor = math.floor(game.forces.enemy.evolution_factor * 10)
		end
		global.tick = global.tick + 1800
	end

				 
		local radius = 10
		local pos = entity.position	
		local area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}}
		local unit_names = {"ne-biter-fast-1", "ne-biter-fast-2", "ne-biter-fast-3", "ne-biter-fast-4", "ne-biter-fast-5", "ne-biter-fast-6", "ne-biter-fast-7", "ne-biter-fast-8", "ne-biter-fast-9", "ne-biter-fast-10", "ne-biter-fast-11", "ne-biter-fast-12", "ne-biter-fast-13", "ne-biter-fast-14", "ne-biter-fast-15", "ne-biter-fast-16", "ne-biter-fast-17", "ne-biter-fast-18", "ne-biter-fast-19", "ne-biter-fast-20", "ne-biter-fastL-1", "ne-biter-fastL-2", "ne-biter-fastL-3", "ne-biter-fastL-4", "ne-biter-fastL-5", "ne-biter-fastL-6", "ne-biter-fastL-7", "ne-biter-fastL-8", "ne-biter-fastL-9", "ne-biter-fastL-10", "ne-biter-fastL-11", "ne-biter-fastL-12", "ne-biter-fastL-13", "ne-biter-fastL-14", "ne-biter-fastL-15", "ne-biter-fastL-16", "ne-biter-fastL-17", "ne-biter-fastL-18", "ne-biter-fastL-19", "ne-biter-fastL-20"} 
		local green_units = entity.surface.count_entities_filtered{area=area, name=unit_names}
		
		--writeDebug("Count is: "..green_units)
		
		-- Only spawn new units if there are 20 or less units in the area. - Prevents over-crowding...
		if green_units <= (19 + NE_Enemies.Settings.NE_Difficulty) then
			SpawnLaunchedUnits(entity)
		end
		
    end
	
	--- WORM Launcher Projectile Trigger
	if entity.valid and entity.name == "ne_green_splash_2" then

	if global.tick < event.tick then
		if game.forces.enemy.evolution_factor > 0.995 then
			global.evoFactorFloor = 10
		else
			global.evoFactorFloor = math.floor(game.forces.enemy.evolution_factor * 10)
		end
		global.tick = global.tick + 1800
	end
	
	--Randomly choose a unit to shoot - weighted
		function get_unit_to_spawn()
				local spawn_options = 
					{
					  {spawn="ne-biter-breeder-" , weight=20},
					  {spawn="ne-biter-fire-" , weight=30},
					  {spawn="ne-biter-fast-" , weight=60},
					  {spawn="ne-biter-wallbreaker-" , weight=50},
					  {spawn="ne-biter-tank-" , weight=20},	  
					  {spawn="ne-spitter-breeder-" , weight=8},
					  {spawn="ne-spitter-fire-" , weight=3},
					  {spawn="ne-spitter-ulaunch-" , weight=2},
					  {spawn="ne-spitter-webshooter-" , weight=10},
					  {spawn="ne-spitter-mine-" , weight=10}
					}
								  
				local calculate_odds = {}
				for k,spawn in ipairs(spawn_options) do
					for i=1, spawn.weight do
						calculate_odds[#calculate_odds+1] = k
					end
				end

				local random_num = #calculate_odds
				return spawn_options[calculate_odds[math.random(random_num)]]

		end
		
		local unit_to_spawn =  get_unit_to_spawn()
		SpawnLaunchedUnits(entity, unit_to_spawn)
		
    end
		
	
	--- A cliff got bombed 
    if entity.valid and NE_Enemies.Settings.Tree_Hugger and global.cliff_explosive[entity.name] then
		----writeDebug("Cliff Bombed")
		Look_and_Attack(entity, 2)
    end	

	
	--- If Fire then destroy stuff on ground
    if entity.valid and entity.name == "ne-fire-flame-2" then
		--writeDebug("Fire Trigger")
		Look_and_Burn(entity, 0.25)
    end	


	--- If Fire then destroy stuff on ground
    if entity.valid and entity.name == "fire-flame" then
		--writeDebug("Fire Trigger: fire-flame")
		Look_and_Burn(entity, 0.5)
    end	




end)


-------------------------------------------------------------------------------
script.on_event(defines.events.on_research_finished, function(event)

	local research = event.research.name
  
    if research == "military-science-pack" then
        global.tech_level = global.tech_level + 10
    end      

    if research == "military" then
        global.tech_level = global.tech_level + 5
    end 
	
    if research == "military-2" then
        global.tech_level = global.tech_level + 5
    end    	
  
    if research == "military-3" then
        global.tech_level = global.tech_level + 5
    end  
  
    if research == "military-4" then
        global.tech_level = global.tech_level + 5
    end  
  
    if research == "uranium-ammo" then
        global.tech_level = global.tech_level + 10
    end  
  
    if research == "atomic-bomb" then
        global.tech_level = global.tech_level + 500
    end  
  
     if research == "explosives" then
        global.tech_level = global.tech_level + 50
    end 

     if research == "flammables" then
        global.tech_level = global.tech_level + 5
    end 
	
    if research == "land-mine" then
        global.tech_level = global.tech_level + 5
    end  
  
    if research == "flamethrower" then
        global.tech_level = global.tech_level + 10
    end  
  
    if research == "laser" then
        global.tech_level = global.tech_level + 15
    end  

    if research == "tanks" then
        global.tech_level = global.tech_level + 15
    end 

    if research == "rocketry" then
        global.tech_level = global.tech_level + 5
    end 

    if research == "explosive-rocketry" then
        global.tech_level = global.tech_level + 50
    end 
		
    if research == "heavy-armor" then
        global.tech_level = global.tech_level + 10
    end 

		
    if research == "modular-armor" then
        global.tech_level = global.tech_level + 20
    end 
		
		
    if research == "power-armor" then
        global.tech_level = global.tech_level + 25
    end 
	
		
    if research == "power-armor-2" then
        global.tech_level = global.tech_level + 25
    end 
	
    if research == "turrets" then
        global.tech_level = global.tech_level + 5
    end  
  
    if research == "laser-turrets" then
        global.tech_level = global.tech_level + 15
    end  

			
    if research == "stone-walls" then
        global.tech_level = global.tech_level + 5
    end 
	
	
    if research == "rocket-silo" then
        global.tech_level = global.tech_level + 500
    end  

    if research == "combat-robotics" then
        global.tech_level = global.tech_level + 15
    end  

	
    if research == "combat-robotics-2" then
        global.tech_level = global.tech_level + 15
    end  

    if research == "combat-robotics-3" then
        global.tech_level = global.tech_level + 15
    end  
	
    if research == "artillery" then
        global.tech_level = global.tech_level + 500
    end  


    if research == "energy-shield-equipment" then
        global.tech_level = global.tech_level + 50
    end  

    if research == "energy-shield-mk2-equipment" then
        global.tech_level = global.tech_level + 50
    end 	


    if research == "personal-laser-defense-equipment" then
        global.tech_level = global.tech_level + 10
    end 


    if research == "discharge-defense-equipment" then
        global.tech_level = global.tech_level + 10
    end 
	
	---- Military Tech Upgrades
    if research == "physical-projectile-damage-1" then
        global.tech_level = global.tech_level + 10
    end

    if research == "physical-projectile-damage-2" then
        global.tech_level = global.tech_level + 20
    end

    if research == "physical-projectile-damage-3" then
        global.tech_level = global.tech_level + 30
    end

    if research == "physical-projectile-damage-4" then
        global.tech_level = global.tech_level + 40
    end

    if research == "physical-projectile-damage-5" then
        global.tech_level = global.tech_level + 50
    end

    if research == "physical-projectile-damage-6" then
        global.tech_level = global.tech_level + 100
    end

    if research == "physical-projectile-damage-7" then
        global.tech_level = global.tech_level + 150
    end
	
    if research == "stronger-explosives-1" then
        global.tech_level = global.tech_level + 10
    end  
	
    if research == "stronger-explosives-2" then
        global.tech_level = global.tech_level + 20
    end 
	
    if research == "stronger-explosives-3" then
        global.tech_level = global.tech_level + 30
    end 
	
    if research == "stronger-explosives-4" then
        global.tech_level = global.tech_level + 40
    end 
	
    if research == "stronger-explosives-5" then
        global.tech_level = global.tech_level + 50
    end 
	
    if research == "stronger-explosives-6" then
        global.tech_level = global.tech_level + 100
    end 
	
    if research == "stronger-explosives-7" then
        global.tech_level = global.tech_level + 150
    end 
	
    if research == "refined-flammables-1" then
        global.tech_level = global.tech_level + 10
    end  
		
    if research == "refined-flammables-2" then
        global.tech_level = global.tech_level + 20
    end 
		
    if research == "refined-flammables-3" then
        global.tech_level = global.tech_level + 30
    end 
		
    if research == "refined-flammables-4" then
        global.tech_level = global.tech_level + 40
    end 
		
    if research == "refined-flammables-5" then
        global.tech_level = global.tech_level + 50
    end 
		
    if research == "refined-flammables-6" then
        global.tech_level = global.tech_level + 100
    end 
		
    if research == "refined-flammables-7" then
        global.tech_level = global.tech_level + 150
    end 
		 
	
    if research == "energy-weapons-damage-1" then
        global.tech_level = global.tech_level + 50
    end  
	
    if research == "energy-weapons-damage-2" then
        global.tech_level = global.tech_level + 50
    end 
		
    if research == "energy-weapons-damage-3" then
        global.tech_level = global.tech_level + 50
    end 
		
    if research == "energy-weapons-damage-4" then
        global.tech_level = global.tech_level + 50
    end 
		
    if research == "energy-weapons-damage-5" then
        global.tech_level = global.tech_level + 100
    end 
		
    if research == "energy-weapons-damage-6" then
        global.tech_level = global.tech_level + 200
    end 
		
    if research == "energy-weapons-damage-7" then
        global.tech_level = global.tech_level + 500
    end 
		
    if research == "weapon-shooting-speed-1" then
        global.tech_level = global.tech_level + 5
    end
	
    if research == "weapon-shooting-speed-2" then
        global.tech_level = global.tech_level + 15
    end
	
    if research == "weapon-shooting-speed-3" then
        global.tech_level = global.tech_level + 25
    end 
	
    if research == "weapon-shooting-speed-4" then
        global.tech_level = global.tech_level + 50
    end 
	
    if research == "weapon-shooting-speed-5" then
        global.tech_level = global.tech_level + 100
    end 
	
    if research == "weapon-shooting-speed-6" then
        global.tech_level = global.tech_level + 150
    end 

    if research == "laser-turret-speed-1" then
        global.tech_level = global.tech_level + 50
    end	

    if research == "laser-turret-speed-2" then
        global.tech_level = global.tech_level + 60
    end	

    if research == "laser-turret-speed-3" then
        global.tech_level = global.tech_level + 80
    end	
	
    if research == "laser-turret-speed-4" then
        global.tech_level = global.tech_level + 90
    end		
    
	if research == "laser-turret-speed-5" then
        global.tech_level = global.tech_level + 100
    end	
	
	if research == "laser-turret-speed-6" then
        global.tech_level = global.tech_level + 150
    end	
	
	if research == "laser-turret-speed-7" then
        global.tech_level = global.tech_level + 200
    end	
	
	--
	if research == "artillery-shell-range-1" then
        global.tech_level = global.tech_level + 300
    end	

	--
	if research == "artillery-shell-speed-1" then
        global.tech_level = global.tech_level + 300
    end		

	--
	if research == "follower-robot-count-1" then
        global.tech_level = global.tech_level + 100
    end		
		
	if research == "follower-robot-count-2" then
        global.tech_level = global.tech_level + 100
    end		
		
	if research == "follower-robot-count-3" then
        global.tech_level = global.tech_level + 100
    end		
		
	if research == "follower-robot-count-4" then
        global.tech_level = global.tech_level + 100
    end		
		
	if research == "follower-robot-count-5" then
        global.tech_level = global.tech_level + 100
    end		
		
	if research == "follower-robot-count-6" then
        global.tech_level = global.tech_level + 100
    end		
		
	if research == "follower-robot-count-7" then
        global.tech_level = global.tech_level + 100
    end						
	
	
end)


-------------------------------------------------------------------------------
--[[EVENTS]]--
-------------------------------------------------------------------------------


script.on_configuration_changed(On_Config_Change)
script.on_init(On_Init)
script.on_event(defines.events.on_tick, on_tick)


local build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
script.on_event(build_events, On_Built)

local pre_remove_events = {defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined} 
script.on_event(pre_remove_events, On_Remove)

local death_events = {defines.events.on_entity_died}
script.on_event(death_events, On_Death)

-------------------------------------------------------------------------------


--- DeBug Messages 
function writeDebug(message)
	if QC_Mod == true then  
		for i, player in pairs(game.players) do
			player.print(tostring(message))
		end
	end
end


