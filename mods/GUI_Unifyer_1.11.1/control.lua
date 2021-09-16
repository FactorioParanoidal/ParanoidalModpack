local mod_gui = require("mod-gui")
local gui_button_style = "slot_button_notext"
local gui_button_style_whitetext = "slot_button_whitetext"
local checknexttick = true
local activedebug = false

local iconlist = {
	--modname					--sprite 						button									tooltip 					dontreplacesprite	buttonpath (array)	windowtocheck (array)
	{"helmod",					"helmod_button", 				"helmod_planner-command", 				{'guiu.helmod_button'}, 			nil,		nil,				{"screen", "HMProductionPanel"}},
	{"factoryplanner",			"factoryplanner_button", 		"fp_button_toggle_interface", 			{'guiu.factoryplanner_button'}, 	nil,		nil,				nil},
	{"ModuleInserter",			"moduleinserter_button", 		"module_inserter_config_button", 		{'guiu.moduleinserter_button'}, 	nil,		nil,				nil},
	{"Placeables",				"placeables_button", 			"buttonPlaceablesVisible", 				nil,								nil,		nil,				{"screen", "framePlaceablesOuter"}},
	{"Todo-List",				"todolist_button", 				"todo_maximize_button", 				{'guiu.todolist_button'}, 			nil,		nil,				{"screen", "todo_main_frame"}},
	{"creative-mod",			"creativemod_button", 			"creative-mod_main-menu-open-button", 	nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "creative-mod_main-menu-container"}},
	{"BeastFinder",				"beastfinder_button", 			"beastfinder-menu-button", 				{'guiu.beastfinder_button'}, 		nil,		nil,				{"screen", "frame_BeastFinder_main"}},
	{"bobclasses",				"bobclasses_button", 			"bob_avatar_toggle_gui", 				nil,								nil,		nil,				{"left", "bob_avatar_gui"}},
	{nil,						"bobinserters_button", 			"bob_logistics_inserter_button", 		nil,								nil,		nil,				{"left", "bob_logistics_inserter_gui"}},
	{"CleanMap",				"cleanmap_button", 				"CleanMap", 							nil,								nil,		nil,				nil},
	{"DeleteEmptyChunks",		"cleanmap_button", 				"DeleteEmptyChunks", 					nil,								nil,		nil,				nil},
	{"Death_Counter",			"deathcounter_button", 			"DeathCounterMainButton", 				{'guiu.deathcounter_button'}, 		nil,		nil,				{"left", "DeathCounterMain"}},
	{"ingteb",					"ingteb_button", 				"ingteb", 								nil,								nil,		nil,				{"screen", "Selector"}},
	{"OutpostPlanner",			"outpostplanner_button", 		"OutpostBuilder", 						nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "OutpostBuilderWindow"}},
	{"rocket-silo-stats",		"rocketsilostats_button", 		"rocket-silo-stats-toggle", 			{'guiu.rocketsilostats_button'}, 	nil,		nil,				{"left", "mod_gui_frame_flow", "rocket-silo-stats"}},
	{"SchallSatelliteController","schall_sc_button", 			"Schall-SC-mod-button", 				nil,								nil,		nil,				{"screen", "Schall-SC-frame-main"}},
	{"actual-craft-times-remade","actr_button", 				"ACTR_mod_button", 						nil,								nil,		nil,				{"left", "ACTR_Calculator_Frame"}},
	{"BetterBotsFixed",			"betterbotsfixed_button", 		"betterbots_top_btn", 					{'guiu.betterbotsfixed_button'}, 	nil,		nil,				{"left", "mod_gui_frame_flow", "betterbots_left"}},
	{"ChangeMapSettings",		"changemapsettings_button", 	"change-map-settings-toggle-config", 	{'guiu.changemapsettings_button'}, 	nil,		nil,				{"screen", "change-map-settings-main-flow"}},
	{"DoingThingsByHand",		"doingthingsbyhand_button", 	"DoingThingsByHandMainButton", 			{'guiu.doingthingsbyhand_button'},	nil,		nil,				{"left", "DoingThingsByHandMain"}},
	{"FacAutoScreenshot",		"facautoscreenshot_button", 	"togglegui", 							{'guiu.facautoscreenshot_button'}, 	nil,		nil,				{"screen", "guiFrame", "content_frame", "auto_frame"}},
	{"KillLostBots",			"killlostbots_button", 			"KillLostBots", 						nil,								nil,		nil,				nil},
	{"kraskaska-total-raw-resources-calc","kttrrc_button", 		"ttrrc_main_frame_button", 				{'guiu.kttrrc_button'}, 			nil,		nil,				{"left", "mod_gui_frame_flow", "ttrrc_main_frame"}},
	{"Kux-CraftingTools",		"kuxcraftingtools_button", 		"CraftNearbyGhostItemsButton", 			nil,								nil,		nil,				nil},
	{"Kux-OrbitalIonCannon",	"kuxorbitalioncannon_button", 	"ion-cannon-button", 					{'guiu.kuxorbitalioncannon_button'},nil,		nil,				{"left", "ion-cannon-stats"}},
	{"LandfillEverything",		"markers_button", 				"markers_gui_toggle", 					{'guiu.markers_button'}, 			nil,		nil,				{"left", "mod_gui_frame_flow", "markers_gui"}},
	{"Not_Enough_Todo",			"notenoughtodo_button", 		"TODO_CLICK01_", 						{'guiu.notenoughtodo_button'}, 		nil,		nil,				nil},
	{"osha_hot_swap",			"oshahotswap_button", 			"hotswap-menu-button", 					{'guiu.oshahotswap_button'}, 		nil,		nil,				{"left", "hotswap-main-container"}},
	{"PickerInventoryTools",	"pickerinventorytools_button", 	"filterfill_requests", 					nil,								nil,		nil,				nil},
	{"Powered_Entities",		"poweredentities_button", 		"poweredEntitiesRecalculateButton", 	{'guiu.poweredentities_button'}, 	nil,		nil,				nil},
	{"research-counter",		"researchcounter_button", 		"research-counter-button", 				{'guiu.researchcounter_button'}, 	nil,		nil,				{"screen", "research-counter-base"}},
	{"Rich_Text_Helper",		"richtexthelper_button", 		"RICH_CLICK_20_player01", 				{'guiu.richtexthelper_button'}, 	nil,		nil,				nil},
	{"RitnTeleportation",		"ritnteleportation_button", 	"ritn-button-main", 					{'guiu.ritnteleportation_button'},	nil,		nil,				{"left", "mod_gui_frame_flow", "menu-flow-common", "main_menu-frame-menu"}},
	{"solar-calc",				"solarcalc_button", 			"kaktusbot-sc-open-calc-button", 		{'guiu.solarcalc_button'}, 			nil,		nil,				{"screen", "kaktusbot-sc-main-gui"}},
	{"SolarRatio",				"solarcalc_button", 			"niet-sr-guibutton", 					nil,								nil,		nil,				{"center", "niet-sr-guiframe"}},
	{"SpaceMod",				"spacemod_button", 				"space_toggle_button", 					{'guiu.spacemod_button'}, 			nil,		nil,				{"left", "mod_gui_frame_flow", "space_progress_frame"}},
	{"train-log",				"trainlog_button", 				"train_log", 							nil,								nil,		nil,				nil},
	{"train-pubsub",			"trainpubsub_button", 			"tm_sprite_button", 					nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "tm_button_frame"}},
	{"upgrade-planner-next",	"upgradeplannernext_button", 	"upgrade_planner_config_button", 		nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "upgrade_planner_config_frame"}},
	{"whats-missing",			"whatsmissing_button", 			"whats-missing-button", 				nil,								nil,		nil,				{"screen", "whats-missing-gui"}},
	{"PicksRocketStats",		"picksrocketstats_button", 		"pi_rss_but_toggle", 					{'guiu.picksrocketstats_button'}, 	nil,		nil,				{"left", "mod_gui_frame_flow", "pi_rss_rocket-silo-stats"}},
	{"SchallRailwayController",	"schall_rc_button", 			"Schall-RC-mod-button", 				{'guiu.schall_rc_button'}, 			nil,		nil,				{"screen", "Schall-RC-frame-main"}},
	{"BlackMarket2",			"blackmarket1_button", 			"but_blkmkt_main", 						{'guiu.blackmarket1_button'},		nil,		{"flw_blkmkt"},		{"left", "mod_gui_frame_flow", "frm_blkmkt_gen"}},
	{"BlackMarket2",			"blackmarket2_button", 			"but_blkmkt_credits", 					nil,								nil,		{"flw_blkmkt"},		{"left", "mod_gui_frame_flow", "frm_blkmkt_itml"}},
	{"AutoTrash",				"autotrash_button",				"at_config_button",						nil,								1,			nil,				nil},
	{"TogglePeacefulMode",		"togglepeacefulmode_button",	"tpm-button",							{'guiu.togglepeacefulmode_button'},	1,			nil,				nil},
	{"what-is-it-really-used-for","wiiuf_button",				"looking-glass",						{'guiu.wiiuf_button'}, 				nil, {"wiiuf_flow", "search_flow"},{"screen", "wiiuf_center_frame"}},
	{"TheFatController",		"thefatcontroller_button",		"toggleTrainInfo",						{'guiu.thefatcontroller_button'}, 	nil, {"fatControllerButtons"},	{"left", "fatController", "trainInfo"}},
	{"quickbarimportexport",	"quickbarimportexport_button", 	"qbie_button_show_options", 			nil,								nil, {"qbie_flow_choose_action"},{"left", "mod_gui_frame_flow", "qbie_frame_main_window"}},
	{"quickbarimportexport",	"quickbarimport_button", 		"qbie_button_import", 					nil,								nil, {"qbie_flow_choose_action"},nil},
	{"quickbarimportexport",	"quickbarexport_button", 		"qbie_button_export", 					nil,								nil, {"qbie_flow_choose_action"},nil},
	{"informatron",				"informatron_button", 			"informatron_overhead",					nil,								1,			nil,				{"screen", "informatron_main"}},
	{"space-exploration",		"se_interstellar_button", 		"se-overhead_interstellar",				nil,								1,			nil,				{"left", "se-remote-view", "system_toggles_table", "map_view_toggles", "show_danger_zones"}},
	{"space-exploration",		"se_satellite_button", 			"se-overhead_satellite",				nil,								1,			nil,				{"left", "se-remote-view"}},
	{"space-exploration",		"se_explorer_button", 			"se-overhead_explorer",					nil,								1,			nil,				{"screen", "se-zonelist_main"}},
	{"CommuGuideMod",			"commuguidemod_guide_button", 	"main_menu_guide_button",				{'guiu.commuguidemod_guide_button'},nil,		nil,				nil},
	{"CommuGuideMod",			"commuguidemod_pupil_button", 	"main_menu_player_button",				{'guiu.commuguidemod_pupil_button'},nil,		nil,				nil},
	{"FJEI",					"fjei_toggle_button", 			"fjei_toggle_button",					nil,								1,			nil,				{"left", "fjei_main_window","fjei_main_window_control_table"}}, -- {"", ""}
	{"ToggleSpeedBoost",		"togglespeedboost_button", 		"togglespeedboost_button",				nil,								1,			nil,				nil},
	{"248k",					"248k_button", 					"top248kbutton",						{'guiu.248k_button'},				nil,		nil,				{"left", "main248kframe"}},
	{"BlueprintAlignment",		"blueprintalignment_button", 	"BlueprintAlignment_Button",			nil,								nil,		nil,				nil},
	{"CargoTrainManager",		"cargotrainmanager_button", 	"ctm_toolbutton",						nil,								nil,		nil,				{"screen", "ctm_main_dialog"}},
	{"clusterio",				"clusterio_button", 			"clusterio-main-config-gui-toggle-button",{'guiu.clusterio_button'},		nil,		nil,				{"top", "clusterio-main-config-gui"}},
	{"Cursed-Exp",				"cursedexp_button", 			"openMain",								{'guiu.cursedexp_button'},			nil,		{"openMainFlow"},	{"left", "flowMainOut", "frameMain"}},
	{"default-wait-conditions",	"defaultwaitconditions_button",	"default-wait-conditions-main-button",	nil,								nil,		nil,				{"screen", "default-wait-conditions-main-frame"}},
	{"diplomacy",				"diplomacy_button", 			"diplomacy_button",						nil,								nil,		nil,				{"screen", "diplomacy_frame"}},
	{"Electronic_Locomotives",	"electronic_locomotives_button","ELECTRONIC_CLICK01",					{'guiu.electronic_locomotives_button'},nil,		nil,				{"screen", "ELECTRONIC_LOCATION"}},
	{"forces",					"forces_button", 				"forcesMenu",							nil,								nil,		nil,				{"center", "inviteDialogue"}},
	{nil,						"hive_mind_button1", 			"join-hive-button",						nil,								nil,		nil,				nil},
	{nil,						"hive_mind_button2", 			"leave-hive-button",					nil,								nil,		nil,				nil},
	{"howfardiditgo",			"howfardiditgo_button", 		"train_distance_button",				{'guiu.howfardiditgo_button'},		nil,		nil,				{"top", "mod_gui_top_frame", "mod_gui_inner_frame", "train_filtertextbox"}},
	{"Kux-BlueprintEditor",		"kuxblueprinteditor_button", 	"mod-blueprint-editor-toolbar-button",	nil,								nil,		nil,				{"screen", "blueprint-editor-modal"}},
	{"Kux-HandcraftGhosts",		"kuxcraftingtools_button", 		"PlayerGhostCraft",						nil,								nil,		nil,				nil},
	{"Logistic-Machines",		"logisticmachines_button", 		"lm_default_circuit_button",			{'guiu.logisticmachines_button'},	nil,		nil,				{"left", "mod_gui_frame_flow", "ld_default_circuit_window"}},
	{"LogisticRequestManager",	"logisticrequestmanager_button","logistic-request-manager-gui-button",	{'guiu.logisticrequestmanager_button'},nil,		nil,				{"screen", "logistic-request-manager-gui-master"}},
	{"region-cloner",			"regioncloner_button", 			"region-cloner_main-button",			nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "region-cloner_control-window"}},
	{"ResetEvolutionPollution",	"resetevolpol_button",			"ResetEvolutionPollution",				nil,								nil,		nil,				nil},
	{"Shuttle_Train_Continued",	"shuttle_train_button",			"shuttle_lite_button",					nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "shuttle_lite_frame"}},
	{"Simple_Circuit_Trains",	"simple_circuit_trains_button",	"SIMPLE_CLICK_01",						{'guiu.simple_circuit_trains_button'},nil,		nil,				{"screen", "SIMPLE_LOCATION"}},
	{"TeamCoop",				"teamcoop_button1", 			"spwn_ctrls",							{'guiu.teamcoop_button1'},			nil,		nil,				{"left", "spwn_ctrl_panel"}},
	{"TeamCoop",				"teamcoop_button2", 			"spwn_admin_ctrls",						{'guiu.teamcoop_button2'},			nil,		nil,				{"left", "spwn_admin_ctrl_panel"}},
	{"smartchest",				"smartchest_button", 			"sc_button",							nil,								nil,		nil,				{"left", "sc_filter_panel"}},
	{"homeworld_redux",			"homeworld_redux_button", 		"Homeworld_btn",						{'guiu.homeworld_redux_button'},	nil,		nil,				{"left", "homeworld"}},
	{"m-lawful-evil",			"mlawfulevil_button", 			"lawful_evil_button",					{'guiu.mlawfulevil_button'},		nil,		nil,				{"center", "lawful_evil_gui"}},
	{"Trashcan",				"trashcan_button", 				"trashbinguibutton",					{'guiu.trashcan_button'},			nil,		nil,				nil},
	{"pycoalprocessing",		"pycoalprocessing_button", 		"pywiki",								{'guiu.pycoalprocessing_button'},	nil,		nil,				{"screen", "wiki_frame"}},
	{"usage-detector",			"usagedetector_button", 		"usage_detector",						{'guiu.usagedetector_button'},		nil,		nil,				{"center", "usage_detector_center"}},
	{"RPG",						"rpg_button", 					"104",									{'guiu.rpg_button'},				nil,		nil,				{"screen", "105"}},
	{nil,						"spawncontrol_button", 			"spawn",								{'guiu.spawncontrol_button'},		nil,		nil,				nil},
	{"TimedSpawnControl",		"spawncontrol_random_button", 	"random",								{'guiu.spawncontrol_random_button'},nil,		nil,				nil},
	{"what-is-missing",			"whatsmissing_button", 			"what_is_missing",						{'guiu.whatismissing_button'},		nil,		nil,				{"left", "what_is_missing"}},
	{"advanced-logistics-system-fork","logisticssystemfork_button","logistics-view-button",				{'guiu.logisticssystemfork_button'},nil,		nil,				{"center", "logisticsFrame"}},
	{"some-zoom",				"somezoom_out_button", 			"but_zoom_zout",						{'guiu.somezoom_out_button'},		nil,		nil,				nil},
	{"some-zoom",				"somezoom_in_button", 			"but_zoom_zin",							{'guiu.somezoom_in_button'},		nil,		nil,				nil},
	{"production-monitor",		"productionmonitor_button", 	"stats_show_settings",					{'guiu.productionmonitor_button'},	nil,		nil,				{"center", "stats_center"}},
	{"Teleportation_Redux",		"teleportation_button", 		"teleportation_main_button",			{'guiu.teleportation_button'},		nil,		nil,				{"left", "teleportation_main_window"}},
	{"PersonalTeleporter",		"teleportation_button", 		"personalTeleporter_PersonalTeleportTool",{'guiu.teleportation_button'},	nil,		nil,				{"left", "personlaTeleportWindow"}},
	{"SchallEndgameEvolution",	"schallendgameevolution_button","Schall-EE-mod-button",					nil,								1,			nil,				{"screen", "Schall-EE-frame-main"}},
	{"NewGamePlus",				"newgameplus_button",			"new-game-plus-toggle-config",			nil,								nil,		nil,				{"left", "mod_gui_frame_flow", "new-game-plus-config-frame"}},
	{"Nullius",					"nullius_button",				"nullius_mission_button",				nil,								nil,		nil,				{"left", "nullius_mission_panel"}},

	--{"trainschedulesignals_button", "TSS=open-close",						nil,								nil,		nil}, 		??
	--{"attachnotes_button", 			"attach-note-button",					nil,								1,			nil} 	-- too complex
	--{"avatars_button", ""},																												??
	--{"modmashsplinterboom_button", "landmine-toggle-button"},																				??
	--{"modmashsplinternewworlds_button", "planets-toggle-button"},																			??
	--{"dana_button", 				"dana-shortcut",				nil, nil,		nil}, 												-- can't button name!
	--{"deleteadjacentchunk_button", ""},																								-- too complex
	--timeline							timeline				hard
	--controllinator				["controllinator-toggle"]			button created from
	--automatic-belt-direction			abdgui						toggle button comment changer images?
	--RPGsystem						205992
	--Bluegistics
}

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

