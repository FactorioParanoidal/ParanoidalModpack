

function purgeLocoFromPairs(loco)
	-- Purge pairs with these same locomotives before adding a new pair with them
	-- Safe remove-while-iterating algorithm from 
	-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
	local n = #storage.mu_pairs
	local done = false
	for i=1,n do
		local entry = storage.mu_pairs[i]
		if (entry[1] == loco or entry[2] == loco) then
			-- This old pair has the given loco, so it is invalid
			storage.mu_pairs[i] = nil
		end
	end
	local j=0
	for i=1,n do
		if storage.mu_pairs[i] ~= nil then
			j = j+1
			storage.mu_pairs[j] = storage.mu_pairs[i]
		end
	end
	for i=j+1,n do
		storage.mu_pairs[i] = nil
	end

end

return purgeLocoFromPairs