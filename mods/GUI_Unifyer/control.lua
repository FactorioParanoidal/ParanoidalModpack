local debug = require('scripts/debug')
local mod_gui = require("mod-gui")
local icons = require('icons')  -- Load icons during initial parse
local logging = require('scripts/logging')

local gui_button_style = "slot_button_notext"
local gui_button_style_whitetext = "slot_button_whitetext"
local activedebug = false

-- Debug logging function (legacy support)
local function log_debug(message)
    logging.debug("GUI", message, game.get_player(1))
end

-- Set to keep track of mods we've already processed
local function get_processed_mods()
    local processed = {}
    if global.gubuttonarray then
        for _, entry in pairs(global.gubuttonarray) do
            if entry[1] then  -- Mod name is first element
                processed[entry[1]] = true
            end
        end
    end
    return processed
end

local function setup_player(player)
    if not player or not player.valid then 
        logging.warning("Player", "Attempted to setup invalid player", game.get_player(1))
        return 
    end
    
    logging.debug("Player", "Setting up player: " .. player.name, player)
    if not global.player then global.player = {} end
    if not global.player[player.index] then
        global.player[player.index] = {
            checknexttick = 0
        }
        logging.info("Player", "Initialized new player state for: " .. player.name, player)
    end
end

-- Initialize or reset the global state
local function ensure_global_state()
    -- First create the global table if it doesn't exist
    if not global then
        global = {}
        logging.info("State", "Recreated global table", game.get_player(1))
    end
    
    -- Then initialize core global tables if they don't exist
    if not global.player then
        global.player = {}
        logging.info("State", "Recreated player table", game.get_player(1))
    end
    
    if not global.gubuttonarray then
        global.gubuttonarray = {}
        logging.info("State", "Recreated button array", game.get_player(1))
    end
    
    if not global.window_states then
        global.window_states = {}
        logging.info("State", "Recreated window states", game.get_player(1))
    end
    
    -- Handle edge case where array might be empty but initialized
    if not next(global.gubuttonarray) then
        global.gubuttonarray = {}
        logging.info("State", "Created empty button array", game.get_player(1))
    end
    
    -- Ensure all connected players have valid entries
    if game and game.players then
        for _, player in pairs(game.players) do
            if player and player.valid and not global.player[player.index] then
                setup_player(player)
                logging.info("State", "Setup missing player " .. player.index, game.get_player(1))
            end
        end
    end
end