local function change_one_icon(player, sprite, button, tooltip, dontreplacesprite, buttonpath, windowtocheck)
	if not player or not player.valid or not sprite or not button then return end
	local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
	if windowtocheck then
		local windowtocheckpath = player.gui
		local isselected = true
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

local function fix_buttons(player)
	if not player or not player.valid then return end
	local button_flow = mod_gui.get_button_flow(player)
	--local blackmarketvalue = button_flow.flw_blkmkt and button_flow.flw_blkmkt.but_blkmkt_credits and button_flow.flw_blkmkt.but_blkmkt_credits.caption or ""
	--"Credit: ".. blackmarketvalue,
	for _, k in pairs(iconlist) do
		change_one_icon(player, k[2], k[3], k[4], k[5], k[6], k[7])
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
	local button_flow = mod_gui.get_button_flow(player)
	local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"

	if game.active_mods["FJEI"] then
		if not button_flow.fjei_toggle_button then
			button_flow.add {
				type = "sprite-button",
				name = "fjei_toggle_button",
				sprite = "fjei_button",
				style = gu_button_style_setting,
				tooltip = {'guiu.fjei_button'},
			}
		end
	elseif button_flow["fjei_toggle_button"] then
		button_flow["fjei_toggle_button"].destroy()
	end

	if game.active_mods["homeworld_redux"] then
		if not button_flow.Homeworld_btn then
			button_flow.add {
				type = "sprite-button",
				name = "Homeworld_btn",
				style = gu_button_style_setting,
				sprite = "homeworld_redux_button",
			}
		end
	elseif button_flow["Homeworld_btn"] then
		button_flow["Homeworld_btn"].destroy()
	end

	if game.active_mods["m-lawful-evil"] then
		if not button_flow.lawful_evil_button then
			button_flow.add {
				type = "sprite-button",
				name = "lawful_evil_button",
				style = gu_button_style_setting,
				sprite = "mlawfulevil_button",
			}
		end
	elseif button_flow["lawful_evil_button"] then
		button_flow["lawful_evil_button"].destroy()
	end

	if game.active_mods["Trashcan"] then
		if not button_flow.trashbinguibutton then
			button_flow.add {
				type = "sprite-button",
				name = "trashbinguibutton",
				style = gu_button_style_setting,
				sprite = "trashcan_button",
			}
		end
	elseif button_flow["trashbinguibutton"] then
		button_flow["trashbinguibutton"].destroy()
	end

	if game.active_mods["pycoalprocessing"] then
		if not button_flow.pywiki then
			button_flow.add {
				type = "sprite-button",
				name = "pywiki",
				style = gu_button_style_setting,
				sprite = "pycoalprocessing_button",
			}
		end
	elseif button_flow["pywiki"] then
		button_flow["pywiki"].destroy()
	end

	if game.active_mods["usage-detector"] then
		if not button_flow.usage_detector then
			button_flow.add {
				type = "sprite-button",
				name = "usage_detector",
				style = gu_button_style_setting,
				sprite = "usagedetector_button",
			}
		end
	elseif button_flow["usage_detector"] then
		button_flow["usage_detector"].destroy()
	end

	if game.active_mods["RPG"] then
		if not button_flow["104"] then
			button_flow.add {
				type = "sprite-button",
				name = "104",
				style = gu_button_style_setting,
				sprite = "rpg_button",
			}
		end
	elseif button_flow["104"] then
		button_flow["104"].destroy()
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

	if game.active_mods["TimedSpawnControl"] then
		if not button_flow.random then
			button_flow.add {
				type = "sprite-button",
				name = "random",
				style = gu_button_style_setting,
				sprite = "spawncontrol_random_button",
			}
		end
	elseif button_flow["random"] then
		button_flow["random"].destroy()
	end

	if game.active_mods["what-is-missing"] then
		if not button_flow.what_is_missing then
			button_flow.add {
				type = "sprite-button",
				name = "what_is_missing",
				style = gu_button_style_setting,
				sprite = "whatsmissing_button",
			}
		end
	elseif button_flow["what_is_missing"] then
		button_flow["what_is_missing"].destroy()
	end


	if game.active_mods["advanced-logistics-system-fork"] then
		if player.force and player.force.technologies["advanced-logistics-systems"] and player.force.technologies["advanced-logistics-systems"].researched then
			if not button_flow["logistics-view-button"] then
				button_flow.add {
					type = "sprite-button",
					name = "logistics-view-button",
					style = gu_button_style_setting,
					sprite = "logisticssystemfork_button",
					tooltip = {'guiu.logisticssystemfork_button'},
				}
			end
		end
	elseif button_flow["logistics-view-button"] then
		button_flow["logistics-view-button"].destroy()
	end

	--[[if game.active_mods["timeline"] then
		if not button_flow["timeline"] then
			button_flow.add {
				type = "sprite-button",
				name = "timeline",
				style = gu_button_style_setting,
				sprite = "timeline_button",
			}
		end
	end]]

	if game.active_mods["some-zoom"] then
		if not button_flow.but_zoom_zout then
			button_flow.add {
				type = "sprite-button",
				name = "but_zoom_zout",
				style = gu_button_style_setting,
				sprite = "somezoom_out_button",
				tooltip = {'guiu.somezoom_out_button'},
			}
		end
		if not button_flow.but_zoom_zin then
			button_flow.add {
				type = "sprite-button",
				name = "but_zoom_zin",
				style = gu_button_style_setting,
				sprite = "somezoom_in_button",
				tooltip = {'guiu.somezoom_in_button'},
			}
		end
	else
		if button_flow["but_zoom_zout"] then
			button_flow["but_zoom_zout"].destroy()
		end
		if button_flow["but_zoom_zin"] then
			button_flow["but_zoom_zin"].destroy()
		end
	end

	if game.active_mods["production-monitor"] then
		if not button_flow.stats_show_settings then
			button_flow.add {
				type = "sprite-button",
				name = "stats_show_settings",
				style = gu_button_style_setting,
				sprite = "productionmonitor_button",
				tooltip = {'guiu.productionmonitor_button'},
			}
		end
	elseif button_flow["stats_show_settings"] then
		button_flow["stats_show_settings"].destroy()
	end

	if game.active_mods["Teleportation_Redux"] then
		if global.Teleportation_Redux_built then
			if not button_flow.teleportation_main_button then
				button_flow.add {
					type = "sprite-button",
					name = "teleportation_main_button",
					style = gu_button_style_setting,
					sprite = "teleportation_button",
					tooltip = {'guiu.teleportation_button'},
				}
			end
		end
	elseif button_flow["teleportation_main_button"] then
		button_flow["teleportation_main_button"].destroy()
	end

	if game.active_mods["PersonalTeleporter"] then
		if global.PersonalTeleporter_built then
			if not button_flow.personalTeleporter_PersonalTeleportTool then
				button_flow.add {
					type = "sprite-button",
					name = "personalTeleporter_PersonalTeleportTool",
					style = gu_button_style_setting,
					sprite = "teleportation_button",
					tooltip = {'guiu.teleportation_button'},
				}
			end
		end
	elseif button_flow["personalTeleporter_PersonalTeleportTool"] then
		button_flow["personalTeleporter_PersonalTeleportTool"].destroy()
	end

	if game.active_mods["inserter-throughput"] then
		if not button_flow["inserter-throughput-toggle"] then
			button_flow.add {
				type = "sprite-button",
				name = "inserter-throughput-toggle",
				style = gu_button_style_setting,
				sprite = "inserterthroughput_off_button",
				tooltip = {'guiu.inserterthroughput_off_button'},
			}
		end
		if button_flow["inserter-throughput-toggle"] and settings.get_player_settings(player)["inserter-throughput-enabled"] then
			if settings.get_player_settings(player)["inserter-throughput-enabled"].value == true then
				button_flow["inserter-throughput-toggle"].sprite = "inserterthroughput_on_button"
				button_flow["inserter-throughput-toggle"].tooltip = {'guiu.inserterthroughput_on_button'}
			else
				button_flow["inserter-throughput-toggle"].sprite = "inserterthroughput_off_button"
				button_flow["inserter-throughput-toggle"].tooltip = {'guiu.inserterthroughput_off_button'}
			end
		end
	elseif button_flow["inserter-throughput-toggle"] then
		button_flow["inserter-throughput-toggle"].destroy()
	end

	if game.active_mods["YARM"] then
		if not button_flow["YARM_filter_none"] then --current mode all
			button_flow.add {
				type = "sprite-button",
				name = "YARM_filter_none",
				style = gu_button_style_setting,
				sprite = "yarm_all_button",
				tooltip = {'guiu.yarm_all_button'},
				visible = false,
			}
		end
		if not button_flow["YARM_filter_warnings"] then --current mode none
			button_flow.add {
				type = "sprite-button",
				name = "YARM_filter_warnings",
				style = gu_button_style_setting,
				sprite = "yarm_none_button",
				tooltip = {'guiu.yarm_none_button'},
				visible = false,
			}
		end
		if not button_flow["YARM_filter_all"] then --current mode warnings
			button_flow.add {
				type = "sprite-button",
				name = "YARM_filter_all",
				style = gu_button_style_setting,
				sprite = "yarm_warnings_button",
				tooltip = {'guiu.yarm_warnings_button'},
				visible = true,
			}
		end
	else
		if button_flow["YARM_filter_none"] then
			button_flow["YARM_filter_none"].destroy()
		end
		if button_flow["YARM_filter_warnings"] then
			button_flow["YARM_filter_warnings"].destroy()
		end
		if button_flow["YARM_filter_all"] then
			button_flow["YARM_filter_all"].destroy()
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

