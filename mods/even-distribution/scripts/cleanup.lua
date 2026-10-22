-- Inventory Cleanup Hotkey
--
-- Paranoidal rewrite of the hot paths (behaviour kept):
--  * entities are searched only among types that can own an inventory (no belts, poles, rails,
--    walls, pipes...), cheap name checks run before operable/to_be_deconstructed API calls;
--  * static per-entity data (type, burner categories, recipe ingredients/products, requests,
--    chest contents, ammo support) is read once per key press instead of once per trash item;
--  * can_insert() is called only for entities that pass the cheap eligibility rules;
--  * distribution works on plain arrays instead of entity-indexed metatables.

local this = {}
local drag = scripts.drag
local util = scripts.util
local metatables = scripts.metatables
local protocache = require("scripts.protocache")
local itemstate = require("scripts.itemstate")
local qualities = require("scripts.quality")
local config = require("config")

local helpers = scripts.helpers
local _ = helpers.on

local floor = math.floor

local CRAFTING = { ["furnace"] = true, ["assembling-machine"] = true, ["rocket-silo"] = true }
local CHESTS   = { ["container"] = true, ["logistic-container"] = true }
local TURRETS  = { ["ammo-turret"] = true, ["artillery-turret"] = true, ["artillery-wagon"] = true }
local VEHICLES = { ["car"] = true, ["spider-vehicle"] = true }
local OUTPUT_PRODUCERS = { ["furnace"] = true, ["assembling-machine"] = true }
local REQUESTER_TYPES = { ["logistic-container"] = true, ["infinity-container"] = true, ["spider-vehicle"] = true }

-- prototype-derived memos (deterministic, per session)
local labInputs = {}  -- lab prototype name -> set of accepted items
local function labAccepts(entityPrototype, item)
	local set = labInputs[entityPrototype.name]
	if not set then
		set = {}
		for __,input in pairs(entityPrototype.lab_inputs or {}) do set[input] = true end
		labInputs[entityPrototype.name] = set
	end
	return set[item] == true
end

local robotItems = {} -- item name -> can go into a roboport (robots, repair packs)
local function isRoboportItem(prototype)
	local value = robotItems[prototype.name]
	if value == nil then
		local placeResult = prototype.place_result
		value = prototype.type == "repair-tool" or (placeResult ~= nil and placeResult.max_payload_size ~= nil)
		robotItems[prototype.name] = value
	end
	return value
end

function this.on_inventory_cleanup(event)
	local player   = _(game.get_player(event.player_index)); if player:isnot("valid player") or not player:setting("enableInventoryCleanupHotkey") then return end
	local items    = player:trashItems()                ; if #items == 0 then return end -- Paranoidal: { name, quality, count }
	local area     = _(player.position):perimeter(player:droprange())
	local records  = this.getEntities(area, player)     ; if #records == 0 then return end

	local options = {
		dropToChests = player:setting("dropTrashToChests"),
		dropToOutput = player:setting("dropTrashToOutput"),
		useFuelLimit = player:setting("cleanupUseFuelLimit"),
		useAmmoLimit = player:setting("cleanupUseAmmoLimit"),
		balance      = player:setting("distributionMode") ~= "distribute",
	}

	local offY, marked = 0, {}
	for __,entry in ipairs(items) do
		if this.processItem(player, records, entry.name, entry.count, options, offY, marked, entry.quality) then
			offY = offY - 0.5
		end
	end
end

---------------------------------------------------------------------------------------------------
-- per-entity data, read lazily and at most once per key press

local function recipeSets(rec)
	if rec.ingredients == nil then
		local ingredients, products = {}, {}
		if CRAFTING[rec.type] then
			local recipe = rec.w:recipe():toPlain()
			if recipe and recipe.valid then
				for __,ingredient in pairs(recipe.ingredients) do ingredients[ingredient.name] = true end
				for __,product in pairs(recipe.products) do
					if (product.amount or product.amount_min or product.amount_max or product.probability or 1) > 0 then
						products[product.name] = true
					end
				end
			end
		end
		rec.ingredients, rec.products = ingredients, products
	end
	return rec.ingredients, rec.products
end

local function isRequester(rec)
	if rec.requester == nil then
		local entity = rec.entity
		rec.requester = rec.prototype.logistic_mode == "requester" or
			(rec.type == "spider-vehicle" and entity.get_logistic_point(defines.logistic_member_index.character_requester) ~= nil)
	end
	return rec.requester
