require('scripts/debug')

local mod_gui = require("mod-gui")
local gui_button_style = "slot_button_notext"
local gui_button_style_whitetext = "slot_button_whitetext"
local activedebug = false

local iconlist = require('iconlist')

local iconlist_creativemod = {
	{"creative-mod",			"creativemod_button", 			"creative-mod_main-menu-open-button", 	nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "creative-mod_main-menu-container"}},
	{"creative-mod",			"creativemod_button",			"creative-mod_creative-chest-open-button",nil,								1,	{"creative-mod_entity-gui-button-container"},	{"left", "mod_gui_frame_flow", "creative-mod_entity-gui-container", "creative-mod_entity-gui-frame"}},
	{"creative-mod",			"creativemod_button",			"creative-mod_duplicating-chest-open-button",nil,							1,	{"creative-mod_entity-gui-button-container"},	{"left", "mod_gui_frame_flow", "creative-mod_entity-gui-container", "creative-mod_entity-gui-frame"}},
	{"creative-mod",			"creativemod_button",			"creative-mod_configurable-super-boiler-open-button",nil,					1,	{"creative-mod_entity-gui-button-container"},	{"left", "mod_gui_frame_flow", "creative-mod_entity-gui-container", "creative-mod_entity-gui-frame"}},
	{"creative-mod",			"creativemod_button",			"creative-mod_item-source-open-button",	nil,								1,	{"creative-mod_entity-gui-button-container"},	{"left", "mod_gui_frame_flow", "creative-mod_entity-gui-container", "creative-mod_entity-gui-frame-container"}},
	{"creative-mod",			"creativemod_button",			"creative-mod_duplicator-open-button",	nil,								1,	{"creative-mod_entity-gui-button-container"},	{"left", "mod_gui_frame_flow", "creative-mod_entity-gui-container", "creative-mod_entity-gui-frame-container"}},
	{"creative-mod",			"creativemod_button",			"creative-mod_item-void-open-button",	nil,								1,	{"creative-mod_entity-gui-button-container"},	{"left", "mod_gui_frame_flow", "creative-mod_entity-gui-container", "creative-mod_entity-gui-frame-container"}},
}

local iconlist_Picker = {
	{"PickerInventoryTools",	"pickerinventorytools_button", 	"filterfill_requests", 					nil,								nil,		nil,				nil},
	{"PickerInventoryTools",	"filterfill_requests_btn_bp",	"filterfill_requests_btn_bp",			nil,								1,	 {"filterfill_requests"},	nil},
	{"PickerInventoryTools",	"filterfill_requests_btn_2x",	"filterfill_requests_btn_2x",			nil,								1,	 {"filterfill_requests"},	nil},
	{"PickerInventoryTools",	"filterfill_requests_btn_5x",	"filterfill_requests_btn_5x",			nil,								1,	 {"filterfill_requests"},	nil},
	{"PickerInventoryTools",	"filterfill_requests_btn_10x",	"filterfill_requests_btn_10x",			nil,								1,	 {"filterfill_requests"},	nil},
	{"PickerInventoryTools",	"filterfill_requests_btn_max",	"filterfill_requests_btn_max",			nil,								1,	 {"filterfill_requests"},	nil},
	{"PickerInventoryTools",	"filterfill_requests_btn_0x",	"filterfill_requests_btn_0x",			nil,								1,	 {"filterfill_requests"},	nil},
	{"PickerInventoryTools",	"filterfill_filters_btn_all",	"filterfill_filters_btn_all",			nil,								1,	 {"filterfill_filters"},	nil},
	{"PickerInventoryTools",	"filterfill_filters_btn_down",	"filterfill_filters_btn_down",			nil,								1,	 {"filterfill_filters"},	nil},
	{"PickerInventoryTools",	"filterfill_filters_btn_right",	"filterfill_filters_btn_right",			nil,								1,	 {"filterfill_filters"},	nil},
	{"PickerInventoryTools",	"filterfill_filters_btn_set_all","filterfill_filters_btn_set_all",		nil,								1,	 {"filterfill_filters"},	nil},
	{"PickerInventoryTools",	"filterfill_filters_btn_clear_all","filterfill_filters_btn_clear_all",	nil,								1,	 {"filterfill_filters"},	nil},
}

