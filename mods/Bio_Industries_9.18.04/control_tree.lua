
-- All tree Growing stuff
local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)

terrains = require("libs/trees-and-terrains")


Bi_Industries = {}


Bi_Industries.fertility = 
	{
		["vegetation-green-grass-1"] = 100,
		["grass-1"] =  100,
		["grass-3"] =  85,
		["grass-2"] =  70,
		["grass-4"] =  60,
		["red-desert-0"] =  50,
		["dirt-3"] =  40,
		["dirt-5"] =  37,
		["dirt-6"] =  34,
		["dirt-7"] =  31,
		["dirt-4"] =  28,
		["dry-dirt"] =  25,
		["dirt-2"] =  22,
		["dirt-1"] =  19,
		["red-desert-2"] =  16,
		["red-desert-3"] =  13,
		["sand-3"] =  10,
		["sand-2"] =  7,
		["sand-1"] =  4,
		["red-desert-1"] =  1,
		["frozen-snow-0"] = 1,
		["frozen-snow-1"] = 1,
		["frozen-snow-2"] = 1,
		["frozen-snow-3"] = 1,
		["frozen-snow-4"] = 1,
		["frozen-snow-5"] = 1,
		["frozen-snow-6"] = 1,
		["frozen-snow-7"] = 1,
		["frozen-snow-8"] = 1,
		["frozen-snow-9"] = 1,
		["mineral-aubergine-dirt-1"] = 45,
		["mineral-aubergine-dirt-2"] = 45,
		["mineral-aubergine-dirt-3"] = 25,
		["mineral-aubergine-dirt-4"] = 25,
		["mineral-aubergine-dirt-5"] = 25,
		["mineral-aubergine-dirt-6"] = 25,
		["mineral-aubergine-dirt-7"] = 25,
		["mineral-aubergine-dirt-8"] = 25,
		["mineral-aubergine-dirt-9"] = 25,
		["mineral-aubergine-sand-1"] = 15,
		["mineral-aubergine-sand-2"] = 15,
		["mineral-aubergine-sand-3"] = 10,
		["mineral-beige-dirt-1"] = 45,
		["mineral-beige-dirt-2"] = 45,
		["mineral-beige-dirt-3"] = 25,
		["mineral-beige-dirt-4"] = 25,
		["mineral-beige-dirt-5"] = 25,
		["mineral-beige-dirt-6"] = 25,
		["mineral-beige-dirt-7"] = 25,
		["mineral-beige-dirt-8"] = 25,
		["mineral-beige-dirt-9"] = 25,
		["mineral-beige-sand-1"] = 10,
		["mineral-beige-sand-2"] = 10,
		["mineral-beige-sand-3"] = 10,
		["mineral-black-dirt-1"] = 45,
		["mineral-black-dirt-2"] = 45,
		["mineral-black-dirt-3"] = 25,
		["mineral-black-dirt-4"] = 25,
		["mineral-black-dirt-5"] = 25,
		["mineral-black-dirt-6"] = 25,
		["mineral-black-dirt-7"] = 25,
		["mineral-black-dirt-8"] = 25,
		["mineral-black-dirt-9"] = 25,
		["mineral-black-sand-1"] = 10,
		["mineral-black-sand-2"] = 10,
		["mineral-black-sand-3"] = 10,
		["mineral-brown-dirt-1"] = 25,
		["mineral-brown-dirt-2"] = 25,
		["mineral-brown-dirt-3"] = 25,
		["mineral-brown-dirt-4"] = 25,
		["mineral-brown-dirt-5"] = 25,
		["mineral-brown-dirt-6"] = 25,
		["mineral-brown-dirt-7"] = 25,
		["mineral-brown-dirt-8"] = 25,
		["mineral-brown-dirt-9"] = 25,
		["mineral-brown-sand-1"] = 10,
		["mineral-brown-sand-2"] = 10,
		["mineral-brown-sand-3"] = 10,
		["mineral-cream-dirt-1"] = 25,
		["mineral-cream-dirt-2"] = 25,
		["mineral-cream-dirt-3"] = 25,
		["mineral-cream-dirt-4"] = 25,
		["mineral-cream-dirt-5"] = 25,
		["mineral-cream-dirt-6"] = 25,
		["mineral-cream-dirt-7"] = 25,
		["mineral-cream-dirt-8"] = 25,
		["mineral-cream-dirt-9"] = 25,
		["mineral-cream-sand-1"] = 10,
		["mineral-cream-sand-2"] = 10,
		["mineral-cream-sand-3"] = 10,
		["mineral-dustyrose-dirt-1"] = 25,
		["mineral-dustyrose-dirt-2"] = 25,
		["mineral-dustyrose-dirt-3"] = 25,
		["mineral-dustyrose-dirt-4"] = 25,
		["mineral-dustyrose-dirt-5"] = 25,
		["mineral-dustyrose-dirt-6"] = 25,
		["mineral-dustyrose-dirt-7"] = 25,
		["mineral-dustyrose-dirt-8"] = 25,
		["mineral-dustyrose-dirt-9"] = 25,
		["mineral-dustyrose-sand-1"] = 10,
		["mineral-dustyrose-sand-2"] = 10,
		["mineral-dustyrose-sand-3"] = 10,
		["mineral-grey-dirt-1"] = 25,
		["mineral-grey-dirt-2"] = 25,
		["mineral-grey-dirt-3"] = 25,
		["mineral-grey-dirt-4"] = 25,
		["mineral-grey-dirt-5"] = 25,
		["mineral-grey-dirt-6"] = 25,
		["mineral-grey-dirt-7"] = 25,
		["mineral-grey-dirt-8"] = 25,
		["mineral-grey-dirt-9"] = 25,
		["mineral-grey-sand-1"] = 10,
		["mineral-grey-sand-2"] = 10,
		["mineral-grey-sand-3"] = 10,
		["mineral-purple-dirt-1"] = 25,
		["mineral-purple-dirt-2"] = 25,
		["mineral-purple-dirt-3"] = 25,
		["mineral-purple-dirt-4"] = 25,
		["mineral-purple-dirt-5"] = 25,
		["mineral-purple-dirt-6"] = 25,
		["mineral-purple-dirt-7"] = 25,
		["mineral-purple-dirt-8"] = 25,
		["mineral-purple-dirt-9"] = 25,
		["mineral-purple-sand-1"] = 10,
		["mineral-purple-sand-2"] = 10,
		["mineral-purple-sand-3"] = 10,
		["mineral-red-dirt-1"] = 25,
		["mineral-red-dirt-2"] = 25,
		["mineral-red-dirt-3"] = 25,
		["mineral-red-dirt-4"] = 25,
		["mineral-red-dirt-5"] = 25,
		["mineral-red-dirt-6"] = 25,
		["mineral-red-dirt-7"] = 25,
		["mineral-red-dirt-8"] = 25,
		["mineral-red-dirt-9"] = 25,
		["mineral-red-sand-1"] = 10,
		["mineral-red-sand-2"] = 10,
		["mineral-red-sand-3"] = 10,
		["mineral-tan-dirt-1"] = 25,
		["mineral-tan-dirt-2"] = 25,
		["mineral-tan-dirt-3"] = 25,
		["mineral-tan-dirt-4"] = 25,
		["mineral-tan-dirt-5"] = 25,
		["mineral-tan-dirt-6"] = 25,
		["mineral-tan-dirt-7"] = 25,
		["mineral-tan-dirt-8"] = 25,
		["mineral-tan-dirt-9"] = 25,
		["mineral-tan-sand-1"] = 10,
		["mineral-tan-sand-2"] = 10,
		["mineral-tan-sand-3"] = 10,
		["mineral-violet-dirt-1"] = 25,
		["mineral-violet-dirt-2"] = 25,
		["mineral-violet-dirt-3"] = 25,
		["mineral-violet-dirt-4"] = 25,
		["mineral-violet-dirt-5"] = 25,
		["mineral-violet-dirt-6"] = 25,
		["mineral-violet-dirt-7"] = 25,
		["mineral-violet-dirt-8"] = 25,
		["mineral-violet-dirt-9"] = 25,
		["mineral-violet-sand-1"] = 10,
		["mineral-violet-sand-2"] = 10,
		["mineral-violet-sand-3"] = 10,
		["mineral-white-dirt-1"] = 25,
		["mineral-white-dirt-2"] = 25,
		["mineral-white-dirt-3"] = 25,
		["mineral-white-dirt-4"] = 25,
		["mineral-white-dirt-5"] = 25,
		["mineral-white-dirt-6"] = 25,
		["mineral-white-dirt-7"] = 25,
		["mineral-white-dirt-8"] = 25,
		["mineral-white-dirt-9"] = 25,
		["mineral-white-sand-1"] = 10,
		["mineral-white-sand-2"] = 10,
		["mineral-white-sand-3"] = 10,
		["vegetation-blue-grass-1"] = 70,
		["vegetation-blue-grass-2"] = 70,		
		["vegetation-green-grass-2"] = 75,
		["vegetation-green-grass-3"] = 85,
		["vegetation-green-grass-4"] = 70,
		["vegetation-mauve-grass-1"] = 70,
		["vegetation-mauve-grass-2"] = 70,
		["vegetation-olive-grass-1"] = 70,
		["vegetation-olive-grass-2"] = 70,
		["vegetation-orange-grass-1"] = 70,
		["vegetation-orange-grass-2"] = 70,
		["vegetation-purple-grass-1"] = 70,
		["vegetation-purple-grass-2"] = 70,
		["vegetation-red-grass-1"] = 70,
		["vegetation-red-grass-2"] = 70,
		["vegetation-turquoise-grass-1"] = 70,
		["vegetation-turquoise-grass-2"] = 70,
		["vegetation-violet-grass-1"] = 70,
		["vegetation-violet-grass-2"] = 70,
		["vegetation-yellow-grass-1"] = 70,
		["vegetation-yellow-grass-2"] = 70,
		["volcanic-blue-heat-1"] = 1,
		["volcanic-blue-heat-2"] = 1,
		["volcanic-blue-heat-3"] = 1,
		["volcanic-blue-heat-4"] = 1,
		["volcanic-green-heat-1"] = 1,
		["volcanic-green-heat-2"] = 1,
		["volcanic-green-heat-3"] = 1,
		["volcanic-green-heat-4"] = 1,
		["volcanic-orange-heat-1"] = 1,
		["volcanic-orange-heat-2"] = 1,
		["volcanic-orange-heat-3"] = 1,
		["volcanic-orange-heat-4"] = 1,
		["volcanic-purple-heat-1"] = 1,
		["volcanic-purple-heat-2"] = 1,
		["volcanic-purple-heat-3"] = 1,
		["volcanic-purple-heat-4"] = 1
	}


