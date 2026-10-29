-- Protection layers of a character: vehicle cabin → grid module → armor-slot item.
-- Cabin and module filter a share of the air; any worn armor-slot item then takes the rest of the harm
-- on its filter resource (toxicPollution2 behaviour): the body is not poisoned while it lasts.
-- Spends module energy and the resource, refills it with air filters, replaces a worn-out item without
-- a grid by the longest-lasting protection from the inventory.
local C = require("shared.config")
local V = require("shared.vehicles")
local M = require("scripts.model")

local P = {}

local EXHAUSTED = C.MODEL.exhausted
local GRID_FLOOR = EXHAUSTED / 2 -- items with a grid are never destroyed: the resource stops here
local REFILL_RETRY = 600 -- ticks before looking for filters again after none were found

local MODULES = {}
for _, spec in ipairs(C.MODULES) do
	MODULES[spec.name] = spec
end

-- Derived from prototypes only (identical on every peer); rebuilt after each load.
local share_cache, durability_cache = {}, {}
local refill_ready

function P.armor_share(name)
	local share = share_cache[name]
	if share == nil then
		local prototype = prototypes.item[name]
		local resistance = prototype and prototype.type == "armor" and prototype.resistances
			and prototype.resistances[C.RESIST_TYPE]
		share = resistance and M.clamp(resistance.percent, 0, 1) or 0
		share_cache[name] = share
	end
	return share
end

function P.max_resource(stack)
	local quality = stack.quality
	local key = stack.name .. "/" .. quality.name
	local value = durability_cache[key]
	if value == nil then
		value = prototypes.item[stack.name].get_durability(quality) or 0
		durability_cache[key] = value
	end
	return value
end

function P.refill_available()
	if refill_ready == nil then
		refill_ready = prototypes.item[C.REFILL_ITEM] ~= nil and prototypes.item[C.REFILL_RETURN] ~= nil
	end
	return refill_ready
end

function P.count_filters(inventory)
	if not (inventory and P.refill_available()) then return 0 end
	local count = 0
	for _, entry in pairs(inventory.get_contents()) do
		if entry.name == C.REFILL_ITEM then
			count = count + entry.count
		end
	end
	return count
end

local function armor_stack(character)
	local inventory = character.get_inventory(defines.inventory.character_armor)
	local stack = inventory and inventory[1]
	if stack and stack.valid_for_read then
		return stack, inventory
	end
	return nil, inventory
end

local function play(player, path)
	if player.mod_settings["tpr-sounds"].value then
		player.play_sound({ path = path })
	end
end

local function item_name(name)
	local prototype = prototypes.item[name]
	return prototype and prototype.localised_name or name
end

-- Takes one air filter of any quality and returns a used one (spilled if there is no room).
local function take_filter(character)
	local inventory = character.get_main_inventory()
	if not inventory then return false end
	for _, entry in pairs(inventory.get_contents()) do
		if entry.name == C.REFILL_ITEM and inventory.remove({ name = entry.name, quality = entry.quality, count = 1 }) > 0 then
			local used = { name = C.REFILL_RETURN, quality = entry.quality, count = 1 }
			if inventory.insert(used) == 0 then
				character.surface.spill_item_stack({ position = character.position, stack = used, force = character.force,
					allow_belts = false })
			end
			return true
		end
	end
	return false
end

-- Refill when a whole filter fits or less than a quarter is left. Disposable items are never refilled.
local function try_refill(player, character, stack, data)
	if C.DISPOSABLE[stack.name] or not P.refill_available() then return false end
	if (data.refill_retry or 0) > game.tick then return false end
	local max = P.max_resource(stack)
	local missing = max - stack.durability
	if missing < C.REFILL_AMOUNT and stack.durability > max / 4 then return false end
	if not take_filter(character) then
		data.refill_retry = game.tick + REFILL_RETRY
		return false
	end
	stack.durability = math.min(max, stack.durability + C.REFILL_AMOUNT)
	data.exhausted_notice = nil
	player.create_local_flying_text({ text = { "tpr-message.refill", C.REFILL_ITEM, tostring(C.REFILL_AMOUNT) },
		position = character.position, surface = character.surface, color = { 0.6, 1, 0.6 } })
	play(player, "utility/armor_insert")
	return true
end

-- How long a stack protects, in "resource at zero toxin share" (comparable between items).
function P.endurance(stack)
	local share = P.armor_share(stack.name)
	local max = P.max_resource(stack)
	if max <= 0 or share >= 1 then return math.huge end
	if stack.grid and stack.durability < EXHAUSTED then return 0 end
	return stack.durability / (1 - share)
end

-- Best protection in the main and trash inventories: the one that lasts longest.
local function best_protection(character)
	local best, best_score
	for _, id in ipairs({ defines.inventory.character_main, defines.inventory.character_trash }) do
		local inventory = character.get_inventory(id)
		if inventory then
			for index = 1, #inventory do
				local stack = inventory[index]
				if stack.valid_for_read and stack.type == "armor" then
					local score = P.endurance(stack)
					if score > 0 and (not best_score or score > best_score) then
						best, best_score = stack, score
					end
				end
			end
		end
	end
	return best
