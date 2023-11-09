Set = {}
function Set:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.list = o.list or {}
	return o
end
function Set:contains(elem)
	for k,v in pairs(self.list) do
		if v == elem then
			return true
		end
	end
	
	return false
end
function Set:add(elem)
	if not self:contains(elem) then
		self.list[#self.list+1] = elem
	end
end
function Set:remove(elem)
	for i,v in pairs(self.list) do
		if v == elem then
			table.remove(self.list, i)
			break
		end
	end
end