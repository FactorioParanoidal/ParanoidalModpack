local mod_gui = require("mod-gui")
local gui_button_style = "slot_button_notext"
local gui_button_style_whitetext = "slot_button_whitetext"
local checknexttick = false

local function set_button_sprite(button, spritepath)
	if spritepath == nil then
		spritepath = ""
	end

	if button.type == "button" then
		-- normal button, we need to add a sprite as child
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
		-- sprite button, no special handling
		button.sprite = spritepath
		button.hovered_sprite = spritepath
		button.clicked_sprite = spritepath
	end
end

local function change_one_icon(player, sprite, button, tooltip, dontreplacesprite, buttonpath)
	if player and player.valid and sprite and button then
		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
		local button_flow = mod_gui.get_button_flow(player)
		if buttonpath then
			for _, k in pairs(buttonpath) do
				if button_flow[k] then
					button_flow = button_flow[k]
				end
			end
		end
		local modbutton = button_flow[button]
		if modbutton and modbutton.type == "button" or modbutton and modbutton.type == "sprite-button" then
			modbutton.style = gu_button_style_setting
			if not dontreplacesprite then
				set_button_sprite(modbutton, sprite)
			end
			if tooltip then
				modbutton.tooltip = tooltip
			end
		end
	end
end

local function fix_buttons(player)
	if not player or not player.valid then return end


	local button_flow = mod_gui.get_button_flow(player)
	local blackmarketvalue = button_flow.flw_blkmkt and button_flow.flw_blkmkt.but_blkmkt_credits and button_flow.flw_blkmkt.but_blkmkt_credits.caption or ""
	local iconlist = {
		--sprite 						button									tooltip 					dontreplacesprite	buttonpath
		{"helmod_button", 				"helmod_planner-command", 				{'guiu.helmod_button'}, 			nil,		nil},
		{"factoryplanner_button", 		"fp_button_toggle_interface", 			{'guiu.factoryplanner_button'}, 	nil,		nil},
		{"moduleinserter_button", 		"module_inserter_config_button", 		{'guiu.moduleinserter_button'}, 	nil,		nil},
		{"placeables_button", 			"buttonPlaceablesVisible", 				nil,								nil,		nil},
		{"todolist_button", 			"todo_maximize_button", 				{'guiu.todolist_button'}, 			nil,		nil},
		{"creativemod_button", 			"creative-mod_main-menu-open-button", 	nil,								nil,		nil},
		{"beastfinder_button", 			"beastfinder-menu-button", 				{'guiu.beastfinder_button'}, 		nil,		nil},
		{"bobclasses_button", 			"bob_avatar_toggle_gui", 				nil,								nil,		nil},
		{"bobinserters_button", 		"bob_logistics_inserter_button", 		nil,								nil,		nil},
		{"cleanmap_button", 			"CleanMap", 							nil,								nil,		nil},
		{"cleanmap_button", 			"DeleteEmptyChunks", 					nil,								nil,		nil},
		{"deathcounter_button", 		"DeathCounterMainButton", 				{'guiu.deathcounter_button'}, 		nil,		nil},
		{"ingteb_button", 				"ingteb", 								nil,								nil,		nil},
		{"outpostplanner_button", 		"OutpostBuilder", 						nil,								nil,		nil},
		{"rocketsilostats_button", 		"rocket-silo-stats-toggle", 			{'guiu.rocketsilostats_button'}, 	nil,		nil},
		{"schall_sc_button", 			"Schall-SC-mod-button", 				nil,								nil,		nil},
		{"actr_button", 				"ACTR_mod_button", 						nil,								nil,		nil},
		{"betterbotsfixed_button", 		"betterbots_top_btn", 					{'guiu.betterbotsfixed_button'}, 	nil,		nil},
		{"changemapsettings_button", 	"change-map-settings-toggle-config", 	{'guiu.changemapsettings_button'}, 	nil,		nil},
		{"doingthingsbyhand_button", 	"DoingThingsByHandMainButton", 			{'guiu.doingthingsbyhand_button'},	nil,		nil},
		{"facautoscreenshot_button", 	"togglegui", 							{'guiu.facautoscreenshot_button'}, 	1,			nil},
		{"killlostbots_button", 		"KillLostBots", 						nil,								nil,		nil},
		{"kttrrc_button", 				"ttrrc_main_frame_button", 				{'guiu.kttrrc_button'}, 			nil,		nil},
		{"kuxcraftingtools_button", 	"CraftNearbyGhostItemsButton", 			nil,								nil,		nil},
		{"kuxorbitalioncannon_button", 	"ion-cannon-button", 					{'guiu.kuxorbitalioncannon_button'},nil,		nil},
		{"markers_button", 				"markers_gui_toggle", 					{'guiu.markers_button'}, 			nil,		nil},
		{"notenoughtodo_button", 		"TODO_CLICK01_", 						{'guiu.notenoughtodo_button'}, 		nil,		nil},
		{"oshahotswap_button", 			"hotswap-menu-button", 					{'guiu.oshahotswap_button'}, 		nil,		nil},
		{"pickerinventorytools_button", "filterfill_requests", 					nil,								nil,		nil},
		{"poweredentities_button", 		"poweredEntitiesRecalculateButton", 	{'guiu.poweredentities_button'}, 	nil,		nil},
		{"researchcounter_button", 		"research-counter-button", 				{'guiu.researchcounter_button'}, 	nil,		nil},
		{"richtexthelper_button", 		"RICH_CLICK_20_player01", 				{'guiu.richtexthelper_button'}, 	nil,		nil},
		{"ritnteleportation_button", 	"ritn-button-main", 					{'guiu.ritnteleportation_button'},	nil,		nil},
		{"solarcalc_button", 			"kaktusbot-sc-open-calc-button", 		{'guiu.solarcalc_button'}, 			nil,		nil},
		{"solarcalc_button", 			"niet-sr-guibutton", 					nil,								nil,		nil},
		{"spacemod_button", 			"space_toggle_button", 					{'guiu.spacemod_button'}, 			nil,		nil},
		{"trainlog_button", 			"train_log", 							nil,								nil,		nil},
		{"trainpubsub_button", 			"tm_sprite_button", 					nil,								nil,		nil},
		{"upgradeplannernext_button", 	"upgrade_planner_config_button", 		nil,								nil,		nil},
		{"whatsmissing_button", 		"whats-missing-button", 				nil,								nil,		nil},
		{"picksrocketstats_button", 	"pi_rss_but_toggle", 					{'guiu.picksrocketstats_button'}, 	nil,		nil},
		{"schall_rc_button", 			"Schall-RC-mod-button", 				{'guiu.schall_rc_button'}, 			nil,		nil},
		{"blackmarket1_button", 		"but_blkmkt_main", 						{'guiu.blackmarket1_button'},		nil,		{"flw_blkmkt"}},
		{"blackmarket2_button", 		"but_blkmkt_credits", 					"Credit: ".. blackmarketvalue,		nil,		{"flw_blkmkt"}},
		{"autotrash_button",			"at_config_button",						nil,								1,			nil},
		{"togglepeacefulmode_button",	"tpm-button",							{'guiu.togglepeacefulmode_button'},	1,			nil},
		{"wiiuf_button",				"looking-glass",						{'guiu.wiiuf_button'}, 				nil, 		{"wiiuf_flow", "search_flow"}},
		{"thefatcontroller_button",		"toggleTrainInfo",						{'guiu.thefatcontroller_button'}, 	nil, 		{"fatControllerButtons"}},
		{"quickbarimportexport_button", "qbie_button_show_options", 			nil,								nil,		{"qbie_flow_choose_action"}},
		{"quickbarimport_button", 		"qbie_button_import", 					nil,								nil,		{"qbie_flow_choose_action"}},
		{"quickbarexport_button", 		"qbie_button_export", 					nil,								nil,		{"qbie_flow_choose_action"}},
		{"informatron_button", 			"informatron_overhead",					nil,								1,			nil},
		{"se_interstellar_button", 		"se-overhead_interstellar",				nil,								1,			nil},
		{"se_satellite_button", 		"se-overhead_satellite",				nil,								1,			nil},
		{"se_explorer_button", 			"se-overhead_explorer",					nil,								1,			nil},
		{"commuguidemod_guide_button", 	"main_menu_guide_button",				{'guiu.commuguidemod_guide_button'},nil,		nil},
		{"commuguidemod_pupil_button", 	"main_menu_player_button",				{'guiu.commuguidemod_pupil_button'},nil,		nil},
		{"fjei_toggle_button", 			"fjei_toggle_button",					nil,								1,			nil},
		{"togglespeedboost_button", 	"togglespeedboost_button",				nil,								1,			nil},
		{"248k_button", 				"top248kbutton",						{'guiu.248k_button'},				nil,		nil},
		{"blueprintalignment_button", 	"BlueprintAlignment_Button",			nil,								nil,		nil},
		{"cargotrainmanager_button", 	"ctm_toolbutton",						nil,								nil,		nil},
		{"clusterio_button", 			"clusterio-main-config-gui-toggle-button",{'guiu.clusterio_button'},		nil,		nil},
		{"cursedexp_button", 			"openMain",								{'guiu.cursedexp_button'},			nil,		{"openMainFlow"}},
		{"defaultwaitconditions_button","default-wait-conditions-main-button",	nil,								nil,		nil},
		{"diplomacy_button", 			"diplomacy_button",						nil,								nil,		nil},
		{"electronic_locomotives_button","ELECTRONIC_CLICK01",					{'guiu.electronic_locomotives_button'},nil,		nil},
		{"forces_button", 				"forcesMenu",							nil,								nil,		nil},
		{"hive_mind_button1", 			"join-hive-button",						nil,								nil,		nil},
		{"hive_mind_button2", 			"leave-hive-button",					nil,								nil,		nil},
		{"howfardiditgo_button", 		"train_distance_button",				{'guiu.howfardiditgo_button'},		nil,		nil},
		{"kuxblueprinteditor_button", 	"mod-blueprint-editor-toolbar-button",	nil,								nil,		nil},
		{"kuxcraftingtools_button", 	"PlayerGhostCraft",						nil,								nil,		nil},
		{"logisticmachines_button", 	"lm_default_circuit_button",			{'guiu.logisticmachines_button'},	nil,		nil},
		{"logisticrequestmanager_button","logistic-request-manager-gui-button",	{'guiu.logisticrequestmanager_button'},	nil,		nil},
		{"regioncloner_button", 		"region-cloner_main-button",			nil,								nil,		nil},
		{"resetevolutionpollution_button","ResetEvolutionPollution",			nil,								nil,		nil},
		--{"schalloreconversion_button", 	"Schall-OC-mod-button",					nil,								nil,		nil},
		{"shuttle_train_continued_button","shuttle_lite_button",				nil,								nil,		nil},
		{"simple_circuit_trains_button","SIMPLE_CLICK_01",						{'guiu.simple_circuit_trains_button'},nil,		nil},
		{"teamcoop_button1", 			"spwn_ctrls",							{'guiu.teamcoop_button1'},			nil,		nil},
		{"teamcoop_button2", 			"spwn_admin_ctrls",						{'guiu.teamcoop_button2'},			nil,		nil},
		{"smartchest_button", 			"sc_button",							nil,								1,			nil},

		--{"trainschedulesignals_button", "TSS=open-close",						nil,								nil,		nil}, 		??
		--{"attachnotes_button", 			"attach-note-button",					nil,								1,			nil} 	-- too complex
		--{"avatars_button", ""},																												??
		--{"modmashsplinterboom_button", "landmine-toggle-button"},																				??
		--{"modmashsplinternewworlds_button", "planets-toggle-button"},																			??
		--{"dana_button", 				"dana-shortcut",				nil, nil,		nil}, 												-- can't button name!
		--{"deleteadjacentchunk_button", ""},																								-- too complex
		--{"schallendgameevolution_button", "Schall-EE-mod-button"},																		--to do
		--{"nullius_button", ""},										--to do
	}

	for _, k in pairs(iconlist) do
		change_one_icon(player, k[1], k[2], k[3], k[4], k[5])
	end

	-- AttilaZoomMod
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
end

