local debug = require('scripts/debug')
local mod_gui = require("mod-gui")
local icons = require('icons')  -- Load icons during initial parse
local logging = require('scripts/logging')
local gui_properties = require('scripts/gui-properties')

local topelems_tokill = {
    "blpflip_flow", "fjei_toggle_button", "Homeworld_btn", "lawful_evil_button", "trashbingui", "pywiki_frame", "usage_detector", "104",
    "spawn", "random", "what_is_missing", "logistics-view-button", "flw_zoom", "stats_show_settings", "teleportation_main_button",
    "personalTeleporter_PersonalTeleportTool", "inserter-throughput-toggle", "b_recexplo", "CTLM_mainbutton", "market_button", "rd_container", "abdgui", "clockGUI", "visual_signals",
}

-- Bind the legacy field names to Factorio 2.0 storage after it is restored.
local global
local activedebug = false

local function setup_player(player)
    if not player or not player.valid then 
        logging.warning("Player", "Attempted to setup invalid player", game.get_player(1))
        return 
    end
    
    logging.debug("Player", "Setting up player: " .. player.name, player)
    if not global.player then global.player = {} end
    if not global.player[player.index] then
        global.player[player.index] = {}
        logging.info("Player", "Initialized new player state for: " .. player.name, player)
    end
end

-- Lifecycle initialization, not a scan on every construction event.
local function ensure_global_state()
    global = storage
    global.player = global.player or {}
    global.gubuttonarray = global.gubuttonarray or {}
    global.window_states = global.window_states or {}
    global.pending_players = global.pending_players or {}
end

local function queue_player(player)
    if not player or not player.valid or not player.connected then return end
    if not global.player[player.index] then setup_player(player) end
    -- Coalesce any number of events before the next update.
    global.pending_players[player.index] = true
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
				gui_properties.set(button["button_sprite"], "sprite", spritepath)
			end
		end
	end

	if button.type == "sprite-button" then
		gui_properties.set(button, "sprite", spritepath)
		gui_properties.set(button, "hovered_sprite", spritepath)
		gui_properties.set(button, "clicked_sprite", spritepath)
	end
end

local function update_window_state(player, button, windowtocheck)
    if not player or not player.valid or not windowtocheck then return false end
    
    local window_key = player.index .. "_" .. button
    local windowtocheckpath = player.gui
    local is_visible = true
    
    for _, k in ipairs(windowtocheck) do
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
    if global.window_states[window_key] ~= is_visible then
        global.window_states[window_key] = is_visible
        return true -- State changed
    end
    return false
end

local function apply_button(button, style, sprite, tooltip, dontreplacesprite, visible)
    gui_properties.style(button, style)
    if not dontreplacesprite then set_button_sprite(button, sprite) end
    if tooltip then gui_properties.set(button, "tooltip", tooltip) end
    gui_properties.set(button, "visible", visible)
end

local function change_one_icon(player, sprite, button, tooltip, dontreplacesprite, buttonpath, windowtocheck, player_settings, button_flow)
    if not player or not player.valid or not sprite or not button then return end
    player_settings = player_settings or settings.get_player_settings(player)
    button_flow = button_flow or mod_gui.get_button_flow(player)
    local button_setting = player_settings["gu_button_" .. button]
    local visible = not button_setting or button_setting.value
    local style_setting = player_settings["gu_button_style_setting"]
    if not style_setting then return end
    local style = style_setting.value or "slot_button_notext"
    if windowtocheck then
        update_window_state(player, button, windowtocheck)
        if global.window_states[player.index .. "_" .. button] then
            style = style .. "_selected"
        end
    end

    local function apply(element)
        if not element or not element.valid or
            (element.type ~= "button" and element.type ~= "sprite-button") then return end
        -- An incompatible third-party button must not stop the rest of the panel.
        local ok, err = pcall(apply_button, element, style, sprite, tooltip, dontreplacesprite, visible)
        if not ok then
            logging.error("Icons", "Button " .. button .. ": " .. tostring(err), player)
        elseif logging.debug_enabled(player) then
            logging.debug("Icons", "Updated button " .. button, player)
        end
    end

    apply(player.gui.top[button])
    if buttonpath then
        for _, key in ipairs(buttonpath) do
            button_flow = button_flow and button_flow[key]
            if not button_flow then return end
        end
    end
    if button_flow then apply(button_flow[button]) end
