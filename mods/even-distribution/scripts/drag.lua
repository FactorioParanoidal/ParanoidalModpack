local this = {}
local util = scripts.util
local visuals = scripts.visuals
local metatables = scripts.metatables
local protocache = require("scripts.protocache")
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

-- Paranoidal: on_tick and the entity-removal events are registered only while a distribution is
-- pending (about distributionDelay seconds after a CTRL+click drag). Upstream kept on_tick running
-- forever and handled every on_entity_died (every killed biter) by probing all players' caches.
local REMOVAL_EVENTS = {
	defines.events.on_pre_player_mined_item,
	defines.events.on_robot_pre_mined,
	defines.events.on_entity_died,
	defines.events.script_raised_destroy,
}
local registered = nil

local function unwrap(cache) -- pending events of old saves hold helper wrappers
	return type(cache) == "table" and rawget(cache, "__on") or cache
end

local function hasPendingEvents()
	return storage.distrEvents ~= nil and next(storage.distrEvents) ~= nil
end

function this.updateRegistration()
	local active = hasPendingEvents()
	if active == registered then return end
	registered = active

	if active then
		script.on_event(defines.events.on_tick, this.handleTick)
		for __,event in ipairs(REMOVAL_EVENTS) do
			script.on_event(event, this.handleEntityRemoved)
		end
	else
		script.on_event(defines.events.on_tick, nil)
		for __,event in ipairs(REMOVAL_EVENTS) do
			script.on_event(event, nil)
		end
	end
end

function this.on_load()
	registered = nil
	this.updateRegistration()
end

function this.on_init()
	registered = nil
	this.updateRegistration()
end

this.on_configuration_changed = this.on_init

function this.handleTick(event) -- handles distribution events
	local distrEvents = storage.distrEvents
	local tick = event.tick

	local due = distrEvents[tick]
	if due then
		distrEvents[tick] = nil
		for player_index, cache in pairs(due) do
			cache = unwrap(cache)
			local player = _(game.get_player(player_index))

			if player:is("valid player") then
				if player:setting("distributionMode") == "distribute" then
					this.distributeItems(player, cache)
				else
					this.balanceItems(player, cache)
				end
			end

			this.resetCache(cache)
		end
	end

	-- drop stale/empty buckets (e.g. left by player death or old saves) so the handler can stop
	for eventTick, bucket in pairs(distrEvents) do
		if eventTick < tick or next(bucket) == nil then
			for __,cache in pairs(bucket) do this.resetCache(unwrap(cache)) end
			distrEvents[eventTick] = nil
		end
	end

	this.updateRegistration()
end

function this.distributeItems(player, cache)
	local useFuelLimit = player:setting("dragUseFuelLimit")
	local useAmmoLimit = player:setting("dragUseAmmoLimit")
	local takeFromInv  = player:setting("takeFromInventory")
	local takeFromCar  = player:setting("takeFromCar")
	local replaceItems = player:setting("replaceItems")
	local item         = cache.item
	local totalItems   = player:itemcount(item, takeFromInv, takeFromCar)

	if cache.half then totalItems = math.ceil(totalItems / 2) end

	util.distribute(cache.entities, totalItems, function(entity, amount)

		local itemsInserted = 0
		local color
		
		if amount > 0 then
			local takenFromPlayer = player:removeItems(item, amount, takeFromInv, takeFromCar, false)
			
			if takenFromPlayer < amount then color = config.colors.insufficientItems end
			
			if takenFromPlayer > 0 then
				itemsInserted = entity:customInsert(player, item, takenFromPlayer, takeFromCar, false, replaceItems, useFuelLimit, useAmmoLimit, false, {
					-- if modules are recipe ingredients, dont put into module slots
					-- modules = not entity:is("crafting machine") or not _(entity.get_recipe()):hasIngredient(item),
					output = false,
				})

				local failedToInsert = takenFromPlayer - itemsInserted
				if failedToInsert > 0 then
					player:returnItems(item, failedToInsert, takeFromCar, false)
					color = config.colors.targetFull
				end
			end
		else
			color = config.colors.insufficientItems
		end
		
		-- feedback
		entity:spawnDistributionText(player,item, itemsInserted, 0, color)
		-- player.play_sound{ path = "utility/inventory_move" }

	end)