function seed_planted (event)

   -- Seed Planted (Put the seedling in the table
		local entity = event.created_entity
		local surface = entity.surface
		local position = entity.position	
		local fertility
		currentTilename = surface.get_tile(position.x, position.y).name
		
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]				
		else
			fertility = 1 -- < Always a minimum of 1. 
		end
		

		local max_grow_time = math.random(1000) + 4000 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
		table.insert(global.bi.tree_growing, {position = position, time = event.tick + max_grow_time, surface = surface, seed_bomb = "no"})
		table.sort(global.bi.tree_growing, function(a, b) return a.time < b.time end)

end


function seed_planted_trigger (event)
   -- Seed Planted
		local entity = event.entity
		local surface = entity.surface
		local position = entity.position	
		local fertility
		currentTilename = surface.get_tile(position.x, position.y).name
		----writeDebug("The current tile is: " .. currentTilename)

		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]				
		else
			fertility = 1 -- < Always a minimum of 1.
			----writeDebug("Tile NOT in table")			
		end
		
		----writeDebug("The Fertility is: " .. fertility)
		local max_grow_time = math.random(2000) + 6000 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
		table.insert(global.bi.tree_growing, {position = position, time = event.tick + max_grow_time, surface = surface, seed_bomb = "yes"})
		table.sort(global.bi.tree_growing, function(a, b) return a.time < b.time end)