local function create_new_buttons(player)
	if not player or not player.valid then return end
	if game.active_mods["FJEI"] then
		local button_flow = mod_gui.get_button_flow(player)
		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
		if not button_flow.fjei_toggle_button then
			button_flow.add {
				type = "sprite-button",
				name = "fjei_toggle_button",
				sprite = "fjei_button",
				style = gu_button_style_setting,
				tooltip = {'guiu.fjei_button'}
			}
		end
	end
end

--Factorissimo2
local function update_factorissimo(event)
	if event then
		local player = game.players[event.player_index]
		if not player or not player.valid then return end
		local button_flow = mod_gui.get_button_flow(player)
		if player.force.technologies["factory-preview"] and player.force.technologies["factory-preview"].researched and event.element and event.element.valid and event.element.name == "factory_camera_toggle_button" and button_flow.factory_camera_toggle_button then
			local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
			button_flow.factory_camera_toggle_button.style = gu_button_style_setting
			if button_flow.factory_camera_toggle_button.sprite == "technology/factory-architecture-t1" then
				button_flow.factory_camera_toggle_button.sprite = "factorissimo2_button"
				button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
			elseif button_flow.factory_camera_toggle_button.sprite == "technology/factory-preview" then
				button_flow.factory_camera_toggle_button.sprite = "factorissimo2_inspect_button"
				button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
			end
		end
	else
		for idx, player in pairs(game.players) do
			if player and player.valid then
				local button_flow = mod_gui.get_button_flow(player)
				local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
				if player.force.technologies["factory-preview"] and player.force.technologies["factory-preview"].researched and button_flow.factory_camera_toggle_button then
					button_flow.factory_camera_toggle_button.style = gu_button_style_setting
					if button_flow.factory_camera_toggle_button.sprite == "technology/factory-architecture-t1" then
						button_flow.factory_camera_toggle_button.sprite = "factorissimo2_button"
						button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
					elseif button_flow.factory_camera_toggle_button.sprite == "technology/factory-preview" then
						button_flow.factory_camera_toggle_button.sprite = "factorissimo2_inspect_button"
						button_flow.factory_camera_toggle_button.tooltip = {'guiu.factorissimo2_button'}
					end
				end
			end
		end
	end
