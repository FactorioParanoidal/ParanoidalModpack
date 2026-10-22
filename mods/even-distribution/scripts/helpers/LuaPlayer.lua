local config = require("config")
local qualities = require("scripts.quality")
local player = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaPlayer --

function player:setting(name)
	if name == "enableDragDistribute" then
		if settings.global["disable-distribute"].value then return false end
	elseif name == "enableInventoryCleanupHotkey" then
		if settings.global["disable-inventory-cleanup"].value then return false end
	elseif name == "cleanupDropRange" then
		return math.min(storage.settings[self.index].cleanupDropRange, settings.global["global-max-inventory-cleanup-range"].value)
	end

	local setting = storage.settings[self.index][name]
	if setting == nil and self.mod_settings[name] then return self.mod_settings[name].value end
	return setting
end

function player:changeSetting(name, newValue)
	local setting = storage.settings[self.index]
	if setting[name] == nil and self.mod_settings[name] then 
		self.mod_settings[name] = { value = newValue } 
	else
		setting[name] = newValue
	end
end

function player:droprange()
	return math.min(self.reach_distance * config.rangeMultiplier, self:setting("cleanupDropRange"))
end

-- Paranoidal: items of every quality. Returns an array of { name, quality, count } to distribute: everything in
-- the trash slots plus the surplus of the main inventory and cursor over the logistic slots (or the default trash
-- list, the same amount for every quality). A logistic slot takes the qualities its quality and comparator match
-- (first matching slot); its target applies to their total and the surplus is taken worst quality first.
function player:trashItems()
	local cleanupRequestOverflow = self:setting("cleanupRequestOverflow")
	local defaultTrash           = storage.defaultTrash
	local logisticSlots          = self:has("valid", "character") and _(self.character):logisticSlots() or {}
	local trash                  = self:qualityContents("character_trash")

	local function add(entry, surplus)
		if surplus <= 0 then return end
		local key = qualities.key(entry.name, entry.quality)
		local existing = trash[key]
		if existing then
			existing.count = existing.count + surplus
		else
			trash[key] = { name = entry.name, quality = entry.quality, count = surplus }
		end
	end

	local byName = {}
	for __,entry in pairs(self:qualityContents()) do
		local list = byName[entry.name] or {}
		list[#list + 1] = entry
		byName[entry.name] = list
	end

	for item,entries in pairs(byName) do
		local unassigned = entries
		for __,slot in ipairs(logisticSlots[item] or {}) do
			local matched, rest = {}, {}
			for __,entry in ipairs(unassigned) do
				if qualities.matches(slot, entry.quality) then matched[#matched + 1] = entry else rest[#rest + 1] = entry end
			end
			unassigned = rest

			local targetAmount = nil
			if cleanupRequestOverflow and slot.count > 0 then -- request overflow
				targetAmount = slot.count
			elseif slot.max_count ~= nil then -- max value set to infinity = no autotrash
				targetAmount = slot.max_count
			end

			if targetAmount ~= nil and #matched > 0 then
				local total = 0
				for __,entry in ipairs(matched) do total = total + entry.count end
				local surplus = total - targetAmount
				table.sort(matched, function(a, b)
					local ra, rb = qualities.rank(a.quality), qualities.rank(b.quality)
					if ra ~= rb then return ra < rb end
					return a.quality < b.quality
				end)
				for __,entry in ipairs(matched) do
					if surplus <= 0 then break end
					local take = math.min(entry.count, surplus)
					add(entry, take)
					surplus = surplus - take
				end
			end
			if #unassigned == 0 then break end
		end

		-- qualities without a logistic slot: default trash list
		local targetAmount = defaultTrash[item]
		if targetAmount ~= nil then
			for __,entry in ipairs(unassigned) do add(entry, entry.count - targetAmount) end
		end
	end

	local list = {}
	for __,entry in pairs(trash) do list[#list + 1] = entry end
	table.sort(list, function(a, b)
		if a.name ~= b.name then return a.name < b.name end
		return qualities.rank(a.quality) < qualities.rank(b.quality)
	end)
	return list
end

-- Paranoidal: quality (name, nil = normal) is passed through the item functions of the player; the
-- original handled normal quality only (string item names mean normal quality in the 2.0 API).
local function sameItem(stack, item, quality)
	return stack and stack.valid_for_read and stack.name == item and stack.quality.name == (quality or "normal")
end

local function withQuality(item, quality)
	return { name = item, quality = quality or "normal" }
end

function player:playeritemcount(item, includeInv, includeCar, quality)
	local count = 0
	
	local cursor_stack = self.cursor_stack
	if sameItem(cursor_stack, item, quality) then
		count = count + cursor_stack.count
	elseif not includeInv and not includeCar then
		return storage.cache[self.index].cursorStackCount or 0
	end

	if includeInv then
		local mainInv = self:inventory(); 
		if _(mainInv):is("valid") then count = count + mainInv.get_item_count(withQuality(item, quality)) end
	end

	if includeCar and self.driving and self:has("valid", "vehicle") then
		local vehicleInv = _(self.vehicle):inventory("car_trunk")
		if _(vehicleInv):is("valid") then count = count + vehicleInv.get_item_count(withQuality(item, quality)) end
	end
		   
	return count
end

function player:playercontents()
	local contents     = self:contents("main")
	local cursor_stack = self.cursor_stack
	
	if cursor_stack and cursor_stack.valid_for_read and cursor_stack.quality.name == "normal" then -- contents: normal quality
		local item = cursor_stack.name
		contents[item] = (contents[item] or 0) + cursor_stack.count
	end
		   
	return contents
end

function player:removeItems(item, amount, takeFromInv, takeFromCar, takeFromTrash, quality)
	quality = quality or "normal"
	local removed = 0
	if takeFromTrash then
		local trash = self:inventory("character_trash")
		if _(trash):is("valid") then
			removed = trash.remove{ name = item, quality = quality, count = amount }
			if amount <= removed then return removed end
		end
	end	

	if takeFromInv then
		local main = self:inventory()
		if _(main):is("valid") then
			removed = removed + main.remove{ name = item, quality = quality, count = amount - removed }
			if amount <= removed then return removed end
		end
	end
	
	local cursor_stack = self.cursor_stack
	if sameItem(cursor_stack, item, quality) then
		local result = math.min(cursor_stack.count, amount - removed)
		removed = removed + result
		cursor_stack.count = cursor_stack.count - result
		if amount <= removed then return removed end
	elseif not takeFromInv and not takeFromCar and not takeFromTrash then
		local main = self:inventory()
		if _(main):is("valid") then
			return removed + main.remove{ name = item, quality = quality, count = amount - removed }
		end
	end
	
	if takeFromCar and self.driving and self:has("valid", "vehicle") then
		local vehicleInv = _(self.vehicle):inventory("car_trunk")
		if _(vehicleInv):is("valid") then removed = removed + vehicleInv.remove{ name = item, quality = quality, count = amount - removed } end
	end
	
	return removed
end

function player:returnItems(item, amount, takenFromCar, takenFromTrash, quality)
	quality = quality or "normal"
	local remaining = amount - self.insert{ name = item, quality = quality, count = amount }
	
	if remaining > 0 and takenFromCar and self.driving and self:has("valid", "vehicle") then
        local vehicleInv = _(self.vehicle):inventory("car_trunk")
        if _(vehicleInv):is("valid") then remaining = remaining - vehicleInv.insert{ name = item, quality = quality, count = remaining } end
	end
	
	if remaining > 0 and takenFromTrash then
        local trash = self:inventory("character_trash")
        if _(trash):is("valid") then remaining = remaining - trash.insert{ name = item, quality = quality, count = remaining } end
	end
	
	if remaining > 0 then
		self.print({"cant-clear-cursor", {"item-name."..item}})
		self.surface.spill_item_stack{
			position = self.position, 
			stack = { name = item, quality = quality, count = remaining },
			enable_looted = false,
			allow_belts = false
		}
	end
end

function player:itemLimit(prototype, profile)
	if profile then
		local limit = self:setting(profile.valueSetting)
		local type = self:setting(profile.typeSetting)

		if type == "items" then
			return math.ceil(limit)
		elseif type == "stacks" then
			return math.ceil(limit * (prototype.stack_size or 1))
		elseif type == "mj" then
			return math.ceil((limit * 1000000) / (prototype.fuel_value or 1))
		end
	end

	return math.huge
end