local function update_yarm_button(event)
	if event and event.element then
		if event.element.name == "YARM_filter_all" or event.element.name == "YARM_filter_none" or event.element.name == "YARM_filter_warnings" then
			local player = game.players[event.player_index]
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
	if not player or not player.valid or not player.gui or not player.gui.top then return end
	local button_flow = mod_gui.get_button_flow(player)
	local top = player.gui.top

	-- landfilleverything
	if button_flow.le_flow then
		button_flow.le_flow.destroy()
	end

	if not player.is_cursor_blueprint() then
		if button_flow.le_button then button_flow.le_button.destroy() end
		if button_flow.blueprint_flip_horizontal then button_flow.blueprint_flip_horizontal.destroy() end
		if button_flow.blueprint_flip_vertical then button_flow.blueprint_flip_vertical.destroy() end
	end

	-- blueprint_flip_and_turn
	if top.blpflip_flow then
		top.blpflip_flow.destroy()
	end

	if top.fjei_toggle_button then
		top.fjei_toggle_button.destroy()
	end

	if top.Homeworld_btn then
		top.Homeworld_btn.destroy()
	end

	if top.lawful_evil_button then
		top.lawful_evil_button.destroy()
	end

	if top.trashbingui then
		top.trashbingui.destroy()
	end

	if top.pywiki_frame then
		top.pywiki_frame.destroy()
	end

	if top.usage_detector then
		top.usage_detector.destroy()
	end

	if top["104"] then
		top["104"].destroy()
	end

	if top.spawn then
		top.spawn.destroy()
	end

	if top.random then
		top.random.destroy()
	end

	if top.what_is_missing then
		top.what_is_missing.destroy()
	end

	if top["logistics-view-button"] then
		top["logistics-view-button"].destroy()
	end

	--if top.timeline then
	--	top.timeline.destroy()
	--end

	if top.flw_zoom then
		top.flw_zoom.destroy()
	end

	if top.stats_show_settings then
		top.stats_show_settings.destroy()
	end

	--Teleportation_Redux checks that top.teleportation_main_button exists, so we replace with invisible frame.
	if top.teleportation_main_button and top.teleportation_main_button.type == "button" then
		top.teleportation_main_button.destroy()
		top.add {
			type = "frame",
			name = "teleportation_main_button",
			style = "invisible_frame",
		}
	end

	if top.personalTeleporter_PersonalTeleportTool then
		top.personalTeleporter_PersonalTeleportTool.destroy()
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

	if top["inserter-throughput-toggle"] and top["inserter-throughput-toggle"].visible == true then
		top["inserter-throughput-toggle"].visible = false
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
end

