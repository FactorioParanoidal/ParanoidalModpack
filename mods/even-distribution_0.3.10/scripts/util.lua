local util = {}
local config = require("config")

function util.doEvery(tick, func, args)
	if (game.tick % tick) == 0 then func(args) end
end

function util.isValid(object)
	return object and object.valid
end

function util.destroyIfValid(object)
	if util.isValid(object) then object.destroy() end
end

function util.isValidStack(stack)
	return util.isValid(stack) and stack.valid_for_read
end

function util.isValidPlayer(player) -- valid, connected and alive player
	return util.isValid(player) and player.connected and player.controller_type ~= defines.controllers.ghost
end

function util.isCraftingMachine(entity)
	return entity.type == "furnace" or entity.type == "assembling-machine" or entity.type == "rocket-silo"
end

function util.shallowCopy(original) -- Creates a shallow copy of a table
    copy = {}
    for key,value in pairs(original) do copy[key] = value  end
    return copy
end

function util.countTable(tbl)
	local count = 0
	for __ in pairs(tbl) do count = count + 1 end
	return count
end

function util.isEmpty(tbl) -- empty table
	return type(tbl) == "table" and next(tbl) == nil
end

function util.isFilled(tbl) -- filled table
	return type(tbl) == "table" and next(tbl) ~= nil
end

function util.distribute(entities, totalItems, func)
	local insertAmount = math.floor(totalItems / #entities)
	local remainder = totalItems % #entities
	
	for entity in util.epairs(entities) do
		if util.isValid(entity) then
			local amount = insertAmount
			if remainder > 0 then
				amount = amount + 1
				remainder = remainder - 1
			end

			func(entity, amount)
		end
	end
end

function util.epairs(tbl) -- iterator for tables with entity based indices
	local id, start
	local surface, x, y
	local tbls, tblsx, value
	
	tblId = rawget(tbl, "id")
	tblPos = rawget(tbl, "pos")
	if tblId then
		start = true
	elseif not tblPos then
		return function () end
	end
	
	return function () 		-- Iterator
		if id or start then
			start = false
			id, value = next(tblId, id)
			
			if value == nil then
				if not tblPos then return end
				surface, tbls = next(tblPos)
				if not tbls then return end
				x, tblsx = next(tbls)
			else
				return value
			end
		end
		
		while value == nil do
			y, value = next(tblsx, y)
			
			if value == nil then
				x, tblsx = next(tbls, x)
				y = nil
				
				if not tblsx then
					surface, tbls = next(tblPos, surface)
					if not tbls then return end
					x, tblsx = next(tbls, x)
					y = nil
				end
			end
		end
		
		return value
	end
end

return util