local config = require("config")
local player = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaPlayer --

function player:setting(name)
    return self.mod_settings[name].value
end

function player:droprange()
	return math.min(self.reach_distance * config.rangeMultiplier, self:setting("max-inventory-cleanup-drop-range"))
end

function player:trashItems()
	local customTrash  = global.settings[self.index].customTrash
	local defaultTrash = global.defaultTrash
	local trash        = self:contents("character_trash")
	
	local requests, autoTrash
	if self:has("valid", "character") then 
		autoTrash = self.auto_trash_filters

		if self:setting("cleanup-logistic-request-overflow") then 
			requests = self:requests()
		else 
			requests = {} 
		end
	else 
		requests = {} 
		autoTrash = {}
	end

	for item,count in pairs(self:contents()) do
		local targetAmount = autoTrash[item] or requests[item] or customTrash[item] or defaultTrash[item]
		
		if targetAmount then
			local surplus = count - targetAmount
			if surplus > 0 then trash[item] = (trash[item] or 0) + surplus end
		end
	end
	
	return trash
end

function player:playeritemcount(item, includeCar)
	local mainInv      = self:inventory(); if _(mainInv):isnot("valid") then return 0 end
	local cursor_stack = self.cursor_stack
	local count        = mainInv.get_item_count(item)
	
	if cursor_stack.valid_for_read and cursor_stack.name == item then
		count = count + cursor_stack.count
	end
	
	if includeCar and self.driving and self:has("valid", "vehicle") then
		local vehicleInv = _(self.vehicle):inventory("car_trunk")
		if _(vehicleInv):is("valid") then count = count + vehicleInv.get_item_count(item) end
	end
		   
	return count
end

function player:playercontents()
	local contents     = self:contents("main")
	local cursor_stack = self.cursor_stack
	
	if cursor_stack.valid_for_read then
		local item = cursor_stack.name
		contents[item] = (contents[item] or 0) + cursor_stack.count
	end
		   
	return contents
end

function player:removeItems(item, amount, takeFromCar, takeFromTrash)
	local removed = 0
	if takeFromTrash then
		local trash = self:inventory("character_trash")
		if _(trash):is("valid") then
			removed = trash.remove{ name = item, count = amount }
			if amount <= removed then return removed end
		end
	end	

	local main = self:inventory()
	if _(main):is("valid") then
		removed = removed + main.remove{ name = item, count = amount - removed }
		if amount <= removed then return removed end
	end

	local cursor_stack = self.cursor_stack
	if cursor_stack.valid_for_read and cursor_stack.name == item then
		local result = math.min(cursor_stack.count, amount - removed)
		removed = removed + result
		cursor_stack.count = cursor_stack.count - result
		if amount <= removed then return removed end
	end
	
	if takeFromCar and self.driving and self:has("valid", "vehicle") then
		local vehicleInv = _(self.vehicle):inventory("car_trunk")
		if _(vehicleInv):is("valid") then removed = removed + vehicleInv.remove{ name = item, count = amount - removed } end
	end
	
	return removed
end

function player:returnItems(item, amount, takenFromCar, takenFromTrash)
	local remaining = amount - self.insert{ name = item, count = amount }
	
	if remaining > 0 and takenFromCar and self.driving and self:has("valid", "vehicle") then
        local vehicleInv = _(self.vehicle):inventory("car_trunk")
        if _(vehicleInv):is("valid") then remaining = remaining - vehicleInv.insert{ name = item, count = remaining } end
	end
	
	if remaining > 0 and takenFromTrash then
        local trash = self:inventory("character_trash")
        if _(trash):is("valid") then remaining = remaining - trash.insert{ name = item, count = remaining } end
	end
	
	if remaining > 0 then
		self.surface.spill_item_stack(self.position, { name = item, count = remaining }, false)
	end
end