local function build_button_array()
    logging.info("Buttons", "Starting build_button_array", game.get_player(1))
    ensure_global_state()
    
    -- Clear existing array to prevent duplicates
    global.gubuttonarray = {}
    
    -- Process each icon definition using our stored icons variable
    for _, icon in pairs(icons) do
        local mod_name = icon[1]
        
        -- Process all icons, even those we've seen before
        if mod_name and script.active_mods[mod_name] then
            logging.debug("Buttons", "Adding button for mod: " .. mod_name, game.get_player(1))
            table.insert(global.gubuttonarray, icon)
        end
    end
    
    logging.info("Buttons", "Completed build_button_array with " .. #global.gubuttonarray .. " buttons", game.get_player(1))
end

-- For migration compatibility
local function migrate_button_array()
    if global and global.gubuttonarray and #global.gubuttonarray == 0 then
        logging.info("Migration", "Performing button array migration", game.get_player(1))
        -- Only add empty entry if array is completely empty
        global.gubuttonarray = {{}}
    end
end

-- Main function that ties it all together
function init_button_array()
    logging.info("Init", "Starting init_button_array", game.get_player(1))
    
    -- Force rebuild the button array
    build_button_array()
    
    -- Always migrate after building
    migrate_button_array()
    
    logging.info("Init", "Completed init_button_array", game.get_player(1))
end

local function set_button_sprite(button, spritepath)
	if spritepath == nil then
		spritepath = ""
	end

	if button.type == "button" then
		if spritepath == "" then
			if button["button_sprite"] then
				button["button_sprite"].destroy()
			end
		else
			if button["button_sprite"] == nil then
				local sprite = button.add({type="sprite", name="button_sprite", sprite=spritepath, ignored_by_interaction=true })
				sprite.style.stretch_image_to_widget_size = true
				sprite.style.size = {32,32}
			else
				button["button_sprite"].sprite = spritepath
			end
		end
	end

	if button.type == "sprite-button" then
		button.sprite = spritepath
		button.hovered_sprite = spritepath
		button.clicked_sprite = spritepath
	end
end

local function update_window_state(player, button, windowtocheck)
    if not player or not player.valid or not windowtocheck then return false end
    
    local window_key = player.index .. "_" .. button
    local windowtocheckpath = player.gui
    local is_visible = true
    
    for _, k in pairs(windowtocheck) do
        if not windowtocheckpath or not windowtocheckpath[k] then
            is_visible = false
            break
        end
        local next_element = windowtocheckpath[k]
        if not next_element.valid or not next_element.visible then
            is_visible = false
            break
        end
        windowtocheckpath = next_element
    end
    
    -- Update stored state
    if not global.window_states[window_key] ~= is_visible then
        global.window_states[window_key] = is_visible
        return true -- State changed
    end
    return false
end

local function change_one_icon(player, sprite, button, tooltip, dontreplacesprite, buttonpath, windowtocheck)
    -- Validate essential parameters
    if not player or not player.valid or not player.gui or not sprite or not button then 
        logging.debug("Icons", string.format("Invalid parameters for button replacement - Player: %s, Sprite: %s, Button: %s", 
            player and player.name or "nil", 
            sprite or "nil", 
            button or "nil"
        ), player)
        return 
    end
    
    -- Log the attempt
    logging.debug("Icons", string.format("Attempting to replace button '%s' with sprite '%s' for player %s", 
        button, sprite, player.name), player)
    
    -- Safely get button settings
    local settingname = "gu_button_" .. button
    local player_settings = settings.get_player_settings(player)
    if not player_settings then 
        logging.debug("Icons", "Could not get player settings", player)
        return 
    end
    
    local is_button_true = true
    if player_settings[settingname] then
        is_button_true = player_settings[settingname].value
    end
    
    -- Safely get button style
    local style_setting = player_settings["gu_button_style_setting"]
    if not style_setting then 
        logging.debug("Icons", "Could not get style settings", player)
        return 
    end
    local gu_button_style_setting = style_setting.value or "slot_button_notext"
    
    -- Check window state
    if windowtocheck then
        local window_key = player.index .. "_" .. button
        if global.window_states[window_key] then
            gu_button_style_setting = gu_button_style_setting .. "_selected"
        end
    end
    
    -- Safely traverse button path
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow then 
        logging.debug("Icons", "Could not get button flow", player)
        return 
    end

    -- Also check top GUI for buttons
    local top_button = player.gui.top[button]
    if top_button then
        logging.debug("Icons", string.format("Found button '%s' in top GUI", button), player)
        if top_button.valid and (top_button.type == "button" or top_button.type == "sprite-button") then
            local success = pcall(function()
                top_button.style = gu_button_style_setting
                if not dontreplacesprite then
                    set_button_sprite(top_button, sprite)
                end
                if tooltip then
                    top_button.tooltip = tooltip
                end
                top_button.visible = is_button_true
            end)
            if success then
                logging.debug("Icons", string.format("Successfully replaced button '%s' in top GUI", button), player)
            else
                logging.debug("Icons", string.format("Failed to replace button '%s' in top GUI", button), player)
            end
        end
    else
        logging.debug("Icons", string.format("Button '%s' not found in top GUI", button), player)
    end
    
    if buttonpath then
        for _, k in pairs(buttonpath) do
            if not button_flow or not button_flow[k] then
                logging.debug("Icons", string.format("Button path traversal failed at '%s'", k), player)
                return -- Exit if path is invalid
            end
            button_flow = button_flow[k]
        end
    end
    
    -- Final button modifications with safety checks
    local modbutton = button_flow[button]
    if modbutton and modbutton.valid and 
       (modbutton.type == "button" or modbutton.type == "sprite-button") then
        -- Wrap potentially dangerous operations in pcall
        local success = pcall(function()
            modbutton.style = gu_button_style_setting
            if not dontreplacesprite then
                set_button_sprite(modbutton, sprite)
            end
            if tooltip then
                modbutton.tooltip = tooltip
            end
            modbutton.visible = is_button_true
        end)
        
        if success then
            logging.debug("Icons", string.format("Successfully replaced button '%s' in mod_gui flow", button), player)
        else
            logging.debug("Icons", string.format("Failed to replace button '%s' in mod_gui flow", button), player)
        end
    else
        logging.debug("Icons", string.format("Button '%s' not found in mod_gui flow", button), player)
    end
end

local function fix_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)

	if not global.gubuttonarray then build_button_array() end
	for _, k in pairs(global.gubuttonarray) do
		if k[1] == nil or script.active_mods[k[1]] then
			change_one_icon(player, k[2], k[3], k[4], k[5], k[6], k[7])
		end
	end

	if script.active_mods["BlackMarket2"] then
		if button_flow.flw_blkmkt and button_flow.flw_blkmkt.but_blkmkt_credits then
			local blackmarketvalue = button_flow.flw_blkmkt.but_blkmkt_credits.caption
			if blackmarketvalue then
				button_flow.flw_blkmkt.but_blkmkt_credits.tooltip = "Credit: ".. blackmarketvalue
			end
		end
	end

	if script.active_mods["AttilaZoomMod"] then
		for i=1,15 do
			local attilazoommod_button = button_flow["Attila_zm_btn_"..tostring(i)]
			local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
			local attila_button_style_setting = "slot_button_whitetext"
			if gu_button_style_setting == "slot_sized_button_notext" then attila_button_style_setting = "slot_sized_button_blacktext" end
			if attilazoommod_button then
				attilazoommod_button.style = attila_button_style_setting
				attilazoommod_button.tooltip = {'guiu.attilazoommod_button'}
				set_button_sprite(attilazoommod_button, "attilazoommod_button")
			end
		end
	end

	if script.active_mods["Todo-List"] then
		settings.get_player_settings(player)["gu_todolist_style_setting"].hidden = false
		local todolist_button = button_flow.todo_maximize_button
		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
		if todolist_button then
			if settings.get_player_settings(player)["gu_todolist_style_setting"].value == "icon" then
				set_button_sprite(todolist_button, "todolist_button")
				if todolist_button.caption then
					todolist_button.tooltip = todolist_button.caption
				end
			elseif settings.get_player_settings(player)["gu_todolist_style_setting"].value == "longtext" then
				set_button_sprite(todolist_button)
				gu_button_style_setting = "todo_button_default_snouz"
				if todolist_button.caption then
					todolist_button.tooltip = todolist_button.caption
				end
			end
			if player.gui.screen.todo_main_frame and player.gui.screen.todo_main_frame.visible == true then
				gu_button_style_setting = gu_button_style_setting .. "_selected"
			end
			todolist_button.style = gu_button_style_setting
		end
	else
		settings.get_player_settings(player)["gu_todolist_style_setting"].hidden = true
	end

	if script.active_mods["DeleteAdjacentChunk"] and button_flow.DeleteAdjacentChunk_table then
		local dac_buttons_list = {"DeleteAdjacentChunk_nw", "DeleteAdjacentChunk_n", "DeleteAdjacentChunk_ne", "DeleteAdjacentChunk_w", "DeleteAdjacentChunk_e", "DeleteAdjacentChunk_sw", "DeleteAdjacentChunk_s", "DeleteAdjacentChunk_se"}
		for _,k in pairs(dac_buttons_list) do
			if button_flow.DeleteAdjacentChunk_table[k] then
				button_flow.DeleteAdjacentChunk_table[k].style = "adjacentchunks_button"
				button_flow.DeleteAdjacentChunk_table[k].sprite = nil
			end
		end
	end

	if script.active_mods["Factorissimo2"] then
		local fcsmo = button_flow.factory_camera_toggle_button
		if fcsmo then
			if fcsmo.sprite == "technology/factory-architecture-t1" then
				fcsmo.sprite = "factorissimo2_button"
				fcsmo.tooltip = {'guiu.factorissimo2_button'}
			elseif fcsmo.sprite == "technology/factory-preview" then
				fcsmo.sprite = "factorissimo2_inspect_button"
				fcsmo.tooltip = {'guiu.factorissimo2_button'}
			end
		end
	end
