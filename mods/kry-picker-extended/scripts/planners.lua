-------------------------------------------------------------------------------
--[Planners]--
-------------------------------------------------------------------------------
-- TODO Remote API for registering/removing planners ?

local Table = require('__kry_stdlib__/stdlib/utils/table')
local Event = require('__kry_stdlib__/stdlib/event/event')
local Gui = require('__kry_stdlib__/stdlib/event/gui')
local Player = require('__kry_stdlib__/stdlib/event/player')
local Area = require('__kry_stdlib__/stdlib/area/area')
local Math = require('__kry_stdlib__/stdlib/utils/math')
-------------------------------------------------------------------------------
--[Tape Measure]--
-------------------------------------------------------------------------------

-- Input a number value: number = x
-- Outputs a string value with clamped decimal places, based on round_type
local function clamp_number(number, num_digits, round_type)
    local rounded_num

	-- round_type defaults to Math.round_to if not defined
    if round_type == "ceil" then
        rounded_num = Math.ceil_to(number, num_digits)
    elseif round_type == "floor" then
        rounded_num = Math.floor_to(number, num_digits)
    else
        rounded_num = Math.round_to(number, num_digits)
    end
	
	-- reformats the rounded_num to num_digits
    local str = string.format("%." .. num_digits .. "f", rounded_num)

    -- clean up trailing zeros only if num_digits > 0
	-- this prevents rounded_num result of 0 from being "cleaned"
    if num_digits > 0 then
        str = str:gsub("0+$", ""):gsub("%.$", "")
    end

    return str
end

-- Input a point value: point = {x,y}
-- Outputs a table of strings with clamped decimal places
local function clamp_point(point, num_digits)
    return {
        x = clamp_number(point.x, num_digits),
        y = clamp_number(point.y, num_digits)
    }
end

-- Input an area value: area = {point1 = {x=number,y=number}, point2 = {x=number,y=number}}
-- Outputs a table of tables of strings with clamped decimal places
local function clamp_area(area, num_digits)
    local result = {}
    for name, coords in pairs(area) do
        result[name] = clamp_point(coords, num_digits)
    end
    return result
end

-- returns in format of "String: number"
local function format_number(number, str)
    local msg = str.." = ".. number
    return msg
end

-- returns in format of "String: (x value, y value)"
local function format_point(point, str)
    local msg = str.." = ".."(" .. point.x .. ", " .. point.y .. ")"
    return msg
end

-- returns in format specific to Area: Left Top = (x,y), Right Bottom = (x,y)
local function format_area(area)
    local msg = format_point(area.left_top,"Left Top")
    msg = msg..", "..format_point(area.right_bottom,"Right Bottom")
    return msg
end

-- the actual tape measure function
local function measure_area(event)
    if event.item == 'picker-tape-measure' then
        local player = game.players[event.player_index]
		local set = player.mod_settings
		local num_digits = set["picker-tape-measure-clamp"].value
        local area = Area(event.area)
        if event.name == defines.events.on_player_alt_selected_area then
            area = area:ceil()
        end
        local size, width, height = area:size()
		-- if clamp value is 10, just print the raw values
		if num_digits == 10 then
			player.print(format_area(area) .. format_point(area:center(),"Center"))
			player.print('Size = ' .. size .. ' Width = ' .. width .. ' Height = ' .. height)
		elseif num_digits == 0 then
			local new_area = clamp_area(area, num_digits)
			local new_center = clamp_point(area:center(), num_digits)
			player.print(format_area(new_area) .. ", " .. format_point(new_center,"Center"))
			player.print(format_number(clamp_number(size,num_digits,"ceil"),"Size")..", "..
				format_number(clamp_number(width,num_digits,"ceil"),"Width")..", "..
				format_number(clamp_number(height,num_digits,"ceil"),"Height")
			)
		else
			local new_area = clamp_area(area, num_digits)
			local new_center = clamp_point(area:center(), num_digits)
			player.print(format_area(new_area) .. ", " .. format_point(new_center,"Center"))
			player.print(format_number(clamp_number(size,num_digits),"Size")..", "..
				format_number(clamp_number(width,num_digits),"Width")..", "..
				format_number(clamp_number(height,num_digits),"Height")
			)
		end
    end
end
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, measure_area)

