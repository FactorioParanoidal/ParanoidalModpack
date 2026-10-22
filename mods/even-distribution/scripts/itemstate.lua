-- Paranoidal: keeps the per-item state of tools (durability: science packs, repair packs) and ammo (rounds)
-- through the name/count transfers of this mod.
--
-- LuaInventory.remove{name, count} takes the partly used top item of a stack first, and insert{name, count}
-- creates whole items (checked in Factorio 2.0.77), so moving a used pack or magazine through the mod made it
-- whole again (endless science, free rounds). A transfer is wrapped instead: the state total of the item over
-- every inventory involved is taken before, and whatever the transfer created is drained afterwards, first
-- from the targets (where the new items went), then from the player.
local this = {}

local EPSILON = 1e-6

local function plain(object)
	if type(object) == "table" and object.toPlain then return object:toPlain() end
	return object
end

-- "durability" (tools, repair tools) or "ammo"; nil for items without a per-item state.
function this.field(item)
	local prototype = prototypes.item[item]
	if not prototype then return nil end
	if prototype.type == "ammo" then return "ammo" end
	if prototype.type == "tool" or prototype.type == "repair-tool" then return "durability" end
	return nil
end

local function unitOf(prototype, field, quality)
	if field == "ammo" then return prototype.magazine_size end
	return prototype.get_durability(quality)
end

local function matches(stack, item, quality)
	return stack and stack.valid_for_read and stack.name == item and stack.quality.name == quality
end

local function stackTotal(stack, field, unit)
	return (stack.count - 1) * unit + stack[field]
end

-- Every inventory of a LuaControl (player: its character inventories; entity: all of them), the cursor
-- of a player and the trunk of the vehicle the player drives.
local function collect(controls)
	local inventories, stacks, seen = {}, {}, {}
	local function addControl(control)
		control = plain(control)
		if not (control and control.valid) then return end
		-- the same entity twice (e.g. the driven car as a target) would count its items twice
		for __, other in ipairs(seen) do
			if other == control then return end
		end
		seen[#seen + 1] = control
		local ok, last = pcall(function() return control.get_max_inventory_index() end)
		if not ok then last = 0 end
		for index = 1, last do
			local got, inventory = pcall(control.get_inventory, index)
			if got and inventory and inventory.valid then
				inventories[#inventories + 1] = inventory
			end
		end
		if control.object_name == "LuaPlayer" then
			local cursor = control.cursor_stack
			if cursor then stacks[#stacks + 1] = cursor end
			local vehicle = control.driving and control.vehicle
			if vehicle and vehicle.valid then addControl(vehicle) end
		end
	end
	for __, control in ipairs(controls) do addControl(control) end
	return inventories, stacks
end

local function total(item, quality, field, unit, inventories, stacks)
	local sum = 0
	for __, inventory in ipairs(inventories) do
		if inventory.valid then
			for slot = 1, #inventory do
				local stack = inventory[slot]
				if matches(stack, item, quality) then sum = sum + stackTotal(stack, field, unit) end
			end
		end
	end
	for __, stack in ipairs(stacks) do
		if stack.valid and matches(stack, item, quality) then sum = sum + stackTotal(stack, field, unit) end
	end
	return sum
end

-- Takes `amount` of state from one stack, partly used items first. Returns what is left to take.
local function drainStack(stack, field, unit, amount)
	while amount > EPSILON and stack.valid_for_read do
		local current = stack[field]
		if current - amount > EPSILON then
			stack[field] = current - amount
			return 0
		end
		amount = amount - current
		if stack.count > 1 then
			stack.count = stack.count - 1
			stack[field] = unit
		else
			stack.clear()
		end
	end
	return amount
end

local function drain(item, quality, field, unit, amount, inventories, stacks)
	for __, stack in ipairs(stacks) do
		if amount <= EPSILON then return 0 end
		if stack.valid and matches(stack, item, quality) then amount = drainStack(stack, field, unit, amount) end
	end
	for __, inventory in ipairs(inventories) do
		if amount <= EPSILON then return 0 end
		if inventory.valid then
			for slot = 1, #inventory do
				local stack = inventory[slot]
				if matches(stack, item, quality) then
					amount = drainStack(stack, field, unit, amount)
					if amount <= EPSILON then return 0 end
				end
			end
		end
	end
	return amount
end

-- Starts a transfer of `item` at `quality` among `controls` (players and entities). Nil when the item has no
-- per-item state: then the transfer needs no fix.
function this.begin(item, quality, controls)
	local field = this.field(item)
	if not field then return nil end
	quality = quality or "normal"
	local unit = unitOf(prototypes.item[item], field, quality)
	if not unit or unit <= 0 then return nil end
	local inventories, stacks = collect(controls)
	return {item = item, quality = quality, field = field, unit = unit, controls = controls,
		before = total(item, quality, field, unit, inventories, stacks)}
end

-- Ends a transfer: drains what it created from `drainOrder` (targets first, then the player). Controls that
-- joined the transfer later (a new target) can be listed in `extra`.
function this.finish(transfer, drainOrder, extra)
	if not transfer then return end
	local controls = transfer.controls
	if extra then
		controls = {}
		for __, control in ipairs(transfer.controls) do controls[#controls + 1] = control end
		for __, control in ipairs(extra) do controls[#controls + 1] = control end
	end
	local inventories, stacks = collect(controls)
	local after = total(transfer.item, transfer.quality, transfer.field, transfer.unit, inventories, stacks)
	local gain = after - transfer.before
	if transfer.field == "ammo" then gain = math.floor(gain + EPSILON) end
	if gain <= EPSILON then return end
	for __, control in ipairs(drainOrder) do
		local targetInventories, targetStacks = collect({control})
		gain = drain(transfer.item, transfer.quality, transfer.field, transfer.unit, gain, targetInventories, targetStacks)
		if gain <= EPSILON then return end
	end
end

return this
