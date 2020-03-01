
-- All tree Growing stuff

require ("stdlib/event/event")
terrains = require("libs/trees-and-terrains")


Bi_Industries = {}

--[[
if global.alien_biomes then
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

else

	Bi_Industries.fertility = 
	{  -- out of 100, so 100 = always grow tree
		-- Vanilla
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
		["red-desert-1"] =  1
	}

end
--------------------
]]

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
   -- Seed Planted
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
		
		writeDebug("The Fertility is: " .. fertility)
		local max_grow_time = math.random(5000) + 4040 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
		table.insert(global.bi.tree_growing, {position = position, time = event.tick + max_grow_time, surface = surface})
		table.sort(global.bi.tree_growing, function(a, b) return a.time < b.time end)

end


function seed_planted_trigger (event)
   -- Seed Planted
		local entity = event.entity
		local surface = entity.surface
		local position = entity.position	
		local fertility
		currentTilename = surface.get_tile(position.x, position.y).name
		writeDebug("The current tile is: " .. currentTilename)

		if Bi_Industries.fertility[currentTilename] then
			fertility = Bi_Industries.fertility[currentTilename]				
			writeDebug("Tile in table")
		else
			fertility = 1 -- < Always a minimum of 1.
			writeDebug("Tile NOT in table")			
		end
		
		writeDebug("The Fertility is: " .. fertility)
		local max_grow_time = math.random(5000) + 4040 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
		table.insert(global.bi.tree_growing, {position = position, time = event.tick + max_grow_time, surface = surface})
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
		
		writeDebug("The Fertility is: " .. fertility)
		local max_grow_time = math.random(5000) + 4040 - (40 * fertility) --< Fertile tiles will grow faster than barren tiles
		table.insert(global.bi.tree_growing, {position = position, time = event.tick + max_grow_time, surface = surface})
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

local function Grow_tree(position, surface)
	
	local foundtree = false
	local tree = surface.find_entity("seedling", position)
	local tree2 = surface.find_entity("seedling-2", position)
	local tree3 = surface.find_entity("seedling-3", position)
	
	local currentTilename = surface.get_tile(position.x, position.y).name
	--writeDebug("The current tile is: " .. currentTilename)
	local fertility = 1 -- fertility will be 1 if terrain type not listed above, so very small change to grow.
	local growth_chance = math.random(100) -- Random value. Tree will grow if it's this value is smaller that the 'Fertility' value

				
	if tree then
		foundtree = true
		tree.destroy()
		
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


			--writeDebug("The current tile is: " .. currentTilename)
			--writeDebug("The Growth Chance is: " .. growth_chance)
			--writeDebug("The Fertility is: " .. fertility)
			--writeDebug(treetype)



		
		---- Hardcode anything else to tree 9 for now.
		else
			treetype = "tree-09"
			
			writeDebug("Terrain or Fertility not found")
			--writeDebug("The Growth Chance is: " .. growth_chance)
			--writeDebug("The Fertility is: " .. fertility)
			--writeDebug("The current tile is: " .. currentTilename)
			writeDebug(CurrentTilename)
			
			if growth_chance <= fertility and foundtree and surface.can_place_entity({ name=treetype, position=position}) then
				surface.create_entity({ name=treetype, amount=1, position=position})
			end
		
		writeDebug("The Fertility is: " .. fertility)		
		end		

	end
	
	--- Standard Seed Bomb
	if tree2 then
		foundtree = true
		tree2.destroy()
		
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


			--writeDebug("The current tile is: " .. currentTilename)
			--writeDebug("The Growth Chance is: " .. growth_chance)
			--writeDebug("The Fertility is: " .. fertility)
			--writeDebug(treetype)



		
		---- Hardcode anything else to tree 9 for now.
		else
			treetype = "tree-09"
			
			writeDebug("Terrain or Fertility not found")
			--writeDebug("The Growth Chance is: " .. growth_chance)
			--writeDebug("The Fertility is: " .. fertility)
			--writeDebug("The current tile is: " .. currentTilename)
			writeDebug(CurrentTilename)
			
			if growth_chance <= fertility and foundtree and surface.can_place_entity({ name=treetype, position=position}) then
				surface.create_entity({ name=treetype, amount=1, position=position})
			end
		
		writeDebug("The Fertility is: " .. fertility)		
		end		

	end
	
	--- Advanced Seed Bomb
	if tree3 then
		foundtree = true
		tree3.destroy()
		
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


			--writeDebug("The current tile is: " .. currentTilename)
			--writeDebug("The Growth Chance is: " .. growth_chance)
			--writeDebug("The Fertility is: " .. fertility)
			--writeDebug(treetype)



		
		---- Hardcode anything else to tree 9 for now.
		else
			treetype = "tree-09"
			
			writeDebug("Terrain or Fertility not found")
			--writeDebug("The Growth Chance is: " .. growth_chance)
			--writeDebug("The Fertility is: " .. fertility)
			--writeDebug("The current tile is: " .. currentTilename)
			writeDebug(CurrentTilename)
			
			if growth_chance <= fertility and foundtree and surface.can_place_entity({ name=treetype, position=position}) then
				surface.create_entity({ name=treetype, amount=1, position=position})
			end

		writeDebug("The Fertility is: " .. fertility)			
		end		

	end
end



---- Growing Tree
Event.register(defines.events.on_tick, function(event)	


	while #global.bi.tree_growing > 0 do
		if event.tick < global.bi.tree_growing[1].time then
			break 
		end

		Grow_tree(global.bi.tree_growing[1].position, global.bi.tree_growing[1].surface)
		table.remove(global.bi.tree_growing, 1)
	end

end)