end

local function fix_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)
	local player_settings = settings.get_player_settings(player)

	for _, k in ipairs(global.gubuttonarray) do
		change_one_icon(player, k[2], k[3], k[4], k[5], k[6], k[7], player_settings, button_flow)
	end

	if script.active_mods["BlackMarket2"] then
		if button_flow.flw_blkmkt and button_flow.flw_blkmkt.but_blkmkt_credits then
			local blackmarketvalue = button_flow.flw_blkmkt.but_blkmkt_credits.caption
			if blackmarketvalue then
				gui_properties.set(button_flow.flw_blkmkt.but_blkmkt_credits, "tooltip", "Credit: " .. blackmarketvalue)
			end
		end
	end

	if script.active_mods["AttilaZoomMod"] then
		local style = player_settings["gu_button_style_setting"].value
		local attila_style = style == "slot_sized_button_notext" and "slot_sized_button_blacktext" or "slot_button_whitetext"
		for i=1,15 do
			local button = button_flow["Attila_zm_btn_" .. i]
			if button then
				gui_properties.style(button, attila_style)
				gui_properties.set(button, "tooltip", {'guiu.attilazoommod_button'})
				set_button_sprite(button, "attilazoommod_button")
			end
		end
	end

	if script.active_mods["Todo-List"] then
		local button = button_flow.todo_maximize_button
		local style = player_settings["gu_button_style_setting"].value or "slot_button_notext"
		if button then
			local mode = player_settings["gu_todolist_style_setting"].value
			if mode == "icon" then
				set_button_sprite(button, "todolist_button")
			elseif mode == "longtext" then
				set_button_sprite(button)
				style = "todo_button_default_snouz"
			end
			if button.caption then gui_properties.set(button, "tooltip", button.caption) end
			if player.gui.screen.todo_main_frame and player.gui.screen.todo_main_frame.visible then
				style = style .. "_selected"
			end
			gui_properties.style(button, style)
		end
	end

	if script.active_mods["DeleteAdjacentChunk"] and button_flow.DeleteAdjacentChunk_table then
		local dac_buttons_list = {"DeleteAdjacentChunk_nw", "DeleteAdjacentChunk_n", "DeleteAdjacentChunk_ne", "DeleteAdjacentChunk_w", "DeleteAdjacentChunk_e", "DeleteAdjacentChunk_sw", "DeleteAdjacentChunk_s", "DeleteAdjacentChunk_se"}
		for _,k in pairs(dac_buttons_list) do
			if button_flow.DeleteAdjacentChunk_table[k] then
				gui_properties.style(button_flow.DeleteAdjacentChunk_table[k], "adjacentchunks_button")
				gui_properties.set(button_flow.DeleteAdjacentChunk_table[k], "sprite", nil)
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

