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
			this.distributeItems(player_index, cache) -- distribute items
		end

		distrEvents[event.tick] = nil
	end
end

function this.distributeItems(player_index, cache)
	local player = _(game.players[player_index])
	
	if player:is("valid player") then
		local takeFromCar = player:setting("take-from-car")
		local item        = cache.item
		local totalItems  = player:itemcount(item, takeFromCar)

		if cache.half then totalItems = math.ceil(totalItems / 2) end

		util.distribute(cache.entities, totalItems, function(entity, amount)

			local itemsInserted = 0
			local color
			
			if amount > 0 then
				local takenFromPlayer = player:removeItems(item, amount, takeFromCar, false)
				
				if takenFromPlayer < amount then color = config.colors.insufficientItems end
				
				if takenFromPlayer > 0 then
					itemsInserted = entity.insert{ name = item, count = takenFromPlayer }
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
	end
		
	this.resetCache(cache)
end

function this.on_selected_entity_changed(event)
	local index        = event.player_index
	local player       = _(game.players[index]); if player:isnot("valid player", {"mod_settings", "enable-ed", "value"}) then return end
	local cursor_stack = _(player.cursor_stack); if cursor_stack:isnot("valid stack") then return end
	local selected     = _(player.selected)    ; if selected:isnot("valid") or selected:isIgnored(player) then return end

	if not selected.can_insert{ name = cursor_stack.name, count = 1 } then return end

	local cache = _(global.cache[index]):set{
		tick             = event.tick,
		item             = cursor_stack.name,
		itemCount        = selected:itemcount(cursor_stack.name),
		cursorStackCount = cursor_stack.count,
	}
	
	if selected:is("crafting machine") then
		cache:set{
			isCrafting    = selected.is_crafting(),
			inputContents = selected:contents("input"),
		}
	end
	
	if selected.burner then 
		cache.remainingFuel = selected.burner.remaining_burning_fuel
	end
end

function this.on_player_fast_transferred(event)
	local index    = event.player_index
	local player   = _(game.players[index]); if player:isnot("valid player", {"mod_settings", "enable-ed", "value"}) then return end
	local cache    = _(global.cache[index])
	local selected = _(player.selected)    ; if selected:isnot("valid") or selected:isIgnored(player) then return end

	if cache.tick == event.tick and event.entity == selected:toPlain() then

		if event.from_player then
			if cache.item then
				cache.itemCount = selected:itemcount(cache.item) - cache.itemCount
				
				cache.half = false
				if cache.itemCount == 0 then
					player.play_sound{ path = "utility/inventory_move" }

				elseif cache.itemCount > 0 then
					-- determine if half a stack has been transferred (buggy if player only has 1 of the item in inventory but more in car!)
					cache.half = (cache.itemCount == math.floor(cache.cursorStackCount / 2))
				end

				this.stackTransferred(selected, player, cache) -- handle stack transfer
			end
		else
			-- ...
		end

	end
end

function this.stackTransferred(entity, player, cache) -- handle vanilla stack transfer
	if not _(entity):isIgnored(player) then
	
		local distrEvents = global.distrEvents -- register new distribution event
		if cache.applyTick and distrEvents[cache.applyTick] then distrEvents[cache.applyTick][player.index] = nil end
		
		-- wait before applying distribution (seconds defined in mod config)
		cache.applyTick = game.tick + math.max(math.ceil(60 * _(player):setting("distribution-delay")), 1)
		
		distrEvents[cache.applyTick] = distrEvents[cache.applyTick] or {}
		distrEvents[cache.applyTick][player.index] = cache

		local item = cache.item
		if not cache.entities[entity] then
			cache.markers[entity] = entity:mark(player, item)
			cache.entities[entity] = entity
		end

		---- visuals ----
		local takeFromCar = player:setting("take-from-car")
		local totalItems  = player:itemcount(item, takeFromCar) + cache.itemCount
		if cache.half then totalItems = math.ceil(totalItems / 2) end

		util.distribute(cache.entities, totalItems, function(entity, amount)
			visuals.update(cache.markers[entity], item, amount)
		end)
	end
	
	cache.tick = nil -- reset event handler tick to avoid invalid on_player_cursor_stack_changed execution
	
	-- give items back to player
	if cache.itemCount > 0 then
		local giveToPlayer = entity.remove_item{ name = cache.item, count = cache.itemCount }
		
		if giveToPlayer > 0 then
			local cursor_stack = player.cursor_stack
			if cursor_stack.valid_for_read then
				player.insert{ name = cache.item, count = giveToPlayer }
			else
				cursor_stack.set_stack{ name = cache.item, count = giveToPlayer }
			end
		end
	end
	
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