end

function this.balanceItems(player, cache)
	local useFuelLimit      = player:setting("dragUseFuelLimit")
	local useAmmoLimit      = player:setting("dragUseAmmoLimit")
	local takeFromInv       = player:setting("takeFromInventory")
	local takeFromCar       = player:setting("takeFromCar")
	local replaceItems      = player:setting("replaceItems")
	local item              = cache.item
	local entitiesToProcess = metatables.new("entityAsIndex")
	local itemCounts        = metatables.new("entityAsIndex")

	local totalItems  = player:itemcount(item, takeFromInv, takeFromCar)
	if cache.half then totalItems = math.ceil(totalItems / 2) end
	if totalItems > 0 then
		totalItems = player:removeItems(item, totalItems, takeFromInv, takeFromCar, false)
	end

	-- collect all items from all entities
	_(cache.entities):where("valid", function(entity)
		local count = _(entity):itemcount(item)
		local removed = 0
		if count > 0 then
			removed = entity.remove_item{ name = item, count = count }
			totalItems = totalItems + removed
		end

		-- save entities in new list
		entitiesToProcess[entity] = entity
		itemCounts[entity] = {
			original = count,
			remaining = count - removed,  -- amount above balanced level (unable to take out)
			current = count - removed,
		}
	end)

	-- distribute collected items evenly
	local i = 0
	while totalItems > 0 and #entitiesToProcess > 0 do -- retry if some containers full
		if i == 1000 then dlog("WARNING: Balance item loop did not finish!"); break end -- safeguard
		i = i + 1

		util.distribute(entitiesToProcess, totalItems, function(entity, amount)

			local itemCount = itemCounts[entity]
			
			amount = amount - itemCount.remaining
			if amount > 0 then
				local itemsInserted = entity:customInsert(player, item, amount, takeFromCar, false, replaceItems, useFuelLimit, useAmmoLimit, false, {
					-- if modules are recipe ingredients, dont put into module slots
					-- modules = not entity:is("crafting machine") or not _(entity.get_recipe()):hasIngredient(item),
					output = false,
				})

				itemCount.current = itemCount.current + itemsInserted
				totalItems = totalItems - itemsInserted

				local failedToInsert = amount - itemsInserted
				if failedToInsert > 0 then
					entity:spawnDistributionText(player,item, itemCount.current - itemCount.original, 0, config.colors.targetFull)
					entitiesToProcess[entity] = nil -- set nil while iterating bad?
					return
				end

				amount = 0
			end

			itemCount.remaining = -amount -- update remaining item count (amount above balanced level)
			-- add entity to new list?
		end)
	end

	_(entitiesToProcess):each(function(entity)
		local itemCount = itemCounts[entity]
		local amount = itemCount.current - itemCount.original
		_(entity):spawnDistributionText(player,item, amount, 0, (itemCount.current == 0) and config.colors.insufficientItems 
																				   or config.colors.default)
	end)

	if totalItems > 0 then
		player:returnItems(item, totalItems, takeFromCar, false)
	end
end

function this.on_fast_entity_transfer_hook(event) -- fires on every CTRL+click: keep it trivial
	local cache = storage.cache[event.player_index]
	if cache then cache.half = false end
end

function this.on_fast_entity_split_hook(event)
	local cache = storage.cache[event.player_index]
	if cache then cache.half = true end
end