end

local function destroy_obsolete_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)

	-- landfilleverythingu (destroy)
	if button_flow.le_flow and button_flow.le_flow.le_button then
		button_flow.le_flow.le_button.destroy()
		button_flow.le_flow.destroy()
	end

	-- blueprint_flip_and_turn (destroy)
	if game.active_mods["blueprint_flip_and_turn"] then
		if player.gui and player.gui.top and player.gui.top.blpflip_flow then
			local top_flow = player.gui.top.blpflip_flow
			if top_flow.blueprint_flip_horizontal and top_flow.blueprint_flip_vertical then
				top_flow.blueprint_flip_horizontal.destroy()
				top_flow.blueprint_flip_vertical.destroy()
				top_flow.destroy()
			end
		end
	end

	if not player.is_cursor_blueprint() then
		if button_flow.le_button then button_flow.le_button.destroy() end
		if button_flow.blueprint_flip_horizontal then button_flow.blueprint_flip_horizontal.destroy() end
		if button_flow.blueprint_flip_vertical then button_flow.blueprint_flip_vertical.destroy() end
	end

	if game.active_mods["FJEI"] then
		if player.gui.top.fjei_toggle_button then player.gui.top.fjei_toggle_button.destroy() end
	end



	--[[
	-- FNEI

	if not global.fneibuttonevent then global.fneibuttonevent = nil end

	if player.gui and player.gui.left and player.gui.left.fnei_left_flow and player.gui.left.fnei_left_flow["hotbar-main-table"] and player.gui.left.fnei_left_flow["hotbar-main-table"]["fnei_hotbar_frame"] and player.gui.left.fnei_left_flow["hotbar-main-table"]["fnei_hotbar_frame"]["fnei-button"] then
		global.fneibuttonevent = player.gui.left.fnei_left_flow["hotbar-main-table"]["fnei_hotbar_frame"]["fnei-button"].event
		game.print(serpent.block(global.fneibuttonevent))
		player.gui.left.fnei_left_flow["hotbar-main-table"]["fnei_hotbar_frame"]["fnei-button"].destroy()
	end
	if player.gui and player.gui.left and player.gui.left.fnei_left_flow and player.gui.left.fnei_left_flow["fnei_hotbar_flow"] then
		game.print(serpent.block(player.gui.left.fnei_left_flow["fnei_hotbar_flow"]))
	end

	if not button_flow["fnei-button"] then
		button_flow.add {
			type = "sprite-button",
			name = "fnei_hotbar_fnei-button",
			style = "fnei_hotbar_label_button",
			caption = "FNEI",
			event = global.fneibuttonevent,
		}
	end]]--

