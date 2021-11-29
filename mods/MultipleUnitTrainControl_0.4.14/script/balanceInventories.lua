--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: balanceInventories.lua
 * Description: Equalizes the contents of two inventories whenever possible.
 *    Applies to all items types separately.
 *    Mixed inventories may not be balanced correctly if there are no empty slots.
 *    Last item will be repeatedly swapped between inventories until it is consumed.
--]]


function balanceInventories(inventoryOne, inventoryTwo)
	if inventoryOne and inventoryTwo and inventoryOne.valid and inventoryTwo.valid then
		local locoOneInventory = inventoryOne.get_contents()
		local locoTwoInventory = inventoryTwo.get_contents()
	  
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
				itemsToMove = inventoryTwo.insert({name=k,count=itemsToMove})
				if itemsToMove > 0 then  -- Can't remove zero items :D
					inventoryOne.remove({name=k,count=itemsToMove})
				end
			elseif itemsToMove < 0 then
				-- locoTwo has more items
				itemsToMove = inventoryOne.insert({name=k,count=-1*itemsToMove})
				if itemsToMove > 0 then
					inventoryTwo.remove({name=k,count=itemsToMove})
				end
			end
		end
	else
		game.print("MUTC Balancer ignoring invalid inventories")
	end
end

return balanceInventories