local function update_frame_style(player)
	local gu_frame_style_setting = settings.get_player_settings(player)["gu_frame_style_setting"].value or "normal_frame_style"
	if player.gui and player.gui.top and player.gui.top.mod_gui_top_frame and player.gui.top.mod_gui_top_frame.mod_gui_inner_frame then
		if gu_frame_style_setting == "snouz_normal_frame_style" then
			player.gui.top.mod_gui_top_frame.style = "quick_bar_window_frame"
			player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "mod_gui_inside_deep_frame"
			--player.gui.top.mod_gui_top_frame.visible = true
		elseif gu_frame_style_setting == "snouz_barebone_frame_style" then
			player.gui.top.mod_gui_top_frame.style = "snouz_invisible_frame"
			player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "snouz_barebone_frame"
			--player.gui.top.mod_gui_top_frame.visible = true
		elseif gu_frame_style_setting == "snouz_large_barebone_frame_style" then
			player.gui.top.mod_gui_top_frame.style = "snouz_invisible_frame"
			player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "snouz_large_barebone_frame"
			--player.gui.top.mod_gui_top_frame.visible = true
		elseif gu_frame_style_setting == "snouz_invisible_frame_style" then
			player.gui.top.mod_gui_top_frame.style = "snouz_invisible_frame"
			player.gui.top.mod_gui_top_frame.mod_gui_inner_frame.style = "snouz_invisible_frame"
		end
	end


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
		--create_new_buttons(player)
		fix_buttons(player)
	end
	if game.active_mods["Factorissimo2"] then update_factorissimo() end
	checknexttick = true