local function build_button_array()

	global.gubuttonarray = {}

	for k, icon in pairs(iconlist) do
	    if game.active_mods[icon[1]] then
	        local alreadyexists = false
	        for _, addedalready in pairs(global.gubuttonarray) do
	            if addedalready[1] == icon[1] then
	                alreadyexists = true
	            end
	        end
	        if not alreadyexists then
	            table.insert(global.gubuttonarray, icon)
	        end
	    end
	end
	if global.gubuttonarray == {} then global.gubuttonarray = {{}} end
end

local function setup_player(player)
	if not player or not player.valid then return end
	if not global.player then global.player = {} end
	if not global.player[player.index] then
		global.player[player.index] = {
			checknexttick = 0
		}
	end
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

local function change_one_icon(player, sprite, button, tooltip, dontreplacesprite, buttonpath, windowtocheck)
	if not player or not player.valid or not sprite or not button then return end
	local settingname = "gu_button_" .. button
	local is_button_true = true
	if settings.get_player_settings(player)[settingname] then
		is_button_true = settings.get_player_settings(player)[settingname].value
	end
	--game.print(is_button_true)
	local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
	local isselected = true
	if windowtocheck then
		local windowtocheckpath = player.gui
		for i, k in pairs(windowtocheck) do
			if windowtocheckpath[k] and windowtocheckpath[k].visible then
				windowtocheckpath = windowtocheckpath[k]
			else
				isselected = false
			end
		end
		if isselected == true then
			gu_button_style_setting = gu_button_style_setting .. "_selected"
		end
	end
	local button_flow = mod_gui.get_button_flow(player)
	if buttonpath then
		for _, k in pairs(buttonpath) do
			if button_flow[k] then
				button_flow = button_flow[k]
			end
		end
	end
	local modbutton = button_flow[button]
	if modbutton and (modbutton.type == "button" or modbutton.type == "sprite-button") then

		modbutton.style = gu_button_style_setting
		if not dontreplacesprite then
			set_button_sprite(modbutton, sprite)
		end
		if tooltip then
			modbutton.tooltip = tooltip
		end
		if is_button_true == false then
			modbutton.visible = false
		else
			modbutton.visible = true
		end
	end
end