-- Static definitions are allocated once, not on every player update.
	local newbuttonlist = {
		--mod					button name 								sprite 							tooltip 									show button (for some there's already a setting to toggle button)
		{"FJEI",				"fjei_toggle_button",						"fjei_button",					{'guiu.fjei_button'},						true},
		{"homeworld_redux",		"Homeworld_btn",							"homeworld_redux_button",		{'guiu.homeworld_redux_button'},			true},
		{"m-lawful-evil",		"lawful_evil_button",						"mlawfulevil_button",			{'guiu.mlawfulevil_button'},				true},
		{"Trashcan",			"trashbinguibutton",						"trashcan_button",				{'guiu.trashcan_button'},					true},
		{"pycoalprocessing",	"pywiki",									"pycoalprocessing_button",		{'guiu.pycoalprocessing_button'},			true},
		{"usage-detector",		"usage_detector",							"usagedetector_button",			{'guiu.usagedetector_button'},				true},
		{"RPG",					"104",										"rpg_button",					{'guiu.rpg_button'},						true},
		{"TimedSpawnControl",	"unstuck",								"spawncontrol_random_button",	{'guiu.spawncontrol_unstuck'},			true},
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
		{"automatic-belt-direction","abdgui",								"abd_on_button",				{'guiu.abd_on_button'},						"abd-showgui"}
	}

local function create_new_buttons(player)
    local button_flow = mod_gui.get_button_flow(player)
    local player_settings = settings.get_player_settings(player)
    local gu_button_style_setting = player_settings["gu_button_style_setting"].value or "slot_button_notext"

    if script.active_mods["visual-signals"] then
        if player.gui.top["visual_signals"] then
            player.gui.top["visual_signals"].destroy()
        end
        if not button_flow["visual_signals"] then
            button_flow.add {
                type = "sprite-button", name = "visual_signals",
                style = gu_button_style_setting, sprite = "visualsignals_button",
                tooltip = {'guiu.visual_signals_button'}
            }
        end
    end

    local function create_buttons_from_list(mod, button, sprite, tooltip, optionon)
        if script.active_mods[mod] and optionon then
            if not button_flow[button] then
                button_flow.add {
                    type = "sprite-button", name = button, sprite = sprite,
                    style = gu_button_style_setting, tooltip = tooltip,
                }
                if button == "YARM_filter_none" or button == "YARM_filter_warnings" then
                    button_flow[button].visible = false
                end
            end
        elseif button_flow[button] then
            button_flow[button].destroy()
        end
    end

    for _, k in ipairs(newbuttonlist) do
        local enabled = k[5]
        if type(enabled) == "string" then
            local setting = player_settings[enabled]
            enabled = setting and setting.value or false
        end
        create_buttons_from_list(k[1], k[2], k[3], k[4], enabled)
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
		local button = button_flow["inserter-throughput-toggle"]
		local setting = player_settings["inserter-throughput-enabled"]
		if button and setting then
			local sprite = setting.value and "inserterthroughput_on_button" or "inserterthroughput_off_button"
			gui_properties.set(button, "sprite", sprite)
			gui_properties.set(button, "tooltip", {"guiu." .. sprite})
		end
	end
end


local function update_yarm_button(event)
	if event and event.element and event.element.valid then
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
    for _, player in pairs(game.connected_players) do
        queue_player(player)
    end
end

local function general_update_event(event)
    local player = event.player_index and game.get_player(event.player_index)
    queue_player(player)
end

local function on_player_configuration_changed(event)
    logging.invalidate(event.player_index)
    if not event.player_index then
        general_update()
        return
    end
    general_update_event(event)
    if event.setting == "gu_frame_style_setting" and global.player[event.player_index] then
        global.player[event.player_index].update_frame = true
    end
end

local function update_player_buttons(player)
    cycle_buttons_to_rename(player)
    cycle_frames_to_rename(player)
    create_new_buttons(player)
    fix_buttons(player)
    destroy_obsolete_buttons(player)
    if global.player[player.index].update_frame then
        update_frame_style({player_index = player.index})
        global.player[player.index].update_frame = nil
    end
end

local function on_player_joined(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    logging.invalidate(player.index)
    queue_player(player)
    if global.player[player.index] then
        global.player[player.index].update_frame = true
    end

    -- Preserve the existing EvoGUI integration.
    if script.active_mods["EvoGUI"] and player.gui.top.evogui_root then
        player.gui.top.evogui_root.destroy()
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

    queue_player(player)

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
    if event.element and event.element.valid then
        buttname = event.element.name
    else
        return
    end

        --force closed if button clicked
    if script.active_mods["pycoalprocessing"] then
        if buttname == "pywiki" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
            if player.gui.screen.wiki_frame then player.gui.screen.wiki_frame.destroy() end
        end
    end
    if script.active_mods["SolarRatio"] then
        if buttname == "niet-sr-guibutton" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
            if player.gui.center["niet-sr-guiframe"] then player.gui.center["niet-sr-guiframe"].destroy() end
        end
    end
    if script.active_mods["CitiesOfEarth"] then
        if buttname == "coe_button_show_targets" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
            if player.gui.center["coe_choose_target"] then player.gui.center["coe_choose_target"].destroy() end
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

local function on_built(event)
    local entity = event.entity or event.destination
    if not entity or not entity.valid then return end
    local name = entity.name
    if name == "gui-signal-display" and script.active_mods["visual-signals"] then
        general_update()
    elseif name == "teleportation-beacon" and script.active_mods["Teleportation_Redux"] then
        if not global.Teleportation_Redux_built then
            global.Teleportation_Redux_built = true
            general_update()
        end
    elseif name == "Teleporter_Beacon" and script.active_mods["PersonalTeleporter"] then
        if not global.PersonalTeleporter_built then
            global.PersonalTeleporter_built = true
            general_update()
        end
    end
end

local function on_tick()
    -- No player/GUI traversal while idle. Only players dirtied by events are visited.
    local pending = global.pending_players
    if not next(pending) then return end
    -- Detach the batch: events raised during a GUI update belong to the next one.
    -- A failed update is consumed, not retried ten times per second.
    global.pending_players = {}
    for player_index in pairs(pending) do
        local player = game.get_player(player_index)
        if player and player.valid and player.connected then
            local ok, err = pcall(update_player_buttons, player)
            if not ok then
                logging.error("Tick", "Error updating " .. player.name .. ": " .. tostring(err), player)
            end
        end
    end
end

local function initialize()
    ensure_global_state()
    logging.invalidate()
    init_button_array()
    -- Migrate the broken counter without deleting saved flags or existing GUI.
    for _, state in pairs(global.player) do
        state.checknexttick = nil
        state.update_frame = true
    end
    for _, player in pairs(game.connected_players) do
        queue_player(player)
        global.player[player.index].update_frame = true
    end
end

script.on_init(initialize)
script.on_configuration_changed(initialize)
script.on_load(function()
    -- Only restore a local reference; storage must not be mutated in on_load.
    global = storage
end)

script.on_nth_tick(6, on_tick)
script.on_event({defines.events.on_research_finished, defines.events.on_rocket_launched}, general_update)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_player_configuration_changed)
-- Defer until all mods have handled the event; register each event exactly once.
script.on_event({defines.events.on_gui_closed, defines.events.on_gui_confirmed,
    defines.events.on_gui_opened, defines.events.on_player_display_resolution_changed,
    defines.events.on_player_display_scale_changed, defines.events.on_player_changed_surface,
    defines.events.on_player_created}, general_update_event)
script.on_event(defines.events.on_player_joined_game, on_player_joined)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_player_removed, function(event)
    global.player[event.player_index] = nil
    global.pending_players[event.player_index] = nil
    logging.invalidate(event.player_index)
    local prefix = event.player_index .. "_"
    for key in pairs(global.window_states) do
        if key:sub(1, #prefix) == prefix then global.window_states[key] = nil end
    end
end)
if script.active_mods["Hive_Mind"] or script.active_mods["Hive_Mind_Remastered"] then
    script.on_event({defines.events.on_player_gun_inventory_changed, defines.events.on_player_died}, general_update_event)
end

-- Register only the integrations that need construction notifications.
local build_filters = {}
if script.active_mods["visual-signals"] then
    build_filters[#build_filters + 1] = {filter = "name", name = "gui-signal-display"}
end
if script.active_mods["Teleportation_Redux"] then
    build_filters[#build_filters + 1] = {filter = "name", name = "teleportation-beacon"}
end
if script.active_mods["PersonalTeleporter"] then
    build_filters[#build_filters + 1] = {filter = "name", name = "Teleporter_Beacon"}
end
if #build_filters > 0 then
    script.on_event(defines.events.on_built_entity, on_built, build_filters)
    script.on_event(defines.events.on_robot_built_entity, on_built, build_filters)
    script.on_event(defines.events.on_entity_cloned, on_built, build_filters)
end
