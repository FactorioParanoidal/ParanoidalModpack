local MATH_CEIL = math.ceil

local function reverse_table(t)
	local len = #t
	for i = 1,len/2 do
		t[i], t[len-i+1] = t[len-i+1], t[i]
	end
end


local function sort_repair_tool (tool1, tool2)
	local tool1Prototype = prototypes.item[tool1]
	local tool2Prototype = prototypes.item[tool2]
	if tool1Prototype.infinite ~= tool2Prototype.infinite then
		return tool1Prototype.infinite
	end
	return tool1Prototype.speed > tool2Prototype.speed
end

-- Names of the repair tools in storage.repair_tools (rebuilt from it after a load).
local tool_names

local function index_tools()
	tool_names = nil
	local direction = settings.global["inventory-repair-order"].value
	local qualities = {}
	if direction == "ignore" then
		qualities = {"normal"}
	else
		for name in pairs(prototypes.quality) do
			if name ~= "quality-unknown" then
				table.insert(qualities, name)
			end
		end
	end
	table.sort(qualities, function(q1, q2) return prototypes.quality[q1].level > prototypes.quality[q2].level end)


	local tools, inf_tools = {}, {}
	for name, proto in pairs(prototypes.get_item_filtered({{filter="type", type="repair-tool"}})) do
		if proto.infinite then
			table.insert(inf_tools, name)
		else
			table.insert(tools, name)
		end
	end
	table.sort(tools, function(tool1, tool2) return prototypes.item[tool1].speed > prototypes.item[tool2].speed end)
	table.sort(inf_tools, function(tool1, tool2) return prototypes.item[tool1].speed > prototypes.item[tool2].speed end)


	storage.repair_tools = {}
	for _,name in pairs(inf_tools) do
		for _,quality in pairs(qualities) do
			table.insert(storage.repair_tools, {name=name, quality=quality})
		end
	end

	if direction == "low-first" then
		reverse_table(tools)
		reverse_table(qualities)
	end

	for _,name in pairs(tools) do
		for _,quality in pairs(qualities) do
			table.insert(storage.repair_tools, {name=name, quality=quality})
		end
	end

end

-- Performs a repair on an item with a repair pack, simulating the given number of ticks
-- @param repairPack the repair pack to use in the repair
-- @param damagedItem the item to be repaired
-- @param time the number of ticks to simulate
-- @return whether a repair was actually carried out
local function repair_item(repairPack, damagedItem, time)
	local place_result = damagedItem.prototype.place_result
	if not place_result then return false end
	local maxHealth = place_result.get_max_health(damagedItem.quality)
	local currHealth = damagedItem.health * maxHealth
	local speed = repairPack.prototype.speed * place_result.repair_speed_modifier / damagedItem.count
	if speed == 0 then return false end -- if the entity can't actually be repaired, return
	local repairAmount = time -- change in durability to the repair pack. Actual repair amount is this * speed
	
	-- if performing the repair would heal it to above full health, clamp the repairs to full health
	if maxHealth - currHealth < repairAmount * speed then
		repairAmount  = (maxHealth-currHealth) / speed
	end
	repairAmount = MATH_CEIL(repairAmount) -- use up the entire durability point for verismilitude
	
	-- if the repairs require more durability than the tool has, clamp the repairs to the tool's durability
	local remaining_durability = repairPack.prototype.infinite and 1/0 or repairPack.durability
	if remaining_durability < repairAmount then
		repairAmount = remaining_durability
	end
	repairPack.drain_durability(repairAmount)
	damagedItem.health = (currHealth + repairAmount*speed) / maxHealth
	return true
end

-- Searches the inventory to find the first damaged item
-- @param inventory the Inventory to find the item in
-- @return the damaged ItemStack or nil if none are found
local function find_damaged_item(inventory)
	for i=1,#inventory do
		if inventory[i].valid_for_read then
			if inventory[i].health < 1.0 and inventory[i].prototype.place_result then
				return inventory[i]
			end
		end
	end
	return nil
end