end

local function on_configuration_changed()
	for idx, player in pairs(game.players) do
		destroy_obsolete_buttons(player)
		--create_new_buttons(player)
		fix_buttons(player)
		update_frame_style(player)
	end
	if game.active_mods["Factorissimo2"] then update_factorissimo() end
	checknexttick = true
end

local function on_research_finished(event)
	for idx, player in pairs(game.players) do
		fix_buttons(player)
	end

	-- advanced-logistics-system-fork
	if event.research.name == "advanced-logistics-systems" then
        for idx, player in pairs(game.players) do
        	destroy_obsolete_buttons(player)
			create_new_buttons(player)
		end
    end

	if game.active_mods["Factorissimo2"] then update_factorissimo() end
end

local function on_rocket_launched()
	for idx, player in pairs(game.players) do
		destroy_obsolete_buttons(player)
		--create_new_buttons(player)
		fix_buttons(player)
		update_frame_style(player)
	end
	checknexttick = true
end

local function debug_button(event)
	--debug
	if event and event.element then
		local player = game.players[event.player_index]
		--player.print(game.active_mods["usage-detector"])
		for name, version in pairs(game.active_mods) do
		  player.print(name .. " version " .. version)
		end
		player.print(event.element.name)
		if event.element.parent then
			player.print("parent1: " .. event.element.parent.name)
			if event.element.parent.parent then
				player.print("parent2: " .. event.element.parent.parent.name)
				if event.element.parent.parent.parent then
					player.print("parent3: " .. event.element.parent.parent.parent.name)
					if event.element.parent.parent.parent.parent then
						player.print("parent4: " .. event.element.parent.parent.parent.parent.name)
						if event.element.parent.parent.parent.parent.parent then
							player.print("parent5: " .. event.element.parent.parent.parent.parent.parent.name)
							if event.element.parent.parent.parent.parent.parent.parent then
								player.print("parent6: " .. event.element.parent.parent.parent.parent.parent.parent.name)
								if event.element.parent.parent.parent.parent.parent.parent.parent then
									player.print("parent7: " .. event.element.parent.parent.parent.parent.parent.parent.parent.name)
								end
							end
						end
					end
				end
			end
		end
	end