-------------------------------------------------------------------------------
--[Tree Killer Compatibility]--
-------------------------------------------------------------------------------
local function set_tree_killer_filters(player)
    -- this logic taken directly from the Shortcut-ick mod function, tree_killer_setup()
    local settings = settings.get_player_settings(player)
    local entity_types = {}
    if settings["environment-killer-item"].value then
        table.insert(entity_types, "item-entity")
    end
    if settings["environment-killer-cliff"].value then
        table.insert(entity_types, "cliff")
    end
    if settings["environment-killer-fish"].value then
        table.insert(entity_types, "fish")
    end
    if settings["environment-killer-rocks"].value then
        table.insert(entity_types, "simple-entity")
    end
    if settings["environment-killer-trees"].value then
        table.insert(entity_types, "tree")
    end
    if #entity_types == 2 and (entity_types[1] == "tree" or entity_types[2] == "tree") and (entity_types[1] == "simple-entity" or entity_types[2] == "simple-entity") then
        player.cursor_stack.trees_and_rocks_only = true
    else
        local filters = {}
        for _, type in pairs(entity_types) do
            for _, entity in pairs(prototypes.get_entity_filtered({{filter = "type", type = type}})) do
                if entity.has_flag("not-deconstructable") == false and (type == "cliff" or entity.mineable_properties.minable) then
                    if #filters < 255 then
                        if type == "simple-entity" then
                            if prototypes.entity[entity.name].count_as_rock_for_filtered_deconstruction or string.sub(entity.name, 1, 14) == "fulgoran-ruin-" then
                                table.insert(filters, entity.name)
                            end
                        else
                            table.insert(filters, entity.name)
                        end
                    else
                        player.print({"", {"Shortcuts-ick.error-environment", type}, " (ERROR 3)"})
                        break
                    end
                end
            end
        end
        player.cursor_stack.entity_filters = filters
    end
end

-------------------------------------------------------------------------------
--[Planner Menu]--
-------------------------------------------------------------------------------
local function is_creative(player, item)
    return (item.name:find('creative%-mode') and (player.admin or player.cheat_mode) and remote.call('creative-mode', 'is_enabled'))
end

local function planner_enabled(player, item)
    local recipe = player.force.recipes[item.name]
    return not recipe or (recipe and recipe.enabled) or is_creative(player, item)
end

local function get_or_create_planner_flow(player, destroy)
    local pdata = storage.players[player.index]
	local set = player.mod_settings
	local height = set["picker-planner-height"].value
	local width = set["picker-planner-width"].value
    local flow = player.gui.center['picker_planner_flow']
    if flow and destroy then
        return flow.destroy()
    elseif not flow then
        local planners = storage.plan_order
        pdata.planners = pdata.planners or {}
        flow = player.gui.center.add {type = 'flow', name = 'picker_planner_flow', direction = 'vertical'}
        local frame = flow.add {type = 'frame', name = 'picker_planner_frame', direction = 'vertical', caption = {'planner-menu.header'}}
        local scroll = frame.add {type = 'scroll-pane', name = 'picker_planner_scroll'}
        scroll.style.maximal_height = height
        local gui_table = scroll.add {type = 'table', name = 'picker_planner_table', column_count = width}
        for _, planner in pairs(planners) do
            local proto = prototypes.item[planner]
            if pdata.planners[planner] == false then
                if not proto then
                    pdata.planners[planner] = nil
                end
            else
                pdata.planners[planner] = true
            end
            gui_table.add {
                type = 'sprite-button',
                name = 'picker_planner_table_sprite_' .. planner,
                sprite = 'item/' .. planner,
                style = pdata.planners[planner] and 'picker_buttons_med' or 'picker_buttons_med_off',
                tooltip = {'planner-menu.button', proto.localised_name, proto.localised_description}
            }
        end
        flow.visible = false
    end
    return flow
end

-- update the planner menu when mod setting is changed
local function planner_settings_changed(event)
    if event.setting_type ~= "runtime-per-user" then return end
    if event.setting ~= "picker-planner-height"
       and event.setting ~= "picker-planner-width" then return end

    local player = game.players[event.player_index]
    get_or_create_planner_flow(player, true)
end
Event.register(defines.events.on_runtime_mod_setting_changed, planner_settings_changed)

local function planner_clicked(event)
    local player, pdata = Player.get(event.player_index)
    local item = prototypes.item[event.match]

    if item then
        if event.button == defines.mouse_button_type.left then
            if planner_enabled(player, item) and player.clear_cursor() then
                player.cursor_stack.set_stack(event.match)
                player.cursor_stack_temporary = true
                -- compatibility required to set tree killer filters 
                if event.match == "tree-killer" then
                    set_tree_killer_filters(player)
                end
                event.element.parent.parent.parent.parent.visible = false
                pdata.last_planner = event.match
                player.opened = nil
            else
                player.print({'planner-menu.not-enabled'})
            end
        elseif event.button == defines.mouse_button_type.right then
            event.element.style = event.element.style.name == 'picker_buttons_med' and 'picker_buttons_med_off' or 'picker_buttons_med'
            pdata.planners[item.name] = event.element.style.name == 'picker_buttons_med'
        end
    end
end
Gui.on_click('picker_planner_table_sprite_(.*)', planner_clicked)

local function close_planner_menu(event)
    if event.element and event.element.name == 'picker_planner_flow' then
        event.element.visible = false
    end
end
Event.register(defines.events.on_gui_closed, close_planner_menu)

local function open_or_close_planner_menu(event)
    local player = game.players[event.player_index]
    local flow = get_or_create_planner_flow(player)
    flow.visible = not flow.visible
    player.opened = flow.visible and flow or nil
end
Event.register('picker-planner-menu', open_or_close_planner_menu)