end

local function create_new_buttons(player)
    local button_flow = mod_gui.get_button_flow(player)
    local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"

    if script.active_mods["visual-signals"] then
        -- First destroy the original button if it exists
        if player.gui.top["visual_signals"] then
            player.gui.top["visual_signals"].destroy()
        end
        
        -- Then create our version in the button flow
        if not button_flow["visual_signals"] then
            button_flow.add {
                type = "sprite-button",
                name = "visual_signals",
                style = gu_button_style_setting,
                sprite = "visualsignals_button",
                tooltip = {'guiu.visual_signals_button'}
            }
        end
    end

	local function create_buttons_from_list(mod, button, sprite, tooltip, optionon)
		if script.active_mods[mod] and optionon then
			if not button_flow[button] then
				button_flow.add {
					type = "sprite-button",
					name = button,
					sprite = sprite,
					style = gu_button_style_setting,
					tooltip = tooltip,
				}
				if button == "YARM_filter_none" then button_flow.YARM_filter_none.visible = false end
				if button == "YARM_filter_warnings" then button_flow.YARM_filter_warnings.visible = false end
			end
		elseif button_flow[button] then
			button_flow[button].destroy()
		end
	end

	local abdshowgui = settings.get_player_settings(player)["abd-showgui"] and settings.get_player_settings(player)["abd-showgui"].value or false

	local newbuttonlist = {
		--mod					button name 								sprite 							tooltip 									show button (for some there's already a setting to toggle button)
		{"FJEI",				"fjei_toggle_button",						"fjei_button",					{'guiu.fjei_button'},						true},
		{"homeworld_redux",		"Homeworld_btn",							"homeworld_redux_button",		{'guiu.homeworld_redux_button'},			true},
		{"m-lawful-evil",		"lawful_evil_button",						"mlawfulevil_button",			{'guiu.mlawfulevil_button'},				true},
		{"Trashcan",			"trashbinguibutton",						"trashcan_button",				{'guiu.trashcan_button'},					true},
		{"pycoalprocessing",	"pywiki",									"pycoalprocessing_button",		{'guiu.pycoalprocessing_button'},			true},
		{"usage-detector",		"usage_detector",							"usagedetector_button",			{'guiu.usagedetector_button'},				true},
		{"RPG",					"104",										"rpg_button",					{'guiu.rpg_button'},						true},
		{"TimedSpawnControl",	"random",									"spawncontrol_random_button",	{'guiu.spawncontrol_random_button'},		true},
		{"what-is-missing",		"what_is_missing",							"whatsmissing_button",			{'guiu.whatsmissing_button'},				true},
		{"some-zoom",			"but_zoom_zout",							"somezoom_out_button",			{'guiu.somezoom_out_button'},				true},
		{"some-zoom",			"but_zoom_zin",								"somezoom_in_button",			{'guiu.somezoom_in_button'},				true},
		{"production-monitor",	"stats_show_settings",						"productionmonitor_button",		{'guiu.productionmonitor_button'},			true},
		{"Teleportation_Redux",	"teleportation_main_button",				"teleportation_button",			{'guiu.teleportation_button'},				true},
		{"PersonalTeleporter",	"personalTeleporter_PersonalTeleportTool",	"teleportation_button",			{'guiu.teleportation_button'},				true},
		{"inserter-throughput",	"inserter-throughput-toggle",				"inserterthroughput_off_button",{'guiu.inserterthroughput_off_button'},		true},
		{"YARM",				"YARM_filter_none",							"yarm_all_button",				{'guiu.yarm_all_button'},					true},
		{"YARM",				"YARM_filter_warnings",						"yarm_none_button",				{'guiu.yarm_none_button'},					true},
		{"YARM",				"YARM_filter_all",							"yarm_warnings_button",			{'guiu.yarm_warnings_button'},				true},
		{"RecExplo",			"b_recexplo",								"recexplo_button",				{'guiu.recexplo_button'},					true},
		{"BlueprintLab_design",	"BPL_LabButton",							"blueprintlabdesign_button",	{'guiu.blueprintlabdesign_button'},			true},
		{"CredoTimeLapseModByGalapagon","CTLM_mainbutton",					"credotimelapse_button",		{'guiu.credotimelapse_button'},				true},
		{"Decu",				"market_button",							"decu_button",					{'guiu.decu_button'},						true},
		{"rd-se-multiplayer-compat","toggle_forces",						"forces_button",				{'guiu.compatforce_button'},				true},
		{"rd-se-multiplayer-compat","toggle_spawn_gui",						"spawncontrol_button",			{'guiu.compatspawn_button'},				true},
		{"Spiderissmo",			"108",										"item/spidertron",				{'guiu.Spiderissmo_spider_button'},			true},
		{"Spiderissmo",			"minimap_button",							"credotimelapse_button",		{'guiu.Spiderissmo_minimap_button'},		true},
		{"automatic-belt-direction","abdgui",								"abd_on_button",				{'guiu.abd_on_button'},						abdshowgui}
	}

	for _, k in pairs(newbuttonlist) do
		create_buttons_from_list(k[1], k[2], k[3], k[4], k[5])
	end

	--[[local buttons_for_shortcuts = {
		{"LtnManager", 			"gu_ltnm-toggle-gui", 							"forces_button", 				{'guiu.ltnmanager'}, 						true},
	}

	for _, k in pairs(buttons_for_shortcuts) do
		create_buttons_from_list(k[1], k[2], k[3], k[4], k[5])
	end]]

	if player.force and player.force.technologies["advanced-logistics-systems"] and player.force.technologies["advanced-logistics-systems"].researched then
		create_buttons_from_list("advanced-logistics-system-fork", "logistics-view-button", "logisticssystemfork_button", {'guiu.logisticssystemfork_button'}, true)
	end

	if script.active_mods["clock"] then
		if not button_flow.clockGUI then
			button_flow.add {
				type = "button",
				name = "clockGUI",
				style = "todo_button_default_snouz",
				caption = "",
			}
		end
	elseif button_flow.clockGUI then
		button_flow.clockGUI.destroy()
	end

	if script.active_mods["SpawnControl"] or script.active_mods["TimedSpawnControl"] then
		if not button_flow.spawn then
			button_flow.add {
				type = "sprite-button",
				name = "spawn",
				style = gu_button_style_setting,
				sprite = "spawncontrol_button",
			}
		end
	elseif button_flow["spawn"] then
		button_flow["spawn"].destroy()
	end

	if script.active_mods["inserter-throughput"] then
		if button_flow["inserter-throughput-toggle"] and settings.get_player_settings(player)["inserter-throughput-enabled"] then
			if settings.get_player_settings(player)["inserter-throughput-enabled"].value == true then
				button_flow["inserter-throughput-toggle"].sprite = "inserterthroughput_on_button"
				button_flow["inserter-throughput-toggle"].tooltip = {'guiu.inserterthroughput_on_button'}
			else
				button_flow["inserter-throughput-toggle"].sprite = "inserterthroughput_off_button"
				button_flow["inserter-throughput-toggle"].tooltip = {'guiu.inserterthroughput_off_button'}
			end
		end
	end
end


local function update_yarm_button(event)
	if event and event.element then
		if event.element.name == "YARM_filter_all" or event.element.name == "YARM_filter_none" or event.element.name == "YARM_filter_warnings" then
			local player = event.player_index and game.players[event.player_index]
			if not player or not player.valid then return end
			local button_flow = mod_gui.get_button_flow(player)
			local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
			if button_flow["YARM_filter_all"] and button_flow["YARM_filter_none"] and button_flow["YARM_filter_warnings"] then
				if button_flow["YARM_filter_all"].visible == true then
					button_flow["YARM_filter_all"].visible = false
					button_flow["YARM_filter_none"].visible = true
				elseif button_flow["YARM_filter_none"].visible == true then
					button_flow["YARM_filter_none"].visible = false
					button_flow["YARM_filter_warnings"].visible = true
				elseif button_flow["YARM_filter_warnings"].visible == true then
					button_flow["YARM_filter_warnings"].visible = false
					button_flow["YARM_filter_all"].visible = true
				end
			end
		end
	end
end

local function destroy_obsolete_buttons(player)
	local button_flow = mod_gui.get_button_flow(player)
	local top = player.gui.top

	if button_flow.le_flow then
		button_flow.le_flow.destroy()
	end

	if not player.is_cursor_blueprint() then
		if button_flow.le_button then button_flow.le_button.destroy() end
		if button_flow.blueprint_flip_horizontal then button_flow.blueprint_flip_horizontal.destroy() end
		if button_flow.blueprint_flip_vertical then button_flow.blueprint_flip_vertical.destroy() end
	end

	if script.active_mods["automatic-belt-direction"] and button_flow.abdgui and settings.get_player_settings(player)["abd-showgui"] and settings.get_player_settings(player)["abd-showgui"].value == false then
		button_flow.abdgui.destroy()
	end

	local topelems_tokill = {
		"blpflip_flow", "fjei_toggle_button", "Homeworld_btn", "lawful_evil_button", "trashbingui", "pywiki_frame", "usage_detector", "104",
		"spawn", "random", "what_is_missing", "logistics-view-button", "flw_zoom", "stats_show_settings", "teleportation_main_button",
		"personalTeleporter_PersonalTeleportTool", "inserter-throughput-toggle", "b_recexplo", "CTLM_mainbutton", "market_button", "rd_container", "abdgui", "clockGUI", "visual_signals",
	}

	if settings.get_player_settings(player)["gu_mod_enabled_perplayer"].value == true then
		for _, e in pairs(topelems_tokill) do
			if top[e] and top[e].visible == true then
				top[e].visible = false
			end
		end
	elseif settings.get_player_settings(player)["gu_mod_enabled_perplayer"].value == false then
		for _, e in pairs(topelems_tokill) do
			if top[e] and top[e].visible == false then
				top[e].visible = true
			end
		end
	end

	if script.active_mods["production-monitor"] then
		if player.gui.left.stats_item_flow then
			local button_table_pm = player.gui.left.stats_item_flow.children_names[1]
			if player.gui.left.stats_item_flow[button_table_pm] and player.gui.left.stats_item_flow[button_table_pm].stats_show_settings then

				if player.gui.left.stats_item_flow[button_table_pm].column_count <= 1 then
					player.gui.left.stats_item_flow[button_table_pm].stats_show_settings.enabled = false
					player.gui.left.stats_item_flow[button_table_pm].stats_show_settings.visible = false
				end
			end
		elseif player.gui.top.stats_item_flow then
			local button_table_pm = player.gui.top.stats_item_flow.children_names[1]
			if player.gui.top.stats_item_flow[button_table_pm] and player.gui.top.stats_item_flow[button_table_pm].stats_show_settings then

				if player.gui.top.stats_item_flow[button_table_pm].column_count <= 1 then
					player.gui.top.stats_item_flow[button_table_pm].stats_show_settings.enabled = false
					player.gui.top.stats_item_flow[button_table_pm].stats_show_settings.visible = false
				end
			end
		end
	end

	if script.active_mods["YARM"] then
		local ff = mod_gui.get_frame_flow(player)
		if ff and ff.YARM_root and ff.YARM_root.buttons then
			local yarmbuttons = ff.YARM_root.buttons
			if yarmbuttons.YARM_filter_none then yarmbuttons.YARM_filter_none.visible = false end
			if yarmbuttons.YARM_filter_warnings then yarmbuttons.YARM_filter_warnings.visible = false end
			if yarmbuttons.YARM_filter_all then yarmbuttons.YARM_filter_all.visible = false end
		end
	end

	if player.gui.left.BPL_Flow and player.gui.left.BPL_Flow.BPL_LabButton and player.gui.left.BPL_Flow.BPL_LabButton.visible == true then
		player.gui.left.BPL_Flow.BPL_LabButton.visible = false
	end

	if script.active_mods["Spiderissmo"] then
		if top.minimap_button and top.minimap_button.visible == true then
			top.minimap_button.visible = false
		end
		if top["108"] and top["108"].visible == true then
			top["108"].visible = false
		end
		if player.surface and player.surface.name and player.surface.name == "nauvis" then
			if button_flow.minimap_button then button_flow.minimap_button.visible = false end
			if button_flow["108"] then button_flow["108"].visible = false end
		else
			if button_flow.minimap_button then button_flow.minimap_button.visible = true end
			if button_flow["108"] then button_flow["108"].visible = true end
		end
	end
end

local function update_frame_style(event)
    local player = event.player_index and game.players[event.player_index]
    if not player or not player.valid then return end
    local gu_frame_style_setting = settings.get_player_settings(player)["gu_frame_style_setting"].value or "normal_frame_style"
    
    if player.gui and player.gui.top and player.gui.top.mod_gui_top_frame and player.gui.top.mod_gui_top_frame.mod_gui_inner_frame then
        if gu_frame_style_setting == "snouz_normal_frame_style" then
            player.gui.top.mod_gui_top_frame.style = "frame"  -- Using built-in frame style
            player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "inside_shallow_frame"
        elseif gu_frame_style_setting == "snouz_barebone_frame_style" then
            player.gui.top.mod_gui_top_frame.style = "snouz_invisible_frame"
            player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "snouz_barebone_frame"
        elseif gu_frame_style_setting == "snouz_large_barebone_frame_style" then
            player.gui.top.mod_gui_top_frame.style = "snouz_invisible_frame"
            player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "snouz_large_barebone_frame"
        elseif gu_frame_style_setting == "snouz_invisible_frame_style" then
            player.gui.top.mod_gui_top_frame.style = "snouz_invisible_frame"
            player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "snouz_invisible_frame"
        end
    end
end

local function cycle_buttons_to_rename(player)
	local button_flow = mod_gui.get_button_flow(player)
	if button_flow.children then
		for i, k in pairs(button_flow.children) do
			if not k.name or k.name == "" then
				if k.caption and k.caption[1] and k.caption[1] == "nwd2.upgrade-button" then
					k.name = "nwd2_main_gui_button"
				end
				if k.tooltip and k.tooltip[1] and k.tooltip[1] == "upgrade-button-tooltip" then
					k.name = "swd3_main_gui_button"
				end
				if k.tooltip and k.tooltip[1] and k.tooltip[1] == "dana.longName" then
					k.name = "dana_main_gui_button"
				end
				if k.caption and k.caption[1] and k.caption[1] == "teams" then
					k.name = "base_pvp_teams_button"
				end
				if k.caption and k.caption[1] and k.caption[1] == "space_race" then
					k.name = "base_pvp_space_race_button"
				end
				if k.caption and k.caption[1] and k.caption[1] == "admin" then
					k.name = "base_pvp_admin_button"
				end
			end
		end
	end
end

local function cycle_frames_to_rename(player)
	if player.gui.screen.children then
		for i, k in pairs(player.gui.screen.children) do
			if script.active_mods["factoryplanner"] and k.tags and k.tags.mod and k.tags.mod == "fp" and not player.gui.screen.factoryplanner_mainframe then
				k.name = "factoryplanner_mainframe"
			elseif script.active_mods["train-log"] and k.tags and k.tags["train-log"] and not player.gui.screen.trainlog_mainframe then
				k.name = "trainlog_mainframe"
			elseif script.active_mods["ModuleInserter"] and k.tags and k.tags.ModuleInserter and not player.gui.screen.moduleinserter_mainframe then
				k.name = "moduleinserter_mainframe"
			elseif script.active_mods["Rich_Text_Helper"] and k.name and k.name == "RICH_LOCATION_23_player01" and not player.gui.screen.richtexthelper_mainframe then
				k.name = "richtexthelper_mainframe"
			elseif script.active_mods["Not_Enough_Todo"] and k.children and k.children[1] and k.children[1].children and k.children[1].children[1] and k.children[1].children[1].children and k.children[1].children[1].children[1] and k.children[1].children[1].children[1].caption and k.children[1].children[1].children[1].caption[1] and k.children[1].children[1].children[1].caption[1] == "Todo.GuiTitle" and not player.gui.screen.notenoughtodo_mainframe then
				k.name = "notenoughtodo_mainframe"
			end
		end
	end
end

local function check_buttons_disabled(event)
	local player = event.player_index and game.players[event.player_index]
	if not player or not player.valid then return end

	local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
end

local function on_player_cursor_stack_changed(event)
	local player = event.player_index and game.players[event.player_index]
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)

	destroy_obsolete_buttons(player)

	if player.is_cursor_blueprint() then

		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"

		if script.active_mods["blueprint-request"] then
			local blueprintrequest_button = button_flow["blueprint-request-button"]
			if blueprintrequest_button then
				blueprintrequest_button.style = gu_button_style_setting
				set_button_sprite(blueprintrequest_button, "blueprintrequest_button")
			end
		end

		if script.active_mods["LandfillEverythingU"] or script.active_mods["LandfillEverything"] or script.active_mods["LandfillEverythingButTrains"] or script.active_mods["LandfillEverythingAndPumps"] then
			if not button_flow.le_button then
				button_flow.add {
					type = "sprite-button",
					name = "le_button",
					sprite = "landfilleverythingu_button",
					style = gu_button_style_setting,
					tooltip = { "landfill_everything_tooltip" }
				}
			end
		end

		if script.active_mods["blueprint_flip_and_turn"] then
			if not button_flow.blueprint_flip_horizontal and not button_flow.blueprint_flip_vertical then
				button_flow.add {
					type = "sprite-button",
					name = "blueprint_flip_horizontal",
					sprite = "blueprint_flip_horizontal_button",
					style = gu_button_style_setting,
					tooltip = {'guiu.blueprint_flip_horizontal_button'}
				}
				button_flow.add {
					type = "sprite-button",
					name = "blueprint_flip_vertical",
					sprite = "blueprint_flip_vertical_button",
					style = gu_button_style_setting,
					tooltip = {'guiu.blueprint_flip_vertical_button'}
				}
			end
		end
	end

	if script.active_mods["SchallOreConversion"] then
		local pcs = player.cursor_stack
		if pcs and pcs.valid_for_read and pcs.valid and pcs.name then
			if pcs.name == "iron-ore" or pcs.name == "copper-ore" or pcs.name == "stone" or pcs.name == "coal" or pcs.name == "uranium-ore" or pcs.name == "crude-oil" then
				local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
				local schalloreconversion_button = button_flow["Schall-OC-mod-button"]
				if schalloreconversion_button then
					schalloreconversion_button.style = gu_button_style_setting
					set_button_sprite(schalloreconversion_button, "schalloreconversion_button")
				end
			end
		end
	end
