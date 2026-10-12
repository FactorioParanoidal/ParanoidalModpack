local util = {}

function util.doEvery(tick, func, args)
	if (game.tick % tick) == 0 then func(args) end
end

-- remove leading and trailing whitespaces
function util.trim(str)
  return str and (str:gsub("^%s*(.-)%s*$", "%1")) or ""
end

-- trim and also remove multiple whitespaces
function util.fullTrim(str)
  return (util.trim(str):gsub("[ \t\r\n]*[\r\n][ \t\r\n]*", "\r\n"):gsub("[ \t]+", " "))
end

-- escape string for use with regex
local quotepattern = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
function util.escape(str)
    return str:gsub(quotepattern, "%%%1")
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
	return util.isValid(player) and 
		   player.connected and (
		       player.controller_type == defines.controllers.character or
		       player.controller_type == defines.controllers.god or
		       player.controller_type == defines.controllers.editor
		   )
end

function util.isCraftingMachine(entity)
	return entity.type == "furnace" or entity.type == "assembling-machine" or entity.type == "rocket-silo"
end

function util.shallowCopy(original) -- Creates a shallow copy of a table
    local copy = {}
    for key,value in pairs(original) do copy[key] = value  end
    return copy
end

function util.hasInventory(prototype)
	for __,index in pairs(defines.inventory) do
		if prototype.get_inventory_size(index) then return true end
	end
	return false
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
	-- Paranoidal: iterate a snapshot. The old hand-written walker reused the x key of the previous
	-- surface and failed on the empty sub-tables that removals leave behind.
	local values, n = {}, 0
	local tblId = rawget(tbl, "id")
	if tblId then
		for __, value in pairs(tblId) do
			n = n + 1
			values[n] = value
		end
	end
	local tblPos = rawget(tbl, "pos")
	if tblPos then
		for __, bySurface in pairs(tblPos) do
			for __, byX in pairs(bySurface) do
				for __, value in pairs(byX) do
					n = n + 1
					values[n] = value
				end
			end
		end
	end

	local i = 0
	return function()
		i = i + 1
		return values[i]
	end
end

return util