-- Fires for every hovered entity of every player: cheapest checks first, no wrappers until the
-- hover can actually start a drag transfer (item in cursor over an eligible entity).
function this.on_selected_entity_changed(event)
	local index    = event.player_index
	local player   = game.get_player(index); if not player then return end
	local selected = player.selected        ; if not selected then return end
	local cursor_stack = player.cursor_stack
	if not (cursor_stack and cursor_stack.valid_for_read) then return end
	if cursor_stack.quality.name ~= "normal" then return end -- TODO: Add support for quality
	if not protocache.isAllowedEntity(selected.name) then return end

	local cache = storage.cache[index]; if not cache then return end
	player = _(player)
	if not util.isValidPlayer(player:toPlain()) or not player:setting("enableDragDistribute") then return end
	if _(selected):isIgnored(player) then return end

	local item = cursor_stack.name
	cache.selectedEvent = {
		tick             = event.tick,
		item             = item,
		itemCount        = selected.get_item_count(item),
		cursorStackCount = cursor_stack.count,
	}
end

function this.on_player_fast_transferred(event)
	if not event.from_player then return end -- only player -> entity transfers are distributed
	local index = event.player_index
	local cache = storage.cache[index]
	local selectedEvent = cache and cache.selectedEvent
	if not (selectedEvent and selectedEvent.tick == event.tick and selectedEvent.item) then return end

	local player   = _(game.get_player(index)); if player:isnot("valid player") or not player:setting("enableDragDistribute") then return end
	local selected = _(player.selected)       ; if selected:isnot("valid") or selected:isIgnored(player) then return end
	if event.entity ~= selected:toPlain() then return end

	cache.item             = selectedEvent.item
	cache.itemCount        = selected.get_item_count(selectedEvent.item) - selectedEvent.itemCount
	cache.cursorStackCount = selectedEvent.cursorStackCount

	this.onStackTransferred(selected, player, cache) -- handle stack transfer
end

function this.onStackTransferred(entity, player, cache) -- handle vanilla drag stack transfer
	local takeFromInv      = player:setting("takeFromInventory")
	local takeFromCar      = player:setting("takeFromCar")
	local distributionMode = player:setting("distributionMode")
	local item = cache.item
	local first = #cache.entities > 0 and util.epairs(cache.entities)() or nil

	if _(entity):is("valid") and not _(entity):isIgnored(player) and this.isEntityEligible(entity, item) and 
	   (_(first):isnot("valid") or ((first.type == "car" or  first.type == "spider-vehicle") and (entity.type == "car" or  entity.type == "spider-vehicle"))
	   				 		    or ((first.type ~= "car" and first.type ~= "spider-vehicle") and (entity.type ~= "car" and entity.type ~= "spider-vehicle"))) then
	
		local distrEvents = storage.distrEvents -- register new distribution event
		local oldBucket = cache.applyTick and distrEvents[cache.applyTick]
		if oldBucket then
			oldBucket[player.index] = nil
			if next(oldBucket) == nil then distrEvents[cache.applyTick] = nil end
		end
		
		-- wait before applying distribution (seconds defined in mod config)
		cache.applyTick = game.tick + math.max(math.ceil(60 * _(player):setting("distributionDelay")), 1)
		
		distrEvents[cache.applyTick] = distrEvents[cache.applyTick] or {}
		distrEvents[cache.applyTick][player.index] = unwrap(cache)
		this.updateRegistration()

		if not cache.entities[entity] then
			cache.markers[entity] = entity:mark(player, item)
			cache.entities[entity] = entity -- helper wrapper: distribution callbacks use its methods
		end

		if cache.itemCount == 0 then
			player.play_sound{ path = "utility/inventory_move" }
		end
	end

	-- give back transferred items
	local collected = 0
	local cursor_stack = player.cursor_stack

	if cache.itemCount > 0 then
		collected = entity.remove_item{ name = item, count = cache.itemCount }
	end

	if cursor_stack.valid_for_read and cursor_stack.name ~= item then
		-- other items in cursor
		player:inventory().insert{ name = item, count = collected }

	else -- same items
		-- collect cursor and transferred items temporarily
		if cursor_stack.valid_for_read then
			collected = collected + cursor_stack.count
		end

		-- fill cursor to previous amount
		if collected < cache.cursorStackCount then
			collected = collected + player:inventory().remove{ name = item, count = cache.cursorStackCount - collected }
		end
		
		if collected > 0 then
			if collected < cache.cursorStackCount then
				cursor_stack.set_stack{ name = item, count = collected }
			else
				cursor_stack.set_stack{ name = item, count = cache.cursorStackCount }
				collected = collected - cache.cursorStackCount
				if collected > 0 then
					player:inventory().insert{ name = item, count = collected }
				end
			end
		end
	end

	---- visuals ----
	local totalItems  = player:itemcount(item, takeFromInv, takeFromCar)
	if cache.half then totalItems = math.ceil(totalItems / 2) end

	if distributionMode == "balance" then
		_(cache.entities):where("valid", function(entity)
			totalItems = totalItems + _(entity):itemcount(item)
		end)
	end

	util.distribute(cache.entities, totalItems, function(entity, amount)
		-- if distributionMode == "balance" then
		-- 	local count = _(entity):itemcount(item)
		-- 	if count > amount then
		-- 		visuals.update(cache.markers[entity], item, count, config.colors.targetFull)
		-- 		return
		-- 	end
		-- end

		visuals.update(cache.markers[entity], item, amount)
	end)
	
	player.clear_local_flying_texts()
