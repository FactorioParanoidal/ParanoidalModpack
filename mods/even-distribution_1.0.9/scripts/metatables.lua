local this = {}

local getmetatable, setmetatable, type, rawget, rawset = getmetatable, setmetatable, type, rawget, rawset

function this.uses(obj, name)
    return getmetatable(obj) == this[name]
end

function this.use(obj, name)
	if type(obj) == "table" then 
		rawset(obj, "__mt", name)
		return setmetatable(obj, this[name]) 
	end
end

function this.set(obj, name) -- not persistent
	if type(obj) == "table" then 
		return setmetatable(obj, this[name]) 
	end
end

function this.new(name)
	return setmetatable({ __mt = name }, this[name])
end

function this.refresh(obj)
	if type(obj) == "table" and not obj.__self then 
		for key,val in pairs(obj) do
			this.refresh(val)
		end

		local name = rawget(obj, "__mt")
		if type(name) == "string" then
			local mt = this[name]
			if mt then return setmetatable(obj, mt) end
		end
	end
end

this.entityAsIndex = { -- metatable for using an entity as a table index
	__index = function (tbl, entity)
		if type(entity) == "table" and entity.valid then
			local id = entity.unit_number
			
			if id then
				local tblId = rawget(tbl, "id")
				if tblId then return tblId[id] end
			else
				local tblPos = rawget(tbl, "pos")
			
				if tblPos then 
					local surface, pos = entity.surface.name, entity.position
					local x, y = pos.x, pos.y
					local tbls = tblPos[surface]
					
					if tbls then
						local tblsx = tbls[x]
						if tblsx then return tblsx[y] end
					end
				end
			end
		end
    end,
	
	__newindex = function (tbl, entity, value)
		local id = entity.unit_number
		local count = rawget(tbl, "count") or 0
		
		if id then -- entities indexed by unit number
			local tblId = rawget(tbl, "id")
			
			if tblId then 
				local oldvalue = tblId[id]
				if value ~= oldvalue then
					if value == nil then
						rawset(tbl, "count", count - 1)
					else
						rawset(tbl, "count", count + 1)
					end
					
					tblId[id] = value
				end
			elseif value ~= nil then
				rawset(tbl, "id", { [entity.unit_number] = value })
				rawset(tbl, "count", count + 1)
			end
		else -- other entities that don't support unit number indexed by their surface and position
			local surface, pos = entity.surface.name, entity.position
			local x, y = pos.x, pos.y
			local tblPos = rawget(tbl, "pos")
			
			if tblPos then
				local tbls = tblPos[surface]
				
				if tbls then
					local tblsx = tbls[x]
					
					if tblsx then
						local oldvalue = tblsx[y]
						if value ~= oldvalue then
							if value == nil then
								rawset(tbl, "count", count - 1)
							else
								rawset(tbl, "count", count + 1)
							end
							
							tblsx[y] = value
						end
					elseif value ~= nil then
						tbls[x] = { [y] = value }
						rawset(tbl, "count", count + 1)
					end
				elseif value ~= nil then
					tblPos[surface] = { [x] = { [y] = value } }
					rawset(tbl, "count", count + 1)
				end
			elseif value ~= nil then
				rawset(tbl, "pos", { [surface] = { [x] = { [y] = value } } })
				rawset(tbl, "count", count + 1)
			end
		end
	end,
	
	__len = function (tbl)
		return rawget(tbl, "count") or 0
	end,
}

return this