end


function seed_planted_arboretum (event, entity)
   -- Seed Planted by arboretum
		local surface = entity.surface
		local position = entity.position	
		local fertility
		currentTilename = surface.get_tile(position.x, position.y).name
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]				
		else
			fertility = 1 -- < Always a minimum of 1. 
		end
		
		----writeDebug("The Fertility is: " .. fertility)
		local max_grow_time = math.random(2000) + 6000 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
		table.insert(global.bi.tree_growing, {position = position, time = event.tick + max_grow_time, surface = surface, seed_bomb = "no"})
		table.sort(global.bi.tree_growing, function(a, b) return a.time < b.time end)

end


function is_value_as_index_in_table (value, tabl) 
  for index, v in pairs (tabl) do
    if value == index then
      return true
    end
  end
  return false
end


function summ_weight (tabl)
  local summ = 0
  for i, tree_weights in pairs (tabl) do
    if (type (tree_weights) == "table") and tree_weights.weight then
      summ = summ + tree_weights.weight
    end
  end
  return summ
end


function tree_from_max_index_tabl (max_index, tabl)
  local rnd_index = math.random (max_index)
  for tree_name, tree_weights in pairs (tabl) do
    if (type (tree_weights) == "table") and tree_weights.weight then
      rnd_index = rnd_index - tree_weights.weight
      if rnd_index <= 0 then
        return tree_name
      end
    end
  end
  return nil