end

local function general_update()
    -- Initialize global table if it doesn't exist
    if not global then
        logging.warning("State", "Global table is nil in general_update, reinitializing", game.get_player(1))
        global = {}
    end
    
    -- Initialize global.player if it doesn't exist
    if not global.player then
        logging.warning("State", "Global.player table is nil in general_update, reinitializing", game.get_player(1))
        global.player = {}
    end

    -- Then process all players
    for _, player in pairs(game.players) do
        if player and player.valid then
            if not global.player[player.index] then 
                logging.debug("Player", "Setting up missing player in general_update: " .. player.name, player)
                setup_player(player) 
            end
            global.player[player.index].checknexttick = global.player[player.index].checknexttick + 1
        end
    end
end

local function general_update_event(event)
    -- First verify we have a valid player
    local player = event.player_index and game.players[event.player_index]
    if not player or not player.valid then 
        logging.error("Event", "Invalid player in general_update_event", game.get_player(1))
        return 
    end

    -- Initialize global if it doesn't exist
    if not global then
        logging.warning("State", "Global table is nil in general_update_event, reinitializing", player)
        global = {}
    end

    -- Initialize global.player if it doesn't exist
    if not global.player then
        logging.warning("State", "Global.player table is nil in general_update_event, reinitializing", player)
        global.player = {}
    end
    
    -- Check if button array needs initialization
    if not global.gubuttonarray or #global.gubuttonarray == 0 then
        logging.info("Buttons", "Button array empty during update, reinitializing", player)
        init_button_array()
    end

    -- Setup player if needed and increment check counter
    if not global.player[event.player_index] then
        logging.debug("Player", "Setting up player " .. player.name, player)
        setup_player(player)
    end

    -- Verify setup succeeded
    if global.player[event.player_index] then
        global.player[event.player_index].checknexttick = global.player[event.player_index].checknexttick + 1
    else
        logging.error("Player", "Failed to setup player " .. player.name .. ", creating minimal state", player)
        global.player[event.player_index] = {
            checknexttick = 1
        }
    end
