local util = scripts.util
local config = require("config")
local entity = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaEntity --

function entity:entityrequests() -- fetch all requests as table
	local requests = {}
	
    if self.request_slot_count > 0 then
		for i = 1, self.request_slot_count do
			local request = self.get_request_slot(i)
			if request then
				local item, amount = request.name, request.count
				if amount > 0 then
					requests[item] = math.max(requests[item] or 0, amount)
				end
			end
		end
	end
	
	return requests
end

function entity:entityrequest(item) -- fetch specific item request
	local count = 0

	if self.request_slot_count > 0 then
		for i = 1, self.request_slot_count do
			local request = self.get_request_slot(i)
			if request and request.name == item and request.count > count then 
				count = math.max(count, request.count)
			end
		end
	end

	return count
end

function entity:logisticSlots() -- fetch all requests as table
	local logisticSlots = {}

    if self.request_slot_count > 0 then
		for i = 1, self.request_slot_count do
			local slot = self.get_personal_logistic_slot(i)
			if slot and slot.name then
				logisticSlots[slot.name] = slot
			end
		end
	end
	
	return logisticSlots
end

function entity:isIgnored(player)
	return not global.allowedEntities[self.name] or
		   global.settings[player.index].ignoredEntities[self.name]
end

function entity:recipe()
	return _(self.get_recipe() or (self.type == "furnace" and self.previous_recipe))
end

-- for turrets
function entity:supportsAmmo(item)
	local ammoType = item.get_ammo_type("turret") or item.get_ammo_type()

	if ammoType then
		local attackParameters = self.prototype.attack_parameters

		if attackParameters then
			return _(attackParameters.ammo_categories):contains(ammoType.category)
		elseif self.type == "artillery-turret" or self.type == "artillery-wagon" then
			return ammoType.category == "artillery-shell"
		end
	end

	return false
end

-- for furnace
function entity:canSmelt(item)
	return #game.get_filtered_recipe_prototypes({
		unpack(_(self.prototype.crafting_categories):map(function(category)
			return nil, {filter = "category", category = category, mode = "or"}
		end):toPlain()),
		{filter = "has-ingredient-item", elem_filters = {{filter = "name", name = item}}, mode = "and"},
	}) > 0
end