end


function random_tree (surface, position)

	local tile = surface.get_tile(position.x, position.y)
	local tile_name = tile.name
	if is_value_as_index_in_table (tile_name, terrains) then
		local trees_table = terrains[tile_name]
		local max_index = summ_weight(trees_table)
		return tree_from_max_index_tabl (max_index, trees_table)
	end
end


local function Grow_tree_stage_0(stage_0_table, event)
	
	local foundtree = false
	local surface = stage_0_table.surface
	local position = stage_0_table.position
	local seed_bomb = stage_0_table.seed_bomb
	----writeDebug(seed_bomb)
	local tree = surface.find_entity("seedling", position)
	local tree2 = surface.find_entity("seedling-2", position)
	local tree3 = surface.find_entity("seedling-3", position)
	
	local currentTilename = surface.get_tile(position.x, position.y).name
	local fertility = 1 -- fertility will be 1 if terrain type not listed above, so very small change to grow.
	local growth_chance = math.random(100) -- Random value. Tree will grow if it's this value is smaller that the 'Fertility' value

				
	if tree and seed_bomb == "no" then
		foundtree = true
		tree.destroy()

		
		--- Depending on Terain, choose tree type & Convert seedling into a tree	
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	
		-- Grow the new tree
			local tree_name = random_tree (surface, position)
			if tree_name then
				local can_be_placed = surface.can_place_entity{name=tree_name, position=position, force = "neutral"}
				if can_be_placed and growth_chance <= (fertility + 5) and foundtree then
			  
				local max_grow_time = math.random(2000) + 4000 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
				if max_grow_time <= 0 then max_grow_time = 1 end
					
					local sage_1_tree_name = "bio-tree-"..tree_name.."-1"
					if game.item_prototypes[sage_1_tree_name] or game.entity_prototypes[sage_1_tree_name] then
						sage_1_tree_name = "bio-tree-"..tree_name.."-1"
					else	
						sage_1_tree_name = tree_name
					end
					table.insert(global.bi.tree_growing_stage_1, {tree_name=sage_1_tree_name, final_tree=tree_name, position = position, time = event.tick + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_1, function(a, b) return a.time < b.time end)
					-- Plant the new tree						
					local new_tree = surface.create_entity({name=sage_1_tree_name, position=position, force = "neutral"})
			  end
			  
			end

		end

	end
	
	--- Seed Bomb Code
		--- Seed Bomb Code
	if tree2 or tree3 then
		foundtree = true
		
		if tree2 then tree2.destroy() end
		if tree3 then tree3.destroy() end
		--- Depending on Terain, choose tree type & Convert seedling into a tree
		
		
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	

			local tree_name = random_tree (surface, position)
			if tree_name then
			  local can_be_placed = surface.can_place_entity{name=tree_name, position=position, force = "neutral"}
			  if can_be_placed and growth_chance <= fertility and foundtree then
				local new_tree = surface.create_entity{name=tree_name, position=position, force = "neutral"}
			  end
			end
	

		end		

	end

	
	if seed_bomb == "yes" then
		foundtree = true
		----writeDebug("Seed Bomb was YES")
		if tree then tree.destroy() end

		--- Depending on Terain, choose tree type & Convert seedling into a tree
		
		
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	
			----writeDebug("Got Tile")
			local tree_name = random_tree (surface, position)
			if tree_name then
			----writeDebug("Found Tree")
			  local can_be_placed = surface.can_place_entity{name=tree_name, position=position, force = "neutral"}
			  if can_be_placed and growth_chance <= fertility and foundtree then
				local new_tree = surface.create_entity{name=tree_name, position=position, force = "neutral"}
			  end
			  --writeDebug("Tree not Found")
			end
	
		else
			--writeDebug("Tile not Found")
		end		

	end


end
	


local function Grow_tree_stage_1(stage_1_table)
	
	
	local tree_name = stage_1_table.tree_name
	local final_tree = stage_1_table.final_tree
	local surface = stage_1_table.surface
	local position = stage_1_table.position
	local time_planted = stage_1_table.time
	local foundtree = false
	local tree = surface.find_entity(tree_name, position)
	if tree_name then
		tree = surface.find_entity(tree_name, position)
	end

	
	local currentTilename = surface.get_tile(position.x, position.y).name
	local fertility = 1 -- fertility will be 1 if terrain type not listed above, so very small change to grow.


				

	if tree then
		foundtree = true
		tree.destroy()
		
		--- Depending on Terain, choose tree type & Convert seedling into a tree				
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	
			-- Select Tree 
			local sage_2_tree_name = "bio-tree-"..final_tree.."-2"
			if game.item_prototypes[sage_2_tree_name] or game.entity_prototypes[sage_2_tree_name] then
				sage_2_tree_name = "bio-tree-"..final_tree.."-2"
			else	
				sage_2_tree_name = final_tree
				--writeDebug("Stage 2: Prototype did not exist")
			end
			----writeDebug("Stage 2 Tree Name: " .. sage_2_tree_name)
			local can_be_placed = surface.can_place_entity{name=sage_2_tree_name, position=position, force = "neutral"}
			if can_be_placed and foundtree then	  
			
				local max_grow_time = math.random(1500) + 3000 - (30 * fertility) --< Fertile tiles will grow faster than barren tiles		
				if max_grow_time <= 0 then max_grow_time = 1 end
				
				if sage_2_tree_name == final_tree then
					----writeDebug("Tree Reached final Stage, don't insert")
					local new_tree = surface.create_entity({name=sage_2_tree_name, position=position, force = "neutral"})
				else
					table.insert(global.bi.tree_growing_stage_2, {tree_name=sage_2_tree_name, final_tree=final_tree, position = position, time = time_planted + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_2, function(a, b) return a.time < b.time end) 
					local new_tree = surface.create_entity({name=sage_2_tree_name, position=position, force = "neutral"})
				end
			
			end

		---- Terain not found.
		else
		
			--writeDebug("Terrain not found")
			-- Select Tree 
			local sage_2_tree_name = "bio-tree-"..final_tree.."-2"
			if game.item_prototypes[sage_2_tree_name] or game.entity_prototypes[sage_2_tree_name] then
				sage_2_tree_name = "bio-tree-"..final_tree.."-2"
			else	
				sage_2_tree_name = final_tree
				--writeDebug("Stage 2: Prototype did not exist")
			end
			

			if game.entity_prototypes[sage_2_tree_name] and growth_chance <= fertility and foundtree and surface.can_place_entity({ name=sage_2_tree_name, position=position}) then
				local max_grow_time = math.random(1500) + 6000 - (30 * fertility) --< Fertile tiles will grow faster than barren tiles
				if max_grow_time <= 0 then max_grow_time = 1 end
				
				if sage_2_tree_name == final_tree then
					----writeDebug("Tree Reached final Stage, don't insert")
					local new_tree = surface.create_entity({name=sage_2_tree_name, position=position, force = "neutral"})
				else
					table.insert(global.bi.tree_growing_stage_2, {tree_name=sage_2_tree_name, final_tree=final_tree, position = position, time = time_planted + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_2, function(a, b) return a.time < b.time end) 
					local new_tree = surface.create_entity({name=sage_2_tree_name, position=position, force = "neutral"})
				end
			end
				
		end		

	else
		--writeDebug("Did not find that tree I was lookign for...")	
	end


end


local function Grow_tree_stage_2(stage_2_table)
	
	
	local tree_name = stage_2_table.tree_name
	local final_tree = stage_2_table.final_tree
	local surface = stage_2_table.surface
	local position = stage_2_table.position
	local time_planted = stage_2_table.time
	local foundtree = false
	if tree_name then
		tree = surface.find_entity(tree_name, position)
	end
	
	local currentTilename = surface.get_tile(position.x, position.y).name
	local fertility = 1 -- fertility will be 1 if terrain type not listed above, so very small change to grow.


				
	if tree then
		foundtree = true
		tree.destroy()
		
		--- Depending on Terain, choose tree type & Convert seedling into a tree				
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	
			-- Grow the new tree	
			local sage_3_tree_name = "bio-tree-"..final_tree.."-3"
			if game.item_prototypes[sage_3_tree_name] or game.entity_prototypes[sage_3_tree_name] then
				sage_3_tree_name = "bio-tree-"..final_tree.."-3"
			else	
				sage_3_tree_name = final_tree
				--writeDebug("Stage 3: Prototype did not exist")
			end
			
			----writeDebug("Stage 3 Tree Name: " .. sage_3_tree_name)
			local can_be_placed = surface.can_place_entity{name=sage_3_tree_name, position=position, force = "neutral"}
			if can_be_placed and foundtree then
			  
				local max_grow_time = math.random(1000) + 2000 - (20 * fertility) --< Fertile tiles will grow faster than barren tiles
				if max_grow_time <= 0 then max_grow_time = 1 end	
				if sage_3_tree_name == final_tree then
					----writeDebug("Tree Reached final Stage, don't insert")
					local new_tree = surface.create_entity({name=sage_3_tree_name, position=position, force = "neutral"})
				else
					table.insert(global.bi.tree_growing_stage_3, {tree_name=sage_3_tree_name, final_tree=final_tree, position = position, time = time_planted + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_3, function(a, b) return a.time < b.time end) 
					local new_tree = surface.create_entity({name=sage_3_tree_name, position=position, force = "neutral"})
				end
				
	
			end

		---- Terain not found.
		else
		
			--writeDebug("Terrain not found")
			-- Select Tree 
			local sage_3_tree_name = "bio-tree-"..final_tree.."-3"
			if game.item_prototypes[sage_3_tree_name] or game.entity_prototypes[sage_3_tree_name] then
				sage_3_tree_name = "bio-tree-"..final_tree.."-3"
			else	
				sage_3_tree_name = final_tree
				--writeDebug("Stage 3: Prototype did not exist")
			end

			

			if game.entity_prototypes[sage_3_tree_name] and growth_chance <= fertility and foundtree and surface.can_place_entity({ name=sage_3_tree_name, position=position}) then
				local max_grow_time = math.random(1500) + 6000 - (30 * fertility) --< Fertile tiles will grow faster than barren tiles
				if max_grow_time <= 0 then max_grow_time = 1 end
				if sage_3_tree_name == final_tree then
					----writeDebug("Tree Reached final Stage, don't insert")
					local new_tree = surface.create_entity({name=sage_3_tree_name, position=position, force = "neutral"})
				else
					table.insert(global.bi.tree_growing_stage_3, {tree_name=sage_3_tree_name, final_tree=final_tree, position = position, time = time_planted + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_3, function(a, b) return a.time < b.time end) 
					local new_tree = surface.create_entity({name=sage_3_tree_name, position=position, force = "neutral"})
				end
				
			end
				
		end		

	else
		--writeDebug("Did not find that tree I was lookign for...")	
	end
	
end


local function Grow_tree_stage_3(stage_3_table)
	
	
	local tree_name = stage_3_table.tree_name
	local final_tree = stage_3_table.final_tree
	local surface = stage_3_table.surface
	local position = stage_3_table.position
	local time_planted = stage_3_table.time
	local foundtree = false
	if tree_name then
		tree = surface.find_entity(tree_name, position)
	end
	
	local currentTilename = surface.get_tile(position.x, position.y).name
	local fertility = 1 -- fertility will be 1 if terrain type not listed above, so very small change to grow.

				
	if tree then
		foundtree = true
		tree.destroy()
		
		--- Depending on Terain, choose tree type & Convert seedling into a tree				
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	
			-- Grow the new tree	
			local sage_4_tree_name = "bio-tree-"..final_tree.."-4"
			if game.item_prototypes[sage_4_tree_name] or game.entity_prototypes[sage_4_tree_name] then
				sage_4_tree_name = "bio-tree-"..final_tree.."-4"
			else	
				sage_4_tree_name = final_tree
				--writeDebug("Stage 4: Prototype did not exist")
			end
			
			----writeDebug("Stage 4 Tree Name: " .. sage_4_tree_name)
			local can_be_placed = surface.can_place_entity{name=sage_4_tree_name, position=position, force = "neutral"}
			if can_be_placed and foundtree then
			  
				local max_grow_time = math.random(1000) + 2000 - (20 * fertility) --< Fertile tiles will grow faster than barren tiles
				if max_grow_time <= 0 then max_grow_time = 1 end	
				
				if sage_4_tree_name == final_tree then
					----writeDebug("Tree Reached final Stage, don't insert")
					local new_tree = surface.create_entity({name=sage_4_tree_name, position=position, force = "neutral"})
				else
					table.insert(global.bi.tree_growing_stage_4, {tree_name=sage_4_tree_name, final_tree=final_tree, position = position, time = time_planted + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_4, function(a, b) return a.time < b.time end) 
					local new_tree = surface.create_entity({name=sage_4_tree_name, position=position, force = "neutral"})
				end
	
			end

		---- Terain not found.
		else
		
			--writeDebug("Terrain not found")
			-- Select Tree 
			local sage_4_tree_name = "bio-tree-"..final_tree.."-4"
			if game.item_prototypes[sage_4_tree_name] or game.entity_prototypes[sage_4_tree_name] then
				sage_4_tree_name = "bio-tree-"..final_tree.."-4"
			else	
				sage_4_tree_name = final_tree
				--writeDebug("Stage 3: Prototype did not exist")
			end

			

			if game.entity_prototypes[sage_4_tree_name] and growth_chance <= fertility and foundtree and surface.can_place_entity({ name=sage_4_tree_name, position=position}) then
				local max_grow_time = math.random(1500) + 6000 - (30 * fertility) --< Fertile tiles will grow faster than barren tiles
				if max_grow_time <= 0 then max_grow_time = 1 end
				if sage_4_tree_name == final_tree then
					----writeDebug("Tree Reached final Stage, don't insert")
					local new_tree = surface.create_entity({name=sage_4_tree_name, position=position, force = "neutral"})
				else
					table.insert(global.bi.tree_growing_stage_4, {tree_name=sage_4_tree_name, final_tree=final_tree, position = position, time = time_planted + max_grow_time, surface = surface})
					table.sort(global.bi.tree_growing_stage_4, function(a, b) return a.time < b.time end) 
					local new_tree = surface.create_entity({name=sage_4_tree_name, position=position, force = "neutral"})
				end
			end
				
		end		

	else
		--writeDebug("Did not find that tree I was looking for...")	
	end
	
	
end


local function Grow_tree_stage_4(stage_4_table)
	
	
	local tree_name = stage_4_table.tree_name
	local final_tree = stage_4_table.final_tree
	local surface = stage_4_table.surface
	local position = stage_4_table.position
	local time_planted = stage_4_table.time
	local foundtree = false
	if tree_name then
		tree = surface.find_entity(tree_name, position)
	end
	
	local currentTilename = surface.get_tile(position.x, position.y).name
	local fertility = 1 -- fertility will be 1 if terrain type not listed above, so very small change to grow.

				
	if tree then
		foundtree = true
		tree.destroy()
		
		--- Depending on Terain, choose tree type & Convert seedling into a tree
		local final_tree_name = final_tree	
		
		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]
	
		-- Grow the new tree
		

			----writeDebug("Final Tree Name: " .. final_tree_name)
			local can_be_placed = surface.can_place_entity{name=final_tree_name, position=position, force = "neutral"}
			if can_be_placed and foundtree then

				local new_tree = surface.create_entity({name=final_tree_name, position=position, force = "neutral"})	
			end

		---- Hardcode anything else to tree 9 for now.
		else

			--writeDebug("Terrain or Fertility not found")
			
			if growth_chance <= fertility and surface.can_place_entity({ name=final_tree_name, position=position}) then
				local new_tree = surface.create_entity({ name=final_tree_name, position=position, force = "neutral"})
			end

		end		

	end
	
end




---- Growing Tree

--Event.register(-12, function(event)
Event.register(defines.events.on_tick, function(event)	



	if global.bi.tree_growing_stage_1 == nil then
		global.bi.tree_growing_stage_1 = {}
		global.bi.tree_growing_stage_2 = {}
		global.bi.tree_growing_stage_3 = {}
		global.bi.tree_growing_stage_4 = {}
	end

	while #global.bi.tree_growing > 0 do
		if event.tick < global.bi.tree_growing[1].time then
			break 
		end

		Grow_tree_stage_0(global.bi.tree_growing[1], event)
		table.remove(global.bi.tree_growing, 1)
	end

	
	while #global.bi.tree_growing_stage_1 > 0 do
		if event.tick < global.bi.tree_growing_stage_1[1].time then
			break 
		end

		Grow_tree_stage_1(global.bi.tree_growing_stage_1[1])
		table.remove(global.bi.tree_growing_stage_1, 1)
	end	
	


	while #global.bi.tree_growing_stage_2 > 0 do
		if event.tick < global.bi.tree_growing_stage_2[1].time then
			break 
		end

		Grow_tree_stage_2(global.bi.tree_growing_stage_2[1])
		table.remove(global.bi.tree_growing_stage_2, 1)
	end	
	

	while #global.bi.tree_growing_stage_3 > 0 do
		if event.tick < global.bi.tree_growing_stage_3[1].time then
			break 
		end

		Grow_tree_stage_3(global.bi.tree_growing_stage_3[1])
		table.remove(global.bi.tree_growing_stage_3, 1)
	end	
	
	while #global.bi.tree_growing_stage_4 > 0 do
		if event.tick < global.bi.tree_growing_stage_4[1].time then
			break 
		end

		Grow_tree_stage_4(global.bi.tree_growing_stage_4[1])
		table.remove(global.bi.tree_growing_stage_4, 1)
	end	
end)