local function fix_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)

	if not global.gubuttonarray then build_button_array() end
	for _, k in pairs(global.gubuttonarray) do
		if k[1] == nil or game.active_mods[k[1]] then
			change_one_icon(player, k[2], k[3], k[4], k[5], k[6], k[7])
		end
	end

	if game.active_mods["creative-mod"] then
		for _, k in pairs(iconlist_creativemod) do
			change_one_icon(player, k[2], k[3], k[4], k[5], k[6], k[7])
		end
	end

	if game.active_mods["PickerInventoryTools"] then
		for _, k in pairs(iconlist_Picker) do
			change_one_icon(player, k[2], k[3], k[4], k[5], k[6], k[7])
		end
	end

	if game.active_mods["BlackMarket2"] then
		if button_flow.flw_blkmkt and button_flow.flw_blkmkt.but_blkmkt_credits then
			local blackmarketvalue = button_flow.flw_blkmkt.but_blkmkt_credits.caption
			if blackmarketvalue then
				button_flow.flw_blkmkt.but_blkmkt_credits.tooltip = "Credit: ".. blackmarketvalue
			end
		end
	end

	if game.active_mods["AttilaZoomMod"] then
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

	if game.active_mods["Todo-List"] then
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

	if game.active_mods["DeleteAdjacentChunk"] and button_flow.DeleteAdjacentChunk_table then
		local dac_buttons_list = {"DeleteAdjacentChunk_nw", "DeleteAdjacentChunk_n", "DeleteAdjacentChunk_ne", "DeleteAdjacentChunk_w", "DeleteAdjacentChunk_e", "DeleteAdjacentChunk_sw", "DeleteAdjacentChunk_s", "DeleteAdjacentChunk_se"}
		for _,k in pairs(dac_buttons_list) do
			if button_flow.DeleteAdjacentChunk_table[k] then
				button_flow.DeleteAdjacentChunk_table[k].style = "adjacentchunks_button"
				button_flow.DeleteAdjacentChunk_table[k].sprite = nil
			end
		end
	end

	if game.active_mods["Factorissimo2"] then
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

	local function create_buttons_from_list(mod, button, sprite, tooltip, optionon)
		if game.active_mods[mod] and optionon then
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
		{"automatic-belt-direction","abdgui",								"abd_on_button",				{'guiu.abd_on_button'},						abdshowgui},
		--{"warptorio2",		"warptorio_warpbutton",						"credotimelapse_button",		{'guiu.credotimelapse_button'}},
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

	if game.active_mods["clock"] then
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

	if game.active_mods["SpawnControl"] or game.active_mods["TimedSpawnControl"] then
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

	if game.active_mods["inserter-throughput"] then
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

	if game.active_mods["automatic-belt-direction"] and button_flow.abdgui and settings.get_player_settings(player)["abd-showgui"] and settings.get_player_settings(player)["abd-showgui"].value == false then
		button_flow.abdgui.destroy()
	end

	local topelems_tokill = {
		"blpflip_flow", "fjei_toggle_button", "Homeworld_btn", "lawful_evil_button", "trashbingui", "pywiki_frame", "usage_detector", "104",
		"spawn", "random", "what_is_missing", "logistics-view-button", "flw_zoom", "stats_show_settings", "teleportation_main_button",
		"personalTeleporter_PersonalTeleportTool", "inserter-throughput-toggle", "b_recexplo", "CTLM_mainbutton", "market_button", "rd_container", "abdgui", "clockGUI",
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

	if game.active_mods["production-monitor"] then
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

	if game.active_mods["YARM"] then
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

	if game.active_mods["Spiderissmo"] then
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
			player.gui.top.mod_gui_top_frame.style = "quick_bar_window_frame"
			player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "mod_gui_inside_deep_frame"
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
			if game.active_mods["factoryplanner"] and k.tags and k.tags.mod and k.tags.mod == "fp" and not player.gui.screen.factoryplanner_mainframe then
				k.name = "factoryplanner_mainframe"
			elseif game.active_mods["train-log"] and k.tags and k.tags["train-log"] and not player.gui.screen.trainlog_mainframe then
				k.name = "trainlog_mainframe"
			elseif game.active_mods["ModuleInserter"] and k.tags and k.tags.ModuleInserter and not player.gui.screen.moduleinserter_mainframe then
				k.name = "moduleinserter_mainframe"
			elseif game.active_mods["Rich_Text_Helper"] and k.name and k.name == "RICH_LOCATION_23_player01" and not player.gui.screen.richtexthelper_mainframe then
				k.name = "richtexthelper_mainframe"
			elseif game.active_mods["Not_Enough_Todo"] and k.children and k.children[1] and k.children[1].children and k.children[1].children[1] and k.children[1].children[1].children and k.children[1].children[1].children[1] and k.children[1].children[1].children[1].caption and k.children[1].children[1].children[1].caption[1] and k.children[1].children[1].children[1].caption[1] == "Todo.GuiTitle" and not player.gui.screen.notenoughtodo_mainframe then
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

		if game.active_mods["blueprint-request"] then
			local blueprintrequest_button = button_flow["blueprint-request-button"]
			if blueprintrequest_button then
				blueprintrequest_button.style = gu_button_style_setting
				set_button_sprite(blueprintrequest_button, "blueprintrequest_button")
			end
		end

		if game.active_mods["LandfillEverythingU"] or game.active_mods["LandfillEverything"] or game.active_mods["LandfillEverythingButTrains"] or game.active_mods["LandfillEverythingAndPumps"] then
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

		if game.active_mods["blueprint_flip_and_turn"] then
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

	if game.active_mods["SchallOreConversion"] then
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
	for _,player in pairs(game.players) do
		if player and player.valid then
			if not global.player or not global.player[player.index] then setup_player(player) end
			global.player[player.index].checknexttick = global.player[player.index].checknexttick + 1
		end
	end
end

local function general_update_event(event)
	local player = event.player_index and game.players[event.player_index]
	if not player or not player.valid then return end
	if not global.player or not global.player[event.player_index] then setup_player(player) end
	global.player[event.player_index].checknexttick = global.player[event.player_index].checknexttick + 1
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

local function on_player_joined(event)
	local player = event.player_index and game.players[event.player_index]
	local button_flow = mod_gui.get_button_flow(player)
	general_update_event(event)

		--destroy evoGUI to let it recreate and display on the right of main gui.
	if game.active_mods["EvoGUI"] then
		if player.gui.top.evogui_root then
			player.gui.top.evogui_root.destroy()
		end
	end
end

local function on_gui_click(event)
	local player = event.player_index and game.players[event.player_index]
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)
	if game.active_mods["YARM"] then update_yarm_button(event) end

	global.player[player.index].checknexttick = global.player[player.index].checknexttick + 1

	if game.active_mods["clock"] and button_flow.clockGUI then
		if player.gui.left.mod_gui_frame_flow and player.gui.left.mod_gui_frame_flow.clock_gui and player.gui.left.mod_gui_frame_flow.clock_gui.visible then
			button_flow.clockGUI.style = "todo_button_default_snouz_selected"
		else
			button_flow.clockGUI.style = "todo_button_default_snouz"
		end
	end

	local buttname = ""
	if event.element and event.element.name then
		buttname = event.element.name
	else
		return
	end

		--force closed if button clicked
	if game.active_mods["pycoalprocessing"] then
		if buttname == "pywiki" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
			player.gui.screen.wiki_frame.destroy()
		end
	end
	if game.active_mods["SolarRatio"] then
		if buttname == "niet-sr-guibutton" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
			player.gui.center["niet-sr-guiframe"].destroy()
		end
	end
	if game.active_mods["CitiesOfEarth"] then
		if buttname == "coe_button_show_targets" and event.element.style and event.element.style.name and event.element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
			player.gui.center["coe_choose_target"].destroy()
		end
	end

	if game.active_mods["automatic-belt-direction"] then
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

	--[[if buttname == "gu_ltnm-toggle-gui" then
		--game.print("11111111")
		if game.shortcut_prototypes["ltnm-toggle-gui"] then
			--game.print(game.shortcut_prototypes["ltnm-toggle-gui"])
			player.set_shortcut_toggled("ltnm-toggle-gui", not player.is_shortcut_toggled("ltnm-toggle-gui"))
		end
	end]]

	if activedebug or player == game.players["snouz"] then debug_button(event) end