end

-- Paranoidal: requests of every quality; a filter counts for the qualities it matches
local function requestOf(rec, item, quality)
	if rec.requests == nil then
		rec.requests = {} -- name -> array of filters
		local point = rec.w:requesterPoint()
		if point and point.valid then
			for __,filter in pairs(point.filters or {}) do
				if filter and filter.name then
					local list = rec.requests[filter.name] or {}
					list[#list + 1] = filter
					rec.requests[filter.name] = list
				end
			end
		end
	end
	local request = 0
	for __,filter in ipairs(rec.requests[item] or {}) do
		local count = filter.count or 0
		if count > request and qualities.matches(filter, quality) then request = count end
	end
	return request
end

local function chestContents(rec)
	if rec.contents == nil then
		rec.contents = rec.w:qualityContents("main") -- main inventory: "name|quality" -> {name, quality, count}
	end
	return rec.contents
end

local function burnerCategories(rec)
	if rec.burnerCats == nil then
		local burner = rec.entity.burner
		rec.burnerCats = burner and burner.fuel_categories or false
	end
	return rec.burnerCats
end

---------------------------------------------------------------------------------------------------

function this.getEntities(area, player)
	local records = {}
	local force = player.force
	local playerIndex = player.index
	local ignored = storage.settings[playerIndex].ignoredEntities
	local remoteIgnored = storage.remoteIgnoredEntities or {}

	for __,entity in pairs(player.surface.find_entities_filtered{ area = area, force = force, type = protocache.allowedEntityTypes() }) do
		local name = entity.name
		if protocache.isAllowedEntity(name) and not ignored[name] and not remoteIgnored[name] and
		   entity.operable and not entity.to_be_deconstructed() then -- 2.0: no force argument

			records[#records + 1] = {
				entity    = entity,
				w         = _(entity),
				type      = entity.type,
				prototype = entity.prototype,
			}
		end
	end

	return records
end

-- same rules as upstream filterEntities; API-free preconditions decide whether can_insert is needed
function this.isTarget(rec, item, prototype, dropToChests, dropToOutput, quality)
	local entity, entityType = rec.entity, rec.type
	if not entity.valid then return false end
	quality = quality or "normal"
	local id = { name = item, quality = quality }

	local fuelCats = prototype.fuel_category and burnerCategories(rec)
	local fuelMatch = fuelCats and fuelCats[prototype.fuel_category]
	local crafting = CRAFTING[entityType]
	local ingredient = crafting and recipeSets(rec)[item]
	local requester = REQUESTER_TYPES[entityType] and isRequester(rec)
	local chest = dropToChests and CHESTS[entityType]
	local isAmmo = prototype.type == "ammo"

	local lab = entityType == "lab" and labAccepts(rec.prototype, item)
	local roboport = entityType == "roboport" and isRoboportItem(prototype)

	if fuelMatch or ingredient or requester or chest or lab or
	   (TURRETS[entityType] and isAmmo) or roboport or (VEHICLES[entityType] and isAmmo) then

		if entity.can_insert(id) then
			if fuelMatch and rec.w:inventory("fuel").can_insert(id) then return true end
			if ingredient then return true end
			if requester and requestOf(rec, item, quality) - entity.get_item_count(id) > 0 then return true end
			if chest and chestContents(rec)[qualities.key(item, quality)] ~= nil then return true end
			if lab and rec.w:inventory("lab_input").can_insert(id) then return true end
			if TURRETS[entityType] and isAmmo and protocache.supportsAmmo(rec.prototype, prototype) then return true end
			if roboport then return true end
			if VEHICLES[entityType] and isAmmo then return true end
		end
	end

	if dropToOutput and OUTPUT_PRODUCERS[entityType] then
		local __, products = recipeSets(rec)
		if products[item] then return true end
	end

	return false
end

-- quality: Paranoidal, the quality of the item (nil = normal)
function this.insert(player, rec, item, amount, options, quality)
	local entity, entityType = rec.w, rec.type
	local useFuelLimit, useAmmoLimit = options.useFuelLimit, options.useAmmoLimit

	if entityType == "furnace" and entity:recipe():isnot("valid") then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
			fuel = true, ammo = false, input = false, output = false, modules = false, roboport = false, main = false,
		}, quality)

	elseif CRAFTING[entityType] then
		local ingredients, products = recipeSets(rec)
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
			fuel     = true,
			ammo     = false,
			input    = ingredients[item] == true,
			output   = options.dropToOutput and entityType ~= "rocket-silo" and products[item] == true,
			modules  = false,
			roboport = false,
			main     = false,
		}, quality)

	elseif rec.prototype.logistic_mode == "requester" then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, true, {
			fuel = false, ammo = false, input = false, output = false, modules = false, roboport = false, main = true,
		}, quality)

	elseif entityType == "spider-vehicle" and isRequester(rec) then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, true, {
			fuel = true, ammo = true, input = false, output = false, modules = false, roboport = false, main = true,
		}, quality)

	elseif VEHICLES[entityType] then
		return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
			fuel = true, ammo = true, input = false, output = false, modules = false, roboport = false, main = false,
		}, quality)
	end

	-- Default priority insertion
	return entity:customInsert(player, item, amount, false, true, false, useFuelLimit, useAmmoLimit, false, {
		fuel = true, ammo = true, input = true, output = false, modules = false, roboport = true, main = true,
	}, quality)