end

local function on_configuration_changed()
	build_button_array()
	general_update()
end

local function on_player_configuration_changed(event)
	check_buttons_disabled(event)
	general_update_event(event)
	update_frame_style(event)
end

local function force_update_player_buttons(player)
    if not player or not player.valid then
        logging.error("Buttons", "Invalid player in force_update_player_buttons", game.get_player(1))
        return
    end
    
    logging.debug("Buttons", "Forcing button update for player " .. player.name, player)
    
    -- Wrap in pcall for safety
    local status, err = pcall(function()
        create_new_buttons(player)
        fix_buttons(player)
        destroy_obsolete_buttons(player)
    end)
    
    if not status then
        logging.error("Buttons", "Error updating buttons for " .. player.name .. ": " .. tostring(err), player)
    end
end

-- Reset button states safely
local function reset_button_states(player)
    if not player or not player.valid then return end
    
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow then return end
    
    -- Get default style
    local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
    
    -- Reset all button states
    if button_flow.children then
        for _, button in pairs(button_flow.children) do
            if button.valid then
                -- Remove any "_selected" suffix from style
                local current_style = button.style and button.style.name
                if current_style and current_style:match("_selected$") then
                    button.style = gu_button_style_setting
                end
            end
        end
    end
end

local function on_player_joined(event)
    local player = event.player_index and game.players[event.player_index]
    if not player or not player.valid then
        logging.error("Event", "Invalid player in on_player_joined", game.get_player(1))
        return
    end
    
    logging.info("Player", "Player joined: " .. player.name .. " (index: " .. player.index .. ")", player)
    
    -- Initialize player state
    local status, err = pcall(function()
        general_update_event(event)
    end)
    
    if not status then
        logging.error("Event", "Error in general_update_event during player join: " .. tostring(err), player)
        -- Attempt recovery
        if not global then global = {} end
        if not global.player then global.player = {} end
        if not global.player[event.player_index] then
            global.player[event.player_index] = {
                checknexttick = 0
            }
        end
    end
    
    -- Reset button states first
    reset_button_states(player)
    
    -- Force immediate button update instead of waiting for tick
    force_update_player_buttons(player)

    -- EvoGUI handling
    if script.active_mods["EvoGUI"] then
        if player.gui.top.evogui_root then
            logging.debug("GUI", "Destroying and recreating EvoGUI for " .. player.name, player)
            player.gui.top.evogui_root.destroy()
        end
    end
