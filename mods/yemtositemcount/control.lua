local function create_gui(player)
    if not player.gui.center.total_item_count then
        player.gui.center.add{
            type                   = "label",
            name                   = "total_item_count",
            caption                = "0",
            direction              = "vertical",
            ignored_by_interaction = true
        }

        player.gui.center.total_item_count.style.font = "default-bold"
    end
end

local function remove_gui(player)
    if player.gui.center.total_item_count then
        player.gui.center.total_item_count.destroy()
    end
end

function get_blueprint_record(player)
	local record = player.cursor_record
	
	if record and record.valid then
		record = record.type == "blueprint-book" and record.get_selected_record(player) or record 
		if record.valid and record.type == "blueprint" then
			return record
		end
	end	
	
	return nil
end

function get_book_stack(player)
	local stack = player.cursor_stack
	
	if stack and stack.valid_for_read and stack.is_blueprint_book and stack.active_index then
		local book_inv = stack.get_inventory(defines.inventory.item_main)
		if book_inv and stack.active_index <= #book_inv then
			local book_stack = book_inv[stack.active_index]
			return book_stack.valid and book_stack or nil
		end
	end
	
	return nil
end

local function is_blacklisted(player, stack)
    local ignore = {}

	if not stack or not stack.valid_for_read then
		return false
	end
	
    if player.mod_settings["yemtositemcount-disable-blueprint-items"].value then
		ignore["deconstruction-planner"] = true
		ignore["upgrade-planner"] = true
    end

    if player.mod_settings["yemtositemcount-disable-artillery-remote"].value then
		ignore["artillery-targeting-remote"] = true
    end

	return ignore[stack.name]
end

local function format_number(player, num)
    local f = player.mod_settings["yemtositemcount-number-format"].value
	if f == "1,247" then return tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^[^0-9]+", "") end
    if f == "1.247" then return tostring(num):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^[^0-9]+", "") end    
    if f == "1 247" then return tostring(num):reverse():gsub("(%d%d%d)", "%1 "):reverse():gsub("^[^0-9]+", "") end

    if f == "1,2k" or f == "1.2k" then
        local c = 1
        local l = {"","k","M","B","T","Qa","Qi","Sx","Sp","Oc","No"}
        for key,_ in ipairs(l) do
            if num > 1000 then
                num = num / 1000
                c = c + 1
            else
                break
            end
        end

        if f == "1,2k" then return tostring(math.floor(num * 10) / 10):gsub("([^0-9]+)", ",") .. l[c] end
        if f == "1.2k" then return tostring(math.floor(num * 10) / 10):gsub("([^0-9]+)", ".") .. l[c] end
    end

    return num
end

local function calculateFromCost(player, cost_to_build)
	local count = nil
	local inventory = player.get_inventory(defines.inventory.character_main)
	
	if not inventory then
		return ""
	end
	
	for _, required in pairs(cost_to_build) do
		local item_count = inventory.get_item_count({ name=required.name, quality=required.quality })
		local times = item_count / required.count
		if count == nil or times < count then
			count = times
		end
	end
	
	if type(count) ~= "number" then
		return ""
	end
	
	return "x" .. format_number(player, math.floor(count))
end

local function calculatePlayerItem(player, stack)	
	local inventory = player.get_inventory(defines.inventory.character_main)
	
	if not inventory then
		return ""
	end

	-- Player is holding in a blueprint
	if stack and (stack.is_blueprint or stack.is_blueprint_book) then	
		local _, material = pcall(function()
			return stack.cost_to_build
		end)

		if type(material) ~= "table" then
			return ""
		end

		return calculateFromCost(player, material)
		
	-- Player is holding in an item
	else
		local item_count = stack.count + inventory.get_item_count({ name=stack.name, quality=stack.quality })
		return format_number(player, item_count) 
	end
end

local function refresh(e)
	local player = game.players[e.player_index]
	local blueprint = get_blueprint_record(player)
	local stack = get_book_stack(player) or player.cursor_stack

	if player.mod_settings["yemtositemcount-disable-mod"].value then
        remove_gui(player)
		return
    end

	if blueprint then
		create_gui(player)
		player.gui.center.total_item_count.caption = calculateFromCost(player, blueprint.cost_to_build) .. " "
	elseif stack and stack.valid_for_read and not is_blacklisted(player, stack) then
        create_gui(player)
        player.gui.center.total_item_count.caption = calculatePlayerItem(player, stack) .. " "
    else
        remove_gui(player)
    end
end

script.on_event(defines.events.on_player_cursor_stack_changed,          refresh)
script.on_event(defines.events.on_player_main_inventory_changed,        refresh)
script.on_event(defines.events.on_player_ammo_inventory_changed,        refresh)
script.on_event(defines.events.on_player_armor_inventory_changed,       refresh)