end

function this.isEntityEligible(entity, item)
	local prototype = prototypes.item[item]
	entity = _(entity)
	
	if entity.can_insert(item) then
		return true
	elseif entity.burner and entity.burner.fuel_categories[prototype.fuel_category] then
		return true
	elseif entity:is("crafting machine") and entity:recipe():hasIngredient(item) then
		return true
	elseif entity.type == "furnace" and not entity.get_recipe() and entity:canSmelt(item) then -- cached per furnace type + item
		return true
	elseif entity.type == "rocket-silo" then
		return true
	elseif entity.type == "lab" and entity:inventory("lab_input").can_insert(item) then
		return true
	elseif (entity.type == "ammo-turret" or entity.type == "artillery-turret" or entity.type == "artillery-wagon") and entity:supportsAmmo(prototype) then
		return true
	elseif entity.type == "roboport" and (prototype.type == "repair-tool" or (prototype.place_result and prototype.place_result.max_payload_size ~= nil)) then
		return true
	elseif entity.prototype.module_inventory_size and entity.prototype.module_inventory_size > 0 and prototype.type == "module" then
		return true
	elseif entity:inventory("main") then
		return true
	end
	
	return false
end

function this.resetCache(cache)
	cache.item = nil
	cache.half = false
	cache.entities = metatables.new("entityAsIndex")
	visuals.unmark(cache)
end

-- Registered only while distributions are pending (see updateRegistration).
-- Only caches with a pending event can hold entities, so other players are not probed.
function this.handleEntityRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end

	for __,bucket in pairs(storage.distrEvents) do
		for __,cache in pairs(bucket) do
			cache = unwrap(cache)
			if cache.entities and cache.entities[entity] then
				_(cache.markers[entity]):unmark() -- remove markers
				cache.markers[entity] = nil
				cache.entities[entity] = nil
			end
		end
	end
end

function this.on_player_died(event) -- resets distribution cache and events for that player
	local cache = storage.cache[event.player_index]
	
	if cache then
		this.resetCache(cache)
		
		local distrEvents = storage.distrEvents -- remove distribution event
		local bucket = cache.applyTick and distrEvents[cache.applyTick]
		if bucket then
			bucket[event.player_index] = nil
			if next(bucket) == nil then distrEvents[cache.applyTick] = nil end
		end
		cache.applyTick = nil
		this.updateRegistration()
	end
end

this.on_player_left_game = this.on_player_died

return this