end

local function on_gui_click(event)
    -- Skip if we're not properly initialized
    if not global then 
        logging.warning("State", "Skipping on_gui_click - global not initialized", game.get_player(1))
        return 
    end
    
    local player = event.player_index and game.players[event.player_index]
    if not player or not player.valid then return end
    
    -- Ensure player state exists
    if not global.player[player.index] then
        setup_player(player)
    end
    
    if script.active_mods["YARM"] then update_yarm_button(event) end

    global.player[player.index].checknexttick = global.player[player.index].checknexttick + 1

    -- More defensive clock GUI check
    if script.active_mods["clock"] then
        local gui_path = player.gui.top.mod_gui_top_frame
        if gui_path and gui_path.mod_gui_inner_frame then
            local clock_gui = gui_path.mod_gui_inner_frame.clock_gui
            if clock_gui then
                clock_gui.style = clock_gui.visible and "todo_button_default_snouz_selected" or "todo_button_default_snouz"
            end
        end
    end


    local buttname = ""
    if event.element and event.element.name then
        buttname = event.element.name
    else
        return
    end

        --force closed if button clicked
    if script.active_mods["pycoalprocessing"] then
        if buttname == "pywiki" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
            player.gui.screen.wiki_frame.destroy()
        end
    end
    if script.active_mods["SolarRatio"] then
        if buttname == "niet-sr-guibutton" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
            player.gui.center["niet-sr-guiframe"].destroy()
        end
    end
    if script.active_mods["CitiesOfEarth"] then
        if buttname == "coe_button_show_targets" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
            player.gui.center["coe_choose_target"].destroy()
        end
    end

    if script.active_mods["automatic-belt-direction"] then
        if buttname == "abdgui" then
            if player.gui.top.abdgui and player.gui.top.abdgui.sprite == "abd-gui-on" then
                event.element.sprite = "abd_on_button"
                event.element.tooltip = {'guiu.abd_on_button'}
            else
                event.element.sprite = "abd_off_button"
                event.element.tooltip = {'guiu.abd_off_button'}
            end
        end
    end

    if activedebug or player == game.players["snouz"] then debug_button(event) end