end

local function on_player_cursor_stack_changed(event)
	local player = game.players[event.player_index]
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)

	destroy_obsolete_buttons(player)

	if player.is_cursor_blueprint() then

		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"

		-- blueprint-request
		local blueprintrequest_button = button_flow["blueprint-request-button"]
		if blueprintrequest_button then
			blueprintrequest_button.style = gu_button_style_setting
			set_button_sprite(blueprintrequest_button, "blueprintrequest_button")
		end

		-- landfilleverythingu
		if game.active_mods["LandfillEverythingU"] or game.active_mods["LandfillEverything"] or game.active_mods["LandfillEverythingButTrains"] then
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

		-- blueprint_flip_and_turn
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

	-- SchallOreConversion
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



local function on_gui_opened(event)
	local player = game.players[event.player_index]
	fix_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)

	-- PickerInventoryTools
	local requests = button_flow["filterfill_requests"]
	if requests then
		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
		if requests.filterfill_requests_btn_bp then requests.filterfill_requests_btn_bp.style = gu_button_style_setting end
		if requests.filterfill_requests_btn_2x then requests.filterfill_requests_btn_2x.style = gu_button_style_setting end
		if requests.filterfill_requests_btn_5x then requests.filterfill_requests_btn_5x.style = gu_button_style_setting end
		if requests.filterfill_requests_btn_10x then requests.filterfill_requests_btn_10x.style = gu_button_style_setting end
		if requests.filterfill_requests_btn_max then requests.filterfill_requests_btn_max.style = gu_button_style_setting end
		if requests.filterfill_requests_btn_0x then requests.filterfill_requests_btn_0x.style = gu_button_style_setting end
	end
	local filters = button_flow["filterfill_filters"]
	if filters then
		local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
		if filters.filterfill_filters_btn_all then filters.filterfill_filters_btn_all.style = gu_button_style_setting end
		if filters.filterfill_filters_btn_down then filters.filterfill_filters_btn_down.style = gu_button_style_setting end
		if filters.filterfill_filters_btn_right then filters.filterfill_filters_btn_right.style = gu_button_style_setting end
		if filters.filterfill_filters_btn_set_all then filters.filterfill_filters_btn_set_all.style = gu_button_style_setting end
		if filters.filterfill_filters_btn_clear_all then filters.filterfill_filters_btn_clear_all.style = gu_button_style_setting end
	end
