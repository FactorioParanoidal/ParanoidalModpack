local Chest = {}

Chest.color = {r = 200/255, g = 110/255, b = 38/255}
Chest.entity_types = {'container', 'logistic-container', 'infinity-container', 'linked-container'}
Chest.unlocked = function(force) return force.technologies['factory-connection-type-chest'].researched end

local blacklist = {'factory-overlay-controller', 'factory-overlay-display'}
local blacklisted = {}
for _, name in pairs(blacklist) do blacklisted[name] = true end

local function get_chest_type(chest)
	local type = chest.prototype.logistic_mode
	if type == 'requester' then return 'input'
	elseif type == 'active-provider' then return 'output'
	elseif type == 'passive-provider' then return 'output'
	elseif type == 'buffer' then return 'output'
	elseif type == 'storage' then return 'input'
	else return 'neutral' end
end

Chest.connect = function(factory, cid, cpos, outside_entity, inside_entity, settings)
	if blacklisted[outside_entity.name] or blacklisted[inside_entity.name] then return nil end
	
	-- Connection mode: 0 for balance, 1 for inwards, 2 for outwards
	if not settings.mode then
		local outside_type = get_chest_type(outside_entity)
		local inside_type = get_chest_type(inside_entity)
		if outside_type == inside_type then
			settings.mode = 0
		elseif outside_type == 'input' or inside_type == 'output' then
			settings.mode = 1
		elseif outside_type == 'output' or inside_type == 'input' then
			settings.mode = 2
		end
	end
	
	return {outside = outside_entity, inside = inside_entity, do_tick_update = true}
end

Chest.recheck = function(conn)
	return conn.outside.valid and conn.inside.valid
end

local DELAYS = {10, 20, 60, 180, 600}
local DEFAULT_DELAY = 60
Chest.indicator_settings = {'d0', 'b0'}

for _,v in pairs(DELAYS) do
	table.insert(Chest.indicator_settings, 'd' .. v)
	table.insert(Chest.indicator_settings, 'b' .. v)
end

local function make_valid_delay(delay)
	for _,v in pairs(DELAYS) do
		if v == delay then return v end
	end
	return 0 -- Catchall
end

Chest.direction = function(conn)
	local mode = (conn._settings.mode or 0)
	if mode == 0 then
		return 'b' .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), defines.direction.north
	elseif mode == 1 then
		return 'd' .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_in
	else
		return 'd' .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_out
	end
end

Chest.rotate = function(conn)
	conn._settings.mode = ((conn._settings.mode or 0)+1)%3
	local mode = conn._settings.mode
	if mode == 0 then
		return {'factory-connection-text.balance-mode'}
	elseif mode == 1 then
		return {'factory-connection-text.input-mode'}
	else
		return {'factory-connection-text.output-mode'}
	end
end

Chest.adjust = function(conn, positive)
	local delay = conn._settings.delay or DEFAULT_DELAY
	if positive then
		for i = #DELAYS,1,-1 do
			if DELAYS[i] < delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {'factory-connection-text.update-faster', delay}
	else
		for i = 1,#DELAYS do
			if DELAYS[i] > delay then
				delay = DELAYS[i]
				break
			end
		end
		conn._settings.delay = delay
		return {'factory-connection-text.update-slower', delay}
	end
end

local basic_item_types = {['item'] = true, ['capsule'] = true, ['gun'] = true, ['rail-planner'] = true, ['module'] = true}
local function check_for_basic_item(item)
	local items_with_metadata = global.items_with_metadata
	if not items_with_metadata then
		items_with_metadata = {}
		for item_name, prototype in pairs(game.item_prototypes) do
			if not basic_item_types[prototype.type] then
				items_with_metadata[item_name] = true
			end
		end
		global.items_with_metadata = items_with_metadata
	end
	return not items_with_metadata[item]
end

local function move_item(item, count, input_inv, output_inv)
	if check_for_basic_item(item) then
		-- basic item being transfered
		local inserted_count = output_inv.insert{name = item, count = count}
		if inserted_count > 0 then
			input_inv.remove{name = item, count = inserted_count}
		end
	else
		-- advanced item being transfered, need to preserve tags, durablity, ect
		-- not safe to "split" the stack here, may result in some item sloshing
		while count > 0 do
			local stack = input_inv.find_item_stack(item)
			local empty_slot, i = output_inv.find_empty_stack(item)
			if not stack or not empty_slot then break end
			if output_inv.supports_bar() and output_inv.get_bar() == i then break end
			if not stack.swap_stack(empty_slot) then break end
			count = count - stack.count
		end
		output_inv.sort_and_merge()
	end
end

local floor = math.floor
local function balance(outside_inv, inside_inv)
	local outside_contents = outside_inv.get_contents()
	local inside_contents = inside_inv.get_contents()
	for item, count in pairs(outside_contents) do
		local count2 = inside_contents[item] or 0
		local diff = count - count2
		if diff > 1 then
			move_item(item, floor(diff / 2), outside_inv, inside_inv)
		elseif diff < -1 then
			move_item(item, floor(-diff / 2), inside_inv, outside_inv)
		end
	end
	for item, count in pairs(inside_contents) do
		if count > 1 and not outside_contents[item] then
			move_item(item, floor(count / 2), inside_inv, outside_inv)
		end
	end
end

local function inwards(outside_inv, inside_inv)
	local outside_contents = outside_inv.get_contents()
	for item, count in pairs(outside_contents) do
		move_item(item, count, outside_inv, inside_inv)
	end
end

local function outwards(outside_inv, inside_inv)
	local inside_contents = inside_inv.get_contents()
	for item, count in pairs(inside_contents) do
		move_item(item, count, inside_inv, outside_inv)
	end
end

Chest.tick = function(conn)
	local outside = conn.outside
	local inside = conn.inside
	if outside.valid and inside.valid then
		local outside_inv = outside.get_inventory(defines.inventory.chest)
		local inside_inv = inside.get_inventory(defines.inventory.chest)
		local mode = conn._settings.mode or 0
		if mode == 0 then
			balance(outside_inv, inside_inv)
		elseif mode == 1 then
			inwards(outside_inv, inside_inv)
		else
			outwards(outside_inv, inside_inv)
		end
		return conn._settings.delay or DEFAULT_DELAY
	else
		return false
	end
end

Chest.destroy = function(conn)
end

return Chest