-- Parses through the given player's inventory, finding a repair pack and a damaged item and repairing it.
-- @param player the player to check
-- @param infinite whether the item should be repaired to full health
-- @return whether or not repairs were performed
local function check_inventory_for_repairs(player, time)
	local performedRepairs = false
	local playerInventory = player.get_main_inventory()
	if playerInventory then -- spectators and ghosts don't have inventories
		local repairPack, damagedItem = nil, nil
		-- Paranoidal: one get_contents() instead of one find_item_stack per tool and quality (with the 47
		-- qualities of ic-more-qualities up to 5 x 47 inventory searches per player every interval). The
		-- first tool of storage.repair_tools that is present is used, as before.
		if not tool_names then
			tool_names = {}
			for _, tool in ipairs(storage.repair_tools) do tool_names[tool.name] = true end
		end
		local present
		for _, entry in pairs(playerInventory.get_contents()) do
			if tool_names[entry.name] then
				present = present or {}
				present[entry.name .. "/" .. entry.quality] = true
			end
		end
		if present then
			for _, tool in ipairs(storage.repair_tools) do
				if present[tool.name .. "/" .. tool.quality] then
					repairPack = playerInventory.find_item_stack(tool)
					if repairPack then break end
				end
			end
		end
		
		if repairPack then
			damagedItem = find_damaged_item(playerInventory)
		end

		if repairPack and damagedItem then
			if repair_item(repairPack, damagedItem, time) then
				if damagedItem.health == 1 and player.auto_sort_main_inventory then -- inventory doesn't automatically re-sort, so sort it for them
					playerInventory.sort_and_merge()
				end
				player.play_sound({path="repair-pack",position=player.position})
				performedRepairs = true
			end
		end
	end
	return performedRepairs
end

local function instant_repair(player)
	local inventory = player.get_main_inventory()
	if inventory then
		for i = 1,#inventory do
			local item_stack = inventory[i]
			if item_stack.valid_for_read then
				item_stack.health = 1
			end
		end
	end
end

local function register_player(pid)
	storage.players[pid] = game.get_player(pid)
end

local function deregister_player(pid)
	storage.players[pid] = nil
end

-- Cached: the handler runs every tick, the setting changes rarely.
local repair_interval
local function read_interval()
	repair_interval = settings.global["inventory-repair-interval"].value
end

local function check_all_players(event)
	if not repair_interval then read_interval() end
	local interval = repair_interval
	-- Registered with on_nth_tick(interval): every call is a due tick.
	for pid,player in pairs(storage.players) do
		if not player.valid then
			deregister_player(pid)
		elseif player.cheat_mode or player.controller_type == defines.controllers.editor then -- is the player in cheat mode or editor?
			instant_repair(player)
			deregister_player(pid)
		else
			-- attempt to repair an item and deregister the player if no repairs were performed
			if not check_inventory_for_repairs(player, interval) then
				deregister_player(pid)
			end
		end
	end
end

script.on_event({defines.events.on_player_joined_game,defines.events.on_player_main_inventory_changed}, function(event) register_player(event.player_index) end)
script.on_event({defines.events.on_player_left_game}, function (event) deregister_player(event.player_index) end)

--script.on_nth_tick(PERIOD, function(event) check_all_players(event) end)
-- The check runs only on the interval ticks instead of every tick with a modulo gate.
-- Registration is derived from the runtime setting on every peer (init, load, setting change).
local registered_interval
local function register_tick()
	read_interval()
	if registered_interval and registered_interval ~= repair_interval then
		script.on_nth_tick(registered_interval, nil)
	end
	registered_interval = repair_interval
	script.on_nth_tick(repair_interval, check_all_players)
end

script.on_init(function(event) 
	index_tools() 
	storage.players = {}
	register_tick()
end)

script.on_load(register_tick)

script.on_configuration_changed(function(event) 
	index_tools() 
	storage.players = storage.players or {}
	register_tick()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "inventory-repair-interval" then
		register_tick()
	end
	if event.setting == "inventory-repair-order" then
		index_tools()
	end
end)