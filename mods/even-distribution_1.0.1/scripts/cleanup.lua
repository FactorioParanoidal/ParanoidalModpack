-- Inventory Cleanup Hotkey

local this = {}
local drag = scripts.drag
local util = scripts.util
local metatables = scripts.metatables
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

function this.on_inventory_cleanup(event)
	local player   = _(game.players[event.player_index]); if player:isnot("valid player") or not player:setting("enableInventoryCleanupHotkey") then return end
	local items    = _(player:trashItems())             ; if items:is("empty") then return end
	local area     = _(player.position):perimeter(player:droprange())
	local entities = _(this.getEntities(area, player))  ; if entities:is("empty") then return end
	local dropToChests = player:setting("dropTrashToChests")

	if player:setting("distributionMode") == "distribute" then
		this.distributeItems(player, entities, items, dropToChests)
	else
		this.balanceItems(player, entities, items, dropToChests)
	end
end

function this.distributeItems(player, entities, items, dropToChests)
	local offY, marked = 0, metatables.new("entityAsIndex")
	
	items:each(function(item, totalItems)

		local entitiesToProcess = this.filterEntities(entities, item, dropToChests)
		
		if #entitiesToProcess > 0 then

			totalItems = player:removeItems(item, totalItems, true, false, true)
			util.distribute(entitiesToProcess, totalItems, function(entity, amount)

				if amount > 0 then
					local itemsInserted = this.insert(player, entity, item, amount)
					local failedToInsert = amount - itemsInserted

					if itemsInserted > 0 then -- visuals
						entity:spawnDistributionText(item, itemsInserted, offY)
						if not marked[entity] then
							entity:mark(player)
							marked[entity] = true
						end
					end
					
					if failedToInsert > 0 then
						player:returnItems(item, failedToInsert, false, true)
					end
				end
			end)
			offY = offY - 0.5
		end
	end)
end

function this.balanceItems(player, entities, items, dropToChests)
	local offY, marked = 0, metatables.new("entityAsIndex")

	items:each(function(item, totalItems)

		local entitiesToProcess = this.filterEntities(entities, item, dropToChests)

		if #entitiesToProcess > 0 then
			local itemCounts = metatables.new("entityAsIndex")
			totalItems = player:removeItems(item, totalItems, true, false, true)

			-- collect items from filtered entities
			_(entitiesToProcess):each(function(entity)
				local count = entity:itemcount(item)
				local removed = 0
				if count > 0 then
					removed = entity.remove_item{ name = item, count = count }
					totalItems = totalItems + removed
				end

				-- save entities in new list
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
						local itemsInserted = this.insert(player, entity, item, amount)

						itemCount.current = itemCount.current + itemsInserted
						totalItems = totalItems - itemsInserted

						local failedToInsert = amount - itemsInserted
						if failedToInsert > 0 then
							if itemCount.current ~= itemCount.original then
								entity:spawnDistributionText(item, itemCount.current - itemCount.original, offY)
								if not marked[entity] then
									entity:mark(player)
									marked[entity] = true
								end
							end
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
				if amount ~= 0 then
					entity:spawnDistributionText(item, amount, offY)
					if not marked[entity] then
						entity:mark(player)
						marked[entity] = true
					end
				end
			end)

			if totalItems > 0 then
				player:returnItems(item, totalItems, false, true)
			end

			offY = offY - 0.5
		end
	end)
end

function this.insert(player, entity, item, amount)

	local useFuelLimit = player:setting("cleanupUseFuelLimit")
	local useAmmoLimit = player:setting("cleanupUseAmmoLimit")
	if entity.type == "furnace" and not (entity.get_recipe() or entity.previous_recipe) then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
			fuel     = true,
			ammo     = false,
			input    = false,
			modules  = false,
			roboport = false,
			main     = false,
		})

	elseif entity.prototype.logistic_mode == "requester" then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, true, {
			fuel     = false,
			ammo     = false,
			input    = false,
			modules  = false,
			roboport = false,
			main     = true,
		})

	elseif entity.type == "spider-vehicle" and entity.get_logistic_point(defines.logistic_member_index.character_requester) then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, true, {
			fuel     = true,
			ammo     = true,
			input    = false,
			modules  = false,
			roboport = false,
			main     = true,
		})
		
	elseif entity.type == "car" or entity.type == "spider-vehicle" then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
			fuel     = true,
			ammo     = true,
			input    = false,
			modules  = false,
			roboport = false,
			main     = false,
		})
	end
	
	-- Default priority insertion
	return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
		fuel     = true,
		ammo     = true,
		input    = true,
		modules  = false,
		roboport = true,
		main     = true,
	}) 
end

function this.filterEntities(entities, item, dropToChests)
	local result = metatables.new("entityAsIndex")
	local prototype = game.item_prototypes[item]
	
	_(entities):each(function(__, entity)
		entity = _(entity)

		if entity.can_insert(item) then
			if entity.burner and entity.burner.fuel_categories[prototype.fuel_category] and entity:inventory("fuel").can_insert(item) then
				result[entity] = entity
			elseif entity:is("crafting machine") and _(entity.get_recipe() or (entity.type == "furnace" and entity.previous_recipe)):hasIngredient(item) then
				result[entity] = entity
			elseif (entity.prototype.logistic_mode == "requester" or (entity.type == "spider-vehicle" and entity.get_logistic_point(defines.logistic_member_index.character_requester))) and entity:remainingRequest(item) > 0 then
				result[entity] = entity
			elseif dropToChests and (entity.type == "container" or entity.type == "logistic-container") and entity.get_item_count(item) > 0 then
				result[entity] = entity
			elseif entity.type == "lab" and entity:inventory("lab_input").can_insert(item) then
				result[entity] = entity
			elseif entity.type == "ammo-turret" and entity:supportsAmmo(prototype) then
				result[entity] = entity
			elseif entity.type == "roboport" then
				result[entity] = entity
			elseif (entity.type == "car" or entity.type == "spider-vehicle") and prototype.type == "ammo" then
				result[entity] = entity
			end
		end
	end)
	
	return result
end

function this.getEntities(area, player)
	local entities = {}

	for __,entity in ipairs(player.surface.find_entities_filtered{ area = area, force = player.force }) do

		if _(entity):is("valid") and 
		   entity.operable and 
		   not entity.to_be_deconstructed(player.force) and 
		   not _(entity):isIgnored(player) then
			
			entities[#entities + 1] = entity
		end
	end
	
	return entities
end



return this