end

local function markOnce(player, rec, marked)
	local entity = rec.entity
	local id = entity.unit_number or rec
	if not marked[id] then
		rec.w:mark(player)
		marked[id] = true
	end
end

-- distribute (or balance) one trash item of one quality; returns true if any entity was a target
function this.processItem(player, records, item, totalItems, options, offY, marked, quality)
	local prototype = prototypes.item[item]
	if not prototype then return false end
	quality = quality or "normal"

	local targets = {}
	for __,rec in ipairs(records) do
		if this.isTarget(rec, item, prototype, options.dropToChests, options.dropToOutput, quality) then
			targets[#targets + 1] = { rec = rec }
		end
	end
	if #targets == 0 then return false end

	-- Paranoidal: durability/rounds of used packs and magazines are kept (name/count transfers make them whole)
	local involved = {player}
	for __,target in ipairs(targets) do involved[#involved + 1] = target.rec.entity end
	local transfer = itemstate.begin(item, quality, involved)

	totalItems = player:removeItems(item, totalItems, true, false, true, quality)

	-- current counts (balance mode also collects the item from every target first)
	for __,target in ipairs(targets) do
		local entity = target.rec.entity
		local count = entity.get_item_count({ name = item, quality = quality })
		local removed = 0
		if options.balance and count > 0 then
			removed = entity.remove_item{ name = item, quality = quality, count = count }
			totalItems = totalItems + removed
		end
		target.original  = count
		target.current   = count - removed
		target.remaining = options.balance and (count - removed) or 0 -- amount above the balanced level
	end

	-- distribute collected items evenly, retrying while some targets are full
	local active = targets
	local i = 0
	while totalItems > 0 and #active > 0 do
		if i == 1000 then dlog("WARNING: Cleanup distribution loop did not finish!"); break end -- safeguard
		i = i + 1

		local count = #active
		local share, remainder = floor(totalItems / count), totalItems % count
		local nextActive = {}

		for index,target in ipairs(active) do
			local rec = target.rec
			if rec.entity.valid then
				local amount = share
				if index <= remainder then amount = amount + 1 end
				amount = amount - target.remaining

				local full = false
				if amount > 0 then
					local inserted = this.insert(player, rec, item, amount, options, quality)
					target.current = target.current + inserted
					totalItems = totalItems - inserted

					if inserted < amount then
						full = true
						if target.current ~= target.original then
							rec.w:spawnDistributionText(player, item, target.current - target.original, offY, nil, quality)
							markOnce(player, rec, marked)
						end
						target.done = true
					end
					amount = 0
				end

				target.remaining = -amount
				if not full then nextActive[#nextActive + 1] = target end
			end
		end

		-- stop when nothing changed (all remaining targets are above the balanced level)
		if #nextActive == count and share == 0 and remainder == 0 then break end
		active = nextActive
	end

	for __,target in ipairs(targets) do
		local rec = target.rec
		if not target.done and rec.entity.valid then
			local amount = target.current - target.original
			if amount ~= 0 then
				rec.w:spawnDistributionText(player, item, amount, offY, nil, quality)
				markOnce(player, rec, marked)
			end
		end
	end

	if totalItems > 0 then
		player:returnItems(item, totalItems, false, true, quality)
	end

	local drainOrder = {}
	for index = 2, #involved do drainOrder[#drainOrder + 1] = involved[index] end
	drainOrder[#drainOrder + 1] = player
	itemstate.finish(transfer, drainOrder)

	return true
end

return this
