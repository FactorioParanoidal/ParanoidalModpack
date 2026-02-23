--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: balanceInventories.lua
 * Description: Equalizes the contents of two inventories whenever possible.
 *    Applies to all items types separately.
 *    Mixed inventories may not be balanced correctly if there are no empty slots.
 *    Last item will be repeatedly swapped between inventories until it is consumed.
--]]

local function itemKey(entry)
  return entry.name.." "..entry.quality
end

local function itemFromKey(key, count)
  for name,quality in string.gmatch(key, "([^%s]+) ([^%s]+)") do
    return {name=name, quality=quality, count=count}
  end
end

function balanceInventories(inventoryOne, inventoryTwo, settings_debug)
	if inventoryOne and inventoryTwo and inventoryOne.valid and inventoryTwo.valid then
		-- Convert inventory structures to flat dictionaries for processing
    local locoOneInventory = {}
    for _,e in pairs(inventoryOne.get_contents()) do
      locoOneInventory[itemKey(e)] = (locoOneInventory[itemKey(e)] or 0) + e.count
    end
		local locoTwoInventory = {}
    for _,e in pairs(inventoryTwo.get_contents()) do
      locoTwoInventory[itemKey(e)] = (locoTwoInventory[itemKey(e)] or 0) + e.count
    end
		
	  -- loop for each item in locoTwo, add it to locoOne if it's not already there
    
		for k,v in pairs(locoTwoInventory) do
			if not locoOneInventory[k] then
				locoOneInventory[k] = 0
			end
		end
	  
		-- loop over items in locoOne and locoTwo
		for k,v in pairs(locoOneInventory) do
			if not locoTwoInventory[k] then
			  locoTwoInventory[k] = 0
			end
      
      local itemsToMove = math.floor((locoOneInventory[k] - locoTwoInventory[k])/2)
			if itemsToMove > 0 then
				-- locoOne has more items. insert up to this number in locoTwo
				local item = itemFromKey(k, itemsToMove)
        itemsToMove = inventoryTwo.insert(item)
				if itemsToMove > 0 then  -- Can't remove zero items :D
          item.count = itemsToMove
					inventoryOne.remove(item)
				end
			elseif itemsToMove < 0 then
				-- locoTwo has more items
				local item = itemFromKey(k, -1*itemsToMove)
        itemsToMove = inventoryOne.insert(item)
				if itemsToMove > 0 then
          item.count = itemsToMove
					inventoryTwo.remove(item)
				end
			end
		end
	elseif settings_debug == "debug" then
		game.print("MUTC Balancer ignoring invalid inventories")
	end
end

return balanceInventories
