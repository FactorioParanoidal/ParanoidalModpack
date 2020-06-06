--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: addPairToGlobal.lua
 * Description: Takes a new pair of MU locomotives, removes their former pairs, and adds the new one to global.mu_pairs.
--]]


function addPairToGlobal(new_pair)
	-- Purge pairs with these same locomotives before adding a new pair with them
	-- Safe remove-while-iterating algorithm from 
	-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
	local n = #global.mu_pairs
	local done = false
	for i=1,n do
		local entry = global.mu_pairs[i]
		if (entry[1] == new_pair[1] and entry[2] == new_pair[2]) or
		   (entry[1] == new_pair[2] and entry[2] == new_pair[1]) then
			-- This pair is already in the list, don't have to add it
			done = true
			break
		end
		if (entry[1] == new_pair[1] or entry[2] == new_pair[1] or
		    entry[1] == new_pair[2] or entry[2] == new_pair[2]) then
			-- This old pair has only one member of the new one, so it is invalid
			global.mu_pairs[i] = nil
		end
	end
	local j=0
	for i=1,n do
		if global.mu_pairs[i] ~= nil then
			j = j+1
			global.mu_pairs[j] = global.mu_pairs[i]
		end
	end
	for i=j+1,n do
		global.mu_pairs[i] = nil
	end
	
	if done == false then
		table.insert(global.mu_pairs, new_pair)
	end
end

return addPairToGlobal
