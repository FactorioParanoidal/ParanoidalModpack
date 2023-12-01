function getLinearArray(num)
	local ret = {}
	for i = 1,num do
		ret[i] = i
	end
	return ret
end

function getArrayOf(vals, num)
	local ret = {}
	while #ret < num do
		for i,e in pairs(vals) do
			if #ret < num then
				table.insert(ret, e)
			end
		end
	end
	return ret
end

function hasCollisionMask(object, mask)
	return object.prototype and object.prototype.collision_mask[mask]
end

function getTableSize(val)
	if not val then return -1 end
	if type(val) ~= "table" then error("Value '" .. serpent.block(val) .. "' is not a table!") end
--[[
	local count = 0
	for key,num in pairs(val) do
		count = count+1
	end
	return count
	--]]
	return table_size(val)
end

function areTablesEqual(t1, t2)
	if getTableSize(t1) ~= getTableSize(t2) then return false end
	for i,e in ipairs(t1) do
		if type(e) == "table" then
			if not areTablesEqual(e, t2[i]) then return false end
		else
			if t2[i] ~= e then return false end
		end
	end
	return true
end


function getRandomTableEntry(value, randFunc)
	local size = getTableSize(value)
	local idx = randFunc and randFunc(0, size-1) or math.random(0, size-1)
	--game.print(idx .. "/" .. size)
	local i = 0
	for key,val in pairs(value) do
		--game.print(i .. " >> " .. val)
		if i == idx then
			--game.print(val)
			return val
		end
		i = i+1
	end
end

function removeEntryFromListIf(list, func)
	for i = #list,1,-1 do
		if func(list[i]) then
			table.remove(list, i)
		end
	end
end

function removeEntryFromList(list, val)
	for i = #list,1,-1 do
		if list[i] == val then
			table.remove(list, i)
		end
	end
end

function listHasValue(list, val)
	for _,entry in pairs(list) do
		if type(val) == "table" then
			log("Checking tables in " .. serpent.block(list))
			if areTablesEqual(entry, val) then return end
		else
			if entry == val then return true end
		end
	end
end

function removeNilValues(list)
	local ret = {}
	for i,entry in pairs(list) do
		if entry then
			ret[#ret+1] = entry
		end
	end
	return ret
end

function getHighestTableKey(list)
	local lim = -9999999
	local ret = nil
	for k,v in pairs(list) do
		if v > lim then
			lim = v
			ret = k
		end
	end
	return ret
end

function isTableAnArray(t)
	return #t == getTableSize(t)--[[
	--are all indices numerical; count for later
	local count = 0
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		else
			count = count+1
		end
	end
	
	--check if indices are 1->N in order
	for i = 1,count do
		if (not t[i]) and type(t[i]) ~= "nil" then --The value might be nil, have to check the type too
			return false
		end
	end
	return true--]]
end