end

local function on_hivemindchange(event)
	if script.active_mods["Hive_Mind"] or script.active_mods["Hive_Mind_Remastered"] then
		if not event.player_index then return end
		if not global.player or not global.player[event.player_index] then setup_player(game.players[event.player_index]) end
		global.player[event.player_index].checknexttick = global.player[event.player_index].checknexttick + 1
	end
end

local function on_built(event)
    -- Ensure global state is initialized
    ensure_global_state()
    
    -- Log all build events for debugging
    if event and event.created_entity then
        logging.debug("Build Event", string.format(
            "Entity built: %s (type: %s) (tick: %d)",
            event.created_entity.name,
            event.created_entity.type,
            game.tick
        ), game.get_player(1))
    end

    -- Handle Visual Signals button creation
    if script.active_mods["visual-signals"] then
        if event and event.created_entity and event.created_entity.name == "gui-signal-display" then
            -- Create the button for all players if it doesn't exist
            for _, player in pairs(game.players) do
                -- Ensure player state exists
                if not global.player[player.index] then
                    setup_player(player)
                end
                
                local button_flow = mod_gui.get_button_flow(player)
                local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
                
                -- Only create if not exists
                if not button_flow.visual_signals then
                    button_flow.add {
                        type = "sprite-button",
                        name = "visual_signals",
                        style = gu_button_style_setting,
                        sprite = "visualsignals_button",
                        tooltip = {'guiu.visual_signals_button'}
                    }
                end
                
                -- Update styling even if button exists
                if button_flow.visual_signals then
                    button_flow.visual_signals.style = gu_button_style_setting
                    button_flow.visual_signals.sprite = "visualsignals_button"
                    button_flow.visual_signals.tooltip = {'guiu.visual_signals_button'}
                end
                
                -- Set the check counter to force an update
                if global.player[player.index] then
                    global.player[player.index].checknexttick = (global.player[player.index].checknexttick or 0) + 1
                end
            end
        end
    end

    -- Rest of the existing on_built code...
    if script.active_mods["Teleportation_Redux"] then
        if not global.Teleportation_Redux_built then
            if event and event.created_entity and event.created_entity.name == "teleportation-beacon" then
                for _,player in pairs(game.players) do
                    local button_flow = mod_gui.get_button_flow(player)
                    local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
                    if not button_flow.teleportation_main_button then
                        button_flow.add {
                            type = "sprite-button",
                            name = "teleportation_main_button",
                            style = gu_button_style_setting,
                            sprite = "teleportation_button",
                            tooltip = {'guiu.teleportation_button'},
                        }
                    end
                    global.player[player.index].checknexttick = global.player[player.index].checknexttick + 1
                end
                global.Teleportation_Redux_built = true
            end
        end
    end

    if script.active_mods["PersonalTeleporter"] then
        if not global.PersonalTeleporter_built then
            if event and event.created_entity and event.created_entity.name == "Teleporter_Beacon" then
                for _,player in pairs(game.players) do
                    local button_flow = mod_gui.get_button_flow(player)
                    local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
                    if not button_flow.personalTeleporter_PersonalTeleportTool then
                        button_flow.add {
                            type = "sprite-button",
                            name = "personalTeleporter_PersonalTeleportTool",
                            style = gu_button_style_setting,
                            sprite = "teleportation_button",
                            tooltip = {'guiu.teleportation_button'},
                        }
                    end
                    global.player[player.index].checknexttick = global.player[player.index].checknexttick + 1
                end
                global.PersonalTeleporter_built = true
            end
        end
    end