end

local function worn_out(player, character, stack, slot)
	local name = stack.name
	stack.clear()
	player.print({ "tpr-message.worn-out", name, item_name(name) })
	if not player.mod_settings["tpr-auto-equip"].value then
		play(player, "utility/armor_remove")
		return
	end
	local spare = best_protection(character)
	if spare and slot and slot[1].transfer_stack(spare) and slot[1].valid_for_read then
		player.print({ "tpr-message.equipped", slot[1].name, item_name(slot[1].name) })
		play(player, "utility/armor_insert")
	else
		play(player, "utility/armor_remove")
	end
end

-- Spends `amount` of the filter resource of the worn item (smog or poison gas).
function P.spend(player, character, stack, amount, data, slot)
	if amount <= 0 or not (stack and stack.valid_for_read) then return end
	try_refill(player, character, stack, data)
	local left = stack.durability - amount
	if stack.grid then
		if left < EXHAUSTED then
			left = math.max(left, GRID_FLOOR)
			if not data.exhausted_notice then
				data.exhausted_notice = true
				player.print({ "tpr-message.exhausted", stack.name, item_name(stack.name) })
				play(player, "utility/armor_remove")
			end
		end
		stack.durability = left
		return
	end
	if left > 0 then
		stack.durability = left
		return
	end
	worn_out(player, character, stack, slot)
end

function P.armor_slot(character)
	return armor_stack(character)
end

-- Evaluates the layers for `pollution` and, when `apply`, spends module energy and resource.
-- Returns a state table for the model, the HUD and the alerts.
function P.evaluate(player, character, data, pollution, tolerance, level, seconds, apply)
	local state = { pollution = pollution, tolerance = tolerance, level = level }

	local vehicle = character.vehicle
	local vehicle_share = vehicle and V.filtration(vehicle.type, vehicle.name) or 0
	if vehicle_share > 0 then
		state.vehicle = { name = vehicle.name, share = vehicle_share }
	end
	local reaching = pollution * (1 - vehicle_share)

	local stack, slot = armor_stack(character)
	local module_share = 0
	local grid = stack and stack.grid
	if grid then
		local best, spec
		for _, equipment in pairs(grid.equipment) do
			local candidate = MODULES[equipment.name]
			if candidate and (not spec or candidate.filtration > spec.filtration) then
				best, spec = equipment, candidate
			end
		end
		if best then
			local module = { name = spec.name, share = spec.filtration, status = "standby" }
			if reaching > tolerance then
				local need = spec.power * seconds
				local part = math.min(1, best.energy / need)
				if apply then
					best.energy = best.energy - need * part
				end
				module.share = spec.filtration * part
				module.status = part >= 1 and "working" or (part > 0 and "low" or "empty")
			end
			module_share = module.share
			state.module = module
		end
	end
	reaching = reaching * (1 - module_share)

	state.reaching = reaching
	local protecting = false
	if stack then
		local share = P.armor_share(stack.name)
		local max = P.max_resource(stack)
		if max <= 0 then
			-- Without a resource (an infinite armor added after data-final-fixes): protects, never wears.
			protecting = true
			state.armor = { name = stack.name, share = share, exhausted = false, infinite = true, wear = 0,
				resource = 1, max = 1, disposable = true }
		else
			local exhausted = stack.grid ~= nil and stack.durability < EXHAUSTED
			protecting = not exhausted
			local wear = protecting and M.wear(reaching, tolerance, share, level) or 0
			state.armor = {
				name = stack.name, share = share, exhausted = exhausted, wear = wear,
				resource = stack.durability, max = max, disposable = C.DISPOSABLE[stack.name] or false,
			}
			if apply and wear > 0 then
				P.spend(player, character, stack, wear * seconds, data, slot)
				local now = stack.valid_for_read and stack or nil
				local armor = state.armor
				if not now then
					armor.resource, armor.lost = 0, true
					protecting = false
				elseif now.name ~= armor.name then
					-- Worn out and replaced by a spare (the same slot stack).
					armor.name, armor.share, armor.replaced = now.name, P.armor_share(now.name), true
					armor.max = P.max_resource(now)
					armor.resource = armor.max > 0 and now.durability or 1
					armor.disposable = C.DISPOSABLE[now.name] or armor.max <= 0
					armor.exhausted = now.grid ~= nil and armor.max > 0 and now.durability < EXHAUSTED
					protecting = not armor.exhausted
				else
					armor.resource = now.durability
					armor.exhausted = now.grid ~= nil and now.durability < EXHAUSTED
					protecting = not armor.exhausted
				end
			end
		end
	end

	state.protected = protecting
	-- While protected the body breathes nothing harmful: intoxication falls as in clean air.
	state.inhaled = protecting and 0 or reaching
	state.filtration = M.total_filtration({ vehicle_share, module_share })
	state.filters = state.armor and not state.armor.disposable and P.count_filters(character.get_main_inventory()) or nil
	return state
end

return P
