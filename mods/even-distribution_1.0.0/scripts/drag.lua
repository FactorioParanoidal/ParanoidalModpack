local this = {}
local util = scripts.util
local visuals = scripts.visuals
local metatables = scripts.metatables
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

function this.on_tick(event) -- handles distribution events
	local distrEvents = global.distrEvents

	if distrEvents[event.tick] then
		for player_index, cache in pairs(distrEvents[event.tick]) do
			local player = _(game.players[player_index])
	
			if player:is("valid player") then
				if player:setting("distributionMode") == "distribute" then
					this.distributeItems(player, cache)
				else
					this.balanceItems(player, cache)
				end
			end
		end

		distrEvents[event.tick] = nil
	end
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
		entity:spawnDistributionText(item, itemsInserted, 0, color)
		-- player.play_sound{ path = "utility/inventory_move" }

	end)
		
	this.resetCache(cache)
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
				})

				itemCount.current = itemCount.current + itemsInserted
				totalItems = totalItems - itemsInserted

				local failedToInsert = amount - itemsInserted
				if failedToInsert > 0 then
					entity:spawnDistributionText(item, itemCount.current - itemCount.original, 0, config.colors.targetFull)
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
		_(entity):spawnDistributionText(item, amount, 0, (itemCount.current == 0) and config.colors.insufficientItems 
																				   or config.colors.default)
	end)

	if totalItems > 0 then
		player:returnItems(item, totalItems, takeFromCar, false)
	end
		
	this.resetCache(cache)
end

function this.on_fast_entity_transfer_hook(event)
	local index        = event.player_index
	local player       = _(game.players[index]); if player:isnot("valid player") then return end
	local cache        = _(global.cache[index])
	cache.half = false
end

function this.on_fast_entity_split_hook(event)
	local index        = event.player_index
	local player       = _(game.players[index]); if player:isnot("valid player") then return end
	local cache        = _(global.cache[index])
	cache.half = true
end

function this.on_selected_entity_changed(event)
	local index        = event.player_index
	local player       = _(game.players[index]); if player:isnot("valid player") or not player:setting("enableDragDistribute") then return end
	local cursor_stack = _(player.cursor_stack); if cursor_stack:isnot("valid stack") then return end
	local cache        = _(global.cache[index])
	local selected     = _(player.selected)    ; if selected:isnot("valid") or selected:isIgnored(player) then return end

	-- if not selected.can_insert{ name = cursor_stack.name, count = 1 } then return end

	cache.selectedEvent = {
		tick             = event.tick,
		item             = cursor_stack.name,
		itemCount        = selected:itemcount(cursor_stack.name),
		cursorStackCount = cursor_stack.count,
	}
end

function this.on_player_fast_transferred(event)
	local index    = event.player_index
	local player   = _(game.players[index]); if player:isnot("valid player") or not player:setting("enableDragDistribute") then return end
	local cache    = _(global.cache[index])
	local selected = _(player.selected)    ; if selected:isnot("valid") or selected:isIgnored(player) then return end

	if cache.selectedEvent and cache.selectedEvent.tick == event.tick and event.entity == selected:toPlain() then

		if event.from_player then
			-- distribute...

			if cache.selectedEvent.item then
				cache:set{
					item             = cache.selectedEvent.item,
					itemCount        = selected:itemcount(cache.selectedEvent.item) - cache.selectedEvent.itemCount,
					cursorStackCount = cache.selectedEvent.cursorStackCount,
				}
				
				if cache.itemCount == 0 then
					player.play_sound{ path = "utility/inventory_move" }
				end

				this.onStackTransferred(selected, player, cache) -- handle stack transfer
			end
		else
			-- take...
		end
	end
end

function this.onStackTransferred(entity, player, cache) -- handle vanilla drag stack transfer
	local takeFromInv = player:setting("takeFromInventory")
	local takeFromCar = player:setting("takeFromCar")
	local distributionMode    = player:setting("distributionMode")
	local item = cache.item

	if not _(entity):isIgnored(player) then
	
		local distrEvents = global.distrEvents -- register new distribution event
		if cache.applyTick and distrEvents[cache.applyTick] then distrEvents[cache.applyTick][player.index] = nil end
		
		-- wait before applying distribution (seconds defined in mod config)
		cache.applyTick = game.tick + math.max(math.ceil(60 * _(player):setting("distributionDelay")), 1)
		
		distrEvents[cache.applyTick] = distrEvents[cache.applyTick] or {}
		distrEvents[cache.applyTick][player.index] = cache

		if not cache.entities[entity] then
			cache.markers[entity] = entity:mark(player, item)
			cache.entities[entity] = entity
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

		if collected < cache.cursorStackCount then
			cursor_stack.set_stack{ name = item, count = cache.collected }
		else
			cursor_stack.set_stack{ name = item, count = cache.cursorStackCount }
			collected = collected - cache.cursorStackCount
			if collected > 0 then
				player:inventory().insert{ name = item, count = collected }
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
	
	entity:destroyTransferText()
end

function this.resetCache(cache)
	cache.item = nil
	cache.half = false
	cache.entities = metatables.new("entityAsIndex")
	visuals.unmark(cache)
end

function this.on_pre_player_mined_item(event) -- remove mined/dead entities from cache
	local entity = event.entity
	
	for __,cache in pairs(global.cache) do
		if cache.entities[entity] then
			_(cache.markers[entity]):unmark() -- remove markers
			cache.markers[entity] = nil
			cache.entities[entity] = nil
		end
	end
end

this.on_robot_pre_mined = this.on_pre_player_mined_item
this.on_entity_died = this.on_pre_player_mined_item

function this.script_raised_destroy(event)
	event = event or {}
	event.entity = event.entity or event.destroyed_entity or event.destroyedEntity or event.target or nil
	
	if _(event.entity):is("valid") then this.on_pre_player_mined_item(event) end
end

function this.on_player_died(event) -- resets distribution cache and events for that player
	local cache = global.cache[event.player_index]
	
	if cache then
		this.resetCache(cache)
		
		local distrEvents = global.distrEvents -- remove distribution event
		if cache.applyTick and distrEvents[cache.applyTick] then
			distrEvents[cache.applyTick][event.player_index] = nil
			cache.applyTick = nil
		end
	end
end

this.on_player_left_game = this.on_player_died

return this