end

local function on_hivemindchange(event)
	if game.active_mods["Hive_Mind"] or game.active_mods["Hive_Mind_Remastered"] then
		if not event.player_index then return end
		if not global.player or not global.player[event.player_index] then setup_player(game.players[event.player_index]) end
		global.player[event.player_index].checknexttick = global.player[event.player_index].checknexttick + 1
	end
end

local function on_built(event)
	if game.active_mods["Teleportation_Redux"] then
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

	if game.active_mods["PersonalTeleporter"] then
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

local function on_tick()
	for _,player in pairs(game.players) do
		if not player or not player.valid then return end

		if not global.player then
			setup_player(player)
		end

		if global.player[player.index].checknexttick > 1 then
			global.player[player.index].checknexttick = global.player[player.index].checknexttick - 1
		elseif global.player[player.index].checknexttick == 1 then
			cycle_buttons_to_rename(player)
			cycle_frames_to_rename(player)
			create_new_buttons(player)
			fix_buttons(player)
			destroy_obsolete_buttons(player)
			global.player[player.index].checknexttick = 0
		end

		if game.active_mods["clock"] then
			local button_flow = mod_gui.get_button_flow(player)
			if player.gui.top.clockGUI and button_flow.clockGUI then
				button_flow.clockGUI.caption = player.gui.top.clockGUI.caption
			end
		end

		if game.active_mods["Avatars"] then
			local button_flow = mod_gui.get_button_flow(player)
			if button_flow.avatar_disc and not button_flow.avatar_disc["button_sprite"] then
				fix_buttons(player)
			end
		end

		if game.active_mods["creative-mod"] then
			local button_flow = mod_gui.get_button_flow(player)
			if button_flow["creative-mod_main-menu-open-button"] and not button_flow["creative-mod_main-menu-open-button"]["button_sprite"] then
				fix_buttons(player)
			end
		end
	end
end

script.on_init(general_update)
script.on_event({defines.events.on_research_finished, defines.events.on_rocket_launched}, general_update)
script.on_nth_tick(6, on_tick)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_player_configuration_changed)
script.on_event({defines.events.on_gui_closed, defines.events.on_gui_confirmed, defines.events.on_gui_opened, on_player_display_resolution_changed, defines.events.on_player_changed_surface, defines.events.on_player_created}, general_update_event)
script.on_event(defines.events.on_player_joined_game, on_player_joined)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event({defines.events.on_built_entity, defines.events.on_entity_cloned, defines.events.on_robot_built_entity}, on_built)
script.on_event({defines.events.on_player_gun_inventory_changed, defines.events.on_player_died}, on_hivemindchange)

--game.print(serpent.block())