end

local function on_gui_click(event)
	--local player = game.players[event.player_index]
	--destroy_obsolete_buttons(player)
	--fix_buttons(player)
	if game.active_mods["Factorissimo2"] then update_factorissimo(event) end
	if game.active_mods["YARM"] then update_yarm_button(event) end

	checknexttick = true

	if activedebug then debug_button(event) end
end

local function on_gui_closed(event)
	checknexttick = true
end

local function on_player_created(event)
	local player = game.players[event.player_index]
	destroy_obsolete_buttons(player)
	--create_new_buttons(player)
	fix_buttons(player)
	checknexttick = true
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

local function on_built(event)
	if game.active_mods["Teleportation_Redux"] then
		if not global.Teleportation_Redux_built then
			if event and event.created_entity and event.created_entity.name == "teleportation-beacon" then
				for idx, player in pairs(game.players) do
					local button_flow = mod_gui.get_button_flow(player)
					local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
					if not button_flow.teleportation_main_button then
						button_flow.add {
							type = "sprite-button",
							name = "teleportation_main_button",
							style = gu_button_style_setting,
							sprite = "teleportation_redux_button",
							tooltip = {'guiu.teleportation_redux_button'},
						}
					end
				end
				checknexttick = true
				global.Teleportation_Redux_built = true
			end
		end
	end

	if game.active_mods["PersonalTeleporter"] then
		if not global.PersonalTeleporter_built then
			if event and event.created_entity and event.created_entity.name == "Teleporter_Beacon" then
				for idx, player in pairs(game.players) do
					local button_flow = mod_gui.get_button_flow(player)
					local gu_button_style_setting = settings.get_player_settings(player)["gu_button_style_setting"].value or "slot_button_notext"
					if not button_flow.personalTeleporter_PersonalTeleportTool then
						button_flow.add {
							type = "sprite-button",
							name = "personalTeleporter_PersonalTeleportTool",
							style = gu_button_style_setting,
							sprite = "teleportation_redux_button",
							tooltip = {'guiu.teleportation_redux_button'},
						}
					end
				end
				checknexttick = true
				global.PersonalTeleporter_built = true
			end
		end
	end
end

local function on_second_tick()
	if checknexttick then
		-- happens on the tick after a function makes checknexttick = true, to be sure to pass after
		for idx, player in pairs(game.players) do
			create_new_buttons(player)
			fix_buttons(player)
			destroy_obsolete_buttons(player)
		end
		checknexttick = false
	end
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_tick, on_second_tick)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_configuration_changed)
script.on_event(defines.events.on_game_created_from_scenario, on_init)
script.on_event({defines.events.on_player_created, defines.events.on_player_joined_game}, on_player_created)
script.on_event({defines.events.on_player_gun_inventory_changed, defines.events.on_player_died}, on_hivemindchange)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event({defines.events.on_gui_closed, defines.events.on_gui_confirmed}, on_gui_closed)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_research_finished, on_research_finished)
script.on_event(defines.events.on_rocket_launched, on_rocket_launched)
script.on_event(defines.events.on_player_display_resolution_changed, on_gui_click)
script.on_event(defines.events.on_player_changed_surface, on_player_changed_surface)
script.on_event({defines.events.on_built_entity, defines.events.on_entity_cloned, defines.events.on_robot_built_entity}, on_built)


--game.print(serpent.block())