end

local function on_gui_closed(event)
    -- Skip if we're not properly initialized
    if not global then 
        logging.warning("State", "Skipping on_gui_closed - global not initialized", game.get_player(1))
        return 
    end
    
    local player = event.player_index and game.players[event.player_index]
    if not player or not player.valid then return end
    
    -- Ensure player state exists
    if not global.player[player.index] then
        setup_player(player)
    end
    
    -- Only process window states if gubuttonarray exists
    if global.gubuttonarray then
        for _, entry in pairs(global.gubuttonarray) do
            if entry and entry[7] then -- Has windowtocheck
                if update_window_state(player, entry[3], entry[7]) then
                    change_one_icon(player, entry[2], entry[3], entry[4], entry[5], entry[6], entry[7])
                end
            end
        end
    end
end

local function on_gui_opened(event)
    -- Skip if we're not properly initialized
    if not global then 
        logging.warning("State", "Skipping on_gui_opened - global not initialized", game.get_player(1))
        return 
    end
    
    local player = event.player_index and game.players[event.player_index]
    if not player or not player.valid then return end
    
    -- Ensure player state exists
    if not global.player[player.index] then
        setup_player(player)
    end
    
    -- Only process window states if gubuttonarray exists
    if global.gubuttonarray then
        for _, entry in pairs(global.gubuttonarray) do
            if entry and entry[7] then -- Has windowtocheck
                if update_window_state(player, entry[3], entry[7]) then
                    change_one_icon(player, entry[2], entry[3], entry[4], entry[5], entry[6], entry[7])
                end
            end
        end
    end
end

-- Main tick function. Now extra defensive to ensure no crashes
local function on_tick()
    -- Skip if we're not properly initialized
    if not global then return end
    
    for _, player in pairs(game.players) do
        if player and player.valid then
            local player_state = global.player[player.index]
            if not player_state then
                setup_player(player)
                player_state = global.player[player.index]
            end
            
            if player_state.checknexttick == 1 then
                -- Perform GUI updates
                cycle_buttons_to_rename(player)
                cycle_frames_to_rename(player)
                create_new_buttons(player)
                fix_buttons(player)
                destroy_obsolete_buttons(player)
                player_state.checknexttick = 0
            end
        end
    end
end

script.on_init(function()
    logging.info("Init", "Mod initialization started", game.get_player(1))
    
    -- Initialize global state
    ensure_global_state()
    
    -- Initialize button array
    init_button_array()
    
    -- Setup all existing players
    for _, player in pairs(game.players) do
        if player and player.valid then
            setup_player(player)
            force_update_player_buttons(player)
        end
    end
    
    logging.info("Init", "Mod initialization completed", game.get_player(1))
end)

script.on_configuration_changed(function()
    logging.info("Config", "Configuration change detected", game.get_player(1))
    
    -- Ensure global state
    ensure_global_state()
    
    -- Reinitialize button array
    init_button_array()
    
    -- Update all players
    for _, player in pairs(game.players) do
        if player and player.valid then
            setup_player(player)
            force_update_player_buttons(player)
        end
    end
    
    logging.info("Config", "Configuration change handling completed", game.get_player(1))
end)


script.on_event({defines.events.on_research_finished, defines.events.on_rocket_launched}, general_update)

script.on_nth_tick(6, function()
    local status, err = pcall(on_tick)
    if not status then
        logging.error("Tick", "Critical error in tick handler: " .. tostring(err), game.get_player(1))
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, on_player_configuration_changed)
script.on_event({defines.events.on_gui_closed, defines.events.on_gui_confirmed, defines.events.on_gui_opened, on_player_display_resolution_changed, defines.events.on_player_changed_surface, defines.events.on_player_created}, general_update_event)
script.on_event(defines.events.on_player_joined_game, on_player_joined)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event({defines.events.on_built_entity, defines.events.on_entity_cloned, defines.events.on_robot_built_entity}, on_built)
script.on_event({defines.events.on_player_gun_inventory_changed, defines.events.on_player_died}, on_hivemindchange)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)