-------------------------------------------------------------------------------
--[Next Planner]--
-------------------------------------------------------------------------------
-- Check if holding a valid planner from the list of player planners
local function holding_planner(player, pdata)
    if player.cursor_stack.valid_for_read then
        for planner in pairs(pdata.planners) do
            if player.cursor_stack.name == planner then
                return true
            end
        end
    end
    -- otherwise returns nil
end

-- This is where the magic happens
local function next_planner_loop(player, pdata, last_planner)
    local fail = 0
    local planner = last_planner -- this could be nil, ignored via next() function
    repeat
        planner = next(pdata.planners, planner)
        fail = fail + 1
    until pdata.planners[planner] and planner_enabled(player, prototypes.item[planner])
     or fail == (storage.nummber_of_planners+1) or fail == 100 -- failsafe
    return planner
end

-- logic to decide the next planner, and actiavte the next_planner_loop
local function get_next_planner(player, last_planner)
    local pdata = storage.players[player.index]
    local planner
    -- close blueprint menu if open
    get_or_create_planner_flow(player).visible = false
    -- if already holding planner, use it to find the next planner
    if holding_planner(player, pdata) then
        planner = next_planner_loop(player, pdata, last_planner)
    else -- either cursor has non-planner item or is empty
        if player.mod_settings['picker-remember-planner'].value then
            -- next planner should be last planner if it exists, or first valid planner
            planner = last_planner or next_planner_loop(player, pdata)
        else  -- otherwise find the first valid planner via loop
            planner = next_planner_loop(player, pdata)
        end
    end

    -- clear the player cursor and set stack to planner
    player.clear_cursor()
    player.cursor_stack.set_stack(planner)
    player.cursor_stack_temporary = true
    -- compatibility required to set tree killer filters
    if planner == "tree-killer" then
        set_tree_killer_filters(player)
    end
    -- add flying text after each switch
    player.create_local_flying_text{
        text = {"item-name." .. planner},
        create_at_cursor = true
    }
    -- returns the current planner to use as the last planner
    return planner
end

-- Register the cycle planners hotkey, which activates the get_next_planner subscript
local function cycle_planners(event)
    --game.print(serpent.block(storage.plan_order))
    local player, pdata = Player.get(event.player_index)
    if player.controller_type == defines.controllers.character or
       player.controller_type == defines.controllers.remote then
        -- create pdata.planners if it didn't already exist
        if not pdata.planners then
            --pdata.planners = Table.deepcopy(storage.planners)
        end
        -- if all planners are disabled, don't do anything.
        if string.find(serpent.line(pdata.planners),"true") then
            pdata.last_planner = get_next_planner(player, pdata.last_planner)
        end
    end
end
Event.register('picker-next-planner', cycle_planners)

-- this may be a little inefficient, but probably won't have more than 10, maybe 20 planners to check
local function sort_planner_storage()
    local sorted_keys = {}
    for key in pairs(storage.plan_order) do
        table.insert(sorted_keys, key)
    end

    table.sort(sorted_keys, function(a, b)
        return storage.plan_order[a] < storage.plan_order[b]
    end)

    storage.plan_order = Table.deepcopy(sorted_keys)
end

-- This runs on first init and when mod configuration is changed, I think
local function planners_changed()
    storage.planners = {}
    storage.plan_order = {}
    local plannerTypes = {
        "blueprint", "deconstruction-item","upgrade-item", "blueprint-book", "selection-tool"
    }
    local blacklist = {
        "^selection%-tool", "no%-picker"
    }
    -- Registers every matching planner types, excluding the ones on the blacklist
    --  adds it to the storage list for later use
    local nummber_of_planners = 0
    for _, item in pairs(prototypes.item) do
        for _, plannerType in pairs(plannerTypes) do
            if item.type == plannerType then
                for _, blacklisted in pairs(blacklist) do
                    if item.name:find(blacklisted) or item.order:find(blacklisted) then
                        goto skip_blueprint
                    end
                end
                storage.planners[item.name] = true
                storage.plan_order[item.name] = item.order or ("zzz"..tostring(nummber_of_planners))
                nummber_of_planners = nummber_of_planners + 1
                ::skip_blueprint::
            end
        end
    end
    -- set the number of planners and sort the list of planners
    storage.nummber_of_planners = nummber_of_planners
    sort_planner_storage()
	-- for each player in the game, update planner menu entries to current modlist
    for player_index, _ in pairs(game.players) do
		-- get player data and check if each planner still exists
		local player, pdata = Player.get(player_index)
		-- only check if pdata.planners exists
		if pdata.planners then
			for planner_name, enabled in pairs(pdata.planners) do
				-- if planner is not currently loaded, then we remove the entry
				if not storage.planners[planner_name] then
					pdata.planners[planner_name] = nil
				end
			end
			-- also do the inverse, for each planner that exists, but is NOT in the menu, add it
			for planner_name, _ in pairs(storage.planners) do
				if pdata.planners[planner_name] == nil then
					pdata.planners[planner_name] = true
				end
			end
		end
		-- This seems important for the blueprint menu
        local gui = player.gui.center['picker_planner_flow']
        if gui then
            gui.destroy()
        end
    end
end
Event.register(Event.core_events.init_and_config, planners_changed)