end

local function on_init()
	for idx, player in pairs(game.players) do
		destroy_obsolete_buttons(player)
		create_new_buttons(player)
		fix_buttons(player)
	end
	update_factorissimo()
	checknexttick = true
end

local function on_configuration_changed()
	for idx, player in pairs(game.players) do
		destroy_obsolete_buttons(player)
		create_new_buttons(player)
		fix_buttons(player)
	end
	update_factorissimo()
	checknexttick = true
end

local function on_research_finished()
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end
	update_factorissimo()
end

local function on_gui_click(event)
	local player = game.players[event.player_index]
	destroy_obsolete_buttons(player)
	fix_buttons(player)
	update_factorissimo(event)

	--debug
	--if event and event.element then player.print(event.element.name) end

end


local function on_player_created(event)
	local player = game.players[event.player_index]
	destroy_obsolete_buttons(player)
	create_new_buttons(player)
	fix_buttons(player)
end

local function on_player_changed_surface(event)
	fix_buttons(game.players[event.player_index])
end

local function on_hivemindchange(event)
	if game.active_mods["Hive_Mind"] or game.active_mods["Hive_Mind_Remastered"] then
		fix_buttons(game.players[event.player_index])
	end
	checknexttick = true
end

local function on_tick()
	if checknexttick then
		for idx, player in pairs(game.players) do
			fix_buttons(player)
		end
		checknexttick = false
	end
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_configuration_changed)
script.on_event(defines.events.on_game_created_from_scenario, on_init)
script.on_event({defines.events.on_player_created, defines.events.on_player_joined_game}, on_player_created)
script.on_event({defines.events.on_player_gun_inventory_changed, defines.events.on_player_died}, on_hivemindchange)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_research_finished, on_research_finished)
script.on_event(defines.events.on_player_display_resolution_changed, on_gui_click)
script.on_event(defines.events.on_player_changed_surface, on_player_changed_surface)


--